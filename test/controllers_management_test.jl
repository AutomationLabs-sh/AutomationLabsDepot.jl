# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module ControllerManagementTest

using Test
using DataFrames
using Random

using AutomationLabsDepot

@testset "List controllers" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # List the controller project and test it is depicted
    list = list_controller_local_folder_db(project_name)

    @test size(list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

@testset "Add and remove a controller to database" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # Name of the controller
    controller_name = "c1"

    # Parameters (random for the test as it is saved as a JLD file in folder)
    controller_parameters = Random.randstring('a':'z', 6)

    # Controller not used as it is not recommended
    controller = "nothing"

    # Add the controller to local database
    rslt = add_controller_local_folder_db(
        controller,
        controller_parameters,
        project_name,
        controller_name,
    )

    @test rslt == true

    #Is it necessary to include the sleep or a while loop for writing in HDD ?

    # List the controller and test it is depicted
    list = list_controller_local_folder_db(project_name)

    println(list)
    # List the controller
    @test size(list) == (1, 6)

    # Remove the controller 
    remove_controller_local_folder_db(project_name, controller_name)

    # List the controller
    list = list_controller_local_folder_db(project_name)
    @test size(list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

@testset "Load a controller" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # Name of the controller
    controller_name = "c1"

    # Parameters (random for the test as it is saved as a JLD file in folder)
    controller_parameters = Random.randstring('a':'z', 6)

    # Controller not used as it is not recommended
    controller = nothing

    # Add the controller to local database
    add_controller_local_folder_db(
        controller,
        controller_parameters,
        project_name,
        controller_name,
    )

    # Load the controller with wrong name
    controller_loaded =
        load_controller_local_folder_db("fake_project_name", controller_name)

    @test controller_loaded == false

    # Load the controller with wrong name
    controller_loaded = load_controller_local_folder_db(project_name, "fake_project_name")

    @test controller_loaded == false

    # Load the controller
    controller_loaded = load_controller_local_folder_db(project_name, controller_name)

    # List the controller
    @test controller_loaded != nothing

    # Remove the controller 
    remove_controller_local_folder_db(project_name, controller_name)

    # List the controller
    list = list_controller_local_folder_db(project_name)
    @test size(list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

end
