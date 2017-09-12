function [ closures, releases ] = ...
    predict_nasals( LMDist, nonLMDist,T,V,F0,F1 )
%PREDICT predicts whether each time point is a nasal based on the given
%model.
%Inputs:
%   soundfile: the name of a .wav file
%   nasalPrior: the prior probability (e.g. 0.05) that a nasal is being
%       spoken at any given time
%   nasalDist: a GMM of the nasal measurement vector
%   nonnasalDist: a GMM of the nonnasal measurement vector
%   probabilityThreshold: the threshold posterior must attain to trigger a
%       predicted nasal closure and release
%   durationThreshold: the threshold duration (in secs) the posterior must 
%       sustain above the probabilityThreshold in order to predict a 
%       closure and release

%[T, V, ~] = vectorize(soundfile);

% Probabilities
%LMPdf = pdf(LMDist, V);
%posterior = LMPdf*prior ./ ...
%    (LMPdf*prior + pdf(nonLMDist, V)*(1-prior));
prior=0.06;
probabilityThreshold=0.7;
durationThreshold=0.030;

ratioV=zeros(length(V),1);
sumV=zeros(length(V),1);
prob=zeros(length(V),1);
F1=smooth(F1,20);
for i=1:length(V)
    sumV(i) = sum(V(i,:));
    ratioV(i) = V(i,1)/sum(V(i,:));
end
sumV=smooth(sumV,20);
ratioV=smooth(ratioV,20);
for i=1:length(V)
    if sumV(i)>1 && ratioV(i)>0.7 && sumV(i)<8 && F0(i)
        prob(i)=1;
    end
end
posterior=smooth(prob);

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

