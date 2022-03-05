"""Function that corrects chronologies for sudden jumps in time

Some occurrences in the model results can lead the CumDY function
to detect extra year transitions, resulting in sudden jumps in
the shell chronology or a start of the chronology at an age
beyond 1 year. This function removes these sharp transitions
and late onset by adding or subtracting whole years to the age
result.

[resultarray] Array containing the full results of
the optimized growth model

[T_per] The period length of one year (in days)

[agecorrection] Correct for jumps in age (/code{TRUE}) or
only for starting time (/code{FALSE})

[plot] Should the results be plotted? (/code{TRUE/FALSE})

Returns an updated and corrected version of \code{resultarray}

Examples

"""
module age_corr

export age_corr!

using DataFrames


function age_corr!(resultarray, T_per=365, plot=true,  agecorrection=true)
    mean_window_age = DataFrame(
                            1:(length(resultarray[1,,1])-5)
                        )
end

end
