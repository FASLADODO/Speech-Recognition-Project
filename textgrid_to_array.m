function [output,tiers] = textgrid_to_array(filename)
% textgrid_to_array.m
%
% Converts textgrid point and interval tiers into rows of a MATLAB array
%
% Input: filename - name of textgrid file
% 
% Output: output - a CxN string array, C is number of TextGrid tiers, N
% is the number of frames. Most strings will be empty, but there will be
% strings containing label text at the locations of corresponding labels in
% the TextGrid file
%         tiers - a Cx1 char array containing the names of the tiers
%
% Known Bugs: Currently none
%
% Author: Collin Potts, Speech Communication Group, RLE, MIT  March 21 2017

T=1; %frame size in milliseconds
[labels,~,stops,file]=func_readTextgrid(filename); %extract information from textgrid
time=stops{1,2}(end); %find total time of file
frames=ceil(1000*time/T); %convert time into a number of individual frames
[~,rows]=size(labels); %count number of tiers
output=strings(rows,frames); %create empty string array to be filled in
file_data=char(file{1,1}); %import the file in order to find tier names
tiers=string(file_data(string(file_data(:,1:4))=='name',8:end)); %create an array consisting of tier names
intervalTiers=0;
for i=1:length(tiers)
   if strncmpi(tiers(i),string('"words"'),5) || strncmpi(tiers(i),string('"utterance"'),10) || strncmpi(tiers(i),string('"phone"'),6)
      intervalTiers=intervalTiers+1;
   end
end
for tier = 1:rows
    label_list=char(labels{1,tier}); %make a list of values that occur in given tier
    for value = 1:length(labels{1,tier})
        frame=ceil(1000*stops{1,tier}(value)/T); %determine the frame where the label occurs
        output(tier,frame)=label_list(value,:); %assign tier values to frame locations
    end
end
for interval = 1:intervalTiers
    output(interval,end)='';
    for frame = 1:frames-1
        if output(interval,frames-frame)== ''
            if not(output(interval,frames-frame+1)=='""      ' || output(interval,frames-frame+1)=='""  ')
                output(interval,frames-frame)=output(interval,frames-frame+1); %fills in interval tiers with interval values
            end
        end
    end
end
end