@testset "Miscellaneous" begin

    @testset "Results storage" begin
        results_storage = Dict()
        results_storage[new_processing_key(results_storage, "FTest")] = 4
        results_storage[new_processing_key(results_storage, "Turtle")] = 5
        results_storage[new_processing_key(results_storage, "FTest")] = 49

        @test new_processing_key(results_storage, "FTest") == "FTest3"

        @test find_keys_containing(results_storage, "FTest") == [1, 3]
        @test find_keys_containing(results_storage, "Mum") == []

    end

    @testset "File parts" begin

        a, b, c = fileparts("")
        @test a == ""
        @test b == ""
        @test c == ""

        a, b, c = fileparts("/Users/test/subdir/test-file.bdf")
        @test a == "/Users/test/subdir/"
        @test b == "test-file"
        @test c == "bdf"

        a, b, c = fileparts("/Users/test/subdir/test_file.bdf")
        @test a == "/Users/test/subdir/"
        @test b == "test_file"
        @test c == "bdf"

        a, b, c = fileparts("test-file.bdf")
        @test a == ""
        @test b == "test-file"
        @test c == "bdf"
    end

    @testset "Find closest number index" begin
        @test _find_closest_number_idx([1, 2, 2.7, 3.2, 4, 3.1, 7], 3) == 6
    end

end
