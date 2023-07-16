module VisualCrossing
using Scratch

const SCRATCH_DATA_DIR = "user_data"
const SCRATCH_API_DIR = "api"
const API_KEY_FILE = "api_key.txt"

function write_api_key(key)
    d = @get_scratch!(SCRATCH_API_DIR)
    f = joinpath(d, API_KEY_FILE)
    open(f, "w") do file
        write(file, "$(key)\n")
    end
    return f
end

export write_api_key

function get_api_key()
    d = @get_scratch!(SCRATCH_API_DIR)
    f = joinpath(d, API_KEY_FILE)
    key = open(f, "r") do file
        key = readline(file)
    end
    return key
end



end # module VisualCrossing
