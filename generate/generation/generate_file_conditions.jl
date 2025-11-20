"""
    generate_file_conditions(parsed_files::Vector{FileRules}) -> Vector{String}

Generate the Julia source code for a file validator based on parsed file-level conditions.
"""
function generate_file_conditions(parsed_files::Vector{FileRules})
    lines = String[]
    # Header
    push!(lines, "# Auto-generated file - Generic file presence validator")
    push!(lines, "# Generated from GTFS specification parsing")
    push!(lines, "")
    # Emit FILE_RULES dictionary
    push!(lines, "# Compact rule set distilled from parsed file-level conditions")
    push!(lines, "const FILE_RULES = Dict(")
    for (i, pf) in enumerate(parsed_files)
        fname = pf.filename
        presence = pf.presence
        push!(lines, indent(":$fname => (", 1))
        push!(lines, indent("presence = \"$presence\",", 2))
        push!(lines, indent("relations = [", 2))
        for fr in pf.conditions
            # Serialize a FileRule
            required = fr.required
            forbidden = fr.forbidden
            push!(lines, indent("(", 3))
            push!(lines, indent("required = $(required), forbidden = $(forbidden), when_all = [", 4))
            for c in fr.when_all_conditions
                if isa(c, FileCondition)
                    push!(lines, indent("(type = :file, file = :$(c.file), must_exist = $(c.must_exist)),", 5))
                elseif isa(c, FileFieldCondition)
                    field_sym = format_symbol(c.field)
                    push!(lines, indent("(type = :field, file = :$(c.file), field = $field_sym, value = \"$(c.value)\"),", 5))
                else
                    # Unknown condition -> no-op true guard in evaluator
                    push!(lines, indent("(type = :unknown),", 5))
                end
            end
            push!(lines, indent("],", 4))
            push!(lines, indent("),", 3))
        end
        push!(lines, indent("],", 2))
        push!(lines, indent("),", 1))
    end
    push!(lines, ")")
    return lines
end
