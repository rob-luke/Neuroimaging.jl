using DataFrames

@doc doc"""
Concatanate `strings` with a `separator` between each.

### Input

* strings: Array of strings to place one after another
* separator: String to place between each string (Default: ` `)

### Output

String consisting of all input strings
""" ->
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


# Find the index of closest number in a list
function _find_closest_number_idx(list::Array, target::Number)

    diff_array = abs(list .- target)
    targetIdx  = findfirst(diff_array , minimum(diff_array))

    return targetIdx
end


#######################################
#
# DataFrame manipulation
#
#######################################

function add_dataframe_static_rows(a::DataFrame, args...)
    debug("Adding column(s)")
    for kwargs in args
        debug(kwargs)
        for k in kwargs
            name = convert(Symbol, k[1])
            code = k[2]
            expanded_code = vec(repmat([k[2]], size(a, 1), 1))
            debug("Name: $name  Code: $code")
            DataFrames.insert_single_column!(a, DataFrames.upgrade_vector(expanded_code), size(a,2)+1)
            rename!(a, convert(Symbol, string("x", size(a,2))),  name)
        end
    end
    return a
end
