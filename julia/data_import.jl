
using CSV


"""Function to import d18O data and process yearmarkers and calculation windows.

Takes the name of a file that is formatted according to the standard format
and converts it to an object to be used later in the model. In doing so, the
function also reads the user-provided yearmarkers in the file and uses them
as a basis for the length of windows used throughout the model. This ensures
that windows are not too short and by default contain at least one year of
growth for modeling.

"""
function data_import(filename::String)
    dat = CSV.read(filename)
end
