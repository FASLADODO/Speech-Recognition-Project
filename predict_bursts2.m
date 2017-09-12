function [bursts] = predict_bursts2(f_starts,f_stops,T,V,wav_file)
audio=audioread(wav_file);
audio=smooth(audio,10);
bursts=zeros(2*length(f_starts),1);
burst_index=0;
for i=1:length(f_starts)
    start_index = floor(f_starts(i)*44000);
    stop_index = floor(f_stops(i)*44000);
    [peaks,peak_locs]=findpeaks(audio(start_index:stop_index));
    peak1_index=find(peaks==max(peaks),1);
    burst_index=burst_index+1;
    bursts(burst_index)=(peak_locs(peak1_index)+start_index-1)/44000;
    peak2_index=find(peaks==max(peaks(peaks ~= max(peaks))),1);%
    dist1=eDist(V,T,peak_locs(peak1_index)+start_index-1);
    dist2=eDist(V,T,peak_locs(peak2_index)+start_index-1);
    %if sum(abs(dist1-dist2))>6
    %    burst_index=burst_index+1;
    %    bursts(burst_index)=(peak_locs(peak2_index)+start_index-1)/44000;
    %end
end
bursts(burst_index+1:end)=[];
end

function [dist] = eDist(V,T,i_init)
    t=i_init/44000;
    i = find(abs(T-t)==min(abs(T-t)));
    V1=averageV(V,i,1);
    V2=averageV(V,i,2);
    V3=averageV(V,i,3);
    V4=averageV(V,i,4);
    V5=averageV(V,i,5);
    V6=averageV(V,i,6);
    V_list=[V1 V2 V3 V4 V5 V6];
    V_list=sort(V_list);
    dist=[find(V_list==V1) find(V_list==V2) find(V_list==V3) find(V_list==V4) ...
        find(V_list==V5) find(V_list==V6)];
end

function V_new = averageV(V,i,n)
    netV=sum(V(i-5:i+5,n));
    V_new = netV/length(V(i-5:i+5,n));
end