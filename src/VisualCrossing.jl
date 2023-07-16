module VisualCrossing

using Scratch, Dates, HTTP

include("file_functions.jl")

function wquery(lastday=nothing, duration=nothing, station_id=nothing)
    if isnothing(duration) 
        duration = Dates.Day(1)
    else
        duration = Dates.Day(duration)
    end

    isnothing(lastday) && (lastday = Date(now()) - Dates.Day(1))
    firstday = lastday - duration
    isnothing(station_id) && (station_id = get_station_id())

    api_key = get_api_key()

    query = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$(station_id)/$(firstday)/$(lastday)?key=$(api_key)&include=days&elements=tempmax,tempmin,temp&unitGroup=metric"
    return query
end

export wquery

function getpage(url)
    r = HTTP.get(url; status_exception=false)
    ok = r.status == 200
    if ok
        body = String(r.body)
    else
        body = ""
    end
    return (; ok, body)
end

function wfetch(fname="testfile.txt", lastday=nothing, duration=nothing, station_id=nothing; overwrite=false, save2file=true)
    fname == "testfile.txt" && (overwrite=true)
    qurl = wquery(lastday, duration, station_id)
    (; ok, body) = getpage(qurl)

    if ok
        data = body
        if save2file 
            datafile = savedata(fname, data, overwrite)

        end
    else
        data = datafile = nothing
    end

    return (;ok, data, datafile)
end

export wfetch

end # module VisualCrossing
