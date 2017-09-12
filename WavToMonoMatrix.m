function [ soundMono, Fs ] = WavToMonoMatrix( soundFile )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

[sound, Fs] = audioread(soundFile);
soundMono = sound(:,1);
soundMono = soundMono(Fs*.1:end);

end

