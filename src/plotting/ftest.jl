@doc doc"""
Visualise the data used to determine the f statistic.

The spectrum is plotted in black, the noise estimate is highlited in red, and the signal marked in green.
Dots indicate the noise and signal power.

This wrapper function extracts all required information from the SSR type

### Input

* s: Steady state response type

### Output

Saves a pdf to disk
""" ->
function plot_ftest(s::SSR; freq_of_interest::Real=modulationrate(s), side_freq::Real=1, spill_bins::Int=2,
    min_plot_freq::Real=1, max_plot_freq::Real=2.2*modulationrate(s), plot_channel::Int=1,
    fig_name::String="ftest.pdf", kwargs...)

    if !haskey(s.processing, "sweeps")
        warn("You need to calculate sweeps before you can display the ftest spectrum")

        if !haskey(s.processing, "epochs")
            warn("You need to calculate epochs to create sweeps")

            s = extract_epochs(s; kwargs...)
        end

        s = create_sweeps(s; kwargs...)
    end

    spectrum = EEG._ftest_spectrum(s.processing["sweeps"])
    spectrum = compensate_for_filter(s.processing, spectrum, samplingrate(s))
    frequencies = linspace(0, 1, int(size(spectrum, 1)))*samplingrate(s)/2

    plot_ftest(spectrum, frequencies, freq_of_interest, side_freq, spill_bins, min_plot_freq, max_plot_freq, plot_channel, fig_name)
end


function plot_ftest{T <: FloatingPoint}(sweeps::Array{T, 3}, fs::Real,
    freq_of_interest::Real, side_freq::Real, spill_bins::Int, min_plot_freq::Real, max_plot_freq::Real,
    plot_channel::Int, fig_name::String)

    spectrum    = EEG._ftest_spectrum(sweeps)
    # Does not compensate for filtering
    frequencies = linspace(0, 1, int(size(spectrum, 1)))*float(fs)/2

    plot_ftest(spectrum, frequencies, freq_of_interest, side_freq, spill_bins; kwargs...)
end


@doc doc"""
Visualise the data used to determine the f statistic.

The spectrum is plotted in black, the noise estimate is highlited in red, and the signal marked in green.
Dots indicate the noise and signal power.

### Input

* spectrum: Spectrum of data to plot
* frequencies: The frequencies associated with each point in the spectrum
* freq_of_interest: The frequency to analyse
* side_freq: How many Hz each side to use to determine the noise estimate
* spill_bins: How many bins either side of the freq_of_interest to ignore in noise estimate. This is in case of spectral leakage
* min_plot_freq: Minimum frequency to plot in Hz
* max_plot_freq: Maximum frequency to plot in Hz
* plot_channel: If there are multiple dimensions, this specifies which to plot
* fig_name: Figure name to save the pdf to

### Output

Saves a pdf to disk
""" ->
function plot_ftest{T <: FloatingPoint}(spectrum::Array{Complex{T},2}, frequencies::AbstractArray,
    freq_of_interest::Real, side_freq::Real, spill_bins::Int, min_plot_freq::Real, max_plot_freq::Real,
    plot_channel::Int, fig_name::String)

    spectrum = spectrum[:, plot_channel]

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

    raw_plot = layer(x=frequencies[idx_low_plot:idx_high_plot], y=abs(spectrum[idx_low_plot:idx_high_plot, :]).^2, Geom.line, Theme(default_color=color("black")))
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

