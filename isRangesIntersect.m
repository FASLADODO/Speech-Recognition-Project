%Takes two intervals and determines whether they intersect
function result = isRangesIntersect(range1, range2)
    if range1(1) <= range2(1)
        lowRange = range1;
        highRange = range2;
    else
        lowRange = range2;
        highRange = range1;
    end

    result = lowRange(2) > highRange(1);

end