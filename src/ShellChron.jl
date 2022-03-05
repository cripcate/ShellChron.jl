module ShellChron

# Export names
# export run_model

# Load requirements
begin
    using CSV
    using DataFrames
end

# Define types and structs
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


# Include functions in module
include("gui.jl")
include("data_import.jl")
include("age_corr.jl")
include("sinreg.jl")



# Experiment with functionality
T = Temperature(4.2, 5, 2, 3)
G = Growth(4.2, 5, 2, 3, 1)
mod = Model(T, G)

data_import("data-raw/test.csv")

end