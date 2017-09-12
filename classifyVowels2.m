%Written by Max Murin March 2017
%Modified by Collin Potts July 2017 for use with full system
%Classify a set of vowels based on a training dataset and a testing
%dataset.
%Inputs -- train: training dataset as a struct array with fields f1, f2,
%back, high, low, ctr, and atr.
%  test: testing dataset as a struct array with fields f1 and f2 (at
%  least).
%  classCovariance: boolean, set to true if covariances should be used
%  based on each class or based on the overall covariance
%Outputs -- the input classify with extra fields back, high, low, ctr, and
%  atr. Does not modify other fields in classify.

function [v_info] = classifyVowels2(v_times,T,F1,F2)

classify = struct('f1',zeros(1,length(v_times)), 'f2', zeros(1,length(v_times)));
for i=1:length(v_times)
    f1 = F1(floor(v_times(i)*length(F1)/T(end)));
    f2 = F2(floor(v_times(i)*length(F2)/T(end)));
    classify(i).f1 = f1;
    classify(i).f2 = f2;
end

extCategories = struct('back', {0, 1});
heightCategories = struct('high', {1, 0, 0}, 'low', {0, 0, 1});
atrHighCategories = struct('high', {1, 1}, 'atr', {1, 0}, 'ctr', {0, 0});
atrMidCategories = struct('high', {0, 0}, 'low', {0, 0}, 'atr', {1, 0}, 'ctr', {0, 0});
ctrCategories = struct('low', {1, 1}, 'atr', {0, 0}, 'ctr', {1, 0});
load('models.mat','extTraining','heightTraining','atrHighTraining',...
    'atrMidTraining','ctrTraining');
classified = classifyCategories(extTraining, classify, extCategories);
[classified, classes] = classifyCategories(heightTraining, classified, heightCategories);
%[~, testedHigh] = classifyCategories(atrHighTraining, classified,atrHighCategories);
[classified, testedMid] = classifyCategories(atrMidTraining, classified, atrMidCategories);
[classified, testedLow] = classifyCategories(ctrTraining, classified, ctrCategories);
%classified = multiInterleave(classes, testedHigh, testedMid, testedLow);

v_info = strings(length(v_times),5);
%length(v_times)
%[classified.atr]
for i=1:length(v_times)
    if classified(i).back
        v_info(i,1) = '"<back>"';
    else
        v_info(i,1) = '"<front>"';
    end
    if classified(i).high
        v_info(i,2) = '"<high>"';
    elseif classified(i).low
        v_info(i,2) = '"<low>"';
    else
        v_info(i,2) = '"<mid>"';
    end
    if classified(i).atr
        v_info(i,3) = '"<atr>"';
    end
    if classified(i).ctr
        v_info(i,4) = '"<ctr>"';
    end
end
end