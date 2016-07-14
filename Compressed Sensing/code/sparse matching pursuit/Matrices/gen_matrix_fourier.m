% generates a scrambled Fourier "matrix" of M measurements
% Written by Radu Berinde, MIT, Jan. 2008

function matrix = gen_matrix_fourier(N, M, arg1_unused, arg2_unused)

matrix.N = N;
matrix.M = M;

matrix.P = randperm(N);
matrix.OMEGA = randperm(N);
matrix.OMEGA = matrix.OMEGA(1:M/2);

addpath  l1magic/Measurements

matrix.Afun = @(z) A_f(z, matrix.OMEGA, matrix.P);
matrix.Atfun = @(z) At_f(z, N, matrix.OMEGA, matrix.P); 
