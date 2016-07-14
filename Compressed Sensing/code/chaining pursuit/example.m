function example;

% Two examples of Chaining Pursuit in action
%
% by Joel A. Tropp, copyright 2005
% See readme.rtf for restrictions
% Date: 15 November 2005

disp( 'Generating a measurement system Phi...' )

Phi = GenerateMeasurements( 1024, 16, 4 )

disp( 'Generating a signal s of length 1024 with 4 spikes...' );

s = sparse( 1024, 1 );
spikes = ceil( 1024 * rand( 4, 1 ) );
s( spikes ) = randn( 4, 1 )

disp( 'Encoding the signal to obtain data V...' );

V = EncodeSignal( s, Phi )

disp( 'Recovering the signal with Chaining Pursuit...' );

tic; hat = ChainingPursuit( 4, V, Phi ), toc,

disp( strcat( 'Error in l1 norm: ', 32, num2str( norm( s - hat, 1 ) ) ) );

input( 'Press return to continue.' );

disp( strcat(13) );

%%%%%%%%

disp( 'Generating a signal in weak l1...' );

s = 1./ (1:1024)' .* sign( randn(1024, 1) );

disp( 'Largest 8 terms: ' );

s8 = sparse( s(1:8) )

disp( 'Encoding the signal to obtain data...' );

V = EncodeSignal( s, Phi );

disp( 'Recovering the best eight terms (or so)...' );

tic; hat = ChainingPursuit( 8, V, Phi), toc,

disp( strcat( 'Error in approximation, l1 norm: ', 32, num2str( norm( s - hat, 1 ) ) ) );
disp( strcat( 'Error in best 8-term approximation, l1 norm: ', 32, num2str( norm( s(9:1024), 1 ) ) ) );
