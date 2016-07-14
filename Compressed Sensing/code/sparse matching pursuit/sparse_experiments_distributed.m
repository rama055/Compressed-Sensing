% Performs experiments with truly sparse vectors; useful to get a sparsity vs
% measurements probability of success plot.
%
% DCT variant to be run on a cluster.
%
% Written by Radu Berinde, MIT, 2008

function sparse_experiments_distributed(matrix, method, signaltype, extraname)

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

N = 500000;
Ks = 500:500:6000;
Ms = 20000:20000:200000;
attempts = 20;
epsilon = 1e-4;

outfile = ['sparse_experiments-' method '-' matrix '-' signaltype extraname '.mat'];
description = sprintf('N = %d\nK = %s\nM = %s\nmatrix = %s\nsignal = %s\nattempts = %d\nepsilon = %f\n', ...
                       N, mat2str(Ks), mat2str(Ms), matrix, signaltype, attempts, epsilon);
                       
SuccessMatrix = ones(length(Ks), length(Ms)) .* -1;

jm = findResource('scheduler', 'configuration', 'generic');
set(jm, 'configuration', 'generic');
job = createJob(jm);

set(job, 'FileDependencies', {'l1magic', 'Matrices', 'Util', 'recovery.m', ...
         'gen_matrix.m', 'gen_signal.m', 'gen_sparse_signal.m', 'recover_countmin_positive.m', ...
         'sparse_experiments_distributed_helper.m', 'GPSR_BB.m'});

get(job)

for k = Ks
    for m = Ms
        disp(sprintf('Scheduling job K = %d  M = %d', k, m));
        t = createTask(job, @sparse_experiments_distributed_helper, 1, {N, m, k, method, matrix, signaltype, epsilon, attempts});
    end
end

submit(job);
disp('Submitted...');
tic
waitForState(job);
disp('Done.');
toc

job.Tasks
celldisp(get(job.Tasks, {'ErrorMessage'}))

results = getAllOutputArguments(job);

destroy(job);

results

index = 0;
for k = Ks
    for m = Ms
        index = index + 1;
        SuccessMatrix(find(Ks == k), find(Ms == m)) = results{index};
    end
end

save(outfile, 'N', 'Ks', 'Ms', 'attempts', 'epsilon', 'matrix', 'SuccessMatrix', 'description');
