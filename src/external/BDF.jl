module BDF

# The license below is provided to comply with the requirements from the original repository https://github.com/sam81/BDF.jl
# On a personal note, I thank Samuele Carcagno for releasing this excellent package. I am repackaging it here as the original repository does not work with new compat versions.
# I believe that including the license below, but please contact me if I have incorrectly understood my obligations.

# The MIT License (MIT)
#
# Copyright (c) 2013-2016 Samuele Carcagno sam.carcagno@gmail.com
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

using Dates

export readBDF,
    readBDFHeader, writeBDF, splitBDFAtTime, splitBDFAtTrigger, decodeStatusChannel

"""
Read the data from a BDF file

##### Args:

* `fName`: Name of the BDF file to read.
* `from`: Start time of data chunk to read (seconds).
* `to`: End time of data chunk to read (seconds).
* `channels`: Channels to read (indices or channel names).
* `transposeData`: If `true`, return transposed version of the `dats` array. Default is `false`.

##### Returns:

* `dats::Array{Float32, 2}`: The matrix containing the data, this will be a nChannels X nDataPoints matrix if `transposeData` is `false` (default).
                             If `transposeData` is `true`, however, it will be a nDataPoints X nChannels matrix.
* eventTable: dictionary with three fields
    * code: trigger codes
    * idx: trigger indexes
    * dur: trigger durations
* trigChannel: the raw trigger channel
* syscodeChannel: the raw system codes channel


##### Examples:

```julia
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf")
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf", channels=[1,3]) #read only channels 1 and 3
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf", channels=["Fz","RM"]) #read only channels Fz and RM
dats, evtTab, trigChan, sysChan = readBDF("res1.bdf", transposeData=true) #return transposed data matrix (i.e. nDataPoints X nChannels)
```
"""
function readBDF(
    fName::AbstractString;
    from::Real = 0,
    to::Real = -1,
    channels::AbstractVector = [-1],
    transposeData::Bool = false,
)

    channels = unique(channels)
    if isa(channels, AbstractVector{String})
        bdfHeader = readBDFHeader(fName)

        for c in channels
            if findfirst(isequal(c), bdfHeader["chanLabels"]) == nothing
                #one of the requested channels not in channel labels
                error(string("Channel ", c, " not found among BDF file channel labels"))
            end
        end

        channels = [findfirst(isequal(c), bdfHeader["chanLabels"]) for c in channels]

    end

    readBDF(
        open(fName, "r"),
        from = from,
        to = to,
        channels = channels,
        transposeData = transposeData,
    )
end


