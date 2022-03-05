# using Pkg; Pkg.add("SineFit")

begin
    using Printf
    using DSP, SineFit
    using Plots, StatsPlots
end

struct SinregResult
    period::Float64
    params::SineFit.WaveFitParams
    plot
end

"""Sinusoidal regression function.

Fits a sinusoid to data provided as as `x` and `y` and returns a named tuple
containing both the fitted curve and the parameters of that curve.
Used to produce initial values for modeling data windows and later?|
to find peaks in modeled julian day values to align the result to
a cumulative age timeline.

[x] Vector of `x` values of input data

[y] Vector of `y` values of input data

[fixed_period] Optional variable for fixing the period of the sinusoid 
in the depth domain. Defaults to `NA`, period is not fixed. Supply a 
single value to fix the period.

[plot] Should the fitting result be plotted? `TRUE/FALSE`

RETURNS: A list containing a vector of parameters of the fitted sinusoid
and the fitted values belonging to each `x` value.
Fitting parameters:

`I` | sineparams.vertoffst = the mean annual value of the sinusoid (height)
`A` | sineparams.amplitude = the amplitude of the sinusoid
`Dper` | sineparams.frequency = the period of the sinusoid in `x` domain
`peak` | sineparams.phaseshft = the location of the peak in the sinusoid
`R2adj` = the adjusted `R^2` value of the fit
`p` = the p-value of the fit


R Examples
```
# Create dummy data
x <- seq(1000, 11000, 1000)
y <- sin((2 * pi * (seq(1, 11, 1) - 8 + 7 / 4)) / 7)
sinlist <- sinreg(x, y, plot = FALSE) # Run the function
@export
```
"""
function sinreg(
        x::Union{AbstractArray{Number, 1}, AbstractVector},
        y::Union{AbstractArray{Number, 1}, AbstractVector};
        fixed_period=nothing, plot::Bool=false, verbose::Bool=false
    )

    # Determine sine period
    if fixed_period == nothing
        # Get periodogram from FFT
        ssp = periodogram(y)
        # Get frequency of maximum density
        per = 1 / ssp.freq[ssp.power .== maximum(ssp.power)]
        println(per)
        dper = per * diff([extrema(x)...])
    else 
        dper = fixed_period
    end

    # SineFit
    sineparams = calculate_wave_shape(x, y)
    sinpred = SineFit.sin(x, sineparams)
    fstring = @sprintf(
                "y = %.2f sin(%.2f x + %.2f) + %.2f",
                sineparams.amplitude, sineparams.frequency,
                sineparams.phaseshft, sineparams.vertoffst
                )

    # Print results
    if verbose
        print(fstring)
    end

    # Draw plot
    if plot
        # Plot results
        scatter(x, y, label="Data")
        plot = plot!(x, sinpred, lw=2, label="SinFit")
        annotate!(plot, [(-12, -0.8, (fstring, font("serif", 14, :red, :left,))),])
    else
        plot = nothing
    end

    # Gather results
    results = SinregResult(dper, sineparams, plot)

    # return results
    return results
end

x =  collect(-10π:0.01:10π)
y =  Base.sin.(x .* 2.1).+ rand(length(x))

result = sinreg(x, y, plot=true)

result.plot

