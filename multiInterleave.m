%Written by Max Murin March 2017
%Interleaves multiple arrays to form one large array, with indices given by
%mark.
%Inputs -- mark: an array of integers between 1 and numel(varargin)
%   numel(mark) should be the sum of the numels of the elements of varargin
%   varargin: some number of arrays of the same type
%Outputs -- interleaved: an array consisting of the elements of varargin
%  joined together, where the elements of varargin{i} are mapped to the
%  indices j where mark(j) == i

function [interleaved] = multiInterleave(mark, varargin)
index = zeros(1, numel(varargin));
interleaved = cell2mat(varargin);
for i=1:numel(interleaved)
    index(mark(i)) = index(mark(i)) + 1;
    interleaved(i) = varargin{mark(i)}(index(mark(i)));
end

end