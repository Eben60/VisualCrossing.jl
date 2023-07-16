using Test
using VisualCrossing

using VisualCrossing: get_api_key, data_file_path, savedata, get_station_id

@test length(get_api_key()) == 25
@test length(get_station_id()) == 5

fname = "test_data_file.txt"
f = data_file_path(fname)
if isfile(f)
    rm(f)
end

@test savedata(fname, "blableblu") == f
@test_throws ErrorException savedata(fname, "blableblu")
@test savedata(fname, "blableblublo", true) == f