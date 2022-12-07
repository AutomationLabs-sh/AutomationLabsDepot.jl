# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module ProjectManagementTest

using Test
using DataFrames

using AutomationLabsDepot

@testset "Project_create_manage_remove" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # List the project and test it is depicted
    list = list_project_local_folder_db()

    @test findfirst(isequal("jean"),list) != nothing

    # Remove the project
    remove_project_local_folder_db(project_name)

    # List the project and test it is depicted
    list = list_project_local_folder_db()

    @test findfirst(isequal("jean"),list) == nothing

end

end