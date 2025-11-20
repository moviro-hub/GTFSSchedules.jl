"""
    create_type_map(extracted_types::Vector{FileTypes}) -> Dict{String,String}

Create a dynamic mapping from extracted type names to GTFS type constants using rule-based logic.
"""
function create_type_map(extracted_types::Vector{FileTypes})
    # Collect all unique type names
    all_types = Set{String}()
    for file_types in extracted_types
        for field_type in file_types.fields
            push!(all_types, field_type.primary_type)
            for alt_type in field_type.alternative_types
                push!(all_types, alt_type)
            end
        end
    end

    type_map = Dict{String, String}()
    for type_name in all_types
        # Convert type name to GTFS constant format
        words = split(type_name, r"\s+")
        capitalized_words = uppercasefirst.(words)
        gtfs_type = join(capitalized_words, "")
        type_map[type_name] = gtfs_type
    end

    return type_map
end

"""
    map_to_gtfs_type(type_name::String, type_map::Dict{String,String}) -> String

Map extracted type names to GTFS type constants using dynamic mapping.
"""
function map_to_gtfs_type(type_name::String, type_map::Dict{String, String})
    if haskey(type_map, type_name)
        return type_map[type_name]
    else
        # Warning for unmapped types and fallback to GTFSText
        @warn "No GTFS type mapping found for '$type_name', using GTFSText as fallback"
        return "GTFSText"
    end
end

"""
    generate_field_types(extracted_types::Vector{FileTypes}) -> Vector{String}

Generate source code for field type validation rules:
- `const FIELD_TYPES` with per-file field type information
"""
function generate_field_types(extracted_types::Vector{FileTypes})
    lines = String[]
    # Header
    push!(lines, "# Auto-generated file - Field type validation rules")
    push!(lines, "# Generated from GTFS specification parsing")
    push!(lines, "")

    # Create dynamic type mapping from input data
    type_map = create_type_map(extracted_types)

    # Emit FIELD_TYPES dictionary
    push!(lines, "# Compact rule set distilled from parsed field type information")
    push!(lines, "const FIELD_TYPES = Dict(")

    for file_type_info in extracted_types
        filename = file_type_info.filename
        push!(lines, indent(":$filename => [", 1))

        for field_type_info in file_type_info.fields
            fieldname = field_type_info.fieldname
            primary_type = field_type_info.primary_type
            alternative_types = field_type_info.alternative_types

            # Map types to GTFS type constants using dynamic mapping
            primary_gtfs_type = map_to_gtfs_type(primary_type, type_map)
            alternative_gtfs_types = [map_to_gtfs_type(alt_type, type_map) for alt_type in alternative_types]

            # Create field type entry
            push!(lines, "        (")
            field_sym = format_symbol(fieldname)
            push!(lines, "            field = $field_sym,")
            push!(lines, "            gtfs_type = :$primary_gtfs_type,")

            if !isempty(alternative_gtfs_types)
                push!(lines, "            alternative_types = [")
                for alt_gtfs_type in alternative_gtfs_types
                    push!(lines, "                :$alt_gtfs_type,")
                end
                push!(lines, "            ],")
            else
                push!(lines, "            alternative_types = [],")
            end

            push!(lines, "        ),")
        end

        push!(lines, indent("],", 1))
    end

    push!(lines, ")")
    return lines
end
