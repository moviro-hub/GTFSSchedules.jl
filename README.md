# GTFSSchedules.jl

[Documentation](https://moviro-hub.github.io/GTFSSchedules.jl)

A Julia package for reading and validating GTFS (General Transit Feed Specification) schedule data.

GTFS is the standard format for public transit data used by Google Maps, transit apps, and planning tools. This package provides a Julia implementation for reading GTFS schedule data and validating them. The validation largely uses rules generated from the official [GTFS specification](https://gtfs.org/documentation/schedule/reference/). The generation pipeline is included in this repository, making it easy to update rules when the specification changes.

## Key Features

- **Complete GTFS Support**: Read GTFS schedule data from ZIP files and directories. The reader makes few assumptions about the data and therefore tolerates non‑conforming input.
- **Comprehensive Validation**: Built-in validation against official GTFS rules with detailed error reporting. Validation aims to cover all rules in the specification.

## Installation

```julia
using Pkg
Pkg.add(url="https://github.com/moviro-hub/GTFSSchedules.jl.git")
```

## Quick Start

```julia
using GTFSSchedules
using DataFrames

# Read GTFS schedule data from a ZIP file
gtfs = read_gtfs("./test/example/sample-feed-1.zip")

# Access data using DataFrames
println("Number of agencies: ", nrow(gtfs[:agency]))

# Validate the schedule data
result = GTFSSchedules.Validations.validate_gtfs(gtfs)
if !GTFSSchedules.Validations.has_validation_errors(result)
    println("✓ Schedule data is valid!")
else
    println("✗ Issues found: ", result.summary)
end

# Print one individual message
if length(result.messages) > 0
    println(result.messages[1].message)
else
    println("No errors found")
end
```

## License

This package is licensed under the MIT License. See LICENSE file for details.

## References

- [GTFS Schedule Specification](https://gtfs.org/documentation/schedule/reference/)
