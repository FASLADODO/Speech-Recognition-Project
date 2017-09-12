%glideplace looks at times determined to be glides and determines whether
%the glide is an r, l, w, h, or y. This information is used to add
%detail to the vgplace tier.
%
% Inputs: wav_file - the address of the WAV file being analyzed
%         glide_times - determined times of glides
%         rDist,...,yDist - GMM correlated with each type of glide
%         T,...,B3 - sound data determined in the main program
%
% Outputs: glide_info - the predicted type of glide for each glide time
%
% Written by Collin Potts, MIT RLE Speech Communication Group
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [glide_info]=glideplace(wav_file,glide_times,rDist,lDist,wDist,hDist,yDist,T,V1,F1,F2,F3,B1,B2,B3)
%[T, V1, Fs] = vectorize(wav_file);
%[F1, F2, F3, ~, B1, B2, B3, ~, ~] = func_PraatFormants(wav_file, ...
%                                              0.025, 80/Fs, 1, floor(T(end)*Fs/80));
glide_indexes=zeros(length(glide_times),1);
for i=1:length(glide_times)
    glide_time=glide_times(i);
    differences=abs(T-glide_time);
    min_diff=min(differences);
    nearest=find(~(differences-min_diff));
    glide_indexes(i,1)=floor(mean(nearest));
end
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

r_prob=pdf(rDist,V);
l_prob=pdf(lDist,V);
%plot(T,[r_prob l_prob]);
w_prob=pdf(wDist,V);
h_prob=pdf(hDist,V);
y_prob=pdf(yDist,V);

glide_info=strings(length(glide_times));
options=[string('"r"') string('"l"') string('"w"') string('"h"') string('"y"')];
for i=1:length(glide_times)
    probs = [r_prob(glide_indexes(i)) l_prob(glide_indexes(i)) ...
        w_prob(glide_indexes(i)) h_prob(glide_indexes(i)) y_prob(glide_indexes(i))];
    best = find(probs==max(probs));
    if isempty(best)
    glide_info(i)=options(1);
    else
    glide_info(i)=options(best(1));
    end
end