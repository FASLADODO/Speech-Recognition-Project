%readtextgridglides finds all glides labeled in a
%textgrid file
%
% Inputs: textgridFileName - the name of the TextGrid file
%
% Outputs: mins - the times 15ms before each glide label
%          maxs - the times 15ms after each glide label
%
% Written by Collin Potts
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ mins, maxs ] = readtextgridglides( textgridFileName )
[array,tiers]=textgrid_to_array(textgridFileName);
LM_index='Unfound';
for i=1:length(tiers)
    tier=char(tiers(i))
    if findstr(tier,'LM')>1
        LM_index=i
        break
    end
end
if isa(LM_index,'char')
    mins=[];
    maxs=[];
else
LM_tier=array(LM_index,:);
mins=zeros(20,1);
maxs=zeros(20,1);
index=0;
for i=1:length(LM_tier)
    if ~isempty(strfind(LM_tier(i),'"r"'))
        index=index+1;
        mins(index)=(i-15)/1000;
        maxs(index)=(i+15)/1000;
    elseif ~isempty(strfind(LM_tier(i),'"l"'))
        index=index+1;
        mins(index)=(i-15)/1000;
        maxs(index)=(i+15)/1000;
    elseif ~isempty(strfind(LM_tier(i),'"w"'))
        index=index+1;
        mins(index)=(i-15)/1000;
        maxs(index)=(i+15)/1000;
    elseif  ~isempty(strfind(LM_tier(i),'"h"'))
        index=index+1;
        mins(index)=(i-15)/1000;
        maxs(index)=(i+15)/1000;
    elseif ~isempty(strfind(LM_tier(i),'"y"'))
        index=index+1;
        mins(index)=(i-15)/1000;
        maxs(index)=(i+15)/1000;
    end
end
mins(index+1:end)=[];
maxs(index+1:end)=[];
end
end

