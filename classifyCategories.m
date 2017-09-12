%Written by Max Murin March 2017, edited July 2017

function [classified, classes] = classifyCategories(trained, data, categories)

classified = data;
testVowels = [data.f1; data.f2];

dist = zeros(numel(trained), size(testVowels,2));
for i=1:numel(trained)
    means = repmat(trained(i).mean, 1, size(testVowels,2));
    %if classCovariance
        covariance = trained(i).covariance;
    %else
    %    covariance = trainCovariance;
    %end
    dist(i, :) = sqrt(sum((((testVowels-means)) .* (covariance \ (testVowels-means)))));
end

[~,classes] = min(dist);

fields = fieldnames(categories);
for i=1:numel(classified)
    for j=1:numel(fields)
        classified(i).(fields{j}) = categories(classes(i)).(fields{j});
    end
end

end