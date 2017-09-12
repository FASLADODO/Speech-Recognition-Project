%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Speech Smoothing 
%
% Sukmyung Lee                                
% Yonsei Univ. DSP Lab. pooh390@dsp.yonsei.ac.kr                                                                              
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% output: output - smooth signal
% 
% input: input - unsmoothing signal
%        smoothing_length - smoothing length
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = smoothing(input,smoothing_length)

temp=ones(1,smoothing_length);
temp1=conv(input,temp);
temp2=smoothing_length/2;
output=temp1(temp2:length(temp1)-temp2)/smoothing_length;



