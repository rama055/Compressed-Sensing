
function analyze(file)
% Matlab function analyze(file) 
% plots the waveform and power spectrum of a wav sound file.
% For example, type analyze('piano.wav') at the Matlab prompt.
%
% Mark R. Petersen, U. of Colorado Boulder Applied Math Dept, Feb 2004


[y, Fs] = wavread(file);      % y is sound data, Fs is sample frequency.
t = (1:length(y))/Fs;         % time

ind = find(t>0.1 & t<0.12);   % set time duration for waveform plot
figure; subplot(1,2,1)
plot(t(ind),y(ind))  
axis tight         
title(['Waveform of ' file])

N = 2^12;                     % number of points to analyze
c = fft(y(1:N))/N;            % compute fft of sound data
p = 2*abs( c(2:N/2));         % compute power at each frequency
f = (1:N/2-1)*Fs/N;           % frequency corresponding to p

subplot(1,2,2)
semilogy(f,p)
axis([0 4000 10^-4 1])                
title(['Power Spectrum of ' file])