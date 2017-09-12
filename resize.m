function new=resize(old,goal)
if size(old,1)==length(old)
    new=zeros(goal,size(old,2));
    for i=1:goal
        new(i,:)=old(ceil(i*length(old)/goal),:);
    end
else
    new=zeros(size(old,1),goal);
    for i=1:goal
        new(:,i)=old(:,ceil(i*length(old)/goal));
    end
end
end