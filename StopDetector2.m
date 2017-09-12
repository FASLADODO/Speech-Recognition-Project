function [s_starts,s_stops]=StopDetector2(T,V)
sumV=zeros(length(V),1);
for i=1:length(V)
    sumV(i)=sum(V(i,:));
end
meanV=mean(sumV);
lowerBound=0.01*meanV;

durationThreshold=0.01;
s_starts=zeros(20,1);
s_stops=zeros(20,1);
index=0;
stop_time=T(end);

t=1;
while t<length(T)
    if sumV(t)<lowerBound
        potentialStart=t;
        while t<length(T) && sumV(t)<lowerBound
            t=t+1;
        end
        potentialStop=t-1;
        if T(potentialStop)-T(potentialStart)>durationThreshold
            index=index+1;
            s_starts(index)=T(potentialStart);
            s_stops(index)=T(potentialStop);
        end
    end
    t=t+1;
end

s_starts(index+1:end)=[];
s_stops(index+1:end)=[];

end