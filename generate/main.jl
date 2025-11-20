#!/usr/bin/env julia

using JSON: JSON
include("RuleGenerations.jl")
using .RuleGenerations: RuleGenerations

# Pipeline step names
const STEP_DOWNLOAD = "Downloading GTFS reference"
const STEP_INGESTION = "Ingestion GTFS reference"
const STEP_EXTRACTION = "Extraction rules and conditions"
const STEP_GENERATION = "Generating validation types"

"""
    write_json_artifact(filepath::String, data::Any)

Write data to JSON file with pretty formatting.
"""
function write_json_artifact(filepath::String, data::Any)
    return open(filepath, "w") do io
        JSON.print(io, data, 2)
    end
end

"""
    create_temp_dir() -> String

Create temporary directory for intermediate artifacts.
"""
function create_temp_dir()
    tmp_dir = mkpath(joinpath(@__DIR__, "tmp"))
    @assert isdir(tmp_dir) "Failed to create temporary directory: $tmp_dir"
    return tmp_dir
end

"""
    download_spec() -> String

Download GTFS specification and return file path.
"""
function download_spec()
    println("Step 1: $STEP_DOWNLOAD...")
    spec_file = RuleGenerations.Download.download_gtfs_spec_to_dir(".")
    @assert isfile(spec_file) "Downloaded specification file not found: $spec_file"
    println("✓ Downloaded")
    println()
    return spec_file
end

"""
    ingest_specification(spec_file::String, tmp_dir::String)

Parse markdown specification into structured data.
"""
function ingest_specification(spec_file::String, tmp_dir::String)
    println("Step 2: $STEP_INGESTION...")
    markdown_content = read(spec_file, String)
    @assert !isempty(markdown_content) "Downloaded specification file is empty: $spec_file"
    lines = String.(split(markdown_content, '\n'))
    @assert !isempty(lines) "Failed to split markdown content into lines"

    ingested_presence = RuleGenerations.Ingestion.parse_presence_types(lines)
    @assert !isempty(ingested_presence) "No presence keywords found"
    write_json_artifact(joinpath(tmp_dir, "ingested_presence.json"), ingested_presence)

    ingested_dataset_files = RuleGenerations.Ingestion.parse_dataset_files(lines, ingested_presence)
    @assert !isempty(ingested_dataset_files) "No dataset files found in specification"
    write_json_artifact(joinpath(tmp_dir, "ingested_dataset_files.json"), ingested_dataset_files)

    ingested_file_definitions = RuleGenerations.Ingestion.parse_field_definitions(lines)
    @assert !isempty(ingested_file_definitions) "No file definitions found in specification"
    write_json_artifact(joinpath(tmp_dir, "ingested_file_definitions.json"), ingested_file_definitions)

    ingested_field_types = RuleGenerations.Ingestion.parse_field_types(lines)
    @assert !isempty(ingested_field_types) "No field types found in specification"
    write_json_artifact(joinpath(tmp_dir, "ingested_field_types.json"), ingested_field_types)

    ingested_field_signs = RuleGenerations.Ingestion.parse_field_signs(lines)
    @assert !isempty(ingested_field_signs) "No field signs found in specification"
    write_json_artifact(joinpath(tmp_dir, "ingested_field_signs.json"), ingested_field_signs)
    println("✓ Ingested")
    println()

    return (
        ingested_presence, ingested_dataset_files, ingested_file_definitions,
        ingested_field_types, ingested_field_signs,
    )
end

