# API Reference

API documentation for GTFSSchedules.jl functions and types.

## Main Functions

```@docs
GTFSSchedules.read_gtfs
```
## Main Type

`GTFSSchedule` is a type alias for `Dict{Symbol, Union{DataFrames.DataFrame, Nothing}}` that stores GTFS data tables.

## Validation Functions

```@docs
GTFSSchedules.Validations.validate_gtfs
GTFSSchedules.Validations.print_validation_results
GTFSSchedules.Validations.has_validation_errors
```

## Types

```@docs
GTFSSchedules.Validations.ValidationResult
GTFSSchedules.Validations.ValidationMessage
```
