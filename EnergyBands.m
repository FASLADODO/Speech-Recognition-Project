% copied from Stop_Detector --leonxlin 2015-10-12

function [ totalEnergy,energy,dbEnergy,diff_dbEnergy,energynorm,diff_energynorm, dbEnergy_move_avg, T ] = EnergyBands( waveform,waveform_samplingFrequency,hamming_window_length,window_overlap_amount,fft_n,plots,energyDB_to_plot,smoothing_window)
%EnergyBands Speech Analysis Function 
%   by David Couto 12/24/2013 (coutod@mit.edu or david.edwin.couto@gmail.com)
%   Modeled with the help of Jeung-Yoon Elizabeth Choi and
%   "Landmark Detection for Distinctive Feature-Based Speech Recognition"
%   by Sharlene Anne Liu (May 1995)

%   This function will return 6 energy bands (frequency ranges defined
%   below) for a given speech signal. It will also return time T and two
%   subplots (the first detailing energy in dB and the second a derivative
%   plot of the first, both dB are compared to time average energy of input
%   waveform energy band).
%
%   Inputs: waveform: single row or column speech waveform to be used
%           waveform_samplingFrequency: frequency waveform was originally
%               sampled at
%           hamming_window_length: number of sampled in hamming window
%           window_overlap_amount: number of sampled shared in time-adjacent
%               windows
%           fft_n: n number to be used in fft
%           plots: 1 to show plots, 0 if no ploting desired 
%           energyDB_to_plot: list of energy bands to include in output
%               sublots ex. [1 2 4 5] up to 6
 
%   Outputs:
%           energy1-energy6: raw energy band outputs (no dB or diff
%           calculations applied)
%           T: time vector to accompany energy outputs
%
%   Caveats:
%           - Not yet tested for long duration sound clips (expected
%               processing time is high until properly tested)
%           - Only one average is calculated for energy over entire
%               waveform. In the future a moving average may need to
%               replace set average in order to adjust to speaker volume
%               over time. 
%           - Frequency bands may vary based on n number in fft and sampling rate
%               of original waveform. Effects are yet untested. 
%           - No smoothing yet included. Smoothing will be added as a
%               revision as necessary.
%           - When coupled with any power or energy data generated external
%               to this function, units and methods of calculation should
%               be taken into consideration before cross comparison is
%               attempted
%           - This function is not designed for optimal efficiency. A
%               revision may be made for efficiency in the future.
%           - Power spikes due to interference in waveform recordings has
%               not yet been filtered out. Please keep in mind. This may
%               affect time averaging calculations and dB comparison. 


%below:enrgy bands in Hz

band1_low = 0;
band1_high = 400;
band2_low = 800;
band2_high = 1500;
band3_low = 1200;
band3_high = 2000;
band4_low = 2000;
band4_high = 3500;
band5_low = 3500;
band5_high = 5000;
band6_low = 5000;
band6_high = 8000;

%below:
%S is complex matrix of frequency outputs F x time outputs T
%P is the power output associated with time samples T

[S,F,T,P] = spectrogram(waveform,hamming_window_length,window_overlap_amount,fft_n,waveform_samplingFrequency);
signal = (abs(S)).^2; % calculate energy from intensity of frequency output per time


%below: rounded energy band bounds given F
band1_low_index = find((F - band1_low) >= 0,1);
band1_high_index = find((F - band1_high) >= 0,1);
band2_low_index = find((F - band2_low) >= 0,1);
band2_high_index = find((F - band2_high) >= 0,1);
band3_low_index = find((F - band3_low) >= 0,1);
band3_high_index = find((F - band3_high) >= 0,1);
band4_low_index = find((F - band4_low) >= 0,1);
band4_high_index = find((F - band4_high) >= 0,1);
band5_low_index = find((F - band5_low) >= 0,1);
band5_high_index = find((F - band5_high) >= 0,1);
band6_low_index = find((F - band6_low) >= 0,1);
band6_high_index = find((F - band6_high) >= 0,1);

energy = zeros(6,length(T));
%energy2 = zeros(1,length(T));
%energy3 = zeros(1,length(T));
%energy4 = zeros(1,length(T));
%energy5 = zeros(1,length(T));
%energy6 = zeros(1,length(T));
energynorm = zeros(6,length(T));

