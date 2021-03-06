function paramlist = func_getparameterlist(param)
% paramlist = func_getparameterlist(param)
% Input:  param - parameter (optional)
% Output: paramlist - list of parameters; or
%         index of the parameter in the list
% Notes:  Dual purpose function
%
% Author: Yen-Liang Shue, Speech Processing and Auditory Perception Laboratory, UCLA
% Copyright UCLA SPAPL 2009


paramlist = {'F0 (Straight)', ...
             'F0 (Snack)', ...
             'F0 (Praat)', ...
             'F0 (SHR)', ...
             'F0 (Other)', ...
             'F1, F2, F3, F4 (Snack)', ...
             'F1, F2, F3, F4 (Praat)', ...
             'F1, F2, F3, F4 (Other)', ...
             'H1, H2, H4', ...
             'A1, A2, A3' ...
             'H1*-H2*, H2*-H4*', ...
             'H1*-A1*, H1*-A2*, H1*-A3*', ...
             'Energy', ...
             'CPP', ...
             'Harmonic to Noise Ratios - HNR', ...
             'Subharmonic to Harmonic Ratio - SHR', ...
             };


% user is asking for index to a param
if (nargin == 1)
    for k=1:length(paramlist)
        if (strcmp(paramlist{k}, param))
            paramlist = k;
            return;
        end
    end
    paramlist = -1;  % param not found in list
end

