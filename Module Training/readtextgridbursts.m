%readtextgridbursts finds all spectral bursts labeled in a textgrid file
%
% Inputs: textgridFileName - the name of the TextGrid file
%
% Outputs: mins - the time 15ms before each spectral burst
%          maxs - the time 15ms after each spectral burst
%
% Written by Collin Potts
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ mins, maxs ] = readtextgridbursts( textgridFileName )
[array,tiers]=textgrid_to_array(textgridFileName);
cplace_index='Unfound';
for i=1:length(tiers)
    tier=char(tiers(i))
    if findstr(tier,'cplace')>1
        cplace_index=i
    end
end
if isa(cplace_index,'char')
    mins=[];
    maxs=[];
else
cplace_tier=array(cplace_index,:);
mins=zeros(20,1);
maxs=zeros(20,1);
index=0;
for i=1:length(cplace_tier)
    if ~isempty(strfind(cplace_tier(i),'SB'))
        index=index+1;
        mins(index)=(i-15)/1000;
        maxs(index)=(i+15)/1000;
    end
end
mins(index+1:end)=[];
maxs(index+1:end)=[];
end
end

