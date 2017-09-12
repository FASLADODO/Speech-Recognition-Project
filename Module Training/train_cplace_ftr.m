%train_cplace_ftr examines sound data at times when formant releases are labeled
%in order to create a gaussian mixture model of probable release characteristics
%
% Inputs: trainFilePrefixes - the prefixes of WAV and TextGrid file pairs
%         to be used for training
%
% Outputs: labDist - a GMM with values corresponding to measured labial release features
%          denDist - a GMM with values corresponding to measured dental release features
%          alvDist - a GMM with values corresponding to measured alvelor release features
%          palDist - a GMM with values corresponding to measured palatal release features
%          velDist - a GMM with values corresponding to measured velar release features
%          
% Written by Collin Potts, based on train_nasal by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [labDist, denDist, alvDist, palDist, velDist] = train_cplace_ftr( trainFilePrefixes )

%VECTOR_DIMENSIONS = 12;
VECTOR_DIMENSIONS = 12;
PATH = 'C:\Users\colli\OneDrive\Documents\Speech Recognition UROP\MatLab Code\Textgrid Creator\';

% These will be filled up with measurements taken from each of the training
% files. (For memory efficiency, here we preallocate a crude estimate of 
% what will be required.)
labV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
denV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
alvV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
palV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
velV = zeros(numel(trainFilePrefixes)*200, VECTOR_DIMENSIONS);
% The last use indices in the above arrays.
labVIndex = 0;
denVIndex = 0;
alvVIndex = 0;
palVIndex = 0;
velVIndex = 0;

for iFile = 1:numel(trainFilePrefixes)
    [T, V1, Fs] = vectorize([trainFilePrefixes{iFile} '.wav']);
    [F1, F2, F3, ~, B1, ~, ~, ~, ~] = func_PraatFormants([PATH trainFilePrefixes{iFile} '.wav'], ...
                                                  0.025, 80/Fs, 1, floor(T(end)*Fs/80));
    V1=V1(:,1:4);
    V2=[F1 F2];
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
    [lab,den,alv,pal,vel] = ...
        readtextgridftr([trainFilePrefixes{iFile} '.TextGrid']);

    labIndices = isininterval(T, lab-15, lab+15);
    labCount = sum(labIndices);
    denIndices = isininterval(T, den-15, den+15);
    denCount = sum(denIndices);
    alvIndices = isininterval(T, alv-15, alv+15);
    alvCount = sum(alvIndices);
    palIndices = isininterval(T, pal-15, pal+15);
    palCount = sum(palIndices);
    velIndices = isininterval(T, vel-15, vel+15);
    velCount = sum(velIndices);

    labV(labVIndex + 1 : labVIndex + labCount, :) = V(labIndices, :);
    labVIndex = labVIndex + labCount;
    denV(denVIndex + 1 : denVIndex + denCount, :) = V(denIndices, :);
    denVIndex = denVIndex + denCount;
    alvV(alvVIndex + 1 : alvVIndex + alvCount, :) = V(alvIndices, :);
    alvVIndex = alvVIndex + alvCount;
    palV(palVIndex + 1 : palVIndex + palCount, :) = V(palIndices, :);
    palVIndex = palVIndex + palCount;
    velV(velVIndex + 1 : velVIndex + velCount, :) = V(velIndices, :);
    velVIndex = velVIndex + velCount;
end

% Truncate extra zeroes
labV(labVIndex + 1 : end, :) = [];
denV(denVIndex + 1 : end, :) = [];
alvV(alvVIndex + 1 : end, :) = [];
palV(palVIndex + 1 : end, :) = [];
velV(velVIndex + 1 : end, :) = [];

disp('Training model...');
labDist = fitgmdist(labV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
denDist = fitgmdist(denV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
alvDist = fitgmdist(alvV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
palDist = fitgmdist(palV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
velDist = fitgmdist(velV, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));

disp('Model trained.');

end

