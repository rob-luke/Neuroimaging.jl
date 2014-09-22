#######################################
#
# Helper functions
#
#######################################


function append_strings(strings::Union(Array{String}, Array{ASCIIString}); separator::String=" ")

    newString = strings[1]
    if length(strings) > 1
        for n = 2:length(strings)
            newString = string(newString, separator, strings[n])
        end
    end

    return newString
end


function append_strings(strings::String; separator::String=" ")
    return strings
end


function new_processing_key(d::Dict, key_name::String)

    key_numb = 1
    key = string(key_name, key_numb)
    while haskey(d, key)
        key_numb += 1
        key = string(key_name, key_numb)
    end
    return key
end


# Find keys containing a string
function find_keys_containing(d, partial_key::String)

    valid_keys = [beginswith(i, partial_key) for i = collect(keys(d))]
    findin(valid_keys, true)
end


function fileparts(fname::String)

    if fname==""
        pathname = ""
        filename = ""
        extension = ""
    else

        separators = sort(unique([search(fname, '/', i) for i = 1:length(fname)]))
        pathname = fname[1:last(separators)]

        extension  = last(sort(unique([search(fname, '.', i) for i = 1:length(fname)])))

        filename = fname[last(separators)+1:extension-1]

        extension  = fname[extension+1:end]
    end

    return pathname, filename, extension
end
