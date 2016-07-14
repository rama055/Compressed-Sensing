% Performs experiments with truly sparse vectors; useful to get a sparsity vs
% measurements probability of success plot.
%
% Written by Radu Berinde, MIT, 2008

function sparse_experiments(matrix, method, signaltype, extraname)
init

if nargin < 2
    method = 'lp';
end

if nargin < 3
    signaltype = 'plus_minus_one_peaks';
end

if nargin < 4
    extraname = '';
else
    extraname = ['-' extraname];
end

N = 20000;
Ks = 10:10:100;
Ms = 500:500:5000;
attempts = 20;
epsilon = 1e-4;

outfile = ['Experiments/sparse_experiments-' method '-' matrix '-' signaltype extraname '.mat'];
tempfile = ['Experiments/_temp-sparse_experiments-' method '-' matrix '-' signaltype extraname '.mat'];
description = sprintf('N = %d\nK = %s\nM = %s\nmatrix = %s\nsignal = %s\nattempts = %d\nepsilon = %f\n', ...
                       N, mat2str(Ks), mat2str(Ms), matrix, signaltype, attempts, epsilon);
                       
SuccessMatrix = ones(length(Ks), length(Ms)) .* -1;

if exist(tempfile)
    desc = description;
    load(tempfile, 'description');
    if (strcmp(desc, description))
        load(tempfile, 'SuccessMatrix');
    else
        description = desc;
    end
end

time0 = clock;

for k = Ks
    for m = Ms
        if SuccessMatrix(find(Ks == k), find(Ms == m)) >= 0
            disp(sprintf('Data point k = %d, m = %d already computed, skipped.', k, m));
            continue;  % already computed
        end

        mat = gen_matrix(N, m, matrix);
        ok = 0;
        for atttempt = 1:attempts
            signal = gen_signal(N, k, signaltype);

            recovered = recovery(method, signal, mat, k);
            ok = ok + (norm(signal-recovered, inf) < epsilon);
        end
        clear signal
        clear mat
        SuccessMatrix(find(Ks == k), find(Ms == m)) = ok / attempts;
        save(tempfile, 'description', 'SuccessMatrix');
        drawnow;
    end
end

time = etime(clock, time0);
disp(['Experiments done in time: ' time2str(time / 3600) ]);

save(outfile, 'N', 'Ks', 'Ms', 'attempts', 'epsilon', 'matrix', 'SuccessMatrix', 'description', 'time');
delete(tempfile);
