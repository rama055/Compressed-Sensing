% Phi = GenerateMeasurements( d, N, T )
%
% Constructs a measurement system for Chaining Pursuit
%
% The output Phi is a structure with fields
%    d = signal dimension
%    T = number of trials
%    N = number of measurements per trial
%    measurement = a T x d integer matrix;
%       measurement(t, i) = measurement to
%       which posn i is assigned in trial t
%
% Theoretically, N = O(m) and T = O( log m log d ).
%
% by Joel A. Tropp, copyright 2005
% See readme.rtf for restrictions
% Date: 15 November 2005

function Phi = GenerateMeasurements( d, N, T ),

% Basic error checking
%
% Neither of the following will kill the program,
% but it's good to know.

if ( N * T * (log2(d) + 1) > d ),
    disp( 'The number of measurements, including bit tests, exceeds the signal length.' );
elseif ( N * T > d ),
    disp( 'The number of measurements exceeds the signal length.' );
end

% Allocate memory

Phi.d = d;
Phi.T = T;
Phi.N = N;
Phi.measurement = zeros( T, d, 'uint16' );

% In each trial, assign each position to one
% of the N measurements, uniformly at random

% You could do this vectorially, but the present
% method requires less memory.  Important for
% very long signals.

for t = 1 : T, 
    Phi.measurement(t, :) = ceil( N * rand(1, d) );
end