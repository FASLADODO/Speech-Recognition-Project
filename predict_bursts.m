%predict_bursts is a continutation of detectbursts. All shared variables
%are defined there.
%
% Other inputs: prior - the estimated probability of a burst at any time
%               probabilityThreshold - the min probability for a burst period
%               durationThreshold - the min duration for a burst period
%
% Written by Collin Potts, based on predict by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [closures,releases]=predict_bursts(LMDist,nonLMDist,T,V1,F1,F2,B1,B2,B3,B4)

%[T, V1, Fs] = vectorize(soundfile);
%PATH = 'C:\Users\colli\OneDrive\Documents\Speech Recognition UROP\MatLab Code\Textgrid Creator\';
%[F1, F2, ~, ~, B1, B2, B3, B4, ~] = func_PraatFormants([soundfile], ...
%                                                  0.025, 80/Fs, 1, floor(T(end)*Fs/80));
prior=0.04;
probabilityThreshold=0.4;
durationThreshold=0.015;

V2=[F1 F2 B1 B2 B3 B4];
if length(V2)>length(V1)
    V2=V2(1:length(V1),:);
else
    V1=V1(1:length(V2),:);
end
V=[V1 V2];
% Probabilities
LMPdf = pdf(LMDist, V);
posterior = LMPdf*prior ./ ...
    (LMPdf*prior + pdf(nonLMDist, V)*(1-prior));

posterior=smooth(posterior,15);
% Predicted closures and releases

% Preallocate some space for recording times.
closures = zeros(20, 1);
releases = zeros(20, 1);

nLMs = 0;

i = 0;
while i < numel(posterior)
    i = i + 1;
    if posterior(i) > probabilityThreshold
        closureTime = T(i);
        while i < numel(posterior)
            i = i + 1;
            if posterior(i) < probabilityThreshold
                break
            end
        end
        releaseTime = T(i);
        % Only record nasal if the time is above durationThreshold
        if releaseTime - closureTime > durationThreshold
            nLMs = nLMs + 1;
            closures(nLMs) = closureTime;
            releases(nLMs) = releaseTime;
        end
    end
end

closures(nLMs+1:end) = [];
releases(nLMs+1:end) = [];

end

