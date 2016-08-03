facts("Miscellaneous") do

    context("Results storage") do
        results_storage = Dict()
        results_storage[new_processing_key(results_storage, "FTest")] = 4
        results_storage[new_processing_key(results_storage, "Turtle")] = 5
        results_storage[new_processing_key(results_storage, "FTest")] = 49

        @fact new_processing_key(results_storage, "FTest") --> "FTest3"

        @fact find_keys_containing(results_storage, "FTest") --> [1, 3]
        @fact find_keys_containing(results_storage, "Mum") --> []

    end

    context("File parts") do

        a, b, c = fileparts("")
        @fact a --> ""
        @fact b --> ""
        @fact c --> ""

        a, b, c = fileparts("/Users/test/subdir/test-file.bdf")
        @fact a --> "/Users/test/subdir/"
        @fact b --> "test-file"
        @fact c --> "bdf"

        a, b, c = fileparts("/Users/test/subdir/test_file.bdf")
        @fact a --> "/Users/test/subdir/"
        @fact b --> "test_file"
        @fact c --> "bdf"

        a, b, c = fileparts("test-file.bdf")
        @fact a --> ""
        @fact b --> "test-file"
        @fact c --> "bdf"
    end

    context("Find closest number index") do
        @fact _find_closest_number_idx([1, 2, 2.7, 3.2, 4, 3.1, 7], 3) --> 6
    end

end
