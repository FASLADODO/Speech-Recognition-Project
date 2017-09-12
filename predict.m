%create_Textgrid uses modules to find and classify landmarks in a WAV file
%in a manner that is compatible with the Speech Communication Group's
%ASR Consolidator. Individual modules are written by many different authors
%from the Speech Communication Group, and they are given credit within
%each module. The entire program is assembled as the first step to a fully
%automated speech recognition system. 
%
% Inputs: wav_file - A string of the address of a WAV file containing speech
%         For example, wav_file='C:\Users\colli\OneDrive\Documents\words1nod.wav'
%
% Outputs: There is no direct output, but the program creates a Textgrid
%          file in the same location as the program itself
%
% Created and assembled by Collin Potts, MIT RLE Speech Communication Group
%
% Last updated June 13th, 2017
%
% Known Bugs: No specific bugs, but the program's attempts to predict
% features are inherently incomplete, as even humans cannot understand
% speech perfectly

function [array,tiers]=predict(wav_file)

%calculate formants, harmonics, and energy levels
[T,V,Fs]=vectorize(wav_file);
[F1,F2,F3,~,B1,B2,B3,~]=func_PraatFormants(wav_file,0.01,80/Fs,1,floor(T(end)*Fs/80));
[F0, ~, ~] = func_SnackPitch_IM(wav_file, 0.01, 80/Fs, 500, 75);
original=cd;
cd('..\..\wordsbyword Data')
slashes=find(wav_file=='\');
dots=find(wav_file=='.');
name=wav_file(slashes(end)+1:dots(end)-1);
load([name '.mat'],'H1','H2','H4');
cd(original);
F0=resize(F0,length(F1));
H1=resize(H1,length(F1));
H2=resize(H2,length(F1));
H4=resize(H4,length(F1));

%replace NaN values of the F1, F2, F3, B1, B2, and B3
F1_real=find(~isnan(F1));
F1_first=F1_real(1);
F1_last=F1_real(end);
F1(1:F1_first)=F1(F1_first);
F1(F1_last:end)=F1(F1_last);
F2_real=find(~isnan(F2));
F2_first=F2_real(1);
F2_last=F2_real(end);
F2(1:F2_first)=F2(F2_first);
F2(F2_last:end)=F2(F2_last);
F3_real=find(~isnan(F3));
F3_first=F3_real(1);
F3_last=F3_real(end);
F3(1:F3_first)=F3(F3_first);
F3(F3_last:end)=F3(F3_last);
B1_real=find(~isnan(B1));
B1_first=B1_real(1);
B1_last=B1_real(end);
B1(1:B1_first)=B1(B1_first);
B1(B1_last:end)=B1(B1_last);
B2_real=find(~isnan(B2));
B2_first=B2_real(1);
B2_last=B2_real(end);
B2(1:B2_first)=B2(B2_first);
B2(B2_last:end)=B2(B2_last);
B3_real=find(~isnan(B3));
B3_first=B3_real(1);
B3_last=B3_real(end);
B3(1:B3_first)=B3(B3_first);
B3(B3_last:end)=B3(B3_last);

%CALCULATE LANDMARK and GLOTTAL TIERS
%find vowel times, glide, nasal and glottal bounds

%load relevant GMMs
load('models.mat', 'nasalDist', 'nonnasalDist','glottalDist',...
    'nonglottalDist','glideDist','nonglideDist','ippDist','nonippDist');

%find vowel times
v_times=VLD_Main(wav_file);
if v_times==0
    v_times=[];
end

%find nasal and glottal periods
[n_starts,n_stops]=predict_nasals(nasalDist,nonnasalDist,T,V,F0,F1);
[g_starts,g_stops]=predict_glottal(glottalDist,nonglottalDist,T,V,F1,F2,F3,B1,B2);
%[g_starts,g_stops]=detectglottals2(T,F0);

n_closures=n_starts;
n_releases=n_stops;

%detect glide ranges and return the middle of those ranges
[glide_times]=predict_glides(glideDist,nonglideDist,T,V,F1,F2,F3);

%find irregular pitch periods
[ipp_starts,ipp_stops]=predict_ipp(wav_file,ippDist,nonippDist,T,V,F0);


%find fricative and stop landmarks

%load relevant GMMs
load('models.mat','burstDist','nonburstDist','ftcDist','ftrDist','nonftDist');

%find stop periods
%[s_starts,s_stops,stop_time]=StopDetector(wav_file);
[s_starts,s_stops]=StopDetector2(T,V);

%merge adjacent stop periods
[s_starts,s_stops]=time_merge(s_starts,s_stops,0.01);

%find periods of frication (removed because it did not work properly)
%[f_closures,f_releases]=FricativeDetector(wav_file);
[f_starts,f_stops]=FricativeDetector2(T,V,g_starts,g_stops);
%[~,~,f_starts,f_stops]=detectbursts(wav_file,burstDist,nonburstDist,T,V,F1,F2,B1,B2,B3,B4);
%n_closures=[];
%n_releases=[];

%merge adjacent frication periods
[f_starts,f_stops]=time_merge(f_starts,f_stops,0.01);

%find which frications correspond to stop consonants
stop_starts=zeros(length(f_stops),1);
stop_stops=zeros(length(f_stops),1);
stop_index=0;
remaining_bursts=ones(length(f_stops),1);
%if f_stops(1)-f_starts(1)<0.1 
%        stop_index=stop_index+1;
%        stop_starts(stop_index)= f_starts(1);
%       stop_stops(stop_index)= f_stops(1);
%        remaining_bursts(1)=0;
%end
for i=1:length(s_starts)
    if sum(abs(f_starts-s_stops(i))<0.03)>0
        stop_index=stop_index+1;
        f_index=find(abs(f_starts-s_stops(i))<0.03);
        if remaining_bursts(f_index(1))
        stop_starts(stop_index)= s_starts(i);
        stop_stops(stop_index)= f_stops(f_index(1));
        remaining_bursts(f_index)=0;
        end
    end
end
stop_starts(stop_index+1:end)=[];
stop_stops(stop_index+1:end)=[];

%the remaining frications are just frication consonants
fricative_starts=zeros(sum(remaining_bursts),1);
fricative_stops=zeros(sum(remaining_bursts),1);
fricative_index=1;
for i=1:length(remaining_bursts)
   if remaining_bursts(i)==1
       fricative_starts(fricative_index)=f_starts(i);
       fricative_stops(fricative_index)=f_stops(i);
       fricative_index=fricative_index+1;
   end
end

%find locations of cplace labels

%find periods of spectral bursts
%[burst_starts,burst_stops]=predict_bursts(burstDist,nonburstDist,...
%    T,V,F1,F2,B1,B2,B3,B4);
%bursts=0.5*(burst_starts+burst_stops);
[bursts] = predict_bursts2(f_starts,f_stops,T,V,wav_file);

%find formant transitions
%[ft_closures,ft_releases]=predict_fts(ftcDist,ftrDist,nonftDist,...
%    T,V,F1,F2,F3,B1);
[ft_closures,ft_releases]=predict_fts2([stop_starts; fricative_starts],[stop_stops; fricative_stops],T,F1,F2,F3);


%find place of articulation

%find place of vowel articulation
if ~isempty(v_times)
%v_info=vplace(wav_file,v_times,T,F1,F2);
v_info = classifyVowels2(v_times,T,F1,F2);
end

%find place of glide articulation
if ~isempty(glide_times)
load('models.mat','rDist','lDist','wDist','hDist','yDist');
glide_info=glideplace(wav_file,glide_times,rDist,lDist,wDist,hDist,yDist,...
    T,V,F1,F2,F3,B1,B2,B3);
%g_info=vplace(wav_file,glide_times,T,F1,F2);
g_info = classifyVowels2(glide_times,T,F1,F2);
for i=1:length(glide_times)
    if glide_info(i)==string('"r"')
        g_info(i,5)=string('"<rhot>"');
    elseif glide_info(i)==string('"l"')
        g_info(i,5)=string('"<lat>"');
    elseif glide_info(i)==string('"w"')
        g_info(i,5)=string('"<round>"');
    elseif glide_info(i)==string('"h"')
        g_info(i,5)=string('"<spread>"');
    elseif glide_info(i)==string('"y"')
        g_info(i,5)=string('"<dist>"');
    end
end
end

%find place of burst articulation
if ~isempty(bursts)
    [burst_info,ftc_info,ftr_info]=cplace(wav_file,bursts,ft_closures,ft_releases,T,V,F1,F2,F3,B1,B2,B3);
end

%determine consonant voicing
cvoice = cvoicing(stop_starts,stop_stops,fricative_starts,fricative_stops,g_starts,T,F0,F1,H1,H2,H4);

%create array to become textgrid

%determine tiers
tiers=[string('"LM"');string('"vgplace"');string('"cplace"');string('"nasal"');string('"glottal"');string('"cvoicing"')];

%determine number of frames, create empty string array
[y,Fs]=audioread(wav_file);
frames=1000*round(length(y)/Fs,3);
array=strings(length(tiers),int16(frames));

%add vowel landmarks and vowel place
if ~isempty(v_times) && v_times(1)~=0
array(1,1000*round(v_times(:),3))=string('"V"');
for i=1:size(v_info,1)
    features=v_info(i,v_info(i,:)~=string(''));
    for j=1:length(features)
        array(2,1000*round(v_times(i),3)-1+j)=features(j);
    end
end
end

%add irregular pitch periods
if ~isempty(ipp_starts)
array(5,1000*round(ipp_starts(:),3))=string('"<ipp"');
array(5,1000*round(ipp_stops(:),3))=string('"ipp>"');
end

%add glides and glide place
if ~isempty(glide_times)
for i=1:length(glide_times)
%array(1,1000*round(glide_times(i),3))=glide_info(i);
array(1,1000*round(glide_times(i),3))=string('"G"');
end
for i=1:size(g_info,1)
    features=g_info(i,g_info(i,:)~=string(''));
    for j=1:length(features)
        array(2,1000*round(glide_times(i),3)-1+j)=features(j);
    end
end
end

%add stop consonant landmarks
if ~isempty(stop_starts)
for i=1:length(stop_starts)
array(1,1000*round(stop_starts(i),3))=string('"Sc"');
array(1,1000*round(stop_stops(i),3))=string('"Sr"');
end
end

%add fricative consonant landmarks
if ~isempty(fricative_starts)
for i=1:length(fricative_starts)
array(1,1000*round(fricative_starts(i),3))=string('"Fc"');
array(1,1000*round(fricative_stops(i),3))=string('"Fr"');
end 
end

%add formant transition closures
if ~isempty(ft_closures)
for i=1:length(ft_closures)
    array(3,1000*round(ft_closures(i),3))=ftc_info(i)+string('-FTc>"');
end

%add formant transition releases
end
if ~isempty(ft_releases)
for i=1:length(ft_releases)
    array(3,1000*round(ft_releases(i),3))=ftr_info(i)+string('-FTr>"');
end

%add spectral bursts
end
if ~isempty(bursts)
for i=1:length(bursts)
    array(3,1000*round(bursts(i),3))=burst_info(i)+string('-SB>"');
end
end

%add nasal closures and releases
if ~isempty(n_closures)
array(1,1000*round(n_closures(:),3))=string('"Nc"');
array(1,1000*round(n_releases(:),3))=string('"Nr"');
end

%add nasal periods
if ~isempty(n_starts)
array(4,1000*round(n_starts(:),3))=string('"+n"');
array(4,1000*round(n_stops(:),3))=string('"-n"');
end

%add glottal periods
if ~isempty(g_starts)
array(5,1000*round(g_starts(:),3))=string('"+g"');
array(5,1000*round(g_stops(:),3))=string('"-g"');
end

%add consonant voicing
if ~isempty(cvoice{1})
    sc_id=cvoice{1};
    for i=1:length(sc_id)
        if sc_id(i)
        array(6,1000*round(stop_starts(i),3))='"<slack>"';
        else
        array(6,1000*round(stop_starts(i),3))='"<stiff>"';
        end
    end
end
if ~isempty(cvoice{2})
    sr_id=cvoice{2};
    for i=1:length(sr_id)
        if sr_id(i)
        array(6,1000*round(stop_stops(i),3))='"<slack>"';
        else
        array(6,1000*round(stop_stops(i),3))='"<stiff>"';
        end
    end
end
if ~isempty(cvoice{3})
    fc_id=cvoice{3};
    for i=1:length(fc_id)
        if fc_id(i)
        array(6,1000*round(fricative_starts(i),3))='"<slack>"';
        else
        array(6,1000*round(fricative_starts(i),3))='"<stiff>"';
        end
    end
end
if ~isempty(cvoice{4})
    fr_id=cvoice{4};
    for i=1:length(fr_id)
        if fr_id(i)
        array(6,1000*round(fricative_stops(i),3))='"<slack>"';
        else
        array(6,1000*round(fricative_stops(i),3))='"<stiff>"';
        end
    end
end

%create a Textgrid using the array
%array_to_textgrid(array,tiers,1,[name '.TextGrid']);
end