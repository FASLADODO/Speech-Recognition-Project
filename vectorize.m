function [ T, V, Fs ] = vectorize( soundfile )
%VECTORIZE Convert wav file to sequence of vectors used for classification
%Outputs:
%T: vector of times
%V: size(T) x 6 matrix with E1, E2, E3, E4, E5, E6 for each timestamp

%disp(['Taking measurements from ' soundfile '...']);

[sound, Fs] = audioread(soundfile);
sound = sound(:, 1);

% arguments for EnergyBands
hamming_window_size = 256;
window_overlap_size = 176;
FFT_n= 65536;
smoothing_window_length = 10;
[ ~, V, ~, ~, ~, ~, ~, T ] = EnergyBands(sound, Fs, hamming_window_size,...
    window_overlap_size, FFT_n, false, [1 2 3 4 5 6],...
    smoothing_window_length);

V = V';

% Uncomment the following line to include band energy derivatives in the
% vector. You will also need to change VECTOR_DIMENSIONS in train.m.

% V = [V, [0 0 0 0 0 0; diff(V)]];

%disp(['Finished taking measurements from ' soundfile '.']);

end

