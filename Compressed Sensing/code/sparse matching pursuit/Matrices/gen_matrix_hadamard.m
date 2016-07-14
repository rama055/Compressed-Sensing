% generates a scrambled Hadamard "matrix" of M measurements
% Written by Radu Berinde, MIT, Jan. 2008

function matrix = gen_matrix_hadamard(N, M, arg1_unused, arg2_unused)

if N ~= round(2^round(log2(N)))
    error('N should be a power of 2 for Hadamard matrices.');
end

matrix.N = N;
matrix.M = M;

matrix.idx = bitrevorder(1:N);
matrix.P = randperm(N);
matrix.OMEGA = randperm(N);
matrix.OMEGA = matrix.OMEGA(1:M);

matrix.Afun = @(z) A_fw(z, matrix.OMEGA, matrix.idx, matrix.P);
matrix.Atfun = @(z) At_fw(z, matrix.OMEGA, matrix.idx, matrix.P); 
