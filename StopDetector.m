function [ times_start,times_end,time ] = StopDetector( input_file)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

hamming_window_size = 256;
window_overlap_size = 176;
FFT_n= 512;
band_pass_low_freq = 4000;
band_pass_high_freq = 8000;
smoothing_window_length = 10;

[ soundMono, Fs ] = WavToMonoMatrix( input_file);
[signal,freq,time,power] = BandPass( soundMono, hamming_window_size, window_overlap_size, FFT_n,Fs,false,band_pass_low_freq,band_pass_high_freq);
[ smoothCOG, totalEnergy, output ] = SCOG_function_only(time,power,freq,signal,smoothing_window_length,false);
[ signalPower,energy,dbEnergy,diff_dbEnergy,energynorm,diff_energynorm, T ] = EnergyBands(soundMono, Fs, hamming_window_size, window_overlap_size, FFT_n, false, [1 2 3 4 5 6],smoothing_window_length);

% figure;
% plot(time, output);
% 
% figure;
% plot(time(1:end-1),diff(output));

flag = 0;
times_start = [];
times_end = [];
cutoff_energy = mean(signalPower)/3;
signalPower = tsmovavg(signalPower,'t',smoothing_window_length,2);
for i = 1:length(signalPower)
    if (signalPower(i) < cutoff_energy) & (flag == 0) & (output(i) > 0)
        times_start = [times_start time(i)];
        flag = 1;
    end
    if (flag == 1) & (signalPower(i) > cutoff_energy) | (output(i) == 0)
        if(flag == 1)
            times_end = [times_end time(i)];
            flag = 0;
        end
    end
end

if flag
   times_end = [times_end time(end)];
   flag = 0;
end

windows = zeros(1,length(time));
for i = 1:length(time)
    for j = 1:length(times_start)
        if time(i) == times_start(j)
            flag = 1;
        end
    end
    for j = 1:length(times_end)
        if time(i) == times_end(j)
            flag = 0;
        end
    end
    if flag == 1
        windows(i) = 1;
    end
end

% figure;
% subplot(2,1,1);
% plot(time,windows,'-r');
% subplot(2,1,2);
% plot(time,signalPower);

% diff_times = zeros(1,length(times_start));
% 
% for i = 1:length(times_start)
%     diff_times(i) = abs(times_start(i)-times_end(i));
% end
% 
% maxDiff = max(diff_times);
% output_closure_times = [];
% output_release_times = [];
% 
% for i = 1:length(diff_times)
%     if diff_times(i) > maxDiff*.1
%         output_closure_times = [output_closure_times times_start(i)];
%         output_release_times = [output_release_times times_end(i)];
%     end
% end
% 
% windows = zeros(1,length(time));
% for i = 1:length(time)
%     for j = 1:length(output_closure_times)
%         if time(i) == output_closure_times(j)
%             flag = 1;
%         end
%     end
%     for j = 1:length(output_release_times)
%         if time(i) == output_release_times(j)
%             flag = 0;
%         end
%     end
%     if flag == 1
%         windows(i) = 1;
%     end
% end
% 
% figure;
% subplot(2,1,1);
% plot(time,windows,'-r');
% subplot(2,1,2);
% plot(time,signalPower);

counter = 1;
counter2 = 1;
temp_window = [];
temp_time = [];
for i = 1:length(times_start)
    while windows(counter) ~= 1
        counter = counter + 1;
    end
    while windows(counter) == 1
        temp_window(counter2) = smoothCOG(counter);
        temp_time(counter2) = time(counter);
        counter = counter + 1;
        counter2 = counter2 + 1;
    end
    
    counter2 = 1;    
%     figure;
%     plot(temp_time,temp_window);
    temp_window = [];
    temp_time = [];
end

% figure;
% plot(time,signalPower);
end

