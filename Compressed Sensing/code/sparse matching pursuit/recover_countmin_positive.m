% x1 = recover_countmin_positive(matrix, b)
%
%   Performs a count-min sketch recovery when the signal is known to be
% non-negative. Takes the minimum value in each bucket.
%
%     N is the size of the signal
%     matrix is the matrix
%     b is the vector of measurements
%
% Written by Radu Berinde, MIT, Jan. 2008

function x1 = recover_countmin_positive(matrix, b)

% reshape vector
N = matrix.N;
D = matrix.D;
B = matrix.B;
b = reshape(b(1:(B*D)), B, D);
b = b';
% b(i,j) = value of bucket j in sketch i

x1 = zeros(N, 1);

for i = 1:N
    vec = zeros(D, 1);
    m = inf;
    for j = 1:D
        v = b(j, matrix.buckets(i, j));
        if m > v
            m = v;
        end
    end
    x1(i) = m;
end
% x1 = sparsify(x1, K);
