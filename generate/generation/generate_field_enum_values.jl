"""
    generate_field_enum_values(extracted_enums::Vector{FileEnums}) -> Vector{String}

Generate source code for enum validation rules:
- `const ENUM_RULES` with per-file enum validation rules
"""
function generate_field_enum_values(extracted_enums::Vector{FileEnums})
    lines = String[]
    # Header
    push!(lines, "# Auto-generated file - Generic enum validation rules")
    push!(lines, "# Generated from GTFS specification parsing")
    push!(lines, "")
    # Emit ENUM_RULES dictionary
    push!(lines, "# Compact rule set distilled from parsed enum field definitions")
    push!(lines, "const ENUM_RULES = Dict(")
    for file_enum_info in extracted_enums
        push!(lines, "    :$(file_enum_info.filename) => [")
        for enum_field in file_enum_info.fields
            push!(lines, "        (")
            field_sym = format_symbol(enum_field.field)
            push!(lines, "            field = $field_sym,")
            push!(lines, "            enum_values = [")
            for enum_val in enum_field.enum_values
                # Escape quotes in description
                escaped_desc = replace(enum_val.description, "\"" => "\\\"")
                # Convert string value back to integer for generation
                int_value = tryparse(Int, enum_val.value)
                if int_value === nothing
                    # If not a valid integer, keep as string (fallback)
                    push!(lines, "                (value = \"$(enum_val.value)\", description = \"$escaped_desc\"),")
                else
                    push!(lines, "                (value = $int_value, description = \"$escaped_desc\"),")
                end
            end
            push!(lines, "            ],")
            push!(lines, "            allow_empty = $(enum_field.allow_empty),")
            if enum_field.empty_maps_to !== nothing
                # Convert string value back to integer for generation
                int_value = tryparse(Int, enum_field.empty_maps_to)
                if int_value === nothing
                    # If not a valid integer, keep as string (fallback)
                    push!(lines, "            empty_maps_to = \"$(enum_field.empty_maps_to)\",")
                else
                    push!(lines, "            empty_maps_to = $int_value,")
                end
            else
                push!(lines, "            empty_maps_to = nothing,")
            end
            push!(lines, "        ),")
        end
        push!(lines, "    ],")
    end
    push!(lines, ")")
    return lines
end
