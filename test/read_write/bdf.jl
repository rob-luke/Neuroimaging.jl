fname = joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf")
fname_out = joinpath(dirname(@__FILE__), "..", "data", "tmp", "testwrite.bdf")

dats, evtTab, trigs, statusChan = readBDF(fname);
sampRate = readBDFHeader(fname)["sampRate"][1]

@test trigs == create_channel(evtTab, dats, sampRate, code="code", index="idx", duration="dur")

@test trigs !== trigger_channel(read_SSR(fname))

@test trigs == trigger_channel(read_SSR(fname, valid_triggers = collect(-1000:10000)))

s  = read_SSR(fname)
s.header["subjID"] = "test"
write_SSR(s, fname_out)
s  = read_SSR(fname, valid_triggers = collect(-1000:10000))
s.header["subjID"] = "test"
write_SSR(s, fname_out)
s2 = read_SSR(fname_out, valid_triggers = collect(-1000:10000))

show(s)
show(s2)

@test s.data == s2.data
@test s.triggers == s2.triggers
@test s.samplingrate == s2.samplingrate
@test contains(s2.header["subjID"], "test")


#
# Convert between events and channels
#

fname = joinpath(dirname(@__FILE__), "..", "data", "test_Hz19.5-testing.bdf")
dats, evtTab, trigs, statusChan = readBDF(fname);

events  = create_events(trigs, sampRate)
channel = create_channel(events, dats, sampRate)

@test channel == trigs


#
# Change channel names
#

s.channel_names[1] = "A01"
s.channel_names[2] = "A05"
s.channel_names[3] = "A11"
s.channel_names[4] = "B03"
s.channel_names[5] = "A17"
s.channel_names[6] = "B17"

write_SSR(s, fname_out)

s2 = read_SSR(fname_out)

@test s2.channel_names == ["Fp1", "F3", "FC1", "AF8", "CP5", "C2"]
