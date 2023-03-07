# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module DashboardManagementTest

using Test
using DataFrames
using CSV

using AutomationLabsDepot

@testset "Add a dashboard" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # Add the raw data
    project_name = "jean"
    data_path = "./data_QTP"
    raw_name = "data_outputs_depot_test"

    rslt = add_rawdata_local_folder_db(project_name, data_path, raw_name)

    # Dash board of a raw data 
    recipe = "box"
    dash_name_raw_box = "dash_raw_test_box"
    figure = add_rawdata_dashboard_local_folder_db(
        project_name,
        raw_name,
        recipe,
        dash_name_raw_box,
    )
    @test figure != nothing

    recipe = "temporal"
    dash_name_raw_temporal = "dash_raw_test_temporal"
    figure = add_rawdata_dashboard_local_folder_db(
        project_name,
        raw_name,
        recipe,
        dash_name_raw_temporal,
    )
    @test figure != nothing

    # wrong project name 
    project_name = "t"
    figure_false_project_name = add_rawdata_dashboard_local_folder_db(
        project_name,
        raw_name,
        recipe,
        dash_name_raw_box,
    )
    @test figure_false_project_name == false

    # wrong raw name 
    project_name = "jean"
    raw_name = "t"
    figure_false_raw_name = add_rawdata_dashboard_local_folder_db(
        project_name,
        raw_name,
        recipe,
        dash_name_raw_box,
    )
    @test figure_false_raw_name == false

    # Load the CSV files 
    data_in_path = "./data_QTP/data_inputs_m3h_depot_test.csv"
    data_out_path = "./data_QTP/data_outputs_depot_test.csv"

    dfin = DataFrames.DataFrame(CSV.File(data_in_path))
    dfout = DataFrames.DataFrame(CSV.File(data_out_path))

    # io data 
    io_name = "io_test_2"
    rlst = add_iodata_local_folder_db(dfin, dfout, project_name, io_name)

    # Add a dashboard from io data
    dash_name_io_box = "dash_io_test_box"
    recipe = "box"
    figure_io_box = add_iodata_dashboard_local_folder_db(
        project_name,
        io_name,
        recipe,
        dash_name_io_box,
    )
    @test figure_io_box != nothing

    dash_name_io_temporal = "dash_io_test_temporal"
    recipe = "temporal"
    figure_io_temporal = add_iodata_dashboard_local_folder_db(
        project_name,
        io_name,
        recipe,
        dash_name_io_temporal,
    )
    @test figure_io_temporal != nothing

    # wrong project name 
    dash_name_io_test = "test"
    project_name = "t"
    figure_false_project_name = add_iodata_dashboard_local_folder_db(
        project_name,
        raw_name,
        recipe,
        dash_name_io_test,
    )
    @test figure_false_project_name == false

    # wrong io name 
    project_name = "jean"
    raw_name = "t"
    figure_false_io_name = add_iodata_dashboard_local_folder_db(
        project_name,
        raw_name,
        recipe,
        dash_name_io_test,
    )
    @test figure_false_io_name == false

    # List dashboards 
    list = list_dash_local_folder_db(project_name)
    @test size(list) == (1, 6)

    # Remove dashboards 
    remove_dash_local_folder_db(project_name, dash_name_io_box)
    remove_dash_local_folder_db(project_name, dash_name_io_temporal)
    remove_dash_local_folder_db(project_name, dash_name_raw_box)
    remove_dash_local_folder_db(project_name, dash_name_raw_temporal)

    # List dashboards 
    list = list_dash_local_folder_db(project_name)
    @test size(list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

end
