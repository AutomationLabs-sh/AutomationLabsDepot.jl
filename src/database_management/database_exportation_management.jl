# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

### Management exportations local folder ###

# List exportations local folder
function list_exportation_local_folder_db(project_name)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(
        DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"),
    )
    if findall(x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        return false
    end

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # List value from table
    results = DBInterface.execute(
        con,
        "SELECT id, path, name, file_extension, added, size FROM $project_name.exportations;",
    )

    # Transform to DataFrame
    df = DuckDB.toDataFrame(results)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return df
end

# Remove exportations from folder and from the database
function remove_exportation_local_folder_db(project_name, exportation_name)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(
        DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"),
    )
    if findall(x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        return false
    end

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Delete the row from the data base
    DBInterface.execute(
        con,
        "DELETE FROM $project_name.exportations WHERE name = '$exportation_name';",
    )

    # Delete the exportation folder from the path
    rm(
        DEPOT_PATH[begin] *
        "/automationlabs" *
        "/" *
        "exportations" *
        "/" *
        exportation_name,
        recursive=true
    )

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return nothing
end

# Add exportation to local folder
function add_exportation_local_folder_db(
    project_name,
    exportation_name,
)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(
        DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"),
    )
    if findall(x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        return false
    end

    # Write the model
    path_file =
        DEPOT_PATH[begin] * "/automationlabs" * "/exportations/" * exportation_name 

    # Update the model table with the new data
    id = Random.randstring('a':'z', 6)

    # Get the size of the parquet file
    c_file_size = Base.format_bytes.(filesize.(path_file))

    # Get the time
    datenow = string(Dates.now())

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    DBInterface.execute(
        con,
        "INSERT INTO $project_name.exportations VALUES ('$id', 'automationlabs/exportations', '$exportation_name', 'folder', '$datenow', '$c_file_size');",
    )

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    # Add a check that everything is saved properly for the true flag

    return true
end