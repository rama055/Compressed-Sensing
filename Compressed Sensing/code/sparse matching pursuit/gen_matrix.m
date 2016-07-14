%  gen_matrix(N, M, description) - Generates an MxN measurement matrix given N,
%  M and a description string.
%
%  Dispatches to Matrices/gen_matrix_<type> (see those files for descriptions).
%
%  Currently recognized strings are:
%      'sparse<d>' (e.g. 'sparse8', 'sparse16')
%              Random binary sparse matrix with <d> 1s per column. With the
%              right parameters it is (with high probability) an expander.
%
%      'countmin<d>' (<d> is the column density, i.e. number of sketches)
%              Random binary sparse matrix. The rows are divided into <d>
%              "row-sections", and for each column there is one 1 placed
%              randomly inside each section of each column. The original
%              Count-Min algorithm usis this kind of matrix (<d> hash functions,
%              m/<d> buckets each). With the right parameters it is with high
%              probability an expander.
%
%      'countmin_twowise<d>'
%              Same as countmin<d>, except the random positions of the 1s in
%              each row-section are determined using <d> 2-wise independent
%              hash-functions.
%
%      'countmin_threewise<d>'
%              Same as countmin<d>, except the random positions of the 1s in
%              each row-section are determined using <d> 3-wise independent
%              hash-functions.
%
%      'countmin_implicit_twowise<d>'
%              Same as countmin_twowise<d>, except that only the parameters of
%              the hash functions are stored. The matrix is thus stored
%              implicitly, and it is "re-generated" on demand.
%
%      'fourier'
%              Scrambled Fourier transform matrix, an efficient way to emulate a
%              "noise" matrix (as used in the boat image experiments in
%              Candes/Romberg/Tao, Stable Signal Recovery from Incomplete and
%              Inaccurate Measurements).
%
%      'gaussian'
%              Random Gaussian matrix.
%
%      'hadamard'
%              Hadamard matrix.
%
%      'sparseplusminus<d>' (<d> is the column density, like for sparse)
%              Like sparse<d>, but +1 or -1s are placed randomly instead of 1s.
%
% Written by Radu Berinde, MIT, 2008

function matrix = gen_matrix(N, M, description)

addpath Matrices

[name, remainder] = strtok(description, '0123456789');
[args_ret, count, errmsg, nextindex] = sscanf(remainder, '%d.%d');

if nextindex ~= length(remainder)+1
    error(['Invalid matrix argument ' remainder ]);
end


args = [0 0];
for i = 1:2
    if length(args_ret) >= i
        args(i) = args_ret(i);
    end
end

name = lower(name);
matrix = eval(['gen_matrix_' name '(N, M, args(1), args(2))']);

matrix.type = description;
