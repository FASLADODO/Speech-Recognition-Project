function [ PoVdata, time ] = PoV( soundFile, plotOutput, soundMono,hamming_window_length,window_overlap_amount,fft_n,waveform_samplingFrequency )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

input('\nWaveSurfer Instructions:\n\nPLEASE MAKE SURE:\n1) WAVESURFER.EXE IS IN ACTIVE DIRECTORY!!\n2) .WAV FILE CONTAINS NO SPACES!!\n\n1) Right Click 3rd Pane From Top (Pitch Pane)\n2) Select Save Data File\n3) DO NOT Edit Name\n4) Hit Save\n5) Exit WaveSurfer\n\nHit ENTER key to continue:');

system(['wavesurfer.exe -config SpchCommGrp ' soundFile]);

[S,F,T,P] = spectrogram(soundMono,hamming_window_length,window_overlap_amount,fft_n,waveform_samplingFrequency);

string = {soundFile};

s = string{1}(1:end-4);

data = importdata([s '.f0'],',',8);

C = strsplit(data.textdata{6},' ');

frameInterval = str2num(C{3});

PoVdataTemp = data.data(:,2);

PoVdata = PoVdataTemp(.1/frameInterval:end);

numPoints = length(PoVdata);

lastTime = frameInterval*numPoints;

time = frameInterval:frameInterval:lastTime;

if plotOutput
    
    %below: 
    figure;

    subplot(2,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');
    
    subplot(2,1,2);
    plot(time,PoVdata);
    axis tight;
    ylim([0 1.1]);
    ylabel('Probability of Voicing (binary)');
    
    %below: 
    figure;

    subplot(2,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');
    
    subplot(2,1,2);
    plot(time(1:end-1),diff(PoVdata));
    axis tight;
    ylabel('diff Probability of Voicing (binary)');
end

end

