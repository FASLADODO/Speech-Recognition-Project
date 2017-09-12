function [ mins, maxs ] = readtextgridnasals( textgridFileName )
%READTEXTGRID Read a textgrid file and get intervals labeled 'm', 'n', or
%'ng' in a tier named 'phones'
%   returns mins and maxs of intervals

file = fopen(textgridFileName, 'r');

% Read until line that tells how many tiers there are
count = 0;
while (count ~= 1)
    [nTiers, count] = sscanf(fgetl(file), 'size = %d');
end


for iTier = 1:nTiers
    % Find tier 'phones'
    count = 0;
    while count ~= 1
        [tierName, count] = sscanf(strtrim(fgetl(file)), 'name = "%s');
    end
    % This is extremely awful but yes the ending double quote is needed
    if ~strcmp(tierName, 'phones"') 
        continue
    end
    
    % Get number of intervals
    count = 0;
    while (count ~= 1)
        [nIntervals, count] = sscanf(strtrim(fgetl(file)), 'intervals: size = %d');
    end
    
    mins = [];
    maxs = [];
    nNasals = 0;
    
    for iInterval = 1:nIntervals
        % Jump to interval of index iInterval
        i = 0;
        while (i ~= iInterval)
            i = sscanf(fgetl(file), 'intervals [%d]:');
        end
        
        line = fgetl(file);
        min = sscanf(strtrim(line), 'xmin = %f');
        line = fgetl(file);
        max = sscanf(strtrim(line), 'xmax = %f');
        line = fgetl(file);
        text = sscanf(strtrim(line), 'text = "%s"');
        
        % This is extremely awful but yes the ending double quote is needed
        if (~strcmp(text, {'m"', 'n"', 'ng"'}))
            continue
        end
        
        nNasals = nNasals + 1;
        
        mins(nNasals) = min;
        maxs(nNasals) = max;
    end
end

fclose(file);

end

