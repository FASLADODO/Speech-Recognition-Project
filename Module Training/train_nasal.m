function [ nasalDist, nonnasalDist ] = train( trainFilePrefixes )
%TRAIN train on labeled wav files. For example, if 'SI648' is in
% trainFilePrefixes, this file will read from SI648.wav and SI648.TextGrid.
% Inputs:
%   trainFilePrefixes: a cell array of strings, e.g. {'SI648', 'FCJF0 SA1'}
% Outputs:
%   nasalDist: a Gaussian mixture distribution of vectors representing time
%      slices corresponding to nasals
%   nonnasalDist: a Gaussian mixture distribution of vectors representing 
%      time slices corresponding to non-nasals

%VECTOR_DIMENSIONS = 12;
VECTOR_DIMENSIONS = 6;

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
nasalV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
nonnasalV = zeros(numel(trainFilePrefixes)*1000, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
nasalVIndex = 0;
nonnasalVIndex = 0;

for iFile = 1:numel(trainFilePrefixes)
    [T, V, Fs] = vectorize([trainFilePrefixes{iFile} '.wav']);
    [mins, maxs] = ...
        readtextgridnasals([trainFilePrefixes{iFile} '.TextGrid']);

    nasalIndices = isininterval(T, mins, maxs);
    nasalCount = sum(nasalIndices);
    nonnasalCount = numel(nasalIndices) - nasalCount;

    nasalV(nasalVIndex + 1 : nasalVIndex + nasalCount, :) = ...
        V(nasalIndices, :);
    nasalVIndex = nasalVIndex + nasalCount;
    nonnasalV(nonnasalVIndex + 1 : nonnasalVIndex + nonnasalCount, :) = ...
        V(~nasalIndices, :);
    nonnasalVIndex = nonnasalVIndex + nonnasalCount;
end

% Truncate extra zeroes
nasalV(nasalVIndex + 1 : end, :) = [];
nonnasalV(nonnasalVIndex + 1 : end, :) = [];

disp('Training model...');

nasalDist = fitgmdist(nasalV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonnasalDist = fitgmdist(nonnasalV, 8, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end

