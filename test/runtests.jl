# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

print("Testing Data Separation...")
took_seconds = @elapsed include("./data_separation_test.jl");
println("done (took ", took_seconds, " seconds)")

print("Testing Project Management...")
took_seconds = @elapsed include("./project_management_test.jl");
println("done (took ", took_seconds, " seconds)")

print("Testing Data Management...")
took_seconds = @elapsed include("./data_management_test.jl");
println("done (took ", took_seconds, " seconds)")

print("Testing Controllers Management...")
took_seconds = @elapsed include("./controllers_management_test.jl");
println("done (took ", took_seconds, " seconds)")

print("Testing Dashboard Management...")
took_seconds = @elapsed include("./dash_management_test.jl");
println("done (took ", took_seconds, " seconds)")

print("Testing System Management...")
took_seconds = @elapsed include("./system_management_test.jl");
println("done (took ", took_seconds, " seconds)")

print("Testing Exportation Management...")
took_seconds = @elapsed include("./exportation_management_test.jl");
println("done (took ", took_seconds, " seconds)")