function [g_starts,g_stops]=predict_glottals2(T,F0)
g_starts=zeros(floor(length(F0)/50),1);
g_stops=zeros(floor(length(F0)/50),1);
g_start_index=0;
g_stop_index=0;
g=false;
for t=1:length(F0)
    if ~~F0(t)~=g
        g=~g;
        if g==0
            g_stop_index=g_stop_index+1;
            g_stops(g_stop_index)=T(t);
        else
            g_start_index=g_start_index+1;
            g_starts(g_start_index)=T(t);
        end
    end
end
g_starts(g_start_index+1:end)=[];
g_stops(g_stop_index+1:end)=[];
[g_starts,g_stops]=time_merge(g_starts,g_stops,0.015);
end