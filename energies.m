function [T,sumV,normalV,ratioV]=energies(fileName)
[T,V,~]=vectorize(fileName);
sumV=zeros(length(V),1);
normalV=zeros(length(V),6);
ratioV=zeros(length(V),6);
for i=1:length(V)
    sumV(i)=sum(V(i,:));
    normalV(i,:) = V(i,:) ./ sumV(i);
    for j=1:6
        ratioV(i,j)=normalV(i,j)/(1-normalV(i,j));
    end
end
for i=1:length(V)
    if sumV(i)<1
        normalV(i,:)=[0 0 0 0 0 0];
        ratioV(i,:)=[0 0 0 0 0 0];
    end
end
end