%readtextgridfts finds all formant transition closures and releases
%labeled in a textgrid file
%
% Inputs: textgridFileName - the name of the TextGrid file
%
% Outputs: closures - the times of all formant closures
%          releases - the times of all formant releases
%
% Written by Collin Potts
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [ closures, releases ] = readtextgridbursts( textgridFileName )
[array,tiers]=textgrid_to_array(textgridFileName);
cplace_index='Unfound';
for i=1:length(tiers)
    tier=char(tiers(i));
    if findstr(tier,'cplace')>1
        cplace_index=i;
    end
end
if isa(cplace_index,'char')
    closures=[];
    releases=[];
else
cplace_tier=array(cplace_index,:);
closures=zeros(20,1);
releases=zeros(20,1);
index_c=0;
index_r=0;
for i=1:length(cplace_tier)
    if ~isempty(strfind(cplace_tier(i),'FTc'))
        index_c=index_c+1;
        closures(index_c)=i/1000;
    elseif ~isempty(strfind(cplace_tier(i),'FTr'))
        index_r=index_r+1;
        releases(index_r)=i/1000;
end
closures(index_c+1:end)=[];
releases(index_r+1:end)=[];
end
end

