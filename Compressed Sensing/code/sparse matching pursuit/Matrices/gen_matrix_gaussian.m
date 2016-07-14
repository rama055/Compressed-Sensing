% generates a Gaussian matrix of M measurements
% Written by Radu Berinde, MIT, Jan. 2008

function matrix = gen_matrix_gaussian(N, M, arg1_unused, arg2_unused)

matrix.N = N;
matrix.M = M;

matrix.A = randn(M, N);

matrix.Afun = @(z) matrix.A * z;
matrix.Atfun = @(z) matrix.A' * z;
