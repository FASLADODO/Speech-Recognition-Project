%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Vowel Landmark Detection
%
% Energy -> smoothing -> peak picking (Mermelstein)
%
% 2013 Suk-Myung Jesse Lee
% pooh390@gmail.com
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This function needs
% ReadSpeech.m 
% mermelstein.m
% smoothing.m

function times = VLD_Main(input_file, output_file)

% initialize & setup
%close all
%clc

% Params.
spec_window=256; % 16ms
spec_shift=80; % 5 ms
Lower_band=300;
Upper_band=900;
dip_Thr=2;
peak_Thr=17+70;
smooth_factor=10;

    
%initialize  
Loc_of_peak=0;  
Num_of_peak=0;
    
% file input    
speech = 2^15 * audioread(input_file);
[y,Fs]=audioread(input_file);
% get spectrogram and energy
spec=(abs(spectrogram(speech,spec_window,spec_window-spec_shift))).^2;
Band_energy=10*log10(sum(spec(4:15,:))); % 4 means 300 hz; 15 means 900 hz
    
% Smoothing 
[Smooth_energy] = smoothing(Band_energy,smooth_factor);
%plot(Smooth_energy)

% Peak picking
Begin=1;
End=length(Smooth_energy);
[Loc_of_peak, Num_of_peak]=mermelstein(Smooth_energy,Begin,End,dip_Thr,peak_Thr,Loc_of_peak,Num_of_peak); 
times = (Loc_of_peak/End)*(length(y)/Fs);


