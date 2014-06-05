using DataFrames

function save_results(results::ASSR; verbose::Bool=true)

    results = results.processing

    result_keys = find_keys_containing(results, "ftest")

    for k = 1:length(result_keys)
        if result_keys[k]
            result_data = get(results, collect(keys(results))[k], 0)
            save_ftest(result_data, string(collect(keys(results))[k], ".csv"), verbose=true)
        end
    end


end





#######################################
#
# Helper functions
#
#######################################


function find_keys_containing(d, partial_key::String)

    [beginswith(i, partial_key) for i = collect(keys(d))]
end


function save_ftest(results::DataFrame, fname::String; verbose=false)

    if verbose
        println(typeof(results))
        println(results)
        println(size(results))
    end

    writetable(fname, results)
end
