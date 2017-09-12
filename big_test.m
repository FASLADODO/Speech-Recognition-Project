function [scores,fscores,total_errors]=big_test(path,n)
original=cd;
cd(path);
directory=dir;
directory=directory(3:end);
groups=cell(n,1);
total_errors=0;
for i=1:length(groups)
    groups{i}={};
end
for j=0:(length(directory)/2)-1
    name=directory(2*j+1).name;
    dot=find(name=='.');
    dot=dot(1);
    name=name(1:dot-1);
    groups{mod(j,n)+1}{end+1}=name;
end
cd(original)
scores=cell(1,n);
fscores=cell(1,n);
for k=1:n
    testing=groups{k};
    training=groups{1:n ~= k};
    train(path,training);
    [scores{i},fscores{i},errors]=test(path,testing);
    total_errors=total_errors+errors;
end
disp(total_errors);
end