# Copyright (c) 2022: Pierre Blaud and contributors
########################################################
# This Source Code Form is subject to the terms of the #
# Mozilla Public License, v. 2.0. If a copy of the MPL #
# was not distributed with this file,  				   #
# You can obtain one at https://mozilla.org/MPL/2.0/.  #
########################################################

#local dashboard from the depot

function rawdata_temporal_plot_local_folder_db(df; kws_...)

    # Get argument kws
    dict_kws = Dict{Symbol,Any}(kws_)
    kws = get(dict_kws, :kws, kws_)

    if haskey(kws, :title) == true
        title = kws[:title]
    else
        title = ""
    end

    figure = PlotlyJS.make_subplots(
        rows = size(df, 2),
        cols = 1,
        shared_xaxes = true,
        vertical_spacing = 0.02,
    )

    for i = 1:1:size(df, 2)

        PlotlyJS.add_trace!(
            figure,
            PlotlyJS.scatter(;
                y = df[:, i],
                mode = "markers",
                marker = PlotlyJS.attr(maxdisplayed = 1000),
            ),
            row = i,
            col = 1,
        )

    end

    return figure
end

function rawdata_box_plot_local_folder_db(df; kws_...)

    # Get argument kws
    dict_kws = Dict{Symbol,Any}(kws_)
    kws = get(dict_kws, :kws, kws_)


    p_ = []

    for i = 1:1:size(df, 2)
        push!(p_, PlotlyJS.box(; y = df[:, i]))
    end

    figure = PlotlyJS.plot(vcat(p_...))

    PlotlyJS.plot(vcat(p_...))

    return figure

end


function iodata_temporal_plot_local_folder_db(dfin, dfout; kws_...)

    # Get argument kws
    dict_kws = Dict{Symbol,Any}(kws_)
    kws = get(dict_kws, :kws, kws_)

    # Plot the scatter from the inputs 
    p_inputs = []


    for i = 1:1:size(dfin, 2)
        push!(
            p_inputs,
            PlotlyJS.scatter(;
                y = dfin[:, i],
                mode = "markers",
                marker = PlotlyJS.attr(maxdisplayed = 500),
            ),
        )
    end

    plot_1 = PlotlyJS.plot(vcat(p_inputs...))

    # Plot the scatter from the outputs
    p_outputs = []

    for i = 1:1:size(dfout, 2)
        push!(
            p_outputs,
            PlotlyJS.scatter(;
                y = dfout[:, i],
                mode = "markers",
                marker = PlotlyJS.attr(maxdisplayed = 500),
            ),
        )
    end

    plot_2 = PlotlyJS.plot(vcat(p_outputs...))

    # Plot the figure with the both subplots 
    figure = [plot_1; plot_2]

    return figure
end


function iodata_box_plot_local_folder_db(dfin, dfout; kws_...)

    # Get argument kws
    dict_kws = Dict{Symbol,Any}(kws_)
    kws = get(dict_kws, :kws, kws_)

    # Plot the box from the training inputs
    plot_inputs = []

    for i = 1:1:size(dfin, 2)
        push!(plot_inputs, PlotlyJS.box(; y = dfin[:, i]))
    end

    plot_1 = PlotlyJS.plot(vcat(plot_inputs...))

    # Plot the box from the training outputs
    plot_outputs = []

    for i = 1:1:size(dfout, 2)
        push!(plot_outputs, PlotlyJS.box(; y = dfout[:, i]))
    end

    plot_2 = PlotlyJS.plot(vcat(plot_outputs...))

    # plot the figure with the both subplots 
    figure = [plot_1; plot_2]

    return figure

end
