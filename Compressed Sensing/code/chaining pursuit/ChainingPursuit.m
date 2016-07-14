% hat = ChainingPursuit( m, V, Phi ),
%
% Attempt to recover m significant spikes
% given measurements V with the system Phi.
%
% The output, hat, is a sparse vector that
% contains O(m) nonzero positions
%
% by Joel A. Tropp, copyright 2005
% See readme.rtf for restrictions
% Date: 15 November 2005

function hat = ChainingPursuit( m, V, Phi ),

% Initializations

rho = 4;                     % Factor decrease per pass
majority = 2/3;			     % Majority vote to identify spike

B = ceil( log2(Phi.d) );     % Number of bit tests


% Basic error checking

if ( m > Phi.N ),
    error( 'The number N of measurements per trial must exceed the number m of spikes.' );
elseif ( size( V ) ~= [ Phi.T, 1 ] ),
    error( 'The data matrix does not match the measurement system (1).' );
elseif ( size( V{1} ) ~= [ Phi.N, B + 1 ] ),
    error( 'The data matrix does not match the measurement system (2).' );
end


% For each pass, ...

for k = 0 : floor( log(m)/log(rho) ),

    % We need to recover m_k spikes
    
    mk = ceil(m / rho^k);
    
    % Make space for the spikes recovered over all trials
    
    intermed = spalloc( Phi.T, Phi.d, Phi.T * mk );
    
    % For each trial...
    
    for t = 1 : Phi.T,        
        
    % Step 1: For each measurement, use bit tests
    %         to make a preliminary list of
    %         locations and values for spikes

    prelim = zeros(Phi.N, 3);

    for n = 1 : Phi.N,
        
        % complement is the complementary set of bit
        % tests for the nth measurement, i.e., the
        % one bits are masked out instead of the zero bits
        % 
        % Calculated by subtracting each bit test from the
        % sum of all positions assigned to the measurement

        complement = V{t}(n, B + 1) - V{t}(n, 1:B); 

        % bitfield lists the bits of the spike location
        % in order from LSB to MSB

        bitfield = ( abs(V{t}(n, 1:B)) > abs(complement) );
        
        % Convert the binary array to a number
        
        loc = 2.^(0:(B - 1)) * bitfield';
        
        % Use the MSB to estimate the value in location loc
        % A median over bits might be more stable but costs more
        
        if ( bitfield(B) == 1 ),
            val = V{t}(n, B);
        else
            val = complement(B);
        end        
        
        % Add the location, value, and its absolute value
        % to the end of the preliminary list
        
        prelim(n, :) = [loc val abs(val)];
    end
    
    % Step 2: Identify (at most) m_k largest positions in
    %         the preliminary list.  If a position appears
    %         multiple times, use the largest estimated value

    % First, we sort the list by position, then by absolute value
    
    prelim = sortrows( prelim, [1 -3] );
    
    % Now we black out all the duplicate rows in this list

    lastPos = 0;
    
    for n = 1 : Phi.N,
        if (prelim(n, 1) == lastPos ),
            prelim(n, :) = 0;
        else
            lastPos = prelim(n, 1);
        end
    end
    
    % Next, sort the list in descending order of absolute value
    
    prelim = sortrows( prelim, -3 );
    
    % Now we pick up to m_k nonzero items at the top of the list
    % and put them in the t-th row of the intermediate estimate matrix

    topmk = find( ne( prelim(1:mk, 1), 0 ) );
    
    intermed(t, :) ...
        = sparse( 1, prelim(topmk, 1), prelim(topmk, 2), 1, Phi.d );
    
    end
    
    % Step 3: Identify indices that appear in more than majority
    %         of trials.  Estimate their values with medians
    
    [dummy, finalLocs] = find( sum( ne(intermed, 0) ) > majority * Phi.T );
    
    finalVals = median( intermed );
    
    % Step 4: Update the data matrix using the positions we've chosen
    %         Note that this requires O( mk ) time because we can index
    %         the measurements in O(1) time.
    
    %         Random access to the measurement system is critical!
    
    for loc = finalLocs,
                
        update = finalVals( loc ) * [bitget(loc, 1:B), 1]; 
        
        for t = 1 : Phi.T,
        
            V{t}( Phi.measurement(t, loc), : ) ...
                = V{t}( Phi.measurement(t, loc), : ) - update;
        end
    end
    
    % Step 4: Add the current approximation to the estimate
    
    if (k == 0),
        hat = sparse( finalLocs, 1, finalVals(finalLocs), Phi.d, 1, 3*m );
        
    else
        hat = hat + sparse( finalLocs, 1, finalVals(finalLocs), Phi.d, 1 );
        
    end
    
    % Do it again.
end