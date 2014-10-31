using EEG
using Logging
Logging.configure(level=INFO)


#######################################
#
# Test channel rejection
#
#######################################

# Input
fname = joinpath(dirname(@__FILE__), "../data", "test_Hz19.5-testing.bdf")

a = read_SSR(fname)
a = extract_epochs(a)

Logging.configure(level=DEBUG)

a = phase_lag_index(a, analysis_electrodes, ID="Test", freq_of_interest=[20:25])
a = phase_lag_index(a, analysis_electrodes, ID="Test")
a = save_synchrony_results(a)

Logging.configure(level=INFO)


#
# Example plotting
#

#=using DataFrames=#
#=using Gadfly=#

#=df = readtable("test_Hz19.5-testing-synchrony.csv")=#

#=plot(df, x="ChannelOrigin", y="ChannelDestination", color="Strength", Geom.rectbin,=#
    #=Scale.x_discrete(levels=["Cz", "_4Hz_SWN_70dB_R", "10Hz_SWN_70dB_R", "20Hz_SWN_70dB_R", "40Hz_SWN_70dB_R", "80Hz_SWN_70dB_R"]),=#
    #=Scale.y_discrete(levels=["Cz", "_4Hz_SWN_70dB_R", "10Hz_SWN_70dB_R", "20Hz_SWN_70dB_R", "40Hz_SWN_70dB_R", "80Hz_SWN_70dB_R"]))=#
