%cplace examines a WAV file at given times to find the place of
%articulation for formant transitions and spectral bursts
%
% Inputs: wav_file - the address of the WAV file containing speech
%         bursts - the times of spectral bursts
%         ft_closures - the times of formant transition closures
%         ft_releases - the times of formant transition releases
%         T,...,B3 - sound data, calculated in main program
%
% Outputs: burst_info - places of articulation for each burst time
%          ftc_info - places of articulation for each closure time
%          ftr_info - places of articulation for each release time
%
% Written by Collin Potts, MIT RLE Speech Communication Group
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [burst_info,ftc_info,ftr_info]=cplace(wav_file,bursts,ft_closures,ft_releases,T,V1,F1,F2,F3,B1,B2,B3)
load('models.mat','sb_labDist','sb_denDist','sb_alvDist','sb_palDist','sb_velDist');
load('models.mat','ftc_labDist','ftc_denDist','ftc_alvDist','ftc_palDist','ftc_velDist');
load('models.mat','ftr_labDist','ftr_denDist','ftr_alvDist','ftr_palDist','ftr_velDist');
burst_info=strings(length(bursts),1);
ftc_info=strings(length(ft_closures),1);
ftr_info=strings(length(ft_releases),1);
%[T, V1, Fs] = vectorize(wav_file);
%[F1, F2, F3, ~, B1, B2, B3, ~, ~] = func_PraatFormants(wav_file, ...
%                                              0.025, 80/Fs, 1, floor(T(end)*Fs/80));
V2=[F1 F2 F3 B1 B2 B3];
if length(V2)>length(V1)
    V2=V2(1:length(V1),:);
else
    V1=V1(1:length(V2),:);
end
for i=1:size(V1,1)
    V1(i,:)=V1(i,:)/sum(V1(i,:));
end
sbV=[V1 V2];
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
ftV=[V1 V2];

sb_labPdf=pdf(sb_labDist,sbV);
sb_denPdf=pdf(sb_denDist,sbV);
sb_alvPdf=pdf(sb_alvDist,sbV);
sb_palPdf=pdf(sb_palDist,sbV);
sb_velPdf=pdf(sb_velDist,sbV);
ftc_labPdf=pdf(ftc_labDist,ftV);
ftc_denPdf=pdf(ftc_denDist,ftV);
ftc_alvPdf=pdf(ftc_alvDist,ftV);
ftc_palPdf=pdf(ftc_palDist,ftV);
ftc_velPdf=pdf(ftc_velDist,ftV);
ftr_labPdf=pdf(ftr_labDist,ftV);
ftr_denPdf=pdf(ftr_denDist,ftV);
ftr_alvPdf=pdf(ftr_alvDist,ftV);
ftr_palPdf=pdf(ftr_palDist,ftV);
ftr_velPdf=pdf(ftr_velDist,ftV);

burst_indexes=zeros(length(bursts),1);
ftc_indexes=zeros(length(ft_closures),1);
ftr_indexes=zeros(length(ft_releases),1);
for i=1:length(bursts)
    b_time=bursts(i);
    differences=abs(T-b_time);
    min_diff=min(differences);
    index=find(~(differences-min_diff));
    burst_indexes(i,1)=index(1);
end
for i=1:length(ft_closures)
    ftc_time=ft_closures(i);
    differences=abs(T-ftc_time);
    min_diff=min(differences);
    index=find(~(differences-min_diff));
    ftc_indexes(i,1)=index(1);
end
for i=1:length(ft_releases)
    ftr_time=ft_releases(i);
    differences=abs(T-ftr_time);
    min_diff=min(differences);
    index=find(~(differences-min_diff));
    ftr_indexes(i,1)=index(1);
end
options=[string('"<lab') string('"<den') string('"<alv') string('"<pal') string('"<vel')];
for i=1:length(burst_info)
    prob_list=[sb_labPdf(burst_indexes(i)) sb_denPdf(burst_indexes(i)) sb_alvPdf(burst_indexes(i))...
        sb_palPdf(burst_indexes(i)) sb_velPdf(burst_indexes(i))];
    best=options(prob_list==max(prob_list));
    if isempty(best)
    burst_info(i)=options(3);
    else
    burst_info(i)=best(1);
    end
end
for i=1:length(ftc_info)
    prob_list=[ftc_labPdf(ftc_indexes(i)) ftc_denPdf(ftc_indexes(i)) ftc_alvPdf(ftc_indexes(i))...
        ftc_palPdf(ftc_indexes(i)) ftc_velPdf(ftc_indexes(i))];
    best=options(prob_list==max(prob_list));
    if isempty(best)
    ftc_info=options(3);   
    else
    ftc_info(i)=best(1);
    end
end
for i=1:length(ftr_info)
    prob_list=[ftr_labPdf(ftr_indexes(i)) ftr_denPdf(ftr_indexes(i)) ftr_alvPdf(ftr_indexes(i))...
        ftr_palPdf(ftr_indexes(i)) ftr_velPdf(ftr_indexes(i))];
    best=options(prob_list==max(prob_list));
    if isempty(best)
    ftr_info=options(3);   
    else
    ftr_info(i)=best(1);
    end
end
end