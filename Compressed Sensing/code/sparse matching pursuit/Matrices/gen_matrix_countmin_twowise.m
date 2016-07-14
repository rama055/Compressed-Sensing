% Generates a binary sparse matrix of M lines, N columns, and D 1s on each
% column corresponding to a count-min sketch of M/D buckets; D should divide M
% (the code works without this constraint, but the last (M mod D) rows are
% wasted). The matrix is divided row-wise into D sections, each section having
% exactly one 1 on each column section. Also, an NxD neighbor matrix is
% generated, matrix.neighbors(n,i) is the ith neighbor/bucket of n. 
%
% This version uses 2-independent universal hashing to generate the buckets for
% each layer.
%
% Written by Radu Berinde, MIT, 2008

function matrix = gen_matrix_countmin_twowise(N, M, D, arg2_unused)

disp([ 'Creating countmin matrix for M = ' num2str(M) ', D = ' num2str(D) '...']);

if mod(M, D) ~= 0
    disp('WARNING: D should divide M');
end

matrix.N = N;
matrix.M = M;
matrix.D = D;

B = floor(M/D);

matrix.B = B;
matrix.neighbors = uint32(zeros(N, D));
for i = 1:D
    % Generate a prime number between N and 2N
    p = floor(N * 2 * (1 + rand(1))) + 1;
    while ~isprime(p)
        p = p+1;
    end
    a = randint(1, 1, [1, p-1]);
    b = randint(1, 1, [1, p-1]);
    % disp(sprintf('%d %d %d\n', p, a, b));
    for n = 1:N
        matrix.neighbors(n, i) = (i-1)*B + mod(mod(a * n + b, p), B) + 1;
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

disp('Done.');
