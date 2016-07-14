% Runs the multiple attempts of a tespoint. Returns the fraction of successful decodings.
function fraction = sparse_experiments_distributed_helper(N, m, k, method, matrix, signaltype, epsilon, attempts)
init
if m == 0 || m < k
    fraction = 0;
    return;
end

if k == 0
    fraction = 1;
    return;
end

mat = gen_matrix(N, m, matrix);
ok = 0;
for atttempt = 1:attempts
    signal = gen_signal(N, k, signaltype);

    recovered = recovery(method, signal, mat, k);
    ok = ok + (norm(signal-recovered, inf) < epsilon);
end
fraction = ok / attempts;

