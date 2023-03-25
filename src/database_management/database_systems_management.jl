# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

### Management systems local folder ###

# List systems local folder
function list_system_local_folder_db(project_name::String)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(
        DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"),
    )
    if findall(x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        #return a null DataFrames
        df = DataFrames.DataFrame(
            id = Int[],
            path = Int[],
            name = Int[],
            file_extension = Int[],
            added = Int[],
            size = Int[],
        )
        return df
    end

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # List value from table
    results = DBInterface.execute(
        con,
        "SELECT id, path, name, file_extension, added, size FROM $project_name.systems;",
    )

    # Transform to DataFrame
    df = DuckDB.toDataFrame(results)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return df
end

# Remove system from folder and line from database duckdb
function remove_system_local_folder_db(project_name, system_name)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Delete the row from the data base
    DBInterface.execute(
        con,
        "DELETE FROM $project_name.systems WHERE name = '$system_name';",
    )

    # Delete the file from the path
    rm(DEPOT_PATH[begin] * "/automationlabs" * "/" * "systems" * "/" * system_name * ".jld")

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return nothing
end

# Add system to local folder
function add_system_local_folder_db(system, project_name, system_name)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Write the model
    path_file = DEPOT_PATH[begin] * "/automationlabs" * "/systems/" * system_name * ".jld"
    JLD.save(path_file, "system", system)
    #JLD.save(path_file, "controller_parameters", Dict(pairs(controller_parameters)) )

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
        "INSERT INTO $project_name.systems VALUES ('$id', 'automationlabs/systems', '$system_name', '.jld', '$datenow', '$c_file_size');",
    )

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return nothing
end

# load controller from local folder
function load_system_local_folder_db(project_name, system_name)

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

    # Evaluate if the controller is in the database
    c_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.systems WHERE name = '$system_name';",
        ),
    )
    if size(c_list, 1) == 0
        @warn "The controller is not present in the database"
        return false
    end

    # load the controller parameters
    path_file = DEPOT_PATH[begin] * "/automationlabs" * "/systems/" * system_name * ".jld"
    system_p = JLD.load(path_file)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return system_p
end
