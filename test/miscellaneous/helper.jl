using EEG
using Logging
using Base.Test

Logging.configure(level=DEBUG)

@test append_strings(["Turtle", "smAck", "wam3d"]) == "Turtle smAck wam3d"
@test append_strings(["Turtle", "smAck", "wam3d"], separator = "*3a") == "Turtle*3asmAck*3awam3d"
@test append_strings("Turtle") == "Turtle"
