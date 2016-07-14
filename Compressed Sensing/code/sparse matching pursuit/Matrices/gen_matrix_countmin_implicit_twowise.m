% An implicit version of the 2-independent universal hashing matrix (see
% gen_matrix_countmin_twowise). The hash parameters are stored, and the hash is
% recomputed when needed rather than storing the entire matrix.
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

matrix.Ps = uint32(zeros(D, 1));
matrix.As = uint32(zeros(D, 1));
matrix.Bs = uint32(zeros(D, 1));

for i = 1:D
    % Generate a prime number between N and 2N
    p = floor(N * 2 * (1 + rand(1))) + 1;
    while ~isprime(p)
        p = p+1;
    end
    a = randint(1, 1, [1, p-1]);
    b = randint(1, 1, [1, p-1]);

    if p > intmax('uint32')
        error('Prime number overflows uint32.');
    end

    matrix.Ps(i) = uint32(p);
    matrix.As(i) = uint32(a);
    matrix.Bs(i) = uint32(b);
end

matrix.Afun  = @(z) countmin_implicit_twowise_mul(N, M, D, matrix.B, matrix.Ps, matrix.As, matrix.Bs, z);
matrix.Atfun  = @(z) countmin_implicit_twowise_mul_transpose(N, M, D, matrix.B, matrix.Ps, matrix.As, matrix.Bs, z);

matrix.MedianRecoveryFun = @(z) median_recovery_implicit_twowise(N, M, D, matrix.B, matrix.Ps, matrix.As, matrix.Bs, z);

disp('Done.');
