# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

import DataFrames.DataFrame
import DuckDB.DBInterface

const DEFAUT_FOLDER_TEMPLATE = [
    "database",
    "iodata",
    "rawdata",
    "models",
    "controllers",
    "exports",
    "dashboards",
    "systems",
]

### Management local project ###

# Create project folder
function project_folder_create_db(project_name)

    #evaluate if the local folder exists
    if isdir(DEPOT_PATH[begin] * "/automationlabs") == false
        mkdir(DEPOT_PATH[begin] * "/automationlabs")

        # Create the defaults folders 
        for i = 1:1:length(DEFAUT_FOLDER_TEMPLATE)
            mkdir(DEPOT_PATH[begin] * "/automationlabs/" * DEFAUT_FOLDER_TEMPLATE[i])
        end
    end

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Create the schema
    DBInterface.execute(con, "CREATE SCHEMA IF NOT EXISTS $(project_name);")

    # Create the tables
    # Create the iodata table
    DBInterface.execute(
        con,
        "CREATE TABLE IF NOT EXISTS $(project_name).iodata
                           (
                               id VARCHAR(100) PRIMARY KEY NOT NULL,
                               path VARCHAR(100), 
                               name  VARCHAR(100),
                               file_extension VARCHAR(100),
                               added VARCHAR(100),
                               size VARCHAR(100),
                           );",
    )

    # Create the rawdata table
    DBInterface.execute(
        con,
        "CREATE TABLE IF NOT EXISTS $(project_name).rawdata
                           (
                               id VARCHAR(100) PRIMARY KEY NOT NULL,
                               path VARCHAR(100), 
                               name  VARCHAR(100),
                               file_extension VARCHAR(100),
                               added VARCHAR(100),
                               size VARCHAR(100),
                           );",
    )

    # Create the models table
    DBInterface.execute(
        con,
        "CREATE TABLE IF NOT EXISTS $(project_name).models
                           (
                               id VARCHAR(100) PRIMARY KEY NOT NULL,
                               path VARCHAR(100), 
                               name  VARCHAR(100),
                               file_extension VARCHAR(100),
                               added VARCHAR(100),
                               size VARCHAR(100),
                           );",
    )

    # Create the controllers table
    DBInterface.execute(
        con,
        "CREATE TABLE IF NOT EXISTS $(project_name).controllers
                           (
                               id VARCHAR(100) PRIMARY KEY NOT NULL,
                               path VARCHAR(100), 
                               name  VARCHAR(100),
                               file_extension VARCHAR(100),
                               added VARCHAR(100),
                               size VARCHAR(100),
                           );",
    )

    # Create the exports table
    DBInterface.execute(
        con,
        "CREATE TABLE IF NOT EXISTS $(project_name).exports
                           (
                               id VARCHAR(100) PRIMARY KEY NOT NULL,
                               path VARCHAR(100), 
                               name  VARCHAR(100),
                               file_extension VARCHAR(100),
                               added VARCHAR(100),
                               size VARCHAR(100),
                           );",
    )

    # Create the dashboards table
    DBInterface.execute(
        con,
        "CREATE TABLE IF NOT EXISTS $(project_name).dashboards
                           (
                               id VARCHAR(100) PRIMARY KEY NOT NULL,
                               path VARCHAR(100), 
                               name  VARCHAR(100),
                               file_extension VARCHAR(100),
                               added VARCHAR(100),
                               size VARCHAR(100),
                           );",
    )

    # Create the dashboards table
    DBInterface.execute(
        con,
        "CREATE TABLE IF NOT EXISTS $(project_name).systems
                           (
                               id VARCHAR(100) PRIMARY KEY NOT NULL,
                               path VARCHAR(100), 
                               name  VARCHAR(100),
                               file_extension VARCHAR(100),
                               added VARCHAR(100),
                               size VARCHAR(100),
                           );",
    )

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return true
end

# List project on automationlabs folder
function list_project_local_folder_db()

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Information schema
    results = DBInterface.execute(con, "SELECT * FROM information_schema.tables;")

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    # list schema
    schema_list = []
    for row in results
        push!(schema_list, row.table_schema)
    end

    return unique!(schema_list)
end

# Remove project and all files related
function remove_project_local_folder_db(project_name)

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

    # Remove the raw data databse and the files on depot folder
    dfraw = list_rawdata_local_folder_db(project_name)
    for i = 1:1:size(dfraw, 1)
        raw_name = dfraw[!, :name][i]
        remove_rawdata_local_folder_db(project_name, raw_name)
    end

    # Remove the io data databse and the files on depot folder
    dfio = list_iodata_local_folder_db(project_name)
    for i = 1:1:size(dfio, 1)
        io_name = dfio[!, :name][i]
        remove_iodata_local_folder_db(project_name, io_name)
    end

    # Remove the models files
    dfmodels = list_model_local_folder_db(project_name)
    for i = 1:1:size(dfmodels, 1)
        model_name = dfmodels[!, :name][i]
        remove_model_local_folder_db(project_name, model_name)
    end

    # Remove the controllers files
    # to do

    # Remove the dashboards
    dfdash = list_dash_local_folder_db(project_name)
    for i = 1:1:size(dfdash, 1)
        dash_name = dfdash[!, :name][i]
        remove_dash_local_folder_db(project_name, dash_name)
    end

    # Remove the whole schema from the database
    stg = "DROP SCHEMA IF EXISTS " * project_name * " CASCADE;"
    DBInterface.execute(con, stg)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return true
end
