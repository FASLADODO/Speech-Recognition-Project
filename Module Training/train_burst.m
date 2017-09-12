%train_burst examines sound data at times when spectral bursts are labeled
%in order to create a gaussian mixture model of probable burst characteristics
%
% Inputs: trainFilePrefixes - the prefixes of WAV and TextGrid file pairs
%         to be used for training
%
% Outputs: burstDist - a GMM with values corresponding to measured burst features
%          nonburstDist - a GMM with values corresponding to measured non-burst features
%
% Written by Collin Potts, based on train_nasal by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [burstDist, nonburstDist ] = train_burst( trainFilePrefixes )

%VECTOR_DIMENSIONS = 12;
VECTOR_DIMENSIONS = 12;
PATH = 'C:\Users\colli\OneDrive\Documents\Speech Recognition UROP\MatLab Code\Textgrid Creator\';

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
burstV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
nonburstV = zeros(numel(trainFilePrefixes)*1000, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
burstVIndex = 0;
nonburstVIndex = 0;

for iFile = 1:numel(trainFilePrefixes)
    [T, V1, Fs] = vectorize([trainFilePrefixes{iFile} '.wav']);
    [F1, F2, ~, ~, B1, B2, B3, B4, ~] = func_PraatFormants([PATH trainFilePrefixes{iFile} '.wav'], ...
                                                  0.025, 80/Fs, 1, floor(T(end)*Fs/80));
    V2=[F1 F2 B1 B2 B3 B4];
    if length(V2)>length(V1)
        V2=V2(1:length(V1),:);
    else
        V1=V1(1:length(V2),:);
    end
    V=[V1 V2];
    [mins, maxs] = ...
        readtextgridbursts([trainFilePrefixes{iFile} '.TextGrid']);

    burstIndices = isininterval(T, mins, maxs);
    burstCount = sum(burstIndices);
    nonburstCount = numel(burstIndices) - burstCount;

    burstV(burstVIndex + 1 : burstVIndex + burstCount, :) = ...
        V(burstIndices, :);
    burstVIndex = burstVIndex + burstCount;
    nonburstV(nonburstVIndex + 1 : nonburstVIndex + nonburstCount, :) = ...
        V(~burstIndices, :);
    nonburstVIndex = nonburstVIndex + nonburstCount;
end

% Truncate extra zeroes
burstV(burstVIndex + 1 : end, :) = [];
nonburstV(nonburstVIndex + 1 : end, :) = [];

disp('Training model...');

burstDist = fitgmdist(burstV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonburstDist = fitgmdist(nonburstV, 8, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end

