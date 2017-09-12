%Written by Max Murin March 2017
%Finds which indices in potential match a given category
%Inputs -- category: a struct array of size 1
%  potential: a structy array
%Outputs -- matches: the indices i where potential(i) matches category in
%  every field contained in category

function [matches] = matchesCategory(category, potential)
matches = true(1, numel(potential));
fields = fieldnames(category);
for i=1:numel(fields)
    matches = matches & ~xor(category.(fields{i}), [potential.(fields{i})]);
end
end