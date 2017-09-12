function [f_closures,f_releases]=FricativeDetector2(T,V,g_starts,g_stops)
glottal_indices=isininterval(T,g_starts,g_stops);
nong_indices=~glottal_indices;
sumV=zeros(length(V),1);
eRatio=zeros(length(V),1);
for i=1:length(V)
    sumV(i)=sum(V(i,:));
    eRatio(i)=sum(V(i,1:4))/sum(V(i,:));
end
eRatio=smooth(eRatio,50);
minThreshold=mean(sumV)*0.005;
durThreshold=0.01;

f_closures=zeros(20,1);
f_releases=zeros(20,1);
index=0;
t=1;
while t<length(T)
    if nong_indices(t) && sumV(t)>minThreshold && eRatio(t)<0.9
        potentialStart=T(t);
        while t<length(T) && nong_indices(t) && sumV(t)>minThreshold && eRatio(t)<0.9
            t=t+1;
        end
        potentialStop=T(t);
        if potentialStop-potentialStart>durThreshold
            index=index+1;
            f_closures(index)=potentialStart;
            f_releases(index)=potentialStop;
        end
    end
    t=t+1;
end

f_closures(index+1:end)=[];
f_releases(index+1:end)=[];
end