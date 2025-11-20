"""
    Generation

Module for generating Julia source files from extracted GTFS validation rules.

This module takes the extracted validation rules and type information from the
Extraction module and generates clean, type-safe Julia source files including:

- File-level and field-level condition validation rules
- Enum value validation with proper type mappings
- Field type definitions with GTFS type constants
- Foreign key relationship validation
- Field constraint validation (Unique, Non-negative, etc.)

The module provides a complete code generation pipeline that creates maintainable
Julia validation code from the GTFS specification.
"""
module Generation

# =============================================================================
# IMPORTS
# =============================================================================

using ..Extraction: FileRules, FileRule, FileCondition, FileFieldCondition, FieldRules, FieldRule, FieldCondition
using ..Extraction: FileEnums, FieldEnum, FileTypes, FieldType, FileForeigns, FieldForeign, ForeignReference
using ..Extraction: FileConstraints, FieldConstraint
using ..Ingestion: FileFields, Field

# =============================================================================
# EXPORTS
# =============================================================================

# Main generation functions
export write_file
export generate_file_conditions, generate_field_conditions, generate_field_enum_values
export generate_field_types, generate_field_id_references, generate_field_constraints

# Common utilities
export indent

# =============================================================================
# INCLUDES
# =============================================================================

include("generate_file_conditions.jl")
include("generate_field_conditions.jl")
include("generate_field_enum_values.jl")
include("generate_field_types.jl")
include("generate_field_id_references.jl")
include("generate_field_constraints.jl")

# =============================================================================
# COMMON GENERATION UTILITIES
# =============================================================================

"""
    indent(line::String, level::Int=1) -> String

Indent a line by the specified number of levels (4 spaces per level).
"""
function indent(line::String, level::Int = 1)
    if isempty(line)
        return line
    end

    indent = "    "^level
    return indent * line
end

"""
    indents(lines::Vector{String}, level::Int=1) -> Vector{String}

Indent multiple lines by the specified number of levels.
"""
function indents(lines::Vector{String}, level::Int = 1)
    return [indent(line, level) for line in lines]
end

"""
    format_symbol(identifier) -> String

Render a value as a Julia symbol literal without introducing extra
whitespace, while still supporting dotted identifiers via the `:(...)`
syntax.
"""
function format_symbol(identifier)
    name = String(identifier)
    return occursin(".", name) ? ":($(name))" : ":$(name)"
end

"""
    format_julia_struct(struct_name::String, fields::Vector{String}) -> Vector{String}

Format a Julia struct definition.
"""
function format_struct(struct_name::String, fields::Vector{String})
    lines = String[]
    push!(lines, "struct $struct_name")

    for field in fields
        push!(lines, indent(field))
    end

    push!(lines, "end")
    return lines
end

"""
    format_julia_array(array_name::String, elements::Vector{String}, element_type::String="") -> Vector{String}

Format a Julia array definition.
"""
function format_array(array_name::String, elements::Vector{String}, element_type::String = "")
    lines = String[]

    if isempty(element_type)
        array_def = "const $array_name = ["
    else
        array_def = "const $array_name::Vector{$element_type} = ["
    end

    push!(lines, array_def)

    for (i, element) in enumerate(elements)
        if i == length(elements)
            push!(lines, indent(element))
        else
            push!(lines, indent(element * ","))
        end
    end

    push!(lines, "]")
    return lines
end

# =============================================================================
# FILE OPERATIONS
# =============================================================================

"""
    write_source_file(file::String, lines::Vector{String})

Write the generated source file to the specified path.
"""
function write_file(file::String, lines::Vector{String})
    if isempty(file)
        error("File path cannot be empty")
    end

    if isempty(lines)
        error("Cannot write empty source file")
    end

    # Create output directory if it doesn't exist
    output_dir = dirname(file)
    if !isdir(output_dir)
        mkpath(output_dir)
    end

    # Write file
    return open(file, "w") do io
        for line in lines
            println(io, line)
        end
    end
end

end
