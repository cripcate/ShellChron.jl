
 # Set boundary conditions
const days = 1:6*365  # Create timeline of 6 years in days
const years = days / 365  # Convert to years
const temp_ann_mean = 20  # Set mean annual temperature
const temp_ann_amp = 10  # Set seasonal amplitude
const temp_ann_range = 2 * temp_ann_amp  # Calculate extent of seasonal variability
const temp_noise = 1.5  # Set the degree of random non-seasonal noise on the SST curve ("weather")

sst = temp_ann_mean .+ temp_ann_amp .* sin.(2π*years) .+ temp_noise .* randn(length(years))  # Create virtual daily SST data
const growth_rate = repeat([10/365], length(years))  # Set growth rate to 10 mm/yr, create daily growth_rate vector
const d18Ow_mean = 0  # Set d18Osw to 0 permille VSMOW,
const d18Ow_noise = 0.6  # Set the degree of random non-seasonal noise on the d18Osw curve ("salinity fluctuations")
const d18Osw = d18Ow_mean rnorm(length(Ty), rep(0, length(Ty)), DSD)  ä create daily d18Osw vector

SR = 0.75 # Set uneven sampling resolutions

# Create vector for all samples along entire shell length by applying constant sampling resolution
D = seq(SR, sum(growth_rate), SR)

# Calculate virtual data
Virtual_shell = as.data.frame(shellmodel(Ty, SST, growth_rate, d18Osw, D, AV = TRUE))
Virtual_shell$D = Virtual_shell$D * 1000 # Convert to micrometers
Virtual_shell$D_err = rep(100, length(Virtual_shell[, 1])) # Add uncertainties on D (in mm)
Virtual_shell$d18Oc_err = rep(0.1, length(Virtual_shell[, 1])) # Add uncertainties on d18Oc (in permille)
Virtual_shell$D47 = NULL # D47 data is removed

# Add YEARMARKER column based on user identification of the year transitions
Virtual_shell$YEARMARKER = rep(0, nrow(Virtual_shell))
Virtual_shell$YEARMARKER[c(10, 23, 37, 50, 64, 77)] = 1





"""Function for creating d18Oc and D47 data from set of growth conditions and sampling resolution.

All input data are vectors at daily resolution, except for distance, which depends on the sampling resolution and shell length
"""
function shellmodel(time, sst, gr, d18Ow, distance; av=false, plot=false)
    Dday = cumsum(gr) # Create vector linking days to depth values
    if av==false
        SSTnew = subsample(SST, Dday, distance) # Subsample SST along the new sample set
        d18Ownew = subsample(d18Ow, Dday, distance) # Subsample d18Ow along the new sample set
        Tynew = subsample(Ty, Dday, distance) # Subsample time (yr) along the new sample set
    else
        SSTnew = subsample_mean(SST, Dday, distance) # Subsample SST along the new sample set using mean values
        d18Ownew = subsample_mean(d18Ow, Dday, distance) # Subsample d18Ow along the new sample set using mean values
        Tynew = subsample_mean(Ty, Dday, distance) # Subsample time (yr) along the new sample set using mean values
    end
    # alpha = exp((18.03*1000/(SSTnew+273.15)-33.42)/1000) # Calculate alpha of calcite fractionation
    # d18Ow_PDB = (0.97002*d18Ownew-29.98) # Convert d18Ow to PDB
    # d18Oc = ((alpha * (d18Ow_PDB/1000 + 1)) - 1)*1000
    d18Oc = (exp((18.03 * 1000 / (SSTnew + 273.15) - 33.42) / 1000) * ((0.97002 * d18Ownew - 29.98) / 1000 + 1) - 1) * 1000 # Calculate d18O of calcite for each sample according to Kim and O'Neil, 1997
    D47 = (0.0449 * 10^6) / (SSTnew + 273.15) ^ 2 + 0.167 # Calculate D47 of calcite for each sample according to Kele et al., 2015 modified by Bernasconi et al., 2018
    if(plot == TRUE){ # Create plots of new data if requested
        dev.new()
        plot(D, d18Oc, col = "blue")
        par(new = TRUE)
        plot(D, D47, axes = FALSE, bty = "n", xlab = "", ylab = "", col = "red")
        axis(side = 4, at = pretty(range(D47)))
    }
    dat = cbind(Tynew, distance, d18Oc, D47) # Combine new data for export
    return(dat) # Return the new depth, d18Oc and D47 series
end
