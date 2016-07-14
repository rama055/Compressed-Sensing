% generates a (+1, -1, 0) sparse matrix of M lines, N columns, and D +/-1s on each
% column Written by Radu Berinde, MIT, Jan. 2008

function matrix = gen_matrix_sparseplusminus(N, M, D, arg2_unused)

matrix.N = N;
matrix.M = M;

L = zeros(1, N*D);
C = zeros(1, N*D);

disp([ 'Creating matrix for M = ' num2str(M) ', D = ' num2str(D) '...']);
for n = 1:N
    while true
        l = randint(1, D, [1 M]);
        if length(unique(l)) == D
            break;
        end
    end
    for i = 1:D
        L((n-1)*D + i) = l(i);
        C((n-1)*D + i) = n;
    end
    if mod(n, 5000) == 0
        disp([ num2str(n) ' columns done']);
    end
end

V = sign(randn(1, N*D));
matrix.A = sparse(L, C, V, M, N); 

matrix.Afun  = @(z) matrix.A * z;
matrix.Atfun = @(z) matrix.A' * z;
