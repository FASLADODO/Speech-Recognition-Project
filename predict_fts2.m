function [ft_closures,ft_releases]=predict_fts2(f_starts,f_stops,T,F1,F2,F3)
diffF1=abs(diff(smooth(F1)));
diffF2=abs(diff(smooth(F2)));
diffF3=abs(diff(smooth(F3)));
diffF=smooth(diffF1+diffF2+diffF3);
meanF=mean(diffF);

ft_closures=zeros(length(f_starts));
ftc_index=0;
ft_releases=zeros(length(f_stops));
ftr_index=0;

for i=1:length(f_starts)
    start_index=find(T==f_starts(i),1);
    stop_index=find(T==f_stops(i),1);
    %start_index=start_index-15;
    %stop_index=stop_index+15;
    %mid_index=floor(0.5*(start_index+stop_index));
    if start_index>20
    front=diffF(start_index-15:start_index+15); %:mid_index);
    else
    front=diffF(5:start_index+15);
    start_index=20;
    end
    if stop_index<length(diffF)-19
    back=diffF(stop_index-15:stop_index+15);
    else
    back=diffF(stop_index-15:end-5);
    end
    ftc=find(front==max(front),1);
    ftr=find(back==max(back),1);
    if front(ftc)>2*meanF
        ftc_index=ftc_index+1;
        ft_closures(ftc_index)=T(ftc+start_index-16);
    end
    if back(ftr)>2*meanF
        ftr_index=ftr_index+1;
        ft_releases(ftr_index)=T(ftr+stop_index-6);
    end
end
ft_closures(ftc_index+1:end)=[];
ft_releases(ftr_index+1:end)=[];
end