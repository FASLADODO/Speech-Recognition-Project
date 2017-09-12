%detect_ipp.m
%
%Function that detects ipp intervals using the trained data sets from
%train_ipp. Method of implementation for incorporating Gaussian
%distributions in initial detection credited to Jenny from the RLE Speech
%Communications Group.
%
%Input: 
%       1. ippDist - Gaussian distribution representing time slices where
%irregular pitch periods occur
%       2. nonippDist - Gaussian distribution representing time slices where
%irregular pitch periods do not occur
%       3. filename - path to WAV file that is to be detected for IPP
%
%Output:
%       1. T - time slices from vectorize.m
%       2. posterior - vector of probabilities of an ipp occuring at a point in 
% T
%       3. finalClosures - indicates points in T where an IPP begins
%       4. finalReleases - indicates points in T where an IPP ends
%       5. F0 - pitch determined at 1ms frames in the WAV file

function [finalClosures, finalReleases] = predict_ipp(soundfile,ippDist,nonippDist,T,V,F0)
    ippPrior = 0.11;
    probabilityThreshold = 0.9;
    durationThreshold = 0.03;
    
    windowsize = .025;
    frameshift = .001;
    maxF0 = 500;
    minF0 = 75;
    
    %[T, V, ~] = vectorize(soundfile);
  
    ippPdf = pdf(ippDist, V);
    posterior = ippPdf*ippPrior ./ ...
        (ippPdf*ippPrior + pdf(nonippDist, V)*(1-ippPrior));
    
    
    [F0, ~, ~] = func_SnackPitch_IM(soundfile, windowsize, frameshift, maxF0, minF0);% Probabilities
    
    % Predicted closures and releases
    closures = [];
    releases = [];
    clP = [];
    clR = [];

    numIPP = 0;
    indices = [];
    i = 0;
    j = 1;
    while i < numel(posterior)
        i = i + 1;
        probabilityIPP = posterior(i);
        potentialClosure = T(i);
        
        if posterior(i) > probabilityThreshold
            closureTime = T(i);
            indices(j) = round(potentialClosure * 1000);
            j=j+1;
            
            clP(end + 1) = posterior(i);
            while i < numel(posterior)
                i = i + 1;
                if posterior(i) < probabilityThreshold
                    clR(end + 1) = posterior(i);
                    break
                end
            end
            releaseTime = T(i);
            %Only record if the time is above durationThreshold
            if releaseTime - closureTime > durationThreshold
                numIPP = numIPP + 1;
                closures(numIPP) = closureTime;
                releases(numIPP) = releaseTime;
            end

        end
    end
    

    
    j = 1;
    pitchClosures = [];
    pitchReleases = [];
    
    
    for i=1:numel(F0)
        if F0(i)~=0
            soundStart = i;
            break
        end
    end
    
    for i=numel(F0):-1:1
        if F0(i)~=0
            soundEnd = i;
            break
        end
    end
    
    %Uses F0 at a certain point to extract intervals in the sound file
    %where the pitch cannot be identified, indicating that an IPP is
    %possible
    for i=1:numel(indices)
        if indices(i)<soundStart || indices(i)>soundEnd
            continue
        end
        [ippStartCorrected,ippEndCorrected] = linearScan(F0, indices(i));
        if ippEndCorrected-ippStartCorrected > durationThreshold && (ippStartCorrected ~= -1 && ippEndCorrected ~=-1)
            pitchClosures(j) = ippStartCorrected;
            pitchReleases(j) = ippEndCorrected;
        end        
    end
    

    finalClosures = [];
    finalReleases = [];
    
    %Using the predicted IPP periods from posterior, determines if those
    %intervals contain "0" pitch, indicative of an IPP, by intersecting the
    %ranges found earlier.
    for i=1:numel(closures)
        range1 = [closures(i), releases(i)];
        for j=1:numel(pitchClosures)
            range2 = [pitchClosures(j), pitchReleases(j)];
            if isRangesIntersect(range1, range2) 
                finalClosures(end+1) = closures(i);
                finalReleases(end+1) = releases(i);
                break
            end
        end
    end
    
    for i=1:numel(closures)
        detection = 0;
        startIndex = round(closures(i) * 1000);
        endIndex= round(releases(i) * 1000);
        for j=startIndex:endIndex
            if F0(j)==0
                detection = detection + 1;
            end
        end
        ratio = (detection) / (endIndex - startIndex);
        if ratio > .5
            finalClosures(end+1) = closures(i);
            finalReleases(end+1) = releases(i);
        end
    end
    finalClosures = sort(finalClosures);
    finalReleases = sort(finalReleases);
    
    
end