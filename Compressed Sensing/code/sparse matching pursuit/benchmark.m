% Performs a runtime benchmark of several algorithms.
%
% Written by Radu Berinde, MIT, 2008


init
SignalType = 'plus_minus_one_peaks';

Methods = {'countmin', 'countmin', 'smp(10,2)', 'gpsr', 'lp'};
Trials = {200, 200, 50, 20, 10};
MatrixTypes = {'countmin10', 'countmin50', 'countmin10', 'countmin10', 'countmin10'};
Descriptions = {'Count-Min (d=10)', 'Count-Min (d=50)', 'SMP', 'GPSR', 'l1-Magic'};

Ns = round(logspace(3, 6, 10));
Ks = round(Ns .* 0.002);
Ms = round(Ns .* 0.10);

times = zeros(length(Methods), length(Ns));

for i = length(Ns):-1:1
    N = Ns(i);
    K = Ks(i);
    M = Ms(i);
 
    for m = 1:length(Methods)
        method = Methods{m};

        % report
        title(sprintf('i = %d (N=%d, K=%d, M=%d), m = %d', i, N, K, M, m));
        drawnow

        trials = Trials{m};

        % Perform the experiments

        time = 0;
        for t = 1:trials
            signal = gen_signal(N, K, SignalType);
            mat = gen_matrix(N, M, MatrixTypes{m});
            b = mat.Afun(signal);
            [x1, experiment_time] = recovery(method, signal, mat, K);
            if (experiment_time < 0.01) 
                experiment_time = 0.01;
            end
            time = time + experiment_time;
            clear b
            clear mat
            clear signal
        end
        times(m, i) = time / trials;


    end
end

outfile = 'Experiments/benchmark.mat';
save(outfile, 'SignalType', 'Trials', 'MatrixTypes', 'Descriptions', 'Methods', 'Ns', 'Ks', 'Ms', 'times');
