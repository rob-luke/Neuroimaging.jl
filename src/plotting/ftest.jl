using Gadfly

@doc """
VIsualise the data used to determine the f statistic.  
The spectrum is plotted in black, the noise estimate is highlited in red, and the signal marked in green.
Dots indicate the noise and signal power.
""" ->
function plot_ftest(sweeps::Union(Array{Float64, 3}, Array{Float32, 3}), freq_of_interest::Real,
                fs::Real, side_freq::Real, used_filter::Union(Filter, Nothing), spill_bins::Int; kwargs...)

    spectrum    = EEG._ftest_spectrum(sweeps)
    # No compensation for filtering
    frequencies = linspace(0, 1, int(size(spectrum, 1)))*float(fs)/2

    plot_ftest(spectrum, frequencies, freq_of_interest, side_freq, spill_bins; kwargs...)
end


function plot_ftest{T <: FloatingPoint}(spectrum::Array{Complex{T},2}, frequencies::AbstractArray,
            freq_of_interest::Real, side_freq::Real, spill_bins::Int;
            min_plot_freq::Real=2, max_plot_freq::Real=2.2*freq_of_interest, plot_channel::Int=1, fig_name::String="ftest.pdf")


    idx      = _find_closest_number_idx(frequencies, freq_of_interest)
    idx_Low  = _find_closest_number_idx(frequencies, freq_of_interest - side_freq)
    idx_High = _find_closest_number_idx(frequencies, freq_of_interest + side_freq)

    # Determine signal power
    signal_power = abs(spectrum[idx, :]).^2

    # Determine noise power
    noise_idxs      = [idx_Low-spill_bins/2 : idx-spill_bins, idx+spill_bins : idx_High+spill_bins/2]
    noise_bins      = spectrum[noise_idxs,:]
    noise_bins      = abs(noise_bins)
    noise_power     = sum(noise_bins .^2, 1) ./ size(noise_bins,1)

    # Calculate SNR
    snr = (signal_power ./ noise_power)
    snrDb = 10 * log10(snr)

    idx_low_plot  = _find_closest_number_idx(frequencies, min_plot_freq)
    idx_high_plot = _find_closest_number_idx(frequencies, max_plot_freq)

    raw_plot = layer(x=frequencies[idx_low_plot:idx_high_plot], y=abs(spectrum[idx_low_plot:idx_high_plot, plot_channel]).^2, Geom.line, Theme(default_color=color("black")))
    noi_plot = layer(x=frequencies[noise_idxs], y=noise_bins.^2, Geom.line, Theme(default_color=color("red")))
    sig_plot = layer(x=frequencies[idx-1:idx+1], y=abs(spectrum[idx-1:idx+1, :]).^2, Geom.line, Theme(default_color=color("green")))
    noi_pnt  = layer(x=[min_plot_freq], y=[noise_power], Geom.point, Theme(default_color=color("red")))
    sig_pnt  = layer(x=[min_plot_freq], y=[signal_power], Geom.point, Theme(default_color=color("green")))

    p = plot(noi_plot, sig_plot, raw_plot, noi_pnt, sig_pnt,
        Scale.x_continuous(minvalue=min_plot_freq, maxvalue=max_plot_freq),
        Scale.y_log10(),
        Guide.ylabel("Power (uV^2)"), Guide.xlabel("Frequency (Hz)"),
        Guide.title("SNR = $(round(snrDb[1], 3)) (dB)")
        )
    draw(PDF(fig_name, 26cm, 17cm), p)
end

