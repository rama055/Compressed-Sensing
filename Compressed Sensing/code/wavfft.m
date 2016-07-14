% wavfft.m
%
% An example Matlab script to demonstrate the use of the fft
% function with WAV-file data.

% The following function call assumes that the file 'triangle.wav' is
% in the current directory or a location in the Matlab path.
[y, fs, nbits] = wavread('triangle.wav');

% Use the sound function to play the data at the original sample
% rate.
disp('Playing at the original sample rate.');
sound(y, fs);
plot(dct(fs));
% First try the specgram function on the sound.
specgram(y);

disp('Hit any key to continue ...');
pause

% OK, now calculate the signal fft and plot the magnitude
% spectrum.  Note that ffts of very long signals can take a long
% time to compute.  Typically, one takes ffts of smaller chunks of
% the sound signal and views their progression over time.
Y = fft(y);
plot(abs(Y));

% Notice how the spectrum magnitude repeats itself.  This always
% happens when computing an fft of a real signal.  As we know from the
% sampling theorem, only frequency content up to half the sample rate
% (or Nyquist rate) can be correctly distinguished in discrete-time
% signals.  Therefore, we really don't need to view the second half
% of the fft data.
%
% We can use the axis function to "zoom in" on the first half of
% the data.
axis([0 length(Y)/2, 0 max(abs(Y))])

% It would be nice to plot this data vs. frequency values along the
% x-axis (either in Hz or radians).  It would also be nice to have
% axis labels.  But we'll leave that for the homework.
