using WGLMakie

x = collect(-4π:0.1:4π)
y = Base.sin.(x)



function plot_d18o(dist, d18o) # Create menu
    fig = Figure()
    
    colormenu =  Menu(fig, options=[:red, :blue, :black])
    legendmenu = Toggle(fig, active=true)
    fig[1, 1] = vgrid!(
        Label(fig, "Color", width=nothing),
        colormenu,
        Label(fig, "Legend", width=nothing),
        legendmenu,
        width=200, tellheight=false
    )

    ax = Axis(fig[1, 2], size=(800, 400),
            xlabel="Testlabel", ylabel="some quantity (kgm s⁻²)")
    plot = lines!(ax, dist, d18o, c=:black, label="testlegend")

    on(colormenu.selection) do s
        plot.color = s
    end
    # connect!(plot.legend, legendmenu.active)

    fig
end

plot_d18o(range(1,100), cumsum(randn(100)))

include("sinreg.jl")