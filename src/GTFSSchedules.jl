"""
GTFSSchedules.jl - A Julia package for reading and validating GTFS Schedule data

This package provides functionality to read, validate, and work with GTFS (General Transit Feed Specification)
Schedule data in Julia. It supports the official GTFS Schedule specification and includes comprehensive
validation to ensure data compliance.

# Main Features

- Read GTFS feeds from ZIP files
- Comprehensive validation against GTFS specification

# Quick Start

```julia
using GTFSSchedules

# Read a GTFS feed
gtfs = read_gtfs("path/to/transit_feed.zip")

# Validate the feed
result = GTFSSchedules.Validations.validate_gtfs(gtfs)
if !GTFSSchedules.Validations.has_validation_errors(result)
    println("GTFS feed is valid!")
else
    println("Validation issues found:")
    println(result)
end

# Access data using DataFrames
println("Number of agencies: ", DataFrames.nrow(gtfs[:agency]))
println("Number of stops: ", DataFrames.nrow(gtfs[:stops]))
println("Number of routes: ", DataFrames.nrow(gtfs[:routes]))
```

# GTFS Specification

This package implements the official GTFS Schedule specification:
https://gtfs.org/documentation/schedule/reference/

# Package Structure

- `read_gtfs()`: Read GTFS feeds from ZIP files
- `validate_gtfs()`: Validate GTFS feeds against the specification
- `GTFSSchedule`: Main data structure containing all GTFS tables
- `ValidationResult`: Detailed validation results
"""
module GTFSSchedules

using DataFrames: DataFrames
using CSV: CSV
using GeoJSON: GeoJSON
using .Validations

const GTFSSchedule = Dict{Symbol, Union{DataFrames.DataFrame, Nothing}}

# Include submodules
include("gtfs_types.jl")
include("rules/field_types.jl")
include("rules/field_conditions.jl")
include("rules/file_conditions.jl")
include("rules/field_enum_values.jl")
include("rules/field_constraints.jl")
include("rules/field_id_references.jl")
include("reader.jl")
include("validation/Validations.jl")

# Export main types
export GTFSSchedule

# Export main functions
export read_gtfs

end
