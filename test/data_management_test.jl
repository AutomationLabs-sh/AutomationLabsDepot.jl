# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module DataManagementTests

using Test
using DataFrames
using CSV

using AutomationLabsDepot

import AutomationLabsDepot: load_rawdata_local_folder_db
import AutomationLabsDepot: load_iodata_local_folder_db

@testset "Add, list, load, remove the raw data" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # Add the raw data
    project_name = "jean"
    data_path = "./data_QTP"
    raw_name = "data_outputs_depot_test"

    rslt = add_rawdata_local_folder_db(project_name, data_path, raw_name)
    @test rslt == true

    # List the raw data 
    list = list_rawdata_local_folder_db(project_name)
    @test size(list) == (1, 6)

    # Load raw data 
    df = load_rawdata_local_folder_db(project_name, raw_name)
    @test df != nothing

    # Remove the raw data 
    rslt_rm = remove_rawdata_local_folder_db(project_name, raw_name)
    @test rslt_rm == true

    # Remove the project
    remove_project_local_folder_db(project_name)

end

@testset "Add, list, load, remove the io data" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # Load the CSV files 
    data_in_path = "./data_QTP/data_inputs_m3h_depot_test.csv"
    data_out_path = "./data_QTP/data_outputs_depot_test.csv"

    dfin = DataFrames.DataFrame(CSV.File(data_in_path))
    dfout = DataFrames.DataFrame(CSV.File(data_out_path))

    # io data 
    io_name = "io_test_jean2"
    rlst = add_iodata_local_folder_db(dfin, dfout, project_name, io_name)
    @test rlst == true

    sleep(5) #sleep for writing in HDD

    # List io data 
    rslt_list = list_iodata_local_folder_db(project_name)
    @test size(rslt_list) == (1, 6)

    # Load io data 
    train_df_in, train_df_out = load_iodata_local_folder_db(project_name, io_name)
    @test train_df_in != nothing
    @test train_df_out != nothing

    # Remove the io data 
    rslt_rm = remove_iodata_local_folder_db(project_name, io_name)
    @test rslt_rm == true

    # List io data 
    rslt_list = list_iodata_local_folder_db(project_name)
    @test size(rslt_list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

end
