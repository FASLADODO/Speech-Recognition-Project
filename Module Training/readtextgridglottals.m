%readtextgridglottals finds all glottal periods labeled in a
%textgrid file
%
% Inputs: textgridFileName - the name of the TextGrid file
%
% Outputs: mins - the beginnings of glottal periods
%          maxs - the ends of glottal periods
%
% Written by Collin Potts
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ mins, maxs ] = readtextgridglottals( textgridFileName )
[array,tiers]=textgrid_to_array(textgridFileName);
glottal_index='Unfound';
for i=1:length(tiers)
    tier=char(tiers(i));
    if strcmp(tier,'"glottal"')
        glottal_index=i;
    end
end
if isa(glottal_index,'char')
    mins=[];
    maxs=[];
else
glottal_tier=array(glottal_index,:);
mins=zeros(20,1);
maxs=zeros(20,1);
min_index=0;
max_index=0;
for i=1:length(glottal_tier)
    if strcmp(glottal_tier(i),'"+g"')
        min_index=min_index+1;
        mins(min_index)=i/1000;
    elseif strcmp(glottal_tier(i),'"-g"')
        max_index=max_index+1;
        maxs(max_index)=i/1000;
    end
end
mins(min_index+1:end)=[];
maxs(max_index+1:end)=[];
end
end

