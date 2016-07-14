% wavinout.m
%
% An example Matlab script to demonstrate WAV-file input/output, 
%as  well as a few other basic concepts.


% The following function call assumes that the file 'guitar.wav' is
% in the current directory or a location in the Matlab path.
%
% The clear function clears all Matlab variables.  You don't
% necessarily want to use it at the beginning of a script since it
% might wipe away other data you were working with.  But it's
% useful for clearing your workspace variables.
clear

% Also, note that text messages and filenames must be single quoted
% in Matlab.
[y, fs] = audioread('guitar.wav');

% Use the sound function to play the data at the original sample
% rate.
disp('Playing at the original sample rate.');
sound(y, fs);

% The disp function can be used to print simple messages to the
% Matlab console.  The pause function will wait for a keyboard key
% to be depressed.
disp('Hit any key to continue ...');
pause

% Now play the data and half the original sample rate.
disp('Playing at half the sample rate.');
sound(y, fs/2);

% Print the min and max values of the audio data.
fprintf('The maximum data value is %f.\n', max(y));
fprintf('The minimum data value is %f.\n', min(y));

% Let's apply a nonlinear scaling to the signal.  First we'll plot
% the function to be applied.
power = 0.5;
x = -1.0:0.01:1.0;   % equally spaced numbers between -1 and 1
plot(sign(x).*abs(x).^power)
disp('Plotting scale function.');

disp('Hit any key to continue ...');
pause

% Now apply this scaling to the sound data, play it, and then write
% it out to a new file.
y = sign(y).*abs(y).^power;
sound(0.9*y, fs);
audiowrite('newsound.wav',0.9*y, fs);