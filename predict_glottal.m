function [ closures, releases ] = ...
    predict_glottal( LMDist, nonLMDist,T,V1,F1,F2,F3,B1,B2 )
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
prior=0.3;
probabilityThreshold=0.7;
durationThreshold=0.02;

sumV=V1(:,1);
eRatio=zeros(length(V1),1);
for i=1:length(V1)
    sumV(i)=sum(V1(i,:));
    eRatio(i)=sum(V1(i,1:4))/sum(V1(i,:));
end
V=[V1 sumV F1 F2 F3 B1 B2];

% Probabilities
%LMPdf = pdf(LMDist, V);
%posterior = LMPdf*prior ./ ...
%    (LMPdf*prior + pdf(nonLMDist, V)*(1-prior));
minV=mean(sumV)*0.015;
posterior = smooth(sumV>minV,10);
eRatio=smooth(eRatio,10);
for i=1:length(posterior)
    posterior(i)=posterior(i)*eRatio(i);
end

%plot(T,posterior)

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

