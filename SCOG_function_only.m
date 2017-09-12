function [ smoothCOG, outputEnergy, output ] = SCOG_function_only( T,P,F,signal,smoothing_window,plotOutput )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here


cog = zeros(1,length(T));

for j=1:length(T)
    % calculation of spectral center of gravity
    temp = 0;
    temp2 = 0;
    for i = 1: length(F)
        temp = temp + signal(i,j)*F(i);
        temp2 = temp2 + signal(i,j);
    end
    cog(j) = temp/temp2 ;        % spectral center of gravity
end

totalEnergy = zeros(1,length(T));

for i=1:length(T)
    tempSum = 0;
    for j=1:size(signal,1)
        tempSum = tempSum + signal(j,i);
    end
    totalEnergy(i) = tempSum;
end

smoothCOG = tsmovavg(cog,'t',smoothing_window,2);
smoothEnergy = tsmovavg(totalEnergy,'t',smoothing_window,2);

outputEnergy = smoothEnergy/max(smoothEnergy);

H0 = ones(1,length(T));

for i = 1:length(T)
    if smoothEnergy(i) > mean(totalEnergy)/3
        H0(i) = 0;
    end
end

output = smoothCOG.*H0;

if plotOutput

    %below: 
    figure;

    subplot(2,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');
    
    subplot(2,1,2);
    plot(T,output);
    axis tight;
    ylabel('Spectral Center of Gravity (Hz)');
    
        %below: 
    figure;

    subplot(2,1,1);
    surf(T,F,10*log10(P),'edgecolor','none');
    axis tight;
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');
    
    subplot(2,1,2);
    plot(T(1:end-1),diff(output));
    axis tight;
    ylabel('diff Spectral Center of Gravity (Hz)');
end

end