%below: run through energy bands, sum, and store energy per time into
%output vectors
for i=1:length(T)
    tempSum = 0;
    for j=band1_low_index:band1_high_index
        tempSum = tempSum + signal(j,i);
    end
    energy(1,i) = tempSum;
    energynorm(1,i) = tempSum/sum(signal(:,i));
    tempSum = 0;
    for j=band2_low_index:band2_high_index
        tempSum = tempSum + signal(j,i);
    end
    energy(2,i) = tempSum;
    energynorm(2,i) = tempSum/sum(signal(:,i));
    tempSum = 0;
    for j=band3_low_index:band3_high_index
        tempSum = tempSum + signal(j,i);
    end
    energy(3,i) = tempSum;
    energynorm(3,i) = tempSum/sum(signal(:,i));
    tempSum = 0;
    for j=band4_low_index:band4_high_index
        tempSum = tempSum + signal(j,i);
    end
    energy(4,i) = tempSum;
    energynorm(4,i) = tempSum/sum(signal(:,i));
    tempSum = 0;
    for j=band5_low_index:band5_high_index
        tempSum = tempSum + signal(j,i);
    end
    energy(5,i) = tempSum;
    energynorm(5,i) = tempSum/sum(signal(:,i));
    tempSum = 0;
    for j=band6_low_index:band6_high_index
        tempSum = tempSum + signal(j,i);
    end
    energy(6,i) = tempSum;
    energynorm(6,i) = tempSum/sum(signal(:,i));
end

totalEnergy = zeros(1,length(T));

for i=1:length(T)
    tempSum = 0;
    for j=1:size(signal,1)
        tempSum = tempSum + signal(j,i);
    end
    totalEnergy(i) = tempSum;
end

e1_avg = mean(energy(1,:));
e2_avg = mean(energy(2,:));
e3_avg = mean(energy(3,:));
e4_avg = mean(energy(4,:));
e5_avg = mean(energy(5,:));
e6_avg = mean(energy(6,:));

dbEnergy(1,:) = tsmovavg(10*log10(energy(1,:)./e1_avg),'t',smoothing_window,2);
dbEnergy(2,:) = tsmovavg(10*log10(energy(2,:)./e2_avg),'t',smoothing_window,2);
dbEnergy(3,:) = tsmovavg(10*log10(energy(3,:)./e3_avg),'t',smoothing_window,2);
dbEnergy(4,:) = tsmovavg(10*log10(energy(4,:)./e4_avg),'t',smoothing_window,2);
dbEnergy(5,:) = tsmovavg(10*log10(energy(5,:)./e5_avg),'t',smoothing_window,2);
dbEnergy(6,:) = tsmovavg(10*log10(energy(6,:)./e6_avg),'t',smoothing_window,2);

diff_dbEnergy(1,:) = diff(dbEnergy(1,:));
diff_dbEnergy(2,:) = diff(dbEnergy(2,:));
diff_dbEnergy(3,:) = diff(dbEnergy(3,:));
diff_dbEnergy(4,:) = diff(dbEnergy(4,:));
diff_dbEnergy(5,:) = diff(dbEnergy(5,:));
diff_dbEnergy(6,:) = diff(dbEnergy(6,:));

dbEnergy_move_avg = zeros(6,length(energy(1,:)));
%dbEnergy2_move_avg = zeros(1,length(energy(1,:)));
%dbEnergy3_move_avg = zeros(1,length(energy(1,:)));
%dbEnergy4_move_avg = zeros(1,length(energy(1,:)));
%dbEnergy5_move_avg = zeros(1,length(energy(1,:)));
%dbEnergy6_move_avg = zeros(1,length(energy(1,:)));

for i = 1:40
    dbEnergy_move_avg(1,i) = mean(energy(1,1:i+40));
end
for i = 41:(length(energy(1,:))-40)
    dbEnergy_move_avg(1,i) = mean(energy(1,i-40:i+40));
end
for i = (length(energy(1,:))-39):length(energy(1,:))
    dbEnergy_move_avg(1,i) = mean(energy(1,i-40:end));
end

for i = 1:40
    dbEnergy_move_avg(2,i) = mean(energy(2,1:i+40));
end
for i = 41:(length(energy(2,:))-40)
    dbEnergy_move_avg(2,i) = mean(energy(2,i-40:i+40));
end
for i = (length(energy(2,:))-39):length(energy(2,:))
    dbEnergy_move_avg(2,i) = mean(energy(2,i-40:end));
end

for i = 1:40
    dbEnergy_move_avg(3,i) = mean(energy(3,1:i+40));
