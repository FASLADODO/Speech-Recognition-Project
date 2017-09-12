function [ Y ] = isininterval( X, mins, maxs )
%ISININTERVAL Y(i) is 1 or 0; Y(i) == 1 if mins(j) <= X(i) < maxs(j) for
%some j
if length(mins)>length(maxs)
    mins=mins(1:length(maxs));
end
Y = X > 0 & X < 0; % logical of falses
for j = 1:numel(mins)
   Y = Y | (mins(j) <= X & X < maxs(j));
end

end

