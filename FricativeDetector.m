function [ closure,release ] = FricativeDetector( wavFile, plot_graphs_bool )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

hamming_window_size = 256;
window_overlap_size = 176;
FFT_n= 512;
band_pass_low_freq = 4000;
band_pass_high_freq = 8000;
smoothing_window_length = 10;

[ soundMono, Fs ] = WavToMonoMatrix( wavFile );
[signal,freq,time,power] = BandPass( soundMono, hamming_window_size, window_overlap_size, FFT_n,Fs,plot_graphs_bool,band_pass_low_freq,band_pass_high_freq);
[ smoothCOG, totalEnergy, output ] = SCOG_function_only(time,power,freq,signal,smoothing_window_length,plot_graphs_bool);
[closure,release] = FricativeExtract(output,time);

end

