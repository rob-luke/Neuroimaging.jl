using EEG
using Logging
using Base.Test

Logging.configure(level=DEBUG)

@test append_strings(["Turtle", "smAck", "wam3d"]) == "Turtle smAck wam3d"
@test append_strings(["Turtle", "smAck", "wam3d"], separator = "*3a") == "Turtle*3asmAck*3awam3d"
@test append_strings("Turtle") == "Turtle"

results_storage = Dict()
results_storage[new_processing_key(results_storage, "FTest")] = 4
results_storage[new_processing_key(results_storage, "Turtle")] = 5
results_storage[new_processing_key(results_storage, "FTest")] = 49

@test new_processing_key(results_storage, "FTest") == "FTest3"

@test find_keys_containing(results_storage, "FTest") == [1, 3]
@test find_keys_containing(results_storage, "Mum") == []

a, b, c = fileparts("/Users/test/subdir/test-file.bdf")

@test a == "/Users/test/subdir/"
@test b == "test-file"
@test c == "bdf"

@test _find_closest_number_idx([1, 2, 2.7, 3.2, 4, 3.1, 7], 3) == 6