function readBDF(
    fid::IO;
    from::Real = 0,
    to::Real = -1,
    channels::AbstractVector{Int} = [-1],
    transposeData::Bool = false,
)

    if isa(fid, IOBuffer)
        fid.ptr = 1
    end

    idCodeNonASCII = read!(fid, Array{UInt8}(undef, 1))
    idCode = ascii(String(read!(fid, Array{UInt8}(undef, 7))))
    subjID = ascii(String(read!(fid, Array{UInt8}(undef, 80))))
    recID = ascii(String(read!(fid, Array{UInt8}(undef, 80))))
    startDate = ascii(String(read!(fid, Array{UInt8}(undef, 8))))
    startTime = ascii(String(read!(fid, Array{UInt8}(undef, 8))))
    nBytes = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    versionDataFormat = ascii(String(read!(fid, Array{UInt8}(undef, 44))))
    nDataRecords = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    recordDuration = parse(Float64, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    nChannels = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 4)))))
    chanLabels = Array{String}(undef, nChannels)
    transducer = Array{String}(undef, nChannels)
    physDim = Array{String}(undef, nChannels)
    physMin = Array{Int32}(undef, nChannels)
    physMax = Array{Int32}(undef, nChannels)
    digMin = Array{Int32}(undef, nChannels)
    digMax = Array{Int32}(undef, nChannels)
    prefilt = Array{String}(undef, nChannels)
    nSampRec = Array{Int}(undef, nChannels)
    reserved = Array{String}(undef, nChannels)
    scaleFactor = Array{Float32}(undef, nChannels)
    sampRate = Array{Int}(undef, nChannels)

    duration = recordDuration * nDataRecords

    channels = unique(channels)
    if channels == [-1]
        channels = 1:(nChannels-1)
    end
    nKeepChannels = length(channels)

    for i = 1:nChannels
        chanLabels[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 16)))))
    end

    for i = 1:nChannels
        transducer[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 80)))))
    end

    for i = 1:nChannels
        physDim[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        physMin[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        physMax[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        digMin[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        digMax[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        prefilt[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 80)))))
    end

    for i = 1:nChannels
        nSampRec[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        reserved[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 32)))))
    end

    for i = 1:nChannels
        scaleFactor[i] = Float32(physMax[i] - physMin[i]) / (digMax[i] - digMin[i])
        sampRate[i] = nSampRec[i] / recordDuration
    end

    if length(unique(nSampRec)) > 1 #channels have different sampling rates
        error(
            "BDF files with channels having different sampling rates are not currently supported",
        )
    end

    if to < 1
        to = nDataRecords
    end
    recordsToRead = to - from
    if transposeData
        data = Array{Int32}(undef, (recordsToRead * nSampRec[1]), (nKeepChannels))
    else
        data = Array{Int32}(undef, (nKeepChannels), (recordsToRead * nSampRec[1]))
    end
    trigChan = Array{Int16}(undef, recordsToRead * nSampRec[1])
    sysCodeChan = Array{Int16}(undef, recordsToRead * nSampRec[1])

    startPos = 3 * from * nChannels * nSampRec[1]
    skip(fid, startPos)
    x = read!(fid, Array{UInt8}(undef, 3 * recordsToRead * nChannels * nSampRec[1]))
    pos = 1
    if transposeData
        for n = 1:recordsToRead
            for c = 1:nChannels
                cIdx = findfirst(isequal(c), channels)
                if (chanLabels[c] != "Status") & (cIdx != nothing)
                    for s = 1:nSampRec[1]
                        data[(n-1)*nSampRec[1]+s, cIdx] =
                            (
                                (Int32(x[pos]) << 8) |
                                (Int32(x[pos+1]) << 16) |
                                (Int32(x[pos+2]) << 24)
                            ) >> 8
                        pos = pos + 3
                    end
                elseif chanLabels[c] == "Status"
                    for s = 1:nSampRec[1]
                        trigChan[(n-1)*nSampRec[1]+s] =
                            ((UInt16(x[pos])) | (UInt16(x[pos+1]) << 8)) & 255
                        sysCodeChan[(n-1)*nSampRec[1]+s] = Int16(x[pos+2])
                        pos = pos + 3
                    end
                else
                    # Channel not selected
                    for s = 1:nSampRec[1]
                        pos = pos + 3
                    end
                end
            end
        end
    else
        for n = 1:recordsToRead
            for c = 1:nChannels
                cIdx = findfirst(isequal(c), channels)
                if (chanLabels[c] != "Status") & (cIdx != nothing)
                    for s = 1:nSampRec[1]
                        data[cIdx, (n-1)*nSampRec[1]+s] =
                            (
                                (Int32(x[pos]) << 8) |
                                (Int32(x[pos+1]) << 16) |
                                (Int32(x[pos+2]) << 24)
                            ) >> 8
                        pos = pos + 3
                    end
                elseif chanLabels[c] == "Status"
                    for s = 1:nSampRec[1]
                        trigChan[(n-1)*nSampRec[1]+s] =
                            ((UInt16(x[pos])) | (UInt16(x[pos+1]) << 8)) & 255
                        sysCodeChan[(n-1)*nSampRec[1]+s] = Int16(x[pos+2])
                        pos = pos + 3
                    end
                else
                    # Channel not selected
                    for s = 1:nSampRec[1]
                        pos = pos + 3
                    end
                end
            end
        end

    end

    data = map(Float32, data)
    if transposeData
        for ch = 1:size(data, 2)
            data[:, ch] = data[:, ch] * scaleFactor[ch]
        end
    else
        for ch = 1:size(data, 1)
            data[ch, :] = data[ch, :] * scaleFactor[ch]
        end
    end
    close(fid)


    startPoints = vcat(1, findall(diff(trigChan) .!= 0) .+ 1)
    stopPoints = vcat(findall(diff(trigChan) .!= 0), length(trigChan))
    trigDurs = (stopPoints - startPoints) / sampRate[1]

    evt = trigChan[startPoints]
    evtTab = Dict{String,Any}("code" => evt, "idx" => startPoints, "dur" => trigDurs)

    return data, evtTab, trigChan, sysCodeChan

end


