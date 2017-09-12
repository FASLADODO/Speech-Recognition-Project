%readtextgridglideplaces finds all glides labeled in a
%textgrid file
%
% Inputs: textgridFileName - the name of the TextGrid file
%
% Outputs: r - the times of all r glides
%          l - the times of all l glides
%          w - the times of all w glides
%          h - the times of all h glides
%          y - the times of all y glides
%
% Written by Collin Potts
%
% Last updated June 13th, 2017
%
% Known bugs: none

function [r,l,w,h,y] = readtextgridglideplaces( textgridFileName )
[array,tiers]=textgrid_to_array(textgridFileName);
LM_index='Unfound';
for i=1:length(tiers)
    tier=char(tiers(i));
    if findstr(tier,'LM')>1
        LM_index=i;
        break
    end
end
if isa(LM_index,'char')
    r=[];
    l=[];
    w=[];
    h=[];
    y=[];
else
LM_tier=array(LM_index,:);
r=zeros(20,1);
l=zeros(20,1);
w=zeros(20,1);
h=zeros(20,1);
y=zeros(20,1);
r_index=0;
l_index=0;
w_index=0;
h_index=0;
y_index=0;
for i=1:length(LM_tier)
    if ~isempty(strfind(LM_tier(i),'"r"'))
        r_index=r_index+1;
        r(r_index)=i/1000;
    elseif ~isempty(strfind(LM_tier(i),'"l"'))
        l_index=l_index+1;
        l(l_index)=i/1000;
    elseif ~isempty(strfind(LM_tier(i),'"w"'))
        w_index=w_index+1;
        w(w_index)=i/1000;
    elseif  ~isempty(strfind(LM_tier(i),'"h"'))
        h_index=h_index+1;
        h(h_index)=i/1000;
    elseif ~isempty(strfind(LM_tier(i),'"y"'))
        y_index=y_index+1;
        y(y_index)=i/1000;
    end
end
r(r_index+1:end)=[];
l(l_index+1:end)=[];
w(w_index+1:end)=[];
h(h_index+1:end)=[];
y(y_index+1:end)=[];
end
end

