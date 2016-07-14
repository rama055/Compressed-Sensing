function x = reconstructAmp(A, y, T, tol, f)
% RECONSTRUCTAMP recovers a sparse vector x from few linear measurements y.
%
% x = reconstructAmp(A, y, T, tol,f, verbose)
%
%   Arguments:
%       A - measurement matrix
%       y - measurements
%       T - max number of iterations 
%       tol - stopping criteria 
%       f - original vector used to print progress of MSE 



% Set some parameters
if(nargin < 3)
    T = 500;
end
if(nargin < 4)
    tol = 0.0001;
end
if(nargin < 5)
    f = 0;
end

% Length of the original signal
N = size(A, 2);

% Length of the measurement vector
n = size(A, 1);

% Initial estimate
x = zeros(N, 1);
z = y;

% Start estimation
for t = 1:T
    % Pre-threshold value
    gamma = x + A'*z;

    % Find n-th largest coefficient of gamma
    threshold = largestElement(abs(gamma), n);

    % Estimate the signal (by soft thresholding)
    x = eta(gamma, threshold);

    % Update the residual
    z = y - A*x + (z/n)*sum(etaprime(gamma, threshold));

    % Stopping criteria
    if(norm(y - A*x)/norm(y) < tol)
        break;
    end
end