"""
    extract_rules(ingested_data, tmp_dir::String)

Extract validation rules from ingested data.
"""
function extract_rules(ingested_data, tmp_dir::String)
    println("Step 3: $STEP_EXTRACTION...")
    ingested_presence, ingested_dataset_files, ingested_file_definitions,
        ingested_field_types, ingested_field_signs = ingested_data

    extracted_file_conditions = RuleGenerations.Extraction.extract_all_file_conditions(
        ingested_dataset_files, ingested_file_definitions, ingested_presence
    )
    @assert !isempty(extracted_file_conditions) "No file conditions extracted"
    write_json_artifact(joinpath(tmp_dir, "extracted_file_conditions.json"), extracted_file_conditions)

    extracted_field_conditions = RuleGenerations.Extraction.extract_all_field_conditions(
        ingested_file_definitions, ingested_presence
    )
    @assert !isempty(extracted_field_conditions) "No field conditions extracted"
    write_json_artifact(joinpath(tmp_dir, "extracted_field_conditions.json"), extracted_field_conditions)

    extracted_field_enum_values = RuleGenerations.Extraction.extract_all_field_enum_values(
        ingested_file_definitions
    )
    @assert !isempty(extracted_field_enum_values) "No field enum values extracted"
    write_json_artifact(joinpath(tmp_dir, "extracted_field_enum_values.json"), extracted_field_enum_values)

    extracted_field_types = RuleGenerations.Extraction.extract_all_field_types(
        ingested_file_definitions, ingested_field_types, ingested_field_signs
    )
    @assert !isempty(extracted_field_types) "No field types extracted"
    write_json_artifact(joinpath(tmp_dir, "extracted_field_types.json"), extracted_field_types)

    extracted_field_id_references = RuleGenerations.Extraction.extract_all_field_id_references(
        ingested_file_definitions
    )
    @assert !isempty(extracted_field_id_references) "No field ID references extracted"
    write_json_artifact(joinpath(tmp_dir, "extracted_field_id_references.json"), extracted_field_id_references)

    extracted_field_constraints = RuleGenerations.Extraction.extract_all_field_constraints(
        ingested_file_definitions, ingested_field_signs
    )
    @assert !isempty(extracted_field_constraints) "No field constraints extracted"
    write_json_artifact(joinpath(tmp_dir, "extracted_field_constraints.json"), extracted_field_constraints)
    println("✓ Extracted")
    println()

    return (
        extracted_file_conditions, extracted_field_conditions, extracted_field_enum_values,
        extracted_field_types, extracted_field_id_references, extracted_field_constraints,
    )
end

"""
    generate_source_files(extracted_data)

Generate Julia source files from extracted rules.
"""
function generate_source_files(extracted_data)
    println("Step 4: $STEP_GENERATION...")
    extracted_file_conditions, extracted_field_conditions, extracted_field_enum_values,
        extracted_field_types, extracted_field_id_references, extracted_field_constraints = extracted_data

    generated_file_conditions = RuleGenerations.Generation.generate_file_conditions(extracted_file_conditions)
    @assert !isempty(generated_file_conditions) "Failed to generate file conditions"
    RuleGenerations.Generation.write_file("../src/rules/file_conditions.jl", generated_file_conditions)

    generated_field_conditions = RuleGenerations.Generation.generate_field_conditions(extracted_field_conditions)
    @assert !isempty(generated_field_conditions) "Failed to generate field conditions"
    RuleGenerations.Generation.write_file("../src/rules/field_conditions.jl", generated_field_conditions)

    generated_field_enum_values = RuleGenerations.Generation.generate_field_enum_values(extracted_field_enum_values)
    @assert !isempty(generated_field_enum_values) "Failed to generate field enum values"
    RuleGenerations.Generation.write_file("../src/rules/field_enum_values.jl", generated_field_enum_values)

    generated_field_types = RuleGenerations.Generation.generate_field_types(extracted_field_types)
    @assert !isempty(generated_field_types) "Failed to generate field types"
    RuleGenerations.Generation.write_file("../src/rules/field_types.jl", generated_field_types)

    generated_field_id_references = RuleGenerations.Generation.generate_field_id_references(extracted_field_id_references)
    @assert !isempty(generated_field_id_references) "Failed to generate field ID references"
    RuleGenerations.Generation.write_file("../src/rules/field_id_references.jl", generated_field_id_references)

    generated_field_constraints = RuleGenerations.Generation.generate_field_constraints(extracted_field_constraints)
    @assert !isempty(generated_field_constraints) "Failed to generate field constraints"
    RuleGenerations.Generation.write_file("../src/rules/field_constraints.jl", generated_field_constraints)
    println("✓ Generated")
    return println()
end

function main()
    println("=== GTFS Specification Parser ===")
    println("Downloading and parsing the official Google Transit GTFS specification...")
    println()

    try
        tmp_dir = create_temp_dir()
        spec_file = download_spec()
        ingested_data = ingest_specification(spec_file, tmp_dir)
        extracted_data = extract_rules(ingested_data, tmp_dir)
        generate_source_files(extracted_data)
        println("✓ All steps completed successfully")
        return nothing
    catch e
        println("✗ Error occurred during GTFS specification processing:")
        println("   Error: $e")
        println("   Stack trace:")
        for (exc, bt) in Base.catch_stack()
            showerror(stdout, exc, bt)
            println()
        end
        println("   Please check the error details above and try again.")
        rethrow(e)
    end
end

# Run the main function if this script is executed directly
if abspath(PROGRAM_FILE) == @__FILE__
    cd(@__DIR__)
    main()
end
