% retains only the K elephants of signal S
% Written by Radu Berinde, MIT, Jan. 2008
function [res] = sparsify_slow(S, K)
N = length(S);
T = sort(abs(S), 'descend');
kval = T(K);
res = S;
for i = 1:N
    if abs(res(i)) < kval
        res(i) = 0;
    end
end

l0 = nnz(res);
if l0 == K
    return;
end

for i = 1:N
    if abs(res(i)) == kval
        res(i) = 0;
        l0 = l0 - 1;
        if l0 == K
            return;
        end
    end
end
