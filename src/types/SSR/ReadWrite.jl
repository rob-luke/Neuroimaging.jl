#######################################
#
# Read SSR
#
#######################################

@doc md"""
Read a file or IO stream and store the data in an SSR type.

Matching .mat files are read and modulation frequency information extracted.
Failing that, user passed arguments are used or the modulation frequency is extracted from the file name.

### Optional arguments

* min_epoch_length: Minimum epoch length in samples. Shorter epochs will be removed.
* max_epoch_length: Maximum epoch length in samples. Longer epochs will be removed.
* valid_triggers: Triggers that are considered valid, others are removed.
* stimulation_amplitude: Amplitude of stimulation
* modulationfreq: Modulation frequency of SSR stimulation
* participant name: Name of participant
* remove_first: Number of epochs to be removed from start of recording
* max_epochs: Maximum number of epochs to retain

### Supported file formats

* BIOSEMI .bdf


""" ->
function read_SSR(fname::Union(String, IO);
                  stimulation_amplitude::Number=NaN,   # User can set these
                  modulationfreq::Number=NaN,    # values, but if not
                  carrier_frequency::Number=NaN,       # then attempt to read
                  stimulation_side::String="",         # from file name or mat
                  participant_name::String="",
                  valid_triggers::Array{Int}=[1,2],
                  min_epoch_length::Int=0,
                  max_epoch_length::Number=Inf,
                  remove_first::Int=0,
                  max_epochs::Number=Inf,
                  kwargs...)


    info("Importing SSR from file: $fname")

    if isa(fname, String)
        file_path, file_name, ext = fileparts(fname)
    else
        warn("Filetype is IO. Might be bugged")
        file_path = "IO"; file_name = fname; ext = "IO"
    end


    #
    # Extract meta data
    #

    # Extract frequency from the file name if not set manually
    if contains(file_name, "Hz") && isnan(modulationfreq)
        a = match(r"[-_](\d+[_.]?[\d+]+?)Hz|Hz(\d+[_.]?[\d+]+?)[-_]", file_name).captures
        modulationfreq = float(a[[i !== nothing for i = a]][1]) * Hertz
        debug("Extracted modulation frequency from file name: $modulationfreq")
    end

    # Or even better if there is a mat file read it
    mat_path = string(file_path, file_name, ".mat")
    if isreadable(mat_path)
        modulationfreq, stimulation_side, participant_name,
            stimulation_amplitude, carrier_frequency = read_rba_mat(mat_path)
    end


    #
    # Read file data
    #

    # Import raw data
    if ext == "bdf"
        data, triggers, system_codes, samplingrate, reference_channel, header = import_biosemi(fname)
    else
        warn("File type $ext is unknown")
    end

    # Create SSR type
    a = SSR(data, triggers, system_codes, samplingrate * Hertz, modulationfreq,
            [reference_channel], file_path, file_name, header["chanLabels"], Dict())


    #
    # Store meta data in processing dictionary
    #

    if stimulation_side != ""
        a.processing["Side"] = stimulation_side
    end
    if participant_name != ""
        a.processing["Name"] = participant_name
    end
    if !isnan(stimulation_amplitude)
        a.processing["Amplitude"] = stimulation_amplitude
    end
    if !isnan(carrier_frequency)
        a.processing["Carrier_Frequency"] = carrier_frequency
    end


    #
    # Clean up
    #

    # Remove status channel information
    remove_channel!(a, "Status")

    # Clean epoch index
    a.triggers = clean_triggers(a.triggers, valid_triggers, min_epoch_length, max_epoch_length, remove_first, max_epochs)

    return a
end




#######################################
#
# Read event files
#
#######################################

function read_evt(a::SSR, fname::String; kwargs...)
    d = read_evt(fname, a.samplingrate; kwargs...)
    validate_triggers(d)
    a.triggers = d
    return a
end



#######################################
#
# File IO
#
#######################################

function trigger_channel(a::SSR; kwargs...)

    create_channel(a.triggers, a.data, float(a.samplingrate))
end


function system_code_channel(a::SSR; kwargs...)

    create_channel(a.system_codes, a.data, float(a.samplingrate))
end


function write_SSR(a::SSR, fname::String; kwargs...)

    info("Saving $(size(a.data)[end]) channels to $fname")

    writeBDF(fname, a.data', trigger_channel(a), system_code_channel(a), int(a.samplingrate), chanLabels=a.channel_names)

end
