%predict_glides is a continutation of detectglides. All shared variables
%are defined there.
%
% Other inputs: prior - the estimated probability of a glide at any time
%               probabilityThreshold - the min probability for a glide period
%               durationThreshold - the min duration for a glide period
%
% Written by Collin Potts, based on predict by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ mins ] = ...
    predict_glides( LMDist, nonLMDist,T,V1,F1,F2,F3 )
         
%[T, V1, Fs] = vectorize(soundfile);
%[F1, F2, F3, ~, B1, B2, B3, ~, ~] = func_PraatFormants(soundfile, ...
%                                              0.025, 80/Fs, 1, floor(T(end)*Fs/80));
prior=0.06;
probabilityThreshold=0.7;
durationThreshold=0.05;

ratioV=zeros(length(V1),6);
normalV=zeros(length(V1),6);
sumV=zeros(length(V1),1);
for i=1:length(V1)
    sumV(i)=sum(V1(i,:));
    normalV(i,:)=V1(i,:) ./ sum(V1(i,:));
    for j=1:6
        ratioV(i,j)=normalV(i,j)/(1-normalV(i,j));
    end
end
%V1=[ratioV sumV];
%V2=[F1 F2 F3 B1 B2];
%if length(V2)>length(V1)
%    V2=V2(1:length(V1),:);
%else
%    V1=V1(1:length(V2),:);
%end
%V=[V1 V2];
V=[normalV sumV sumV/max(sumV) F1 F2-F1 F3-F2 F3-F1];
% Probabilities
LMPdf = pdf(LMDist, V);
posterior = LMPdf*prior ./ ...
    (LMPdf*prior + pdf(nonLMDist, V)*(1-prior));

posterior=smooth(posterior,15);
% Predicted closures and releases

% Preallocate some space for recording times.
closures = zeros(20, 1);
releases = zeros(20, 1);
mins = zeros(20, 1);

nLMs = 0;

i = 0;
while i < numel(posterior)
    i = i + 1;
    if posterior(i) > probabilityThreshold
        local_min=1000000;
        min_index=i;
        closureTime = T(i);
        while i < numel(posterior)
            energy=V1(i,1)+V1(i,2)+V1(i,3)+V1(i,4)+V1(i,5)+V1(i,6);
            if energy<local_min
                local_min=energy;
                min_index=i;
            end
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
            mins(nLMs) = T(min_index);
        end
    end
end
closures(nLMs+1:end) = [];
releases(nLMs+1:end) = [];
mins(nLMs+1:end) = [];

end

