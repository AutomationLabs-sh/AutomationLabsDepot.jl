# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

### Management model local folder ###

# List models local folder
function list_model_local_folder_db(project_name::String)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"))
    if findall( x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        #return a null DataFrames
        df = DataFrames.DataFrame(id=Int[], path=Int[], name=Int[], file_extension=Int[], added=Int[], size=Int[])
        return df
    end

    # List value from table
    results = DBInterface.execute(
        con, "SELECT id, path, name, file_extension, added, size FROM $project_name.models;"
    )

    # Transform to DataFrame
    df = DuckDB.toDataFrame(results)

    return df
end


# Remove data from folder and line from database duckdb
function remove_model_local_folder_db(project_name::String, model_name::String)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"))
    if findall( x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        return false
    end

    # Evaluate if the model is in the database
    model_list = DuckDB.toDataFrame(DBInterface.execute(con, "SELECT id, path, name, file_extension, added, size  FROM $project_name.models WHERE name = '$model_name';"))      
    if size(model_list, 1) == 0
        @warn "unrecognized model name"
        return false
    end
 
    # Load path data into local depot folder
    path_model = DEPOT_PATH[begin] * "/automationlabs" * "/" * "models" * "/" * model_name * ".jls"
 
    # Evaluate if the files are in the depot folder
    if isfile(path_model) == false
        @warn "unrecognized model in depot folder"
        return false
    end

    # Delete the row from the data base
    DBInterface.execute(
        con, "DELETE FROM $project_name.models WHERE name = '$model_name';"
    )

    # Delete the file from the path
    rm(path_model)

    return true
end

# Add model to local folder
function add_model_local_folder_db(mach_model, project_name::String, model_name::String)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"))
    if findall( x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        return false
    end
 
    # Evaluate if the model is in the database
    model_list = DuckDB.toDataFrame(DBInterface.execute(con, "SELECT id, path, name, file_extension, added, size  FROM $project_name.models WHERE name = '$model_name';"))      
    if size(model_list, 1) != 0
        @warn "there is an equivalent model name"
        return false
    end

    # Load path data into local depot folder
    path_model = DEPOT_PATH[begin] * "/automationlabs/" * "/models/" * model_name * ".jls"
        
    # Evaluate if the files are in the depot folder
    if isfile(path_model) == true
        @warn "there is an equivalent model name"
        return false
    end
    
    # Write the model
    MLJ.save(path_model, mach_model)

    # Get a random id
    id = Random.randstring('a':'z', 6)

    # Get the time
    datenow = string(Dates.now())

    # Get the size of the parquet file
    file_size = Base.format_bytes.(filesize.(path_model))

    # Update the model table with the new data
    DBInterface.execute(
        con, "INSERT INTO $project_name.models VALUES ('$id', 'automationlabs/models', '$model_name', '.jls', '$datenow', '$file_size');"
    )

    return true
end


# Load model from local folder
function load_model_local_folder_db(project_name::String, model_name::String)

    # Load path data into local depot folder
    path_model = DEPOT_PATH[begin] * "/automationlabs" * "/" * "models" * "/" * model_name * ".jls"

    mach_predict_only = MLJ.machine(path_model)

    return mach_predict_only
end

# Get the statistics of a tuned model 
function stats_model_local_folder_db(project_name::String, model_name::String)

    # Connect to the database
    path_db = DEPOT_PATH[begin] * "/automationlabs/database/automationlabs.duckdb"
    con = DBInterface.connect(DuckDB.DB, path_db)

    # Evaluate if the project is in the database
    project_list = DuckDB.toDataFrame(DBInterface.execute(con, "SELECT * FROM information_schema.schemata;"))
    if findall( x -> x == project_name, project_list[!, :schema_name]) == []
        @warn "unrecognized project name"
        return false
    end

    # Evaluate if the model is in the database
    model_list = DuckDB.toDataFrame(DBInterface.execute(con, "SELECT id, path, name, file_extension, added, size  FROM $project_name.models WHERE name = '$model_name';"))      
    if size(model_list, 1) == 0
        @warn "unrecognized model name"
        return false
    end
 
    # Load path data into local depot folder
    path_model = DEPOT_PATH[begin] * "/automationlabs" * "/" * "models" * "/" * model_name * ".jls"
 
    # Evaluate if the files are in the depot folder
    if isfile(path_model) == false
        @warn "unrecognized model in depot folder"
        return false
    end

    # Load the model from the database 
    mach_predict_only = load_model_local_folder_db(project_name, model_name)

    # Get the number of iteration  
    nbr_iter = MLJ.report(mach_predict_only).n_iterations

    # Get the best model 
    loss_best = mach_predict_only.report.vals[1].model_report.best_history_entry.measurement

    # Get the worst model 
    vec = MLJ.report(mach_predict_only).model_report.history

    # Get the hyperparameters of the best model 
    nbr_neuron_best = mach_predict_only.report.vals[1].model_report.best_model.builder.neuron
    nbr_layer_best = mach_predict_only.report.vals[1].model_report.best_model.builder.layer
    nbr_epochs_best = mach_predict_only.report.vals[1].model_report.best_model.epochs
    act_fct_best = mach_predict_only.report.vals[1].model_report.best_model.builder.??

    # Get the chain of the best model 
    chain_best = MLJ.fitted_params(MLJ.fitted_params(mach_predict_only).machine).best_fitted_params[1]

    # Architecture of the best model  (Fnn, ResNet, ....)
    type_architecture = string(typeof(mach_predict_only.report.vals[1].model_report.best_history_entry.model.builder))[30:end]

    return [nbr_iter, loss_best, type_architecture, nbr_neuron_best, nbr_layer_best, nbr_epochs_best, act_fct_best, chain_best]

end
