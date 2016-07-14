function synthesize(file,f,d,p)
% Matlab function synthesize(file,f,d,p) 
% creates a .wav audio file of a sound where the fundamental frequency 
% and amplitudes(power) of the harmonics may be specified.
%
% file is a string which is the name of the .wav file.
% f is the fundamental frequency in Hz
% d is the duration in seconds
% p is a length n vector of amplitudes
%
% For example, synthesize('test.wav', 220, 3, [1 .8 .1 .04])
% makes a 3 second sample at 220 Hz with the harmonics shown.
%
% Mark R. Petersen, U. of Colorado Boulder Applied Math Dept, Feb 2004

Fs=22050; nbits=8;              % frequency and bit rate of wav file

t = linspace(1/Fs, d, d*Fs);    % time
y = zeros(1,Fs*d);              % initialize sound data
for n=1:length(p);
  y = y + p(n)*cos(2*pi*n*f*t); % sythesize waveform
end
y = .5*y/max(y);                % normalize.  Coefficent controls volume.
wavwrite( y, Fs, nbits, file)