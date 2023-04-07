# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module ExporationDbTests

using Test
using AutomationLabsDepot

@testset "List null exportation in data base" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)

    # List the exportation and test it is depicted
    list = list_exportation_local_folder_db(project_name)

    @test size(list) == (0, 6)

    # Remove the project
    remove_project_local_folder_db(project_name)

end

@testset "Add and remove a exportation into the database" begin

    # Create a project
    project_name = "jean"
    project_folder_create_db(project_name)
 
    exportation_name = "test_exportation"

    rslt = add_exportation_local_folder_db(
        project_name,
        exportation_name,
    )

    @test rslt == true

    # List the exportation and test it is depicted
    list = list_exportation_local_folder_db(project_name)

    @test size(list) == (1, 6)

    # Remove the exportation 
    remove_exportation_local_folder_db(project_name, exportation_name)

    # List the exportation
    list = list_exportation_local_folder_db(project_name)
    @test size(list) == (0, 6)
 
    # Remove the project
    remove_project_local_folder_db(project_name)
 
end
    
end
