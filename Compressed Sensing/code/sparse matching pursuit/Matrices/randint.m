% Generates a random integer matrix, with integers in the [Range(1) Range(2)]
% interval.

function out = rand(N, M, Range)

if (Range(2) < Range(1))
    error('Range(2) should be >= Range(1)');
end

out = ones(N, M) * Range(1) + floor(rand(N, M) * (Range(2)-Range(1)+1));
