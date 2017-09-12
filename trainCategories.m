%Written by Max Murin July 2017

function [trained] = trainCategories(train, categories, classCovariance)
trained = struct('category', num2cell(categories), 'mean', [], 'covariance', [], 'number', []);
if(nargin < 4)
    classCovariance = false;
end
vowels = [train.f1; train.f2];
covariance = cov(vowels');

for i = 1:numel(trained)
    class = train(matchesCategory(categories(i), train));
    classVowels = [class.f1; class.f2];
    trained(i).mean = mean(classVowels, 2);
    trained(i).number = numel(class);
    if(classCovariance)
        trained(i).covariance = cov(classVowels');
    else
        trained(i).covariance = covariance;
    end
end