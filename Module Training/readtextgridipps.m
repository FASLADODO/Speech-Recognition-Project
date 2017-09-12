%readtextgridipps finds all irregular pitch periods labeled in a
%textgrid file
%
% Inputs: textgridFileName - the name of the TextGrid file
%
% Outputs: mins - the beginnings of irregular pitch periods
%          maxs - the ends of irregular pitch periods
%
% Written by Israel from the SCG, edited by Collin Potts
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ mins, maxs ] = readtextgridipps( textgridFileName )
[array,tiers]=textgrid_to_array(textgridFileName);
glottal_index='Unfound';
for i=1:length(tiers)
    tier=char(tiers(i));
    if findstr(tier,'glottal')
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
    if strcmp(glottal_tier(i),'"<ipp"')
        min_index=min_index+1;
        mins(min_index)=i/1000;
    elseif strcmp(glottal_tier(i),'"ipp>"')
        max_index=max_index+1;
        maxs(max_index)=i/1000;
    end
end
mins(min_index+1:end)=[];
maxs(max_index+1:end)=[];
end
end

