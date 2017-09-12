%train_glide_place examines sound data at times when glides are labeled
%in order to create a gaussian mixture model of glide characteristics
%
% Inputs: trainFilePrefixes - the prefixes of WAV and TextGrid file pairs
%         to be used for training
%
% Outputs: rDist - a GMM with values corresponding to measured r glide features
%          lDist - a GMM with values corresponding to measured l glide features
%          wDist - a GMM with values corresponding to measured w glide features
%          hDist - a GMM with values corresponding to measured h glide features
%          yDist - a GMM with values corresponding to measured y glide features
%          
% Written by Collin Potts, based on train_nasal by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [rDist, lDist, wDist, hDist, yDist] = train_glide_place( trainFilePrefixes )

VECTOR_DIMENSIONS = 12;
PATH = 'C:\Users\colli\OneDrive\Documents\Speech Recognition UROP\MatLab Code\Textgrid Creator\';

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
rV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
lV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
wV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
hV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
yV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
rVIndex = 0;
lVIndex = 0;
wVIndex = 0;
hVIndex = 0;
yVIndex = 0;

for iFile = 1:numel(trainFilePrefixes)
    [T, V1, Fs] = vectorize([trainFilePrefixes{iFile} '.wav']);
    [F1, F2, F3, ~, B1, B2, B3, ~, ~] = func_PraatFormants([PATH trainFilePrefixes{iFile} '.wav'], ...
                                                  0.025, 80/Fs, 1, floor(T(end)*Fs/80));
    V1=[smooth(diff(V1(:,1)),30) smooth(diff(V1(:,2)),30) smooth(diff(V1(:,3)),30) ...
        smooth(diff(V1(:,4)),30) smooth(diff(V1(:,5)),30) smooth(diff(V1(:,6)),30)];
    V1=[V1; V1(end,:)];
    V2=[F1 F2 F3 B1 B2 B3];
    if length(V2)>length(V1)
        V2=V2(1:length(V1),:);
    else
        V1=V1(1:length(V2),:);
    end
    V=[V1 V2];
    [r,l,w,h,y] = ...
        readtextgridglideplaces([trainFilePrefixes{iFile} '.TextGrid']);

    rIndices = isininterval(T, r-15, r+15);
    rCount = sum(rIndices);
    lIndices = isininterval(T, l-15, l+15);
    lCount = sum(lIndices);
    wIndices = isininterval(T, w-15, w+15);
    wCount = sum(wIndices);
    hIndices = isininterval(T, h-15, h+15);
    hCount = sum(hIndices);
    yIndices = isininterval(T, y-15, y+15);
    yCount = sum(yIndices);

    rV(rVIndex + 1 : rVIndex + rCount, :) = V(rIndices, :);
    rVIndex = rVIndex + rCount;
    lV(lVIndex + 1 : lVIndex + lCount, :) = V(lIndices, :);
    lVIndex = lVIndex + lCount;
    wV(wVIndex + 1 : wVIndex + wCount, :) = V(wIndices, :);
    wVIndex = wVIndex + wCount;
    hV(hVIndex + 1 : hVIndex + hCount, :) = V(hIndices, :);
    hVIndex = hVIndex + hCount;
    yV(yVIndex + 1 : yVIndex + yCount, :) = V(yIndices, :);
    yVIndex = yVIndex + yCount;
end

% Truncate extra zeroes
rV(rVIndex + 1 : end, :) = [];
lV(lVIndex + 1 : end, :) = [];
wV(wVIndex + 1 : end, :) = [];
hV(hVIndex + 1 : end, :) = [];
yV(yVIndex + 1 : end, :) = [];

disp('Training model...');
rDist = fitgmdist(rV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
lDist = fitgmdist(lV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
wDist = fitgmdist(wV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
hDist = fitgmdist(hV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
yDist = fitgmdist(yV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end

