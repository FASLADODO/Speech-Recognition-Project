%predict_fts is a continutation of detectfts. All shared variables
%are defined there.
%
% Other inputs: prior - the estimated probability of a ft at any time
%               probabilityThreshold - the min probability for a ft period
%               durationThreshold - the min duration for a ft period
%
% Written by Collin Potts, based on predict by Leon from the SCG
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ closures, releases ] = ...
    predict_fts(ftcDist, ftrDist, nonftDist,T,V1,F1,F2,F3,B1 )

%[T, V1, Fs] = vectorize(soundfile);
%[F1, F2, F3, ~, B1, ~, ~, ~, ~] = func_PraatFormants(soundfile, ...
%                                          0.025, 80/Fs, 1, floor(T(end)*Fs/80));
prior=0.04;
probabilityThreshold=0.5;
durationThreshold=0.02;

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
% Probabilities
ftcPdf = pdf(ftcDist, V);
ftrPdf = pdf(ftrDist, V);
posterior_c = ftcPdf*prior ./ ...
    ((ftcPdf+ftrPdf)*prior + pdf(nonftDist, V)*(1-prior));
posterior_r = ftrPdf*prior ./ ...
    ((ftcPdf+ftrPdf)*prior + pdf(nonftDist, V)*(1-prior));

posterior_c=smooth(posterior_c,15);
posterior_r=smooth(posterior_r,15);
% Predicted closures and releases

% Preallocate some space for recording times.
starts_c = zeros(20, 1);
stops_c = zeros(20, 1);

nLMs = 0;

i = 0;
while i < numel(posterior_c)
    i = i + 1;
    if posterior_c(i) > probabilityThreshold
        closureTime = T(i);
        while i < numel(posterior_c)
            i = i + 1;
            if posterior_c(i) < probabilityThreshold
                break
            end
        end
        releaseTime = T(i);
        % Only record nasal if the time is above durationThreshold
        if releaseTime - closureTime > durationThreshold
            nLMs = nLMs + 1;
            starts_c(nLMs) = closureTime;
            stops_c(nLMs) = releaseTime;
        end
    end
end
starts_c(nLMs+1:end) = [];
stops_c(nLMs+1:end) = [];

starts_r = zeros(20, 1);
stops_r = zeros(20, 1);

nLMs = 0;

i = 0;
while i < numel(posterior_r)
    i = i + 1;
    if posterior_r(i) > probabilityThreshold
        closureTime = T(i);
        while i < numel(posterior_r)
            i = i + 1;
            if posterior_r(i) < probabilityThreshold
                break
            end
        end
        releaseTime = T(i);
        % Only record nasal if the time is above durationThreshold
        if releaseTime - closureTime > durationThreshold
            nLMs = nLMs + 1;
            starts_r(nLMs) = closureTime;
            stops_r(nLMs) = releaseTime;
        end
    end
end
starts_r(nLMs+1:end) = [];
stops_r(nLMs+1:end) = [];

closures=0.5*(starts_c+stops_c);
releases=0.5*(starts_r+stops_r);
end

