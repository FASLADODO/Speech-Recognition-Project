function g=wierd_test(path,fileNames)
g=zeros(length(fileNames),1);
for i=1:length(fileNames)
    [~,f]=test(path,{fileNames{i}});
    g(i)=f(4);
    disp(g(i));
end
mean(g)
std(g)
end