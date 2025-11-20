"""
    generate_field_id_references(extracted_references::Vector{FileForeigns}) -> Vector{String}

Generate source code for field ID reference validation rules:
- `const FIELD_ID_REFERENCES` with per-file field ID reference information
"""
function generate_field_id_references(extracted_references::Vector{FileForeigns})
    lines = String[]
    # Header
    push!(lines, "# Auto-generated file - Field ID reference validation rules")
    push!(lines, "# Generated from GTFS specification parsing")
    push!(lines, "")
    # Emit FIELD_ID_REFERENCES dictionary
    push!(lines, "# Compact rule set distilled from parsed field ID reference information")
    push!(lines, "const FIELD_ID_REFERENCES = Dict(")

    for file_foreign_info in extracted_references
        filename = file_foreign_info.filename
        push!(lines, "    :$filename => [")

        for field_foreign_info in file_foreign_info.fields
            fieldname = field_foreign_info.fieldname
            references = field_foreign_info.references
            is_conditional = field_foreign_info.is_conditional

            # Create field reference entry
            push!(lines, "        (")
            field_sym = format_symbol(fieldname)
            push!(lines, "            field = $field_sym,")
            push!(lines, "            references = [")

            for ref in references
                push!(lines, "                (")
                push!(lines, "                    table = :$(ref.table),")
                ref_field_sym = format_symbol(ref.field)
                push!(lines, "                    field = $ref_field_sym,")
                push!(lines, "                ),")
            end

            push!(lines, "            ],")
            push!(lines, "            is_conditional = $is_conditional,")
            push!(lines, "        ),")
        end

        push!(lines, "    ],")
    end

    push!(lines, ")")
    return lines
end