end
for i = 41:(length(energy(3,:))-40)
    dbEnergy_move_avg(3,i) = mean(energy(3,i-40:i+40));
end
for i = (length(energy(3,:))-39):length(energy(3,:))
    dbEnergy_move_avg(3,i) = mean(energy(3,i-40:end));
end

for i = 1:40
    dbEnergy_move_avg(4,i) = mean(energy(4,1:i+40));
end
for i = 41:(length(energy(4,:))-40)
    dbEnergy_move_avg(4,i) = mean(energy(4,i-40:i+40));
end
for i = (length(energy(4,:))-39):length(energy(4,:))
    dbEnergy_move_avg(4,i) = mean(energy(4,i-40:end));
end

for i = 1:40
    dbEnergy_move_avg(5,i) = mean(energy(5,1:i+40));
end
for i = 41:(length(energy(5,:))-40)
    dbEnergy_move_avg(5,i) = mean(energy(5,i-40:i+40));
end
for i = (length(energy(5,:))-39):length(energy(5,:))
    dbEnergy_move_avg(5,i) = mean(energy(5,i-40:end));
end

for i = 1:40
    dbEnergy_move_avg(6,i) = mean(energy(6,1:i+40));
end
for i = 41:(length(energy(6,:))-40)
    dbEnergy_move_avg(6,i) = mean(energy(6,i-40:i+40));
end
for i = (length(energy(6,:))-39):length(energy(6,:))
    dbEnergy_move_avg(6,i) = mean(energy(6,i-40:end));
end


e_norm_MA(1,:) = tsmovavg(10*log10(energy(1,:)./dbEnergy_move_avg(1,:)),'t',smoothing_window,2);
e_norm_MA(2,:) = tsmovavg(10*log10(energy(2,:)./dbEnergy_move_avg(2,:)),'t',smoothing_window,2);
e_norm_MA(3,:) = tsmovavg(10*log10(energy(3,:)./dbEnergy_move_avg(3,:)),'t',smoothing_window,2);
e_norm_MA(4,:) = tsmovavg(10*log10(energy(4,:)./dbEnergy_move_avg(4,:)),'t',smoothing_window,2);
e_norm_MA(5,:) = tsmovavg(10*log10(energy(5,:)./dbEnergy_move_avg(5,:)),'t',smoothing_window,2);
e_norm_MA(6,:) = tsmovavg(10*log10(energy(6,:)./dbEnergy_move_avg(6,:)),'t',smoothing_window,2);

energynorm(1,:) = tsmovavg(energynorm(1,:),'t',smoothing_window,2);
energynorm(2,:) = tsmovavg(energynorm(2,:),'t',smoothing_window,2);
energynorm(3,:) = tsmovavg(energynorm(3,:),'t',smoothing_window,2);
energynorm(4,:) = tsmovavg(energynorm(4,:),'t',smoothing_window,2);
energynorm(5,:) = tsmovavg(energynorm(5,:),'t',smoothing_window,2);
energynorm(6,:) = tsmovavg(energynorm(6,:),'t',smoothing_window,2);

diff_energynorm(1,:) = diff(energynorm(1,:));
diff_energynorm(2,:) = diff(energynorm(2,:));
diff_energynorm(3,:) = diff(energynorm(3,:));
diff_energynorm(4,:) = diff(energynorm(4,:));
diff_energynorm(5,:) = diff(energynorm(5,:));
diff_energynorm(6,:) = diff(energynorm(6,:));

