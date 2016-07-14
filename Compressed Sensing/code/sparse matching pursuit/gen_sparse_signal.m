% generates a sparse signal of size 1xN, with num_peaks +/-1 peaks and
% (optional) additive gaussian noise of stdev noise_magnitude
%
% Written by Radu Berinde, MIT, Jan. 2008
function [signal] = gen_sparse_signal(N, num_peaks, noise_magnitude)
if (nargin < 3) noise_magnitude = 0; end;
if (num_peaks > N)
    num_peaks = N;
end
signal = zeros(N, 1);
perm = randperm(N);
signal(perm(1:num_peaks)) = sign(randn(num_peaks, 1));
signal = signal + randn(N, 1) .* noise_magnitude;
