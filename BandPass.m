function [ signal,freq, T, power ] = BandPass( waveform,hamming_window_length,window_overlap_amount,fft_n,waveform_samplingFrequency,plots,low_cutOffFreq,high_cutOffFreq )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

band6_high = 8000;

[S,F,T,P] = spectrogram(waveform,hamming_window_length,window_overlap_amount,fft_n,waveform_samplingFrequency);
S = abs(S);
signal = S((round(low_cutOffFreq/F(end)*length(F)):(round(high_cutOffFreq/F(end)*length(F)))),:); % calculate energy from intensity of frequency output per time
power = (P((round(low_cutOffFreq/F(end)*length(F)):(round(high_cutOffFreq/F(end)*length(F)))),:,:));
freq = F(round(low_cutOffFreq/F(end)*length(F)):(round(high_cutOffFreq/F(end)*length(F))));

if plots
    figure;

    surf(T,freq,10*log10(power),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');
end

end

