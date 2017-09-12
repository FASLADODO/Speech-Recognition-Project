    
function [ippStartCorrected, ippEndCorrected] = linearScan(pitches, beginSearch)
        ippStartCorrected = -1;
        ippEndCorrected = -1;
        %disp(beginSearch);
        k = round(beginSearch);
        while pitches(k)==0            
            ippStartCorrected = k / 1000;
            k = k - 1;
            if k==1
                break
            end
        end 
        
        k = round(beginSearch);
        while pitches(k)==0
            ippEndCorrected = k / 1000;
            k = k + 1;
            if k==size(pitches)-1
                break
            end
        end
        
    end