"""
Read the header of a BDF file


##### Args:

* fName: Name of the BDF file to read.

##### Returns:

* `bdfInfo::Dict{ASCIIString,Any}`: dictionary with the following fields:
    * `idCode::ASCIIString`: Identification code
    * `subjID::`ASCIIString`: Local subject identification
    * `recID::ASCIIString`: Local recording identification
    * `startDate::ASCIIString`: Recording start date
    * `startTime::ASCIIString`: Recording start time
    * `nBytes::Int`: Number of bytes occupied by the BDF header
    * `versionDataFormat::ASCIIString`: Version of data format
    * `nDataRecords::Int`: Number of data records "-1" if unknown
    * `recordDuration::FloatingPoint`: Duration of a data record, in seconds
    * `nChannels::Int`: Number of channels in data record
    * `chanLabels::Array{ASCIIString,1}`: Channel labels
    * `transducer::Array{ASCIIString,1}`: Transducer type
    * `physDim::ASCIIString`: Physical dimension of channels
    * `physMin::Array{Int64,1}`: Physical minimum in units of physical dimension
    * `physMax::Array{Int64,1}`: Physical maximum in units of physical dimension
    * `digMin::Array{Int64,1}`: Digital minimum
    * `digMax::Array{Int64,1}`: Digital maximum
    * `prefilt::Array{ASCIIString,1}`: Prefiltering
    * `nSampRec::Array{Int64,1}`: Number of samples in each data record
    * `reserved::Array{ASCIIString,1}`: Reserved
    * `scaleFactor::Array{Float32,1}`: Scaling factor for digital to physical dimension
    * `sampRate::Array{Int64,1}`: Recording sampling rate

##### Examples

```julia
bdfInfo = readBDFHeader("res1.bdf")
sampRate = bdfInfo["sampRate"][1]
```
"""
function readBDFHeader(fName::AbstractString)

    readBDFHeader(open(fName, "r"), fName = fName)
end


function readBDFHeader(fid::IO; fName::AbstractString = "")

    if isa(fid, IOBuffer)
        fid.ptr = 1
    end

    idCodeNonASCII = read!(fid, Array{UInt8}(undef, 1))
    idCode = ascii(String(read!(fid, Array{UInt8}(undef, 7))))
    subjID = ascii(String(read!(fid, Array{UInt8}(undef, 80))))
    recID = ascii(String(read!(fid, Array{UInt8}(undef, 80))))
    startDate = ascii(String(read!(fid, Array{UInt8}(undef, 8))))
    startTime = ascii(String(read!(fid, Array{UInt8}(undef, 8))))
    nBytes = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    versionDataFormat = ascii(String(read!(fid, Array{UInt8}(undef, 44))))
    nDataRecords = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    recordDuration = parse(Float64, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    nChannels = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 4)))))
    chanLabels = Array{String}(undef, nChannels)
    transducer = Array{String}(undef, nChannels)
    physDim = Array{String}(undef, nChannels)
    physMin = Array{Int32}(undef, nChannels)
    physMax = Array{Int32}(undef, nChannels)
    digMin = Array{Int32}(undef, nChannels)
    digMax = Array{Int32}(undef, nChannels)
    prefilt = Array{String}(undef, nChannels)
    nSampRec = Array{Int}(undef, nChannels)
    reserved = Array{String}(undef, nChannels)
    scaleFactor = Array{Float32}(undef, nChannels)
    sampRate = Array{Int}(undef, nChannels)

    duration = recordDuration * nDataRecords

    for i = 1:nChannels
        chanLabels[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 16)))))
    end

    for i = 1:nChannels
        transducer[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 80)))))
    end

    for i = 1:nChannels
        physDim[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        physMin[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        physMax[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        digMin[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        digMax[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        prefilt[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 80)))))
    end

    for i = 1:nChannels
        nSampRec[i] = parse(Int, ascii(String(read!(fid, Array{UInt8}(undef, 8)))))
    end

    for i = 1:nChannels
        reserved[i] = strip(ascii(String(read!(fid, Array{UInt8}(undef, 32)))))
    end

    for i = 1:nChannels
        scaleFactor[i] = Float32(physMax[i] - physMin[i]) / (digMax[i] - digMin[i])
        sampRate[i] = nSampRec[i] / recordDuration
    end

    close(fid)

    d = Dict{String,Any}(
        "fileName" => fName,
        "idCodeNonASCII" => idCodeNonASCII,
        "idCode" => idCode,
        "subjID" => subjID,
        "recID" => recID,
        "startDate" => startDate,
        "startTime" => startTime,
        "nBytes" => nBytes,
        "versionDataFormat" => versionDataFormat,
        "nDataRecords" => nDataRecords,
        "recordDuration" => recordDuration,
        "nChannels" => nChannels,
        "chanLabels" => chanLabels,
        "transducer" => transducer,
        "physDim" => physDim,
        "physMin" => physMin,
        "physMax" => physMax,
        "digMin" => digMin,
        "digMax" => digMax,
        "prefilt" => prefilt,
        "nSampRec" => nSampRec,
        "reserved" => reserved,
        "scaleFactor" => scaleFactor,
        "sampRate" => sampRate,
        "duration" => duration,
    )
    return (d)

end

"""
Write a BDF file

##### Args:
* `fName`: Name of the BDF file to write.
* `data`: The nChannelsXnDataPoints array to be written to the BDF file
* `trigChan`: The triggers to be written to the BDF file (1XnDataPoints)
* `statusChan`: The status channel codes to be written to the BDF file (1XnDataPoints)
* `sampRate`: The sampling rate of the recording
* `subjID`: Subject identifier (80 characters max)
* `recID`: Recording identifier (80 characters max)
* `startDate`: Start date in "dd.mm.yy" format
* `startTime`: Start time in "hh.mm.ss" format
* `versionDataFormat`: Version of data format
* `chanLabels`: Array of channel labels (1 for each channel)
* `transducer`: Array of transducer type (1 for each channel)
* `physDim`: Array of physical dimension of channels (1 for each channel)
* `physMin`: Array of physical minimum in units of physical dimension (1 for each channel)
* `physMax`: Array of physical maximum in units of physical dimension (1 for each channel)
* `prefilt`: Array of prefilter settings (1 for each channel)
* `reserved`: Array of "reserved" field (1 for each data channel + 1 for the status channel)

#####  Notes:

Only the first five arguments are required. The other arguments are optional and
the corresponding BDF fields will be left empty or filled with defaults arguments.

Data records are written in 1-second units. If the number of data points passed to
`writeBDF` is not an integer multiple of the sampling rate the data array, as well
as the trigger and status channel arrays will be padded with zeros to fill the last
data record before it is written to disk.

##### Examples:

```julia
sampRate = 2048
dats = rand(2, sampRate*10)
trigs = rand(1:255, sampRate*10)
statChan = rand(1:255, sampRate*10)
writeBDF("bdfRec.bdf", dats, trigs, statChan, sampRate)

#add date and time info
writeBDF("bdfRec.bdf", dats, trigs, statChan, sampRate, startDate="23.06.14",
startTime="10.18.19")
```
"""
function writeBDF(
    fName::AbstractString,
    data::AbstractMatrix{P},
    trigChan::AbstractVector{Q},
    statusChan::AbstractVector{R},
    sampRate::Integer;
    subjID::String = "",
    recID::String = "",
    startDate::String = Libc.strftime("%d.%m.%y", time()),
    startTime::String = Libc.strftime("%H.%M.%S", time()),
    versionDataFormat::String = "24BIT",
    chanLabels::AbstractVector{S} = ["" for i = 1:size(data)[1]],
    transducer::AbstractVector{T} = ["" for i = 1:size(data)[1]],
    physDim::AbstractVector{U} = ["" for i = 1:size(data)[1]],
    physMin::AbstractVector{V} = [-262144 for i = 1:size(data)[1]],
    physMax::AbstractVector{W} = [262144 for i = 1:size(data)[1]],
    prefilt::AbstractVector{Z} = ["" for i = 1:size(data)[1]],
    reserved::AbstractVector{O} = ["Reserved" for i = 1:size(data)[1]],
) where {
    P<:Real,
    Q<:Real,
    R<:Real,
    S<:String,
    T<:String,
    U<:String,
    V<:Real,
    W<:Real,
    Z<:String,
    O<:String,
}

    #check data values within physMin physMax range
    for i = 1:size(data)[1]
        if (maximum(data[i, :]) > physMax[i]) | (minimum(data[i, :]) < physMin[i])
            error("Data values exceed [physMin, physMax] range, exiting!")
        end
    end
    # and check also trigs and status don't go over allowed range
    if (maximum(trigChan) > 2^16 - 1) | (minimum(trigChan) < 0)
        error("trigger values exceed allowed range [0, 65535] range, exiting!")
    end
    if (maximum(statusChan) > 2^8 - 1) | (minimum(statusChan) < 0)
        error("status channel values exceed allowed range [0, 255] range, exiting!")
    end

    modulo = mod(size(data)[2], sampRate)
    if modulo == 0
        padSize = 0
    else
        padSize = round(Int, sampRate - modulo)
    end
    dats = hcat(data, zeros(eltype(data), size(data)[1], padSize))
    trigs = vcat(trigChan, zeros(eltype(trigChan), padSize))
    statChan = vcat(statusChan, zeros(eltype(statusChan), padSize))
    ## dats = copy(data) #data are modified (scaled, converted to int) need to copy to avoid mofifying original data
    ## trigs = copy(trigChan)
    ## statChan = copy(statusChan)
    nChannels = size(dats)[1] + 1
    nSamples = size(dats)[2]
    fid = open(fName, "w")

    write(fid, 0xff)
    idCode = "BIOSEMI"
    for i = 1:length(idCode)
        write(fid, UInt8(idCode[i]))
    end
    #subjID
    nSubjID = length(subjID)
    if nSubjID > 80
        println("subjID longer than 80 characters, truncating!")
        subjID = subjID[1:80]
        nSubjID = length(subjID)
    end
    for i = 1:nSubjID
        write(fid, UInt8(subjID[i]))
    end
    for i = 1:(80-nSubjID)
        write(fid, Char(' '))
    end
    #recID
    nRecID = length(recID)
    if nRecID > 80
        println("recID longer than 80 characters, truncating!")
        recID = recID[1:80]
        nRecID = length(recID)
    end
    for i = 1:nRecID
        write(fid, UInt8(recID[i]))
    end
    for i = 1:(80-nRecID)
        write(fid, Char(' '))
    end
    #startDate
    nStartDate = length(startDate)
    if nStartDate > 8
        println("startDate longer than 8 characters, truncating!")
        startDate = startDate[1:8]
        nStartDate = length(startDate)
    end
    for i = 1:nStartDate
        write(fid, UInt8(startDate[i]))
    end
    for i = 1:(8-nStartDate)
        write(fid, Char(' '))
    end
    #startTime
    nStartTime = length(startTime)
    if nStartTime > 8
        println("startTime longer than 8 characters, truncating!")
        startTime = startTime[1:8]
        nStartTime = length(startTime)
    end
    for i = 1:nStartTime
        write(fid, UInt8(startTime[i]))
    end
    for i = 1:(8-nStartTime)
        write(fid, Char(' '))
    end
    #nBytes
    nBytes = string((nChannels + 1) * 256)
    for i = 1:length(nBytes)
        write(fid, UInt8(nBytes[i]))
    end
    for i = 1:(8-length(nBytes))
        write(fid, Char(' '))
    end
    #versionDataFormat
    nVersionDataFormat = length(versionDataFormat)
    if nVersionDataFormat > 44
        println("versionDataFormat longer than 44 characters, truncating!")
        versionDataFormat = versionDataFormat[1:44]
        nVersionDataFormat = length(versionDataFormat)
    end
    for i = 1:nVersionDataFormat
        write(fid, UInt8(versionDataFormat[i]))
    end
    for i = 1:(44-nVersionDataFormat)
        write(fid, Char(' '))
    end
    #nDataRecords
    nDataRecords = round(Int, ceil(size(dats)[2] / sampRate))
    nDataRecordsString = string(nDataRecords)
    for i = 1:length(nDataRecordsString)
        write(fid, UInt8(nDataRecordsString[i]))
    end
    for i = 1:(8-length(nDataRecordsString))
        write(fid, Char(' '))
    end
    #recordDuration
    recordDuration = "1       "
    for i = 1:length(recordDuration)
        write(fid, UInt8(recordDuration[i]))
    end
    #nChannels
    nChannelsString = string(nChannels)
    for i = 1:length(nChannelsString)
        write(fid, UInt8(nChannelsString[i]))
    end
    for i = 1:(4-length(nChannelsString))
        write(fid, Char(' '))
    end
    #chanLabels
    if length(chanLabels) > nChannels - 1
        println("Number of chanLabels greater than number of channels, truncating!")
        chanLabels = chanLabels[1:nChannels-1]
    end
    if length(chanLabels) < nChannels - 1
        #println("Warning: number of chanLabels less than number of channels!")
        chanLabels = vcat(chanLabels, ["" for k = 1:(nChannels-1)-length(chanLabels)])

    end
    for j = 1:length(chanLabels)
        for i = 1:length(chanLabels[j])
            write(fid, UInt8(chanLabels[j][i]))
        end
        for i = 1:(16-length(chanLabels[j]))
            write(fid, Char(' '))
        end
    end
    statusString = "Status"
    for i = 1:length(statusString)
        write(fid, UInt8(statusString[i]))
    end
    for i = 1:(16-length(statusString))
        write(fid, Char(' '))
    end

    #transducer
    if length(transducer) > nChannels - 1
        println("Number of transducer greater than number of channels, truncating!")
        transducer = transducer[1:nChannels-1]
    end
    if length(transducer) < nChannels - 1
        #println("Warning: number of transducer less than number of channels!")
        transducer = vcat(transducer, ["" for k = 1:(nChannels-1)-length(transducer)])
    end
    for j = 1:length(transducer)
        for i = 1:length(transducer[j])
            write(fid, UInt8(transducer[j][i]))
        end
        for i = 1:(80-length(transducer[j]))
            write(fid, Char(' '))
        end
    end
    trigStatusString = "Triggers and Status"
    for i = 1:length(trigStatusString)
        write(fid, UInt8(trigStatusString[i]))
    end
    for i = 1:(80-length(trigStatusString))
        write(fid, Char(' '))
    end

    #physDim
    if length(physDim) > nChannels - 1
        println("Number of physDim greater than number of channels, truncating!")
        physDim = physDim[1:nChannels-1]
    end
    if length(physDim) < nChannels - 1
        #println("Warning: number of physDim less than number of channels!")
        physDim = vcat(physDim, ["" for k = 1:(nChannels-1)-length(physDim)])
    end
    for j = 1:length(physDim)
        for i = 1:length(physDim[j])
            write(fid, UInt8(physDim[j][i]))
        end
        for i = 1:(8-length(physDim[j]))
            write(fid, Char(' '))
        end
    end
    boolString = "Boolean"
    for i = 1:length(boolString)
        write(fid, UInt8(boolString[i]))
    end
    for i = 1:(8-length(boolString))
        write(fid, Char(' '))
    end
    if length(physMin) != nChannels - 1
        error("Length of physMin must match number of data channels, exiting!")
    end
    if length(physMax) != nChannels - 1
        error("Length of physMax must match number of data channels, exiting!")
    end
    physMin = vcat(physMin, -8388608)
    physMax = vcat(physMax, 8388607)
    digMin = [-8388608 for i = 1:nChannels]
    digMax = [8388607 for i = 1:nChannels]
    physMinString = [string(physMin[i]) for i = 1:length(physMin)]
    physMaxString = [string(physMax[i]) for i = 1:length(physMax)]
    digMinString = [string(digMin[i]) for i = 1:length(digMin)]
    digMaxString = [string(digMax[i]) for i = 1:length(digMax)]
    for j = 1:length(physMinString)
        for i = 1:length(physMinString[j])
            write(fid, UInt8(physMinString[j][i]))
        end
        for i = 1:(8-length(physMinString[j]))
            write(fid, Char(' '))
        end
    end
    for j = 1:length(physMaxString)
        for i = 1:length(physMaxString[j])
            write(fid, UInt8(physMaxString[j][i]))
        end
        for i = 1:(8-length(physMaxString[j]))
            write(fid, Char(' '))
        end
    end
    for j = 1:length(digMinString)
        for i = 1:length(digMinString[j])
            write(fid, UInt8(digMinString[j][i]))
        end
        for i = 1:(8-length(digMinString[j]))
            write(fid, Char(' '))
        end
    end
    for j = 1:length(digMaxString)
        for i = 1:length(digMaxString[j])
            write(fid, UInt8(digMaxString[j][i]))
        end
        for i = 1:(8-length(digMaxString[j]))
            write(fid, Char(' '))
        end
    end

    #prefilt
    if length(prefilt) > nChannels - 1
        println("Number of prefilt greater than number of channels, truncating!")
        prefilt = prefilt[1:nChannels-1]
    end
    if length(prefilt) < nChannels - 1
        #println("Warning: number of prefilt less than number of channels!")
        prefilt = vcat(prefilt, ["" for k = 1:(nChannels-1)-length(prefilt)])
    end
    for j = 1:length(prefilt)
        for i = 1:length(prefilt[j])
            write(fid, UInt8(prefilt[j][i]))
        end
        for i = 1:(80-length(prefilt[j]))
            write(fid, Char(' '))
        end
    end
    noFiltString = "No filtering"
    for i = 1:length(noFiltString)
        write(fid, UInt8(noFiltString[i]))
    end
    for i = 1:(80-length(noFiltString))
        write(fid, Char(' '))
    end

    #nSampRec
    nSampRec = sampRate
    nSampRecString = string(sampRate)
    for j = 1:nChannels
        for i = 1:length(nSampRecString)
            write(fid, UInt8(nSampRecString[i]))
        end
        for i = 1:(8-length(nSampRecString))
            write(fid, Char(' '))
        end
    end

    #Reserved
    if length(reserved) > nChannels
        println("Number of reserved greater than number of channels+1, truncating!")
        reserved = reserved[1:nChannels]
    end
    if length(reserved) < nChannels
        #println("Warning: number of chanLabels less than number of channels!")
        reserved = vcat(reserved, ["Reserved" for k = 1:(nChannels)-length(reserved)])

    end
    for j = 1:length(reserved)
        for i = 1:length(reserved[j])
            write(fid, UInt8(reserved[j][i]))
        end
        for i = 1:(32-length(reserved[j]))
            write(fid, Char(' '))
        end
    end

    scaleFactor = zeros(nChannels)
    for i = 1:nChannels
        scaleFactor[i] = Float32(physMax[i] - physMin[i]) / (digMax[i] - digMin[i])
    end
    for i = 1:nChannels-1
        dats[i, :] = dats[i, :] / scaleFactor[i]
    end

    dats = round.(Int32, dats) #need to pad dats
    trigs = round.(Int16, trigs)
    statChan = round.(Int16, statChan)
    for n = 1:nDataRecords
        for c = 1:nChannels
            if c < nChannels
                for s = 1:nSampRec
                    thisSample = dats[c, (n-1)*nSampRec+s]
                    write(fid, thisSample % UInt8)
                    write(fid, (thisSample >> 8) % UInt8)
                    write(fid, (thisSample >> 16) % UInt8)
                end
            else
                for s = 1:nSampRec
                    thisTrig = trigs[(n-1)*nSampRec[1]+s]
                    thisStatus = statChan[(n-1)*nSampRec[1]+s]
                    write(fid, (thisTrig) % UInt8)
                    write(fid, (thisTrig >> 8) % UInt8)
                    write(fid, (thisStatus) % UInt8)
                end
            end
        end
    end

    close(fid)
end

"""
Split a BDF file at points marked by a trigger into multiple files.

##### Args:

* `fName`: Name of the BDF file to split.
* `trigger`: The trigger marking the split points.
* `from`: Start time of data chunk to read (seconds).
* `to`: End time of data chunk to read (seconds).
* `minTrigDur`: minimum duration of the trigger event, in seconds. Certain custom hardware configuration can generate spurious triggers that have a very short duration. The function will only split the file a triggers that last at least as long as `minTrigDur`, allowing to filter out spurious short triggers.

##### Examples:

```julia
splitBDFAtTrigger("res1.bdf", 202)
```
"""
function splitBDFAtTrigger(
    fName::AbstractString,
    trigger::Integer;
    from::Real = 0,
    to::Real = -1,
    minTrigDur = 0,
)

    data, evtTab, trigChan, sysCodeChan = readBDF(fName, from = from, to = to)
    origHeader = readBDFHeader(fName)
    sampRate = origHeader["sampRate"][1] #assuming sampling rate is the same for all channels
    sepPoints = evtTab["idx"][findall(
        (evtTab["code"] .== trigger) .& (evtTab["dur"] .>= minTrigDur),
    )]
    nChunks = length(sepPoints) + 1
    startPoints = [1; sepPoints .+ 1]
    stopPoints = [sepPoints; size(data)[2]]

    startDateTime = DateTime(
        string(origHeader["startDate"], ".", origHeader["startTime"]),
        "dd.mm.yy.HH.MM.SS",
    )
    timeSeconds = [0; round.(Int, sepPoints .* sampRate)]

    for i = 1:nChunks
        thisFname = joinpath(
            dirname(fName),
            basename(fName)[1:end-4] * "_" * string(i) * basename(fName)[end-3:end],
        )
        thisData = data[:, startPoints[i]:stopPoints[i]]
        thisTrigChan = trigChan[startPoints[i]:stopPoints[i]]
        thisSysCodeChan = sysCodeChan[startPoints[i]:stopPoints[i]]
        thisDateTime = startDateTime + Dates.Second(round(Int, timeSeconds[i]))

        writeBDF(
            thisFname,
            thisData,
            thisTrigChan,
            thisSysCodeChan,
            sampRate;
            subjID = origHeader["subjID"],
            recID = origHeader["recID"],
            startDate = Dates.format(thisDateTime, "dd.mm.yy"),
            startTime = Dates.format(thisDateTime, "HH.MM.SS"),
            versionDataFormat = "24BIT",
            chanLabels = origHeader["chanLabels"][1:end-1],
            transducer = origHeader["transducer"][1:end-1],
            physDim = origHeader["physDim"][1:end-1],
            physMin = origHeader["physMin"][1:end-1],
            physMax = origHeader["physMax"][1:end-1],
            prefilt = origHeader["prefilt"][1:end-1],
        )
    end
end

"""
Split a BDF file at one or more time points into multiple files.

##### Args:

* `fName`: Name of the BDF file to split.
* `timeSeconds`: array listing the time(s) at which the BDF file should be split, in seconds.
  This can be either a single number or an array of time points.
* `from`: Start time of data chunk to read (seconds).
* `to`: End time of data chunk to read (seconds).

##### Examples:

```julia
splitBDFAtTime("res1.bdf", 50)
splitBDFAtTime("res2.bdf", [50, 100, 150])
```
"""
function splitBDFAtTime(
    fName::AbstractString,
    timeSeconds::Union{T,AbstractVector{T}};
    from::Real = 0,
    to::Real = -1,
) where {T<:Real}

    data, evtTab, trigChan, sysCodeChan = readBDF(fName, from = from, to = to)
    origHeader = readBDFHeader(fName)
    sampRate = origHeader["sampRate"][1] #assuming sampling rate is the same for all channels
    sepPoints = round.(Int, sampRate .* timeSeconds)
    for i = 1:length(sepPoints)
        if sepPoints[i] > size(data)[2]
            error("Split point exceeds data points")
        end
    end
    nChunks = length(timeSeconds) + 1
    startPoints = [1; sepPoints .+ 1]
    stopPoints = [sepPoints; size(data)[2]]
    startDateTime = DateTime(
        string(origHeader["startDate"], ".", origHeader["startTime"]),
        "dd.mm.yy.HH.MM.SS",
    )
    timeSeconds = [0; timeSeconds]

    for i = 1:nChunks
        thisFname = joinpath(
            dirname(fName),
            basename(fName)[1:end-4] * "_" * string(i) * basename(fName)[end-3:end],
        )
        thisData = data[:, startPoints[i]:stopPoints[i]]
        thisTrigChan = trigChan[startPoints[i]:stopPoints[i]]
        thisSysCodeChan = sysCodeChan[startPoints[i]:stopPoints[i]]
        thisDateTime = startDateTime + Dates.Second(round(Int, timeSeconds[i]))

        writeBDF(
            thisFname,
            thisData,
            thisTrigChan,
            thisSysCodeChan,
            sampRate;
            subjID = origHeader["subjID"],
            recID = origHeader["recID"],
            startDate = Dates.format(thisDateTime, "dd.mm.yy"),
            startTime = Dates.format(thisDateTime, "HH.MM.SS"),
            versionDataFormat = "24BIT",
            chanLabels = origHeader["chanLabels"][1:end-1],
            transducer = origHeader["transducer"][1:end-1],
            physDim = origHeader["physDim"][1:end-1],
            physMin = origHeader["physMin"][1:end-1],
            physMax = origHeader["physMax"][1:end-1],
            prefilt = origHeader["prefilt"][1:end-1],
        )
    end
end

"""
Decode the information stored in the status channel returned by `readBDF`.


##### Args:

* `statusChannel`: the status channel as returned by `readBDF`

##### Returns:

* decodedStatusChannel: dictionary with five fields
    * newEpoch: boolean array, `true` when a new epoch is started
    * speedMode: int8 array, the current speed mode
    * CMSInRange: boolean array, `true` when CMS is in range
    * batteryLow : boolean array, `true` when battery is low
    * isMK2: boolean array, `true` when system is MK2


##### Examples:

```julia
dats, evtTab, trigChan, statusChan = readBDF("res1.bdf")
statusChanInfo = decodeStatusChannel(statusChanInfo)
if length(findall(statusChanInfo["CMSInRange"] .== false)) > 0
   println("CMS was not in range during at least some portions of the recording")
else
   println("CMS was in range during the whole recording")
end
```
"""
function decodeStatusChannel(statusChannel::AbstractVector{Int16})

    n = length(statusChannel)
    newEpoch = Array{Bool}(undef, n)
    speedMode = Array{Int8}(undef, n)
    CMSInRange = Array{Bool}(undef, n)
    batteryLow = Array{Bool}(undef, n)
    isMK2 = Array{Bool}(undef, n)
    for i = 1:n
        x = string(statusChannel[i], base = 2)
        newEpoch[i] = parse(Bool, x[8])
        speedMode[i] = parse(Int, string(x[3], x[5], x[6], x[7]), base = 2)
        CMSInRange[i] = parse(Bool, x[4])
        batteryLow[i] = parse(Bool, x[2])
        isMK2[i] = parse(Bool, x[1])
    end

    decodedStatusChannel = Dict{String,Any}(
        "newEpoch" => newEpoch,
        "speedMode" => speedMode,
        "CMSInRange" => CMSInRange,
        "batteryLow" => batteryLow,
        "isMK2" => isMK2,
    )

    return decodedStatusChannel

end


end # module
