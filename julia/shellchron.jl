
module ShellChron

begin
    using CSV
    using DataFrames
    using CategoricalArrays


    struct Temperature
        av::Number
        amp::Number
        pha::Number
        per::Number
    end

    struct Growth
        av::Number
        amp::Number
        pha::Number
        per::Number
        skw::Number
    end

    struct Model
        t::Temperature
        g::Growth
    end

    T = Temperature(4.2, 5, 2, 3)
    G = Growth(4.2, 5, 2, 3, 1)
    mod = Model(T, G)
end


"""Function to import d18O data and process yearmarkers and calculation windows.

Takes the name of a file that is formatted according to the standard format
and converts it to an object to be used later in the model. In doing so, the
function also reads the user-provided yearmarkers in the file and uses them
as a basis for the length of windows used throughout the model. This ensures
that windows are not too short and by default contain at least one year of
growth for modeling.

"""
function data_import(filename::String)
    # Load CSV file
    dat = CSV.read(filename, DataFrame)

    # Replace species column of dummy dataset with dummy yearmarkaers
    dat[:, 3], dat[:, 5] = dat[:, 5], dat[:, 3]
    yearmarkers = rand([true, false], nrow(dat))

    # Check data format
    @assert(ncol(dat) ∈ [3, 5],
        "Wrong number of columns. Abort.")
    if ncol(dat) == 3
        dist = measurement.(dat[:, 1], missing)
        d18o = measurement.(dat[:, 3], missing)
        # yearmarkers = dat[:, 2]
    elseif ncol(dat) == 5
        dist = measurement.(dat[:, 1], dat[:, 2])
        d18o = measurement.(dat[:, 4], dat[:, 5])
        # yearmarkers = dat[:, 3]
    end
    print(yearmarkers[1:5])
    
    # Check if yearmarkers are correct
    @assert(eltype(yearmarkers) == Bool,
        "Yearmarkers not binary.")
    @assert(count(yearmarker) <= 1,
        "Less than a full year sampled. Abort.")

    modeldata = (; dist, d18o, yearmarkers)

    return modeldata
end

data_import("data-raw/test.csv")

