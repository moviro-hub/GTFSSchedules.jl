"""
    generate_field_constraints(extracted_constraints::Vector{FileConstraints}) -> Vector{String}

Generate source code for field constraint validation rules:
- `const FIELD_CONSTRAINTS` with per-file field constraint information
"""
function generate_field_constraints(extracted_constraints::Vector{FileConstraints})
    lines = String[]
    # Header
    push!(lines, "# Auto-generated file - Field constraint validation rules")
    push!(lines, "# Generated from GTFS specification parsing")
    push!(lines, "")
    # Emit FIELD_CONSTRAINTS dictionary
    push!(lines, "# Compact rule set distilled from parsed field constraint information")
    push!(lines, "const FIELD_CONSTRAINTS = Dict(")

    for file_constraint_info in extracted_constraints
        filename = file_constraint_info.filename
        push!(lines, "    :$filename => [")

        for field_constraint_info in file_constraint_info.fields
            fieldname = field_constraint_info.fieldname
            constraint = field_constraint_info.constraint

            # Create field constraint entry
            push!(lines, "        (")
            field_sym = format_symbol(fieldname)
            push!(lines, "            field = $field_sym,")
            push!(lines, "            constraint = \"$constraint\",")
            push!(lines, "        ),")
        end

        push!(lines, "    ],")
    end

    push!(lines, ")")
    return lines
end
