%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Mermelstein Peakpicking 
% 
% Sukmyung Lee                 
% Yonsei Univ. DSP Lab. pooh390@dsp.yonsei.ac.kr          
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output: Loc_of_peak - Location of peak
% &input  Num_of_peak - number of peak
% 
% input: input - input signal
%        Begin - begin point
%        End - end point
%        dip_Thr - threshold of dip
%        peak_Thr - threshold of peak
%
% REFERENCE: Vowel Landmark Detection , A.W Howitt
%            Vowel Landmark toolkit by Howitt.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [Loc_of_peak, Num_of_peak]=mermelstein(input,Begin,End,dip_Thr,peak_Thr,Loc_of_peak,Num_of_peak)

% Find the peak in the region

[Max_v,Max_p]=max(input(Begin:End));
Max_p=Max_p+Begin-1;

% Forward hull

fdValue=0.0;        % depth of dip value
fd=Begin;           % indices for dips
fh=Begin;           % indices for hulls
for i=Begin:Max_p
    if(input(i)>input(fh))
        fh=i;
    elseif((input(fh)-input(i))>fdValue)
        fdValue=input(fh)-input(i);
        fd=i;
    end
end

% Backward hull

bdValue=0.0;        % depth of dip value
bd=End;             % indices for dips
bh=End;             % indices for hulls
for i=End:-1:Max_p
    if(input(i)>input(bh))
        bh=i;
    elseif((input(bh)-input(i))>bdValue)
        bdValue=input(bh)-input(i);
        bd=i;
    end
end

% Combine the results

dipValue=0.0;       % deepest dip in the regions
dip=0;              % index for deepest dip 

if(fdValue>bdValue)
    dip=fd;
    dipValue=fdValue;
end
if(bdValue>=fdValue)
    dip=bd;
    dipValue=bdValue;
end
% dip
% Judge the value
% recurse or terminate

if(dipValue>dip_Thr)
    [Loc_of_peak, Num_of_peak]=mermelstein(input,Begin,dip,dip_Thr,peak_Thr,Loc_of_peak,Num_of_peak);
    [Loc_of_peak, Num_of_peak]=mermelstein(input,dip,End,dip_Thr,peak_Thr,Loc_of_peak,Num_of_peak);
elseif(Max_v>peak_Thr)
    Num_of_peak=Num_of_peak+1;
    Loc_of_peak(Num_of_peak)=Max_p;
end
