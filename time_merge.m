function [new_starts,new_stops]=time_merge(starts,stops,threshold)
new_starts=starts;
new_stops=stops;
for i=2:length(starts)
   if starts(i)-stops(i-1)<threshold
      new_starts=new_starts(new_starts~=starts(i));
      new_stops=new_stops(new_stops~=stops(i-1));
   end
end

end