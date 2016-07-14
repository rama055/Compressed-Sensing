
function synthesize_fp(file,f,d,p,gamma)
% Matlab function synthesize_fp(file,f,d,p,gamma) 
% creates a .wav audio file of a sound where all frequencies, 
% amplitudes(power) and phase may be specified.
%
% file is a string which is the name of the .wav file.
% f is a length n vector of frequencies in Hz
% d is the duration in seconds
% p is a length n vector of amplitudes
% gamma is a length n vector of phase shifts, as a fraction of the 
%  period of the first harmonic f1.
%
% Mark R. Petersen, U. of Colorado Boulder Applied Math Dept, Feb 2004
  
Fs=22050; nbits=8;              % frequency and bit rate of wav file

t = linspace(1/Fs, d, d*Fs);    % time
y = zeros(1,Fs*d);              % initialize sound data
for j=1:length(p);
  y = y + p(j)*cos(2*pi*f(j)*(t-gamma(j)/f(1))); % sythesize waveform
end
y = .5*y/max(y);                % normalize.  Coefficent controls volume.
wavwrite( y, Fs, nbits, file)