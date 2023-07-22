module VisualCrossing

using Scratch, Dates, HTTP, DataFrames, JSON3, Glob, Missings

include("file_functions.jl")

function wquery(lastday=nothing, duration=nothing, station_id=nothing)
    if isnothing(duration) 
        duration = Day(1)
    else
        duration = Day(duration)
    end

    isnothing(lastday) && (lastday = Date(now()) - Day(1))
    firstday = lastday - duration
    station_id = get_station_id(station_id)

    api_key = get_api_key()

    query = "https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/$(station_id)/$(firstday)/$(lastday)?key=$(api_key)&include=days&elements=tempmax,tempmin,temp,datetime&unitGroup=metric"
    return query
end

export wquery

function getpage(url)
    r = HTTP.get(url; status_exception=false)
    ok = r.status == 200
    return (; ok, body=String(r.body))
end

function wfetch(fname="testfile.txt", lastday=nothing, duration=nothing; station_id=nothing, overwrite=false, save2file=true)
    # julia> Date("2023-05-15")+Day(124)
    # 2023-09-16
    
    fname == "testfile.txt" && (overwrite=true)
    qurl = wquery(lastday, duration, station_id)
    (; ok, body) = getpage(qurl)
    data = body
    datafile = nothing
    (ok & save2file) && (datafile = savedata(fname, data, overwrite))
    return (;ok, data, datafile)
end

function period_data(year=nothing, firstday=nothing, duration=nothing; station_id=1)
    (isnothing(year) == isnothing(firstday)) && error("you must specify either year or concrete date, and not both of them")
    (! isnothing(firstday) & isnothing(duration)) && error("if the starting date is not the default one, you must specify the duration")
    if ! isnothing(year) 
        duration = Day(123)
        firstday = Date(year, 5, 15)
    end

    lastday = Date(firstday) + Day(duration)       
    fname = "rec_$(firstday)_$(lastday)_station-$(station_id).json"
    return (;fname, lastday, duration, station_id)
end

function fetch_period(year=nothing, firstday=nothing, duration=nothing; station_id=1)
    (;fname, lastday, duration, station_id) = period_data(year, firstday, duration; station_id)
    wfetch(fname, lastday, duration; station_id)
end

function dayfromapril1st(d)
    y = year(d)
    april1st = dayofyear(Date(y, 4, 1))
    return dayofyear(d) - april1st # zero-indexing :)
end

export dayfromapril1st

function json2df(source, fromfile=true)
    if fromfile
        jsondata = open(source, "r") do file
            read(file)
        end
    else
        jsondata = source
    end
    # jsondata = String(jsondata)
    data = JSON3.read(jsondata).days
    df = DataFrame(data)
    miss4nothing!(df)
    transform!(df, :datetime => ByRow(Date) => :Date)
    transform!(df, :Date => ByRow(dayfromapril1st) => :DayFromApril1st, :Date => ByRow(year) => :Year)
    select!(df, :Date, :Year, :DayFromApril1st, Not(:datetime))
    return df
end

function json2df(; station_no=1)
    files = list_jsons(station_no)
    dfs = [json2df(f) for f in files]
    df = vcat(dfs...)
    unique!(df)
    return df
end

function fetch_years(lastyear, years=8)
    firstyear = lastyear - years + 1
    for y in firstyear:lastyear
        fetch_period(y; station_id=1)
    end
end

function span(d1::Date, d2::Date)
    day1 = dayfromapril1st(d1)
    day2 = dayfromapril1st(d2)
    return (; day1, day2)
end

span(d1::AbstractString, d2::AbstractString) = span(Date(d1), Date(d2))

span(d1::Nothing=nothing, d2::Nothing=nothing) = span("2015-05-15", "2015-09-15")

span(d1::Integer, d2::Integer) = (; day1=d1, day2=d2)

function filterspan(df, d1=nothing, d2=nothing)
    (; day1, day2) = span(d1, d2)
    return subset(df, :DayFromApril1st=> x -> day1 .<= x .<= day2)
end

function groupstat(df, fn, sourcecol=nothing, d1=nothing, d2=nothing)
    df = deepcopy(df)
    gdf = groupby(filterspan(df, d1, d2), :Year)
    cumstat = combine(gdf, sourcecol => fn => :cumstat)
    return cumstat
end

function miss4nothing!(df)
    for nm in names(df)
        df[!, nm] = replace(df[!, nm], nothing => missing)
    end
    return df
end

export wfetch, period_data, fetch_period, json2df, fetch_years, data_file_path, json2df, span, filterspan, groupstat, miss4nothing!

end # module VisualCrossing
