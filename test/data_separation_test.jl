# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

module DataSeperationTests

using Test
using DataFrames

using AutomationLabsDepot

import AutomationLabsDepot: data_formatting_identification
import AutomationLabsDepot: data_formatting_identification

@testset "Train & Test & Delay" begin

    data_in = DataFrames.DataFrame(A = rand(500000))
    data_out = DataFrames.DataFrame(B = rand(500000), C = rand(500000))
    n_delay = 5
    normalisation = false

    DataTrainTest = data_formatting_identification(
        data_in,
        data_out;
        n_delay = n_delay,
        normalisation = normalisation,
    )

    @test size(DataTrainTest.DataIn) == (499995, 15)
    @test size(DataTrainTest.DataOut) == (499995, 2)

end

@testset "Normalisation 0-1" begin

    data_in = DataFrames.DataFrame(A = 10 * rand(500000))
    data_out = DataFrames.DataFrame(B = 10 * rand(500000), C = 10 * rand(500000))
    n_delay = 5
    normalisation = true

    DataTrainTest = data_formatting_identification(
        data_in,
        data_out;
        n_delay = n_delay,
        normalisation = normalisation,
    )

    @test maximum(Matrix(DataTrainTest.DataIn)) <= 1.0
    @test minimum(Matrix(DataTrainTest.DataIn)) >= 0.0
    @test maximum(Matrix(DataTrainTest.DataOut)) <= 1.0
    @test minimum(Matrix(DataTrainTest.DataOut)) >= 0.0

end

@testset "DataSeparationFloat32" begin

    data_in = DataFrames.DataFrame(A = 10 * rand(500000))
    data_out = DataFrames.DataFrame(B = 10 * rand(500000), C = 10 * rand(500000))
    n_delay = 5
    normalisation = true

    DataTrainTest = data_formatting_identification(
        data_in,
        data_out;
        n_delay = n_delay,
        normalisation = normalisation,
        data_type = Float32,
    )

    @test typeof(DataTrainTest.DataIn[!, 1]) == Vector{Float32}
    @test typeof(DataTrainTest.DataIn[!, 2]) == Vector{Float32}
    @test typeof(DataTrainTest.DataIn[!, 3]) == Vector{Float32}

    @test typeof(DataTrainTest.DataOut[!, 1]) == Vector{Float32}
    @test typeof(DataTrainTest.DataOut[!, 2]) == Vector{Float32}

end

@testset "Limits-data" begin

    data_in = DataFrames.DataFrame(A = 10 * rand(500000))
    data_out = DataFrames.DataFrame(B = 10 * rand(500000), C = 10 * rand(500000))
    n_delay = 1
    normalisation = false

    lower_in = [1 1 2]
    upper_in = [9 Inf 9]

    lower_out = [0.25 0.5]
    upper_out = [9 Inf]


    DataTrainTest = data_formatting_identification(
        data_in,
        data_out;
        n_delay = n_delay,
        normalisation = normalisation,
        data_lower_input = lower_in,
        data_upper_input = upper_in,
        data_lower_output = lower_out,
        data_upper_output = upper_out,
    )

    @test maximum(Matrix(DataTrainTest.DataIn)[:, 1]) <= 9.0
    @test minimum(Matrix(DataTrainTest.DataIn)[:, 1]) >= 1.0

    @test maximum(Matrix(DataTrainTest.DataIn)[:, 2]) <= Inf
    @test minimum(Matrix(DataTrainTest.DataIn)[:, 2]) >= 1.0

    @test maximum(Matrix(DataTrainTest.DataIn)[:, 3]) <= 9.0
    @test minimum(Matrix(DataTrainTest.DataIn)[:, 3]) >= 2.0

    @test maximum(Matrix(DataTrainTest.DataOut)[:, 1]) <= 9.0
    @test minimum(Matrix(DataTrainTest.DataOut)[:, 1]) >= 0.25

    @test maximum(Matrix(DataTrainTest.DataOut)[:, 2]) <= Inf
    @test minimum(Matrix(DataTrainTest.DataOut)[:, 2]) >= 0.5

end

end
