% V = EncodeSignal( s, Phi )
%
% Uses the measurement system Phi to encode the
% signal s
%
% The output V is a cell array with T cells
% -- Each cell is an N x (log(d) + 1) matrix
% -- The nth row of the matrix contains the
%    bit tests for the nth measurement in trial t
%
% by Joel A. Tropp, copyright 2005
% See readme.rtf for restrictions
% Date: 15 November 2005

function V = EncodeSignal( s, Phi ),

% Basic error checking

if ( length(s) ~= Phi.d ),
    error( 'Signal length does not match measurement system.' );
end

s = s(:);                       % Make the signal a column vector

B = ceil( log2( Phi.d ) );      % Number of bit tests

% Allocate memory

V = cell( Phi. T, 1 );                  
for t = 1 : Phi.T,
    V{t} = zeros( Phi.N, B + 1 );      
end
    
% Loop over nonzero signal positions and trials...
%
% Strictly speaking, this approach is cheating but it
% reduces runtime significantly for sparse signals

for i = find(s)',
    
    % Calculate the signal value times the bit masks

    % This implementation masks out zero bits

    % The last column always gets a copy of the signal position
    % ie., its a sum of the signal positions assigned to the measurement
    
    mybits = s(i) * [bitget(i, 1:B), 1];
    
    % Add the signal position to the appropriate measurements
    
    for t = 1 : Phi.T,

    V{ t }( Phi.measurement(t, i), : ) ...
        = V{ t }( Phi.measurement(t, i), : ) + mybits;

    end
end