% Generates a recovery probability plot from the ouput of sparse_experiments.
%     matrix - the type of matrix, used to generate the filename (see below).

% Written by Radu Berinde, MIT, Jan. 2008

function sparse_experiments_plot(matrix, method, signaltype, extraname)

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

load(['Experiments/sparse_experiments-' method '-' matrix '-' signaltype extraname '.mat']);

colormap(gray);
contourf(Ks, Ms, SuccessMatrix');
colorbar;
set(gca, 'FontSize', 13);
xlabel('Sparsity of signal (K)');
ylabel('Number of measurements (M)');
title(sprintf('Matrix: %s  Signal: %s  Method: %s\nProbability of correct recovery, N = %d\nResolution: %d Ms x %d Ks x %d trials', ...
               matrix, signaltype, method, N, ...
               length(Ms), length(Ks), attempts), ...
      'FontSize', 14, 'interpreter', 'none');
saveas(gcf, ['Plots/sparse_experiments-' method '-' matrix '-' signaltype extraname '.jpg'], 'jpg');
saveas(gcf, ['Plots/sparse_experiments-' method '-' matrix '-' signaltype extraname '.eps'], 'epsc');
