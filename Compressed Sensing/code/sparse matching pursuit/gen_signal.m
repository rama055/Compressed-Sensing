%  gen_signal(N, description) - Generates a signal of size N, sparsity K, given
%  a description string.
%
%  Currently recognized strings are:
%      'plus_minus_one_peaks' - signal has K peaks of value +/-1
%      'plus_one_peaks' - K peaks of value +1
%      'gaussian_peaks' - K peaks of random gaussian values
%      'positive_gaussian_peaks' - K peaks of random positive gaussian values
%
%  Written by Radu Berinde, MIT
function signal = gen_signal(N, K, description)

name = strtok(description, '0123456789');
args = sscanf(description, [ name '%d.%d' ]);

switch lower(name)
    case 'plus_minus_one_peaks'
        signal = gen_sparse_signal(N, K);
    case 'plus_one_peaks'
        signal = abs(gen_sparse_signal(N, K));
    case 'gaussian_peaks'
        signal = abs(gen_sparse_signal(N, K)) .* randn(N, 1);
    case 'positive_gaussian_peaks'
        signal = abs(gen_sparse_signal(N, K) .* randn(N, 1));
    otherwise
        disp([ 'Unknown signal type ' name '.' ]);
end
