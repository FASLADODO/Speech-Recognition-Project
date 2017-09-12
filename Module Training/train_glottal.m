%train_glottal examines sound data at times when glottal periods are labeled
%in order to create a gaussian mixture model of probable glottal characteristics
%
% Inputs: trainFilePrefixes - the prefixes of WAV and TextGrid file pairs
%         to be used for training
%
% Outputs: glottalDist - a GMM with values corresponding to measured glottal features
%          nonglottalDist - a GMM with values corresponding to measured non-glottal features
%          
% Written by Collin Potts, based on train_nasal by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [glottalDist, nonglottalDist ] = train_glottal( trainFilePrefixes )

VECTOR_DIMENSIONS = 6;

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
glottalV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
nonglottalV = zeros(numel(trainFilePrefixes)*1000, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
glottalVIndex = 0;
nonglottalVIndex = 0;

for iFile = 1:numel(trainFilePrefixes)
    [T, V, ~] = vectorize([trainFilePrefixes{iFile} '.wav']);
    [mins, maxs] = ...
        readtextgridglottals([trainFilePrefixes{iFile} '.TextGrid']);

    glottalIndices = isininterval(T, mins, maxs);
    glottalCount = sum(glottalIndices);
    nonglottalCount = numel(glottalIndices) - glottalCount;

    glottalV(glottalVIndex + 1 : glottalVIndex + glottalCount, :) = ...
        V(glottalIndices, :);
    glottalVIndex = glottalVIndex + glottalCount;
    nonglottalV(nonglottalVIndex + 1 : nonglottalVIndex + nonglottalCount, :) = ...
        V(~glottalIndices, :);
    nonglottalVIndex = nonglottalVIndex + nonglottalCount;
end

% Truncate extra zeroes
glottalV(glottalVIndex + 1 : end, :) = [];
nonglottalV(nonglottalVIndex + 1 : end, :) = [];

disp('Training model...');

glottalDist = fitgmdist(glottalV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonglottalDist = fitgmdist(nonglottalV, 8, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end

