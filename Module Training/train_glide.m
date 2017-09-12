%train_glide examines sound data at times when glides are labeled
%in order to create a gaussian mixture model of probable glide characteristics
%
% Inputs: trainFilePrefixes - the prefixes of WAV and TextGrid file pairs
%         to be used for training
%
% Outputs: glideDist - a GMM with values corresponding to measured glide features
%          nonglideDist - a GMM with values corresponding to measured non-glide features
%          
% Written by Collin Potts, based on train_nasal by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [glideDist, nonglideDist ] = train_glide( trainFilePrefixes )

%VECTOR_DIMENSIONS = 12;
VECTOR_DIMENSIONS = 12;
PATH = 'C:\Users\colli\OneDrive\Documents\Speech Recognition UROP\MatLab Code\Textgrid Creator\';

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
glideV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
nonglideV = zeros(numel(trainFilePrefixes)*1000, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
glideVIndex = 0;
nonglideVIndex = 0;

for iFile = 1:numel(trainFilePrefixes)
    [T, V1, Fs] = vectorize([trainFilePrefixes{iFile} '.wav']);
    [F1, F2, F3, ~, B1, B2, B3, ~, ~] = func_PraatFormants([PATH trainFilePrefixes{iFile} '.wav'], ...
                                                  0.025, 80/Fs, 1, floor(T(end)*Fs/80));
    V1=[smooth(diff(V1(:,1)),30) smooth(diff(V1(:,2)),30) smooth(diff(V1(:,3)),30) ...
        smooth(diff(V1(:,4)),30) smooth(diff(V1(:,5)),30) smooth(diff(V1(:,6)),30)]
    V1=[V1; V1(end,:)];
    V2=[F1 F2 F3 B1 B2 B3];
    if length(V2)>length(V1)
        V2=V2(1:length(V1),:);
    else
        V1=V1(1:length(V2),:);
    end
    V=[V1 V2];
    [mins, maxs] = ...
        readtextgridglides([trainFilePrefixes{iFile} '.TextGrid'])

    glideIndices = isininterval(T, mins, maxs);
    glideCount = sum(glideIndices);
    nonglideCount = numel(glideIndices) - glideCount;

    glideV(glideVIndex + 1 : glideVIndex + glideCount, :) = ...
        V(glideIndices, :);
    glideVIndex = glideVIndex + glideCount;
    nonglideV(nonglideVIndex + 1 : nonglideVIndex + nonglideCount, :) = ...
        V(~glideIndices, :);
    nonglideVIndex = nonglideVIndex + nonglideCount;
end

% Truncate extra zeroes
glideV(glideVIndex + 1 : end, :) = [];
nonglideV(nonglideVIndex + 1 : end, :) = [];

disp('Training model...');
glideDist = fitgmdist(glideV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonglideDist = fitgmdist(nonglideV, 8, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end

