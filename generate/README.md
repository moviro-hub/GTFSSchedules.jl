# GTFS Rule Generation

Generates Julia validation code from the official GTFS specification.

## Usage

```bash
# From the generate/ directory
julia --project=. main.jl
```

This downloads the GTFS specification, parses it, and generates validation rules in `../src/rules/`:
- `file_conditions.jl` - File-level validation rules
- `field_conditions.jl` - Field presence requirements
- `field_enum_values.jl` - Enum value validation
- `field_types.jl` - Field type mappings
- `field_id_references.jl` - Foreign key relationships
- `field_constraints.jl` - Field constraints
