%train_ft examines sound data at times when formant transitions are labeled
%in order to create a gaussian mixture model of probable transition characteristics
%
% Inputs: trainFilePrefixes - the prefixes of WAV and TextGrid file pairs
%         to be used for training
%
% Outputs: ftcDist - a GMM with values corresponding to measured formant closure features
%          ftrDist - a GMM with values corresponding to measured formant release features
%          nonftDist - a GMM with values corresponding to measured non-transition features
%          
% Written by Collin Potts, based on train_nasal by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ftcDist, ftrDist, nonftDist ] = train_ft( trainFilePrefixes )

%VECTOR_DIMENSIONS = 12;
VECTOR_DIMENSIONS = 12;
PATH = 'C:\Users\colli\OneDrive\Documents\Speech Recognition UROP\MatLab Code\Textgrid Creator\';

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
ftcV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
ftrV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
nonftV = zeros(numel(trainFilePrefixes)*1000, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
ftcVIndex = 0;
ftrVIndex = 0;
nonftVIndex = 0;

for iFile = 1:numel(trainFilePrefixes)
    [T, V1, Fs] = vectorize([trainFilePrefixes{iFile} '.wav']);
    [F1, F2, F3, ~, B1, ~, ~, ~, ~] = func_PraatFormants([PATH trainFilePrefixes{iFile} '.wav'], ...
                                              0.025, 80/Fs, 1, floor(T(end)*Fs/80));
    V1=V1(1:end-1,1:2);
    V2=[abs(smooth(diff(F1))) abs(smooth(diff(F2))) abs(smooth(diff(F3))) abs(smooth(diff(B1)))];
    V1_before=V1(:,:);
    V2_before=V2(:,:);
    for i=11:length(V1)
        V1_before(i,:)=V1(i-10,:);
        V2_before(i,:)=V2(i-10,:);
    end
    V1_after=V1(:,:);
    V2_after=V2(:,:);
    for i=1:length(V1)-10
        V1_after(i,:)=V1(i+10,:);
        V2_after(i,:)=V2(i+10,:);
    end
    V1=[V1_before V1_after];
    V2=[V2_before V2_after];
    if length(V2)>length(V1)
        V2=V2(1:length(V1),:);
    else
        V1=V1(1:length(V2),:);
    end
    V=[V1 V2];
    [closures, releases] = ...
        readtextgridfts([trainFilePrefixes{iFile} '.TextGrid']);

    ftcIndices = isininterval(T, closures-0.015, closures+0.015);
    ftrIndices = isininterval(T, releases-0.015, releases+0.015);
    ftcIndices=ftcIndices(1:end-1);
    ftrIndices=ftrIndices(1:end-1);
    ftcCount = sum(ftcIndices);
    ftrCount = sum(ftrIndices);
    nonftCount = numel(ftcIndices) - ftcCount- ftrCount;

    ftcV(ftcVIndex + 1 : ftcVIndex + ftcCount, :) = ...
        V(ftcIndices, :);
    ftrV(ftrVIndex + 1 : ftrVIndex + ftrCount, :) = ...
        V(ftrIndices, :);
    ftcVIndex = ftcVIndex + ftcCount;
    ftrVIndex = ftrVIndex + ftcCount;
    length(V)
    length(ftcIndices)
    length(ftrIndices)
    nonftV(nonftVIndex + 1 : nonftVIndex + nonftCount, :) = ...
        V(~(ftcIndices+ftrIndices), :);
    nonftVIndex = nonftVIndex + nonftCount;
end

% Truncate extra zeroes
ftcV(ftcVIndex + 1 : end, :) = [];
ftrV(ftrVIndex + 1 : end, :) = [];
nonftV(nonftVIndex + 1 : end, :) = [];

disp('Training model...');
ftcDist = fitgmdist(ftcV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftrDist = fitgmdist(ftrV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonftDist = fitgmdist(nonftV, 8, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end

