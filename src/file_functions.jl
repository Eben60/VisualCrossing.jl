const SCRATCH_DATA_DIR = "user_data"
const SCRATCH_API_DIR = "api"
const API_KEY_FILE = "api_key.txt"
const STATION_ID_FILE = "station_id.txt"

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

function get_station_id()
    d = @get_scratch!(SCRATCH_API_DIR)
    f = joinpath(d, STATION_ID_FILE)
    key = open(f, "r") do file
        key = readline(file)
    end
    return key
end

data_file_path(fname) = joinpath(@get_scratch!(SCRATCH_DATA_DIR), fname)
 
function savedata(fname, data, overwrite=false)
    f = data_file_path(fname)
    (! overwrite & isfile(f)) && error("File $f already exists")
    open(f, "w") do file
        write(file, data)
    end
    return f
end

function readdata(fname="testfile.txt")
    f = data_file_path(fname)
    data = open(f, "r") do file
        read(file)
    end
    return String(data)
end
export readdata
