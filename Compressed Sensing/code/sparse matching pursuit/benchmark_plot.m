% Plots the results of a runtime benchmark (stored in Experiments\benchmark.mat)
%
% Written by Radu Berinde, MIT, 2008

load Experiments\benchmark.mat
Styles = {'-sr', '-vg', '--ob', ':xk', '-.^m' };
for i = 1:length(Descriptions)
    loglog(Ns, times(i, :), Styles{i}, 'LineWidth', 2, 'MarkerSize', 8);
    hold all
end
hold
legend(Descriptions, 'Location', 'NorthWest')
set(gca, 'FontSize', 13)
xlabel('Length of signal (n)');
ylabel('Average recovery time (seconds)');
saveas(gcf, ['Plots/benchmark.jpg'], 'jpg');
saveas(gcf, ['Plots/benchmark.eps'], 'epsc');
