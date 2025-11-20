"""
    generate_field_conditions(parsed_fields::Vector{FieldRules}) -> String

Generate source code for field validation rules:
- `const FIELD_RULES` with per-file field rules
"""
function generate_field_conditions(parsed_fields::Vector{FieldRules})
    lines = String[]
    # Header
    push!(lines, "# Auto-generated file - Generic field presence validator")
    push!(lines, "# Generated from GTFS specification parsing")
    push!(lines, "")
    # Emit FIELD_RULES dictionary
    push!(lines, "# Compact rule set distilled from parsed field-level conditions")
    push!(lines, "const FIELD_RULES = Dict(")
    for pf in parsed_fields
        fname = pf.filename
        push!(lines, indent(":$fname => [", 1))
        for fr in pf.fields
            # Each entry: field, presence, required, forbidden, conditions
            push!(lines, indent("(", 2))
            field_sym = format_symbol(fr.field)
            push!(lines, indent("field = $field_sym,", 3))
            push!(lines, indent("presence = \"$(fr.presence)\",", 3))
            push!(lines, indent("required = $(fr.required),", 3))
            push!(lines, indent("forbidden = $(fr.forbidden),", 3))
            push!(lines, indent("conditions = [", 3))
            for c in fr.when_all_conditions
                cond_field_sym = format_symbol(c.field)
                push!(lines, indent("(type = :field, file = :$(c.file), field = $cond_field_sym, value = \"$(c.value)\"),", 4))
            end
            push!(lines, indent("],", 3))
            push!(lines, indent("),", 2))
        end
        push!(lines, indent("],", 1))
    end
    push!(lines, ")")
    return lines
end
