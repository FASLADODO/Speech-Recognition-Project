%readtextgridftc finds all formant transition closures labeled in a
%textgrid file
%
% Inputs: textgridFileName - the name of the TextGrid file
%
% Outputs: lab - the times of all labial closures
%          den - the times of all dental closures
%          alv - the times of all alvelor closures
%          pal - the times of all palatal closures
%          vel - the times of all velar closures
%
% Written by Collin Potts
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [lab,den,alv,pal,vel] = readtextgridftc( textgridFileName )
[array,tiers]=textgrid_to_array(textgridFileName);
cplace_index='Unfound';
for i=1:length(tiers)
    tier=char(tiers(i));
    if findstr(tier,'cplace')>1
        cplace_index=i;
        break
    end
end
if isa(cplace_index,'char')
    lab=[];
    den=[];
    alv=[];
    pal=[];
    vel=[];
else
cplace_tier=array(cplace_index,:);
lab=zeros(20,1);
den=zeros(20,1);
alv=zeros(20,1);
pal=zeros(20,1);
vel=zeros(20,1);
lab_index=0;
den_index=0;
alv_index=0;
pal_index=0;
vel_index=0;
for i=1:length(cplace_tier)
    if ~isempty(strfind(cplace_tier(i),'lab-FTc'))
        lab_index=lab_index+1;
        lab(lab_index)=i/1000;
    elseif ~isempty(strfind(cplace_tier(i),'den-FTc'))
        den_index=den_index+1;
        den(den_index)=i/1000;
    elseif ~isempty(strfind(cplace_tier(i),'alv-FTc'))
        alv_index=alv_index+1;
        alv(alv_index)=i/1000;
    elseif  ~isempty(strfind(cplace_tier(i),'pal-FTc'))
        pal_index=pal_index+1;
        pal(pal_index)=i/1000;
    elseif ~isempty(strfind(cplace_tier(i),'vel-FTc'))
        vel_index=vel_index+1;
        vel(vel_index)=i/1000;
    end
end
lab(lab_index+1:end)=[];
den(den_index+1:end)=[];
alv(alv_index+1:end)=[];
pal(pal_index+1:end)=[];
vel(vel_index+1:end)=[];
end
end

