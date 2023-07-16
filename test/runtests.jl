using Test
using VisualCrossing

using VisualCrossing: get_api_key

@test length(get_api_key()) == 25
