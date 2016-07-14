% x = smp(matrix, b, l, T)
% Sparse Matching Pursuit algorithm - recover a vector from the sketch b and
% given measurement matrix; use T iterations and l recovery sparsity.
%
% convergence_factor is optional. If given and greater than 0, the algorithm
% limits the norm of the increment at each iteration to at most
% (convergence_factor * |x|_1). Helps to force convergence when the matrix has
% too few measurements to be an l-expander.
%
% Written by Radu Berinde, 2008

function x = smp(matrix, b, l, T, convergence_factor)

if (nargin < 5)
    convergence_factor = 0;
end

N = matrix.N;
x = zeros(N, 1);

for j = 1:T
    disp(sprintf('SMP iteration %d', j));
    c = b - matrix.Afun(x);
    uStar = matrix.MedianRecoveryFun(c);
    u = sparsify(uStar, 2*l);

    % Convergence control
    if (j > 1 && convergence_factor > 0)
        nx = norm(x,1);
        nu = norm(u,1);
        disp(sprintf('u/x norm ratio: %f', nu/nx));
        if (nu > nx*convergence_factor)
           u = u * (convergence_factor*nx/nu);
        end
    end

    x = x + u; % .* 0.5;
    x = sparsify(x, l);
end
