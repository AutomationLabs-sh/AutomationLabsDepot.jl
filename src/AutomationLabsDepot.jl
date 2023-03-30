# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################
module AutomationLabsDepot

#package needed
import CSV
import DataFrames
import Dates
import DuckDB
#import JLD
import JLD2
import Parquet2
import FilePathsBase
import MLJ
import Random
import PlotlyJS
import CUDA
import StatsBase

# iodata
export iodata_local_folder_db

# project db local disk
export project_folder_create_db
export list_project_local_folder_db
export remove_project_local_folder_db

# data raw and io local disk db
export add_rawdata_local_folder_db
export add_iodata_local_folder_db
export list_rawdata_local_folder_db
export list_iodata_local_folder_db
export remove_rawdata_local_folder_db
export remove_iodata_local_folder_db

# model local disk db
export list_model_local_folder_db
export remove_model_local_folder_db
export add_model_local_folder_db

# controller local disk db
export list_controller_local_folder_db
export remove_controller_local_folder_db
export add_controller_local_folder_db
export load_controller_local_folder_db

# dashboards local disk db
export add_rawdata_dashboard_local_folder_db
export add_iodata_dashboard_local_folder_db
export list_dash_local_folder_db
export remove_dash_local_folder_db

# systems local disk db 
export list_system_local_folder_db
export remove_system_local_folder_db
export add_system_local_folder_db
export load_system_local_folder_db

# julia sub files
include("subfunctions/types.jl")

include("database_management/database_data_management.jl")
include("database_management/database_dash_management.jl")
include("database_management/database_models_management.jl")
include("database_management/database_project_management.jl")
include("database_management/database_controllers_management.jl")
include("database_management/database_systems_management.jl")
include("subfunctions/iodata_functions.jl")
include("subfunctions/dashboard.jl")

end
