% generates a binary sparse matrix of M lines, N columns, and D 1s on each column
% Written by Radu Berinde, MIT, Jan. 2008

function matrix = gen_matrix_sparse(N, M, D, arg2_unused)

if D >= M
    disp('Warning: D should be smaller than M!!');
    D = round(M/2) + 1;
    disp(sprintf('Changing D to %d', D));
end

matrix.N = N;
matrix.M = M;
matrix.D = D;

disp([ 'Creating matrix for M = ' num2str(M) ', D = ' num2str(D) '...']);

matrix.neighbors = uint32(randint(N, D, [1 M]));
% Check for and fix duplicate neighbors 
if D > 1
    for n = 1:N
        while true
            if (min(diff(sort(matrix.neighbors(n, :)))) > 0)
                break;
            end
            matrix.neighbors(n, :) = uint32(randint(1, D, [1 M]));
        end
    end
end

L = zeros(1, N*D);
C = zeros(1, N*D);

for n = 1:N
    for i = 1:D
        L((n-1)*D + i) = matrix.neighbors(n, i);
        C((n-1)*D + i) = n;
    end
end


matrix.A = sparse(L, C, 1, M, N); 

matrix.Afun  = @(z) binsparsemul(matrix.A, z);
matrix.Atfun = @(z) binsparsemul(matrix.A', z);

matrix.MedianRecoveryFun = @(z) median_recovery_explicit(N, M, D, matrix.neighbors, z);

