%vplace determines articulatory characteristics of a vowel or glide,
%specifically high/mid/low and front/back
%
% Inputs: wav_file - the address of the WAV file being examined
%         v_times - the times where vowels are glides occur
%         T,F1,F2 - sound data that is calculated in the main program
%
% Outputs: characteristics - an array, where each row contains the
%          articulatory data for that vowel or glide time
%
% Written by Collin Potts, MIT RLE Speech Communication Group
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [characteristics]=vplace(wav_file,v_times,T,F1,F2)
%[T, V1, Fs] = vectorize(wav_file);
%[F1, F2, F3, ~, B1, B2, B3, ~, ~] = func_PraatFormants(wav_file, ...
%                                              0.025, 80/Fs, 1, floor(T(end)*Fs/80));
v_indexes=zeros(length(v_times),1);
for i=1:length(v_times)
    v_time=v_times(i);
    differences=abs(T-v_time);
    min_diff=min(differences);
    index=find(~(differences-min_diff));
    v_indexes(i,1)=index(1);
end
v_before=v_indexes-10;
v_before(v_before<1)=1;
v_after=v_indexes+10;
v_after(v_after>length(F1))=length(F1);
avg_F1s=(F1(v_before)+F1(v_indexes)+F1(v_after))/3;
avg_F2s=(F2(v_before)+F2(v_indexes)+F2(v_after))/3;
scaled_F1s=avg_F1s/mean(F1(F1>0));
scaled_F2s=avg_F2s/mean(F2(F2>0));
characteristics=strings(length(v_indexes),4);
for i=1:length(v_indexes)
    if avg_F1s(i)>600
        characteristics(i,1)=string('"<low>"');
    elseif avg_F1s(i)<400
        characteristics(i,1)=string('"<high>"');
    else
        characteristics(i,1)=string('"<mid>"');
    end
    if avg_F2s(i)<1200
        characteristics(i,2)=string('"<back>"');
    else
        characteristics(i,2)=string('"<front>"');
    end
    if avg_F2s(i)-avg_F1s(i)<400
        characteristics(i,3)=string('"<ctr>"');
    elseif avg_F1s(i)<300
        characteristics(i,3)=string('"<atr>"');
    end
end
end