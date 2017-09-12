function [ output_closure_times,output_release_times ] = FricativeExtract( COG,time )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

diffCOG = diff(COG);
difftime = time(1:end-1);

[peaks,locs] = findpeaks(COG,'MINPEAKHEIGHT',3500);

maxPeak = max(diffCOG);

[peaks_diff_pos, locs_diff_close] = findpeaks(diffCOG,'MINPEAKHEIGHT',maxPeak*.4);
[peaks_diff_release, locs_diff_release] = findpeaks(-1.*diffCOG,'MINPEAKHEIGHT',maxPeak*.4);

if length(locs_diff_close)>length(locs_diff_release)
    locs_diff_close=locs_diff_close(1:length(locs_diff_release));
else
    locs_diff_release=locs_diff_release(1:length(locs_diff_close));
end

closure_times = zeros(1,length(locs_diff_close));
release_times = zeros(1,length(locs_diff_release));
diff_times = zeros(1,length(locs_diff_release));

closure_times(:) = difftime(locs_diff_close(:));
release_times(:) = difftime(locs_diff_release(:));
diff_times(:) = abs(closure_times(:)-release_times(:));


maxDiff = max(diff_times);
%maxDiff=0.05*10;
output_closure_times = [];
output_release_times = [];

for i = 1:length(diff_times)
    if diff_times(i) > maxDiff*.1
        output_closure_times = [output_closure_times closure_times(i)];
        output_release_times = [output_release_times release_times(i)];
    end
end

output = zeros(length(output_closure_times),2);
output(:,1) = output_closure_times;
output(:,2) = output_release_times;

%dlmwrite('output.FDL',output);

end

