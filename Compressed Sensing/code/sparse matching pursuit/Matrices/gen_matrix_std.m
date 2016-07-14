% Written by Radu Berinde, Mar. 2008
% Based on code by Raghu Kainkaryami
%
% Needs to be updated

function matrix = gen_matrix_std(N, M, D, arg2_unused)

if mod(M, D) ~= 0
    disp('WARNING: D does not divide M');
end

matrix.N = N;
matrix.M = M;
matrix.D = D;

B = floor(M/D);

matrix.B = B;

if D >= B
    error('D should be less than M/D');
end

if ~isprime(B)
    B = primes(B);
    B = B(end);
    disp(sprintf('WARNING: M/D should be prime, reducing M/D to %d (effective M is %d)', B, B*D));
end

disp([ 'Creating STD matrix for M = ' num2str(M) ', D = ' num2str(D) '...']);

if rem(log(N), log(B)) == 0
    Gamma = log(N)/log(B)-1;
else
    Gamma = floor(log(N)/log(B));
end


matrix.buckets = zeros(N, D);

for i = 1:N
    for j = 1:D
        s = 0;

        for c = 0:Gamma
            s = s + ((j-1)^c)*floor((i-1)/B^c);
        end

        matrix.buckets(i, j) = 1 + rem(s, B);
    end
end

L = zeros(1, N*D);
C = zeros(1, N*D);

for n = 1:N
    for i = 1:D
        L((n-1)*D + i) = (i-1)*B + matrix.buckets(n, i);
        C((n-1)*D + i) = n;
    end
end

matrix.A = sparse(L, C, 1, M, N); 

matrix.Afun  = @(z) binsparsemul(matrix.A, z);
matrix.Atfun = @(z) binsparsemul(matrix.A', z);

disp('Done.');
