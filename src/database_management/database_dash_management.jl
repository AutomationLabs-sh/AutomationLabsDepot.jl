# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

### Dashboards local management ###

# Add dashboard to local folder with raw data
function add_rawdata_dashboard_local_folder_db(
    project_name::String,
    raw_name::String,
    recipe::String,
    dash_name::String;
    kws_...,
)
    # Get argument kws
    dict_kws = Dict{Symbol,Any}(kws_)
    kws = get(dict_kws, :kws, kws_)

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

    # Evaluate if the dashfiles are in the database
    dash_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.dashboards WHERE name = '$dash_name';",
        ),
    )
    if size(dash_list, 1) != 0
        @warn "there is an equivalent dashboard name"
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

    # Load raw data 
    df = DataFrames.DataFrame(Parquet2.Dataset(path_df_name_parquet_file); copycols = false)

    # Call the recipe with the data
    if recipe == "temporal"
        figure = rawdata_temporal_plot_local_folder_db(df; kws)
    elseif recipe == "box"
        figure = rawdata_box_plot_local_folder_db(df; kws)
    end

    # Write the dashboard on local folder
    path_to_save =
        DEPOT_PATH[begin] * "/automationlabs/" * "/dashboards/" * dash_name * ".html"
    PlotlyJS.savefig(figure, path_to_save)

    # Get the time
    datenow = string(Dates.now())

    # Get the size of the file
    file_size = Base.format_bytes.(filesize.(path_to_save))

    # Update the dash table with the new dashboard
    id = Random.randstring('a':'z', 6)

    DBInterface.execute(
        con,
        "INSERT INTO $project_name.dashboards VALUES ('$id', 'automationlabs/dashboards', '$dash_name', '.html', '$datenow', '$file_size');",
    )

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return figure
end

# Add dashboard to local folder with io data
function add_iodata_dashboard_local_folder_db(
    project_name::String,
    io_name::String,
    recipe::String,
    dash_name::String;
    kws_...,
)

    # Get argument kws
    dict_kws = Dict{Symbol,Any}(kws_)
    kws = get(dict_kws, :kws, kws_)

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

    # Evaluate if the dashfiles are in the database
    dash_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.dashboards WHERE name = '$dash_name';",
        ),
    )
    if size(dash_list, 1) != 0
        @warn "there is an equivalent dashboard name"
        return false
    end

    # Load path data into local depot folder
    path_dfin_name_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfin_" * io_name * ".parquet"
    path_dfout_name_parquet_file =
        DEPOT_PATH[begin] * "/automationlabs/iodata/dfout_" * io_name * ".parquet"

    # Evaluate if the files are in the depot folder
    if isfile(path_dfin_name_parquet_file) == false ||
       isfile(path_dfout_name_parquet_file) == false
        @warn "unrecognized io data in depot folder"
        return false
    end

    # Load io data 
    dfin = DataFrames.DataFrame(
        Parquet2.Dataset(path_dfin_name_parquet_file);
        copycols = false,
    )
    dfout = DataFrames.DataFrame(
        Parquet2.Dataset(path_dfout_name_parquet_file);
        copycols = false,
    )

    # Call the recipe with the data
    if recipe == "temporal"
        figure = iodata_temporal_plot_local_folder_db(dfin, dfout; kws)
    elseif recipe == "box"
        figure = iodata_box_plot_local_folder_db(dfin, dfout; kws)
    end

    # Write the dashboard on local folder
    path_to_save =
        DEPOT_PATH[begin] * "/automationlabs/" * "/dashboards/" * dash_name * ".html"
    PlotlyJS.savefig(figure, path_to_save)

    # Get the time
    datenow = string(Dates.now())

    # Get the size of the file
    file_size = Base.format_bytes.(filesize.(path_to_save))

    # Update the dash table with the new dashboard
    id = Random.randstring('a':'z', 6)
    DBInterface.execute(
        con,
        "INSERT INTO $project_name.dashboards VALUES ('$id', 'automationlabs/dashboards', '$dash_name', '.html', '$datenow', '$file_size');",
    )

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return figure
end

# List dash local folder
function list_dash_local_folder_db(project_name::String)

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
        "SELECT id, path, name, file_extension, added, size FROM $project_name.dashboards;",
    )

    # Transform to DataFrame
    df = DuckDB.toDataFrame(results)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return df
end

# Remove dash from folder and line from database duckdb
function remove_dash_local_folder_db(project_name::String, dash_name::String)

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

    # Evaluate if the dash is in the database
    dash_list = DuckDB.toDataFrame(
        DBInterface.execute(
            con,
            "SELECT id, path, name, file_extension, added, size  FROM $project_name.dashboards WHERE name = '$dash_name';",
        ),
    )
    if size(dash_list, 1) == 0
        @warn "unrecognized dashboard"
        return false
    end

    # Load path dashboard into local depot folder
    path_dashboard =
        DEPOT_PATH[begin] *
        "/automationlabs" *
        "/" *
        "dashboards" *
        "/" *
        dash_name *
        ".html"

    # Evaluate if the file is in the depot folder
    if isfile(path_dashboard) == false
        @warn "unrecognized dashboard in depot folder"
        return false
    end

    # Delete the row from the data base
    DBInterface.execute(
        con,
        "DELETE FROM $project_name.dashboards WHERE name = '$dash_name';",
    )

    # Delete the file from the path
    rm(path_dashboard)

    # Close and disconnect the DuckDB database 
    DBInterface.close!(con)

    return true
end
