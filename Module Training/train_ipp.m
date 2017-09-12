function [ IPPDist, nonIPPDist ] = train_ipp( trainFilePrefixes )
%TRAIN train on labeled wav files. For example, if 'SI648' is in
% trainFilePrefixes, this file will read from SI648.wav and SI648.TextGrid.
% Inputs:
%   trainFilePrefixes: a cell array of strings, e.g. {'SI648', 'FCJF0 SA1'}
% Outputs:
%   IPPDist: a Gaussian mixture distribution of vectors representing time
%      slices corresponding to irregular pitch periods
%   nonIPPDist: a Gaussian mixture distribution of vectors representing 
%      time slices corresponding to non irregular pitch periods

%VECTOR_DIMENSIONS = 12;
VECTOR_DIMENSIONS = 6;

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
IPP_V = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
nonIPP_V = zeros(numel(trainFilePrefixes)*1000, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
IPP_VIndex = 0;
nonIPP_VIndex = 0;

PATH='C:\Users\colli\OneDrive\Documents\Speech Recognition UROP\MatLab Code\Textgrid Creator\';

for iFile = 1:numel(trainFilePrefixes)
    [T, V, Fs] = vectorize([PATH trainFilePrefixes{iFile} '.wav']);
    [mins, maxs] = ...
        readtextgridipps([PATH trainFilePrefixes{iFile} '.TextGrid']);

    IPPIndicies = isininterval(T, mins, maxs);
    IPPCount = sum(IPPIndicies);
    nonIPPCount = numel(IPPIndicies) - IPPCount;

    IPP_V(IPP_VIndex + 1 : IPP_VIndex + IPPCount, :) = ...
        V(IPPIndicies, :);
    IPP_VIndex = IPP_VIndex + IPPCount;
    nonIPP_V(nonIPP_VIndex + 1 : nonIPP_VIndex + nonIPPCount, :) = ...
        V(~IPPIndicies, :);
    nonIPP_VIndex = nonIPP_VIndex + nonIPPCount;
end

% Truncate extra zeroes
IPP_V(IPP_VIndex + 1 : end, :) = [];
nonIPP_V(nonIPP_VIndex + 1 : end, :) = [];
alpha = numel(IPP_V) / (numel(IPP_V) + numel(nonIPP_V));

disp('Training model...');
size(IPP_V)
IPPDist = fitgmdist(IPP_V, 6, 'Regularize', 1e-4, ...
    'Options', statset('Display', 'final'));
nonIPPDist = fitgmdist(nonIPP_V, 6, 'Regularize', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end