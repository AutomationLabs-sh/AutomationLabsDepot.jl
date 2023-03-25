# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

### Management local data ###

# Add rawdata to local folder
function add_rawdata_local_folder_db(
    project_name::String,
    data_path::String,
    raw_name::String,
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

    # Evaluate if the rawfiles are in the database
    raw_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.rawdata WHERE name = '$raw_name';",
        ),
    )
    if size(raw_list, 1) != 0
        @warn "there is an equivalent raw data name"
        return false
    end

    # Store data into local depot folder
    path_name_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/rawdata/" * raw_name * ".parquet"

    # Evaluate if the files are in the depot folder
    if isfile(path_name_parquet_file) == true
        @warn "there is an equivalent raw data name"
        return false
    end

    # Set the path from the file
    data_load_path = data_path * "/" * raw_name * ".csv"

    # Evaluate if the file exists
    if isfile(data_load_path) == false
        @warn "the file does not exist"
        return false
    end

    # Load the files from local hdd
    dfout = DataFrames.DataFrame(CSV.File(data_load_path))

    # Write the parquet file
    Parquet2.writefile(path_name_parquet_file, dfout; compression_codec = :gzip)

    # Random id creation
    id = Random.randstring('a':'z', 6)

    # Get the time
    datenow = string(Dates.now())

    # Get the size of the parquet file
    parquet_file_size = Base.format_bytes.(filesize.(path_name_parquet_file))

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Update the database
    DBInterface.execute(
        con,
        "INSERT INTO $project_name.rawdata VALUES ('$id', 'automationlabs/raw_data', '$raw_name', '.parquet', '$datenow', '$parquet_file_size');",
    )

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return true
end

# Add iodata to local folder
function add_iodata_local_folder_db(
    dfin::DataFrames.DataFrame,
    dfout::DataFrames.DataFrame,
    project_name::String,
    io_name::String,
)

    # Update the io data table with the new data

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

    # Evaluate if the iofiles are in the database
    io_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.iodata WHERE name = '$io_name';",
        ),
    )
    if size(io_list, 1) != 0
        @warn "There is an equivalent io data name in the database"
        return false
    end

    # Load path data into local depot folder
    path_dfinname_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfin_" * io_name * ".parquet"
    path_dfoutname_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfout_" * io_name * ".parquet"

    # Evaluate if the files are in the depot folder
    if isfile(path_dfinname_parquet_file) == true ||
       isfile(path_dfoutname_parquet_file) == true
        @warn "there is an equivalent io data name in the folder"
        return false
    end

    # Write the parquet file
    Parquet2.writefile(path_dfinname_parquet_file, dfin; compression_codec = :gzip)

    Parquet2.writefile(path_dfoutname_parquet_file, dfout; compression_codec = :gzip)

    # Random id creation
    id = Random.randstring('a':'z', 6)

    # Get the time
    datenow = string(Dates.now())

    # Get the size of the parquet file
    parquet_file_size =
        Base.format_bytes.(
            filesize.(path_dfinname_parquet_file) + filesize.(path_dfoutname_parquet_file)
        )

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Update the DuckDB database
    DBInterface.execute(
        con,
        "INSERT INTO $project_name.iodata VALUES ('$id', 'automationlabs/io_data', '$io_name', '.parquet', '$datenow', '$parquet_file_size');",
    )
  
    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return true
end

# List data from local folder from dedicated project
function list_rawdata_local_folder_db(project_name::String)

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

    # List value from table
    results = DBInterface.execute(
        con,
        "SELECT id, path, name, file_extension, added, size FROM $project_name.rawdata;",
    )

    # Transform to DataFrame
    df = DuckDB.toDataFrame(results)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return df
end

# List data from local folder from dedicated project
function list_iodata_local_folder_db(project_name::String)

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

    # List value from table
    results = DBInterface.execute(
        con,
        "SELECT id, path, name, file_extension, added, size FROM $project_name.iodata;",
    )

    # Transform to DataFrame
    df = DuckDB.toDataFrame(results)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return df
end

# Remove data from folder and line from database duckdb
function remove_rawdata_local_folder_db(project_name::String, raw_name::String)

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

    # Evaluate if the rawfiles are in the database
    raw_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.rawdata WHERE name = '$raw_name';",
        ),
    )
    if size(raw_list, 1) == 0
        @warn "unrecognized raw data name"
        return false
    end

    # Load path data into local depot folder
    path_df_name_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/rawdata/" * raw_name * ".parquet"

    # Evaluate if the files are in the depot folder
    if isfile(path_df_name_parquet_file) == false
        @warn "unrecognized raw data in depot folder"
        return false
    end

    # Delete the row from the data base
    DBInterface.execute(con, "DELETE FROM $project_name.rawdata WHERE name = '$raw_name';")

    # Delete the file from the path
    rm(path_df_name_parquet_file)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return true
end

function remove_iodata_local_folder_db(project_name::String, io_name::String)

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

    # Evaluate if the iofiles are in the database
    io_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.iodata WHERE name = '$io_name';",
        ),
    )
    if size(io_list, 1) == 0
        @warn "unrecognized io data name"
        return false
    end

    # Load path data into local depot folder
    path_dfinname_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfin_" * io_name * ".parquet"
    path_dfoutname_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfout_" * io_name * ".parquet"

    # Evaluate if the files are in the depot folder
    if isfile(path_dfinname_parquet_file) == false ||
       isfile(path_dfoutname_parquet_file) == false
        @warn "unrecognized io data in depot folder"
        return false
    end

    # Delete the row from the data base
    DBInterface.execute(con, "DELETE FROM $project_name.iodata WHERE name = '$io_name';")

    rm(path_dfinname_parquet_file)
    rm(path_dfoutname_parquet_file)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return true
end

# load rawdata from local folder and database
function load_rawdata_local_folder_db(project_name, raw_name)

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

    # Evaluate if the rawfiles are in the database
    raw_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.rawdata WHERE name = '$raw_name';",
        ),
    )
    if size(raw_list, 1) == 0
        @warn "unrecognized raw data name"
        return false
    end

    # Load path data into local depot folder
    path_df_name_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/rawdata/" * raw_name * ".parquet"

    # Evaluate if the files are in the depot folder
    if isfile(path_df_name_parquet_file) == false
        @warn "unrecognized raw data in depot folder"
        return false
    end

    # Load the parquet file
    df = DataFrame(Parquet2.Dataset(path_df_name_parquet_file); copycols = false)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return df
end


# load iodata from local folder and database
function load_iodata_local_folder_db(project_name, io_name)

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

    # Evaluate if the iofiles are in the database
    io_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.iodata WHERE name = '$io_name';",
        ),
    )
    if size(io_list, 1) == 0
        @warn "unrecognized io data name"
        return false
    end

    # Load path data into local depot folder
    path_dfinname_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfin_" * io_name * ".parquet"
    path_dfoutname_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfout_" * io_name * ".parquet"

    # Evaluate if the files are in the depot folder
    if isfile(path_dfinname_parquet_file) == false ||
       isfile(path_dfoutname_parquet_file) == false
        @warn "unrecognized io data in depot folder"
        return false
    end

    # Load the parquet files
    dfin_parquet = Parquet2.Dataset(path_dfinname_parquet_file)
    train_dfin = DataFrame(dfin_parquet; copycols = false)

    dfout_parquet = Parquet2.Dataset(path_dfoutname_parquet_file)
    train_dfout = DataFrame(dfout_parquet; copycols = false)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return train_dfin, train_dfout
end
