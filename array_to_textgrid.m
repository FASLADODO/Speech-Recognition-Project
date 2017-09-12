function arrayToTextgrid_cs(CxN,tiers,framelength,name)
% name of program file: arrayToTextgrid_cs.m
%
% Author: Christine Soh, Speech Communication Group, RLE, MIT
%
% Date:  2017
% 
% textgrid = func_arrayToTextGrid(CxN,tiers,framelength)
%
% Overall description: This function converts a CxN array into a TextGrid
% file.
% 
% Input: CxN cell or matrix, with C, number of TextGrid tiers and N, 
% the number of frames. Most strings will be empty, but there will be 
% strings at the locations of corresponding labels in the TextGrid file.
% tiers, an array of the tier names
% framelength (in ms) 
%
% Output: TextGrid file
% 
% Usage: 
% 
% Known bugs: 
original=cd;
cd('..\..\Saved Data');
if iscell(CxN)
    CxNarray = cell2mat(CxN);%convert the cell into a matrix
else
    CxNarray = CxN;%if it already is a matrix
end

T = framelength / 1000; %converts framelength from ms to s
[tierCount,time] = size(CxNarray); %finds the size of the CxN array
length = time * T; 

fileID = fopen(name,'w'); %creates text file in the form for TextGrids
fprintf(fileID,'File type = "ooTextFile" \n');
fprintf(fileID,'Object class = "TextGrid" \n');
fprintf(fileID,'\n');
fprintf(fileID,'xmin = 0 \n');
fprintf(fileID,'xmax = %f \n',length);
fprintf(fileID,'tiers? <exists> \n'); 
fprintf(fileID,'size = %u \n', tierCount);
fprintf(fileID,'item []: \n'); 

counter = 0;
for tier = 1:tierCount %creates the tiers
    counter = counter + 1;
    fprintf(fileID,'\t item [%u]:\n',counter);
    fprintf(fileID,'\t \t class = "%s" \n',tier_class(tiers{tier}));
    fprintf(fileID,'\t \t name = %s \n',tiers{tier});
    fprintf(fileID,'\t \t xmin = 0 \n');
    fprintf(fileID,'\t \t xmax = %f \n',length);
    if ismember(char(tier_class(tiers{tier})), 'IntervalTier')
        [number, interval_vals, interval_start, interval_stop] = number_intervals(CxNarray, tier, T);
        fprintf(fileID,'\t \t intervals: size = %u \n',number);
        for index = 1:number
            fprintf(fileID,'\t \t intervals [%u]: \n',index);
            fprintf(fileID,'\t \t \t xmin = %f \n', interval_start(index));
            fprintf(fileID,'\t \t \t xmax = %f \n', interval_stop(index));
            fprintf(fileID,'\t \t \t text = "%s" \n', interval_vals(index));
        end
    else
        [number, point_vals, point_times] = number_points(CxNarray, tier, T);
        fprintf(fileID,'\t \t points: size = %u \n',number);
        for index = 1:number
            fprintf(fileID,'\t \t \t number = %f \n', point_times(index));
            fprintf(fileID,'\t \t \t mark = "%s" \n', point_vals(index));
        end
    end
end
    
fclose(fileID);
cd(original);
end


function class = tier_class(tier_name)
%Classifies the tier (interval tier or point tier)
%
%Input: tier name
%Output: IntervalTier or TextTier
new_tier_name = strtrim(tier_name);
if ismember(new_tier_name,['"comments"'])
    class = 'TextTier';
elseif ismember(new_tier_name,['"words"','"word"','"phoneme"','"utterance"','"phones"'])
    class = 'IntervalTier';
else
    class = 'TextTier';
end

end

function [number,interval_vals ,interval_start, interval_stop] = number_intervals(CxNarray, tier, T)
%This function finds the number of intervals in the CxN array and finds the
%values of those intervals.
%
%Input: the array of times and the labels, the tier array, and your
%framelength, T
%Output: the number of intervals, the text values of the intervals, and the
%start and stop times of the intervals

[~,time] = size(CxNarray);

interval_vals = repmat(string(''),[time,1]);
interval_start = zeros(time,1);
interval_stop = zeros(time,1);

number = 1;
strrep(CxNarray,'"','');
previous = '""';
for interval = 1:time
    string_val = strtrim(CxNarray(tier,interval));
    string_val = char(string_val);
    string_val = string_val(string_val ~= '"');
    if ~isequal(string_val, previous)
        interval_vals(number+1, 1) = string_val;
        format long g
        interval_stop(number) = T*interval;
        number = number + 1;
        interval_start(number) = T*interval;
        previous = string_val;
    end
end
interval_stop(number) = T*time;
number=number-1;
interval_vals=interval_vals(2:end);
interval_stop=interval_stop(2:end);
interval_start=interval_start(2:end);
end

function [number, point_vals, point_times] = number_points(CxNarray, tier, T)
%This function finds the number of point-markers in the CxN array and finds 
%the values of those points
%
%Input: the array of times and the labels, the tier array, and your
%framelength, T

%Output: the number of points, the text values of the points, and the
%times of the points

[~,time] = size(CxNarray);

point_vals = repmat(string(''),[time,1]);
point_times = zeros(time,1);

number = 1;

strrep(CxNarray,'"','');

for point = 1:time
    string_val = strtrim(CxNarray(tier,point));
    string_val = char(string_val);
    string_val = string_val(string_val ~= '"');
    if ~isempty(string_val)
        point_vals(number, 1) = string_val;
        format long g
        point_times(number) = T*point;
        number = number + 1;
    end
end
number = number - 1;
point_times=point_times(1:end-1);
point_vals=point_vals(1:end-1);
end