if plots %graph outputs if true

    %below: find average energy for duration of clip 

    subplot_length = 1 + length(energyDB_to_plot);

    %below: 
    figure;

    subplot(subplot_length,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');


    %below: plot only desired energy bands for dB and diffdB
    counter = 2;
    
    if ~isempty(find(energyDB_to_plot == 6,1))
        subplot(subplot_length,1,counter);
        plot(T,dbEnergy(6,:));
        axis tight;ylabel('E6 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 5,1))
        subplot(subplot_length,1,counter);
        plot(T,dbEnergy(5,:));
        axis tight;ylabel('E5 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 4,1))
        subplot(subplot_length,1,counter);
        plot(T,dbEnergy(4,:));
        axis tight;ylabel('E4 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 3,1))
        subplot(subplot_length,1,counter);
        plot(T,dbEnergy(3,:));
        axis tight;ylabel('E3 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 2,1))
        subplot(subplot_length,1,counter);
        plot(T,dbEnergy(2,:));
        axis tight;ylabel('E2 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 1,1))
        subplot(subplot_length,1,counter);
        plot(T,dbEnergy(1,:));
        axis tight;ylabel('E1 (dB)');
    end

    figure;

    subplot(subplot_length,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');

    counter = 2;

    if ~isempty(find(energyDB_to_plot == 6,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_dbEnergy(6,:));
        axis tight;ylabel('dE6 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 5,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_dbEnergy(5,:));
        axis tight;ylabel('dE5 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 4,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_dbEnergy(4,:));
        axis tight;ylabel('dE4 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 3,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_dbEnergy(3,:));
        axis tight;ylabel('dE3 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 2,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_dbEnergy(2,:));
        axis tight;ylabel('dE2 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 1,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_dbEnergy(1,:));
        axis tight;ylabel('dE1 (dB)');
    end

    figure;

    subplot(subplot_length,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');

    counter = 2;

    if ~isempty(find(energyDB_to_plot == 6,1))
        subplot(subplot_length,1,counter);
        plot(T,energynorm(6,:));
        axis tight;ylabel('normE6 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 5,1))
        subplot(subplot_length,1,counter);
        plot(T,energynorm(5,:));
        axis tight;ylabel('normE5 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 4,1))
        subplot(subplot_length,1,counter);
        plot(T,energynorm(4,:));
        axis tight;ylabel('normE4 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 3,1))
        subplot(subplot_length,1,counter);
        plot(T,energynorm(3,:));
        axis tight;ylabel('normE3 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 2,1))
        subplot(subplot_length,1,counter);
        plot(T,energynorm(2,:));
        axis tight;ylabel('normE2 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 1,1))
        subplot(subplot_length,1,counter);
        plot(T,energynorm(1,:));
        axis tight;ylabel('normE1 (dB)');
    end
    
    figure;

    subplot(subplot_length,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');

    counter = 2;

    if ~isempty(find(energyDB_to_plot == 6,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_energynorm(6,:));
        axis tight;ylabel('diff_normE6 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 5,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_energynorm(5,:));
        axis tight;ylabel('diff_normE5 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 4,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_energynorm(4,:));
        axis tight;ylabel('diff_normE4 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 3,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_energynorm(3,:));
        axis tight;ylabel('diff_normE3 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 2,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_energynorm(2,:));
        axis tight;ylabel('diff_normE2 (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 1,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff_energynorm(1,:));
        axis tight;ylabel('diff_normE1 (dB)');
    end
    
    figure;

    subplot(subplot_length,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');

    counter = 2;

    if ~isempty(find(energyDB_to_plot == 6,1))
        subplot(subplot_length,1,counter);
        plot(T,e_norm_MA(6,:));
        axis tight;ylabel('e6_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 5,1))
        subplot(subplot_length,1,counter);
        plot(T,e_norm_MA(5,:));
        axis tight;ylabel('e5_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 4,1))
        subplot(subplot_length,1,counter);
        plot(T,e_norm_MA(4,:));
        axis tight;ylabel('e4_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 3,1))
        subplot(subplot_length,1,counter);
        plot(T,e_norm_MA(3,:));
        axis tight;ylabel('e3_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 2,1))
        subplot(subplot_length,1,counter);
        plot(T,e_norm_MA(2,:));
        axis tight;ylabel('e2_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 1,1))
        subplot(subplot_length,1,counter);
        plot(T,e_norm_MA(1,:));
        axis tight;ylabel('e1_norm_MA (dB)');
    end
    
    figure;

    subplot(subplot_length,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');

    counter = 2;

    if ~isempty(find(energyDB_to_plot == 6,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff(e_norm_MA(6,:)));
        axis tight;ylabel('de6_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 5,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff(e_norm_MA(5,:)));
        axis tight;ylabel('de5_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 4,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff(e_norm_MA(4,:)));
        axis tight;ylabel('de4_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 3,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff(e_norm_MA(3,:)));
        axis tight;ylabel('de3_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 2,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff(e_norm_MA(2,:)));
        axis tight;ylabel('de2_norm_MA (dB)');
        counter = counter + 1;
    end
    if ~isempty(find(energyDB_to_plot == 1,1))
        subplot(subplot_length,1,counter);
        plot(T(1:end-1),diff(e_norm_MA(1,:)));
        axis tight;ylabel('de1_norm_MA (dB)');
    end
    
end


