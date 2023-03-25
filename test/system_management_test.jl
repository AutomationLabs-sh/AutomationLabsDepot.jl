# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module SystemManagementTest

using Test
using DataFrames
using Random
using MathematicalSystems
using JLD #need JLD in the module for reconstruction

using AutomationLabsDepot


@testset "List systems" begin

    # Create a project
    project_name = "cx"
    project_folder_create_db(project_name)

    # List the system project and test it is depicted
    list = list_system_local_folder_db(project_name)

    @test size(list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

@testset "Add and remove a system to database" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # Name of the controller
    system_name = "s1"

    # system with MathematicalSystems
    A = [1 1; 0 0.9]
    B = [1; 0.5]
    nbr_state = 2
    nbr_input = 1

    x_cons = [
        -5.0 5.0
        -5.0 5.0
    ]
    u_cons = [-1.0 1.0]

    sys = MathematicalSystems.@system x⁺ = A * x + B * u x ∈ x_cons u ∈ u_cons

    # Add the system to local database
    add_system_local_folder_db(sys, project_name, system_name)

    # List the system and test it is depicted
    list = list_system_local_folder_db(project_name)

    # List the system
    @test size(list) == (1, 6)

    # Load the system from the DataBase 
    sys_load = load_system_local_folder_db(project_name, system_name)
    @test_skip sys_load["system"] == sys
    @test sys_load["system"].A == sys.A
    @test sys_load["system"].B == sys.B
    @test sys_load["system"].X == sys.X
    @test sys_load["system"].U == sys.U

    # Remove the system 
    remove_system_local_folder_db(project_name, system_name)

    # List the system
    list = list_system_local_folder_db(project_name)
    @test size(list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

end
