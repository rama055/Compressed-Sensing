% image_test - performs some tests on an image, change parameters inside script.
% image_test(true) - performs tests but skips tests for which output files
%     already exist.
% Written by Radu Berinde, MIT, Jan. 2008

function image_test(skip_done)

if nargin < 1
    skip_done = false;
end

image = load_image('boat', 'db4', 3, 'per');

Ms = [7500 10000 15000 20000 25000 30000];
matrices = {'countmin_threewise6'}
%matrices = {'sparseplusminus4', 'sparseplusminus8'};
%matrices = {'sparse4', 'sparse8', 'sparse16', 'fourier', 'hadamard'};
experiments = {'tv'};
%experiments = {'lp', 'tv'};

for m = 1:length(Ms)
    for matrix = 1:length(matrices)
        for experiment = 1:length(experiments)
            image_experiment(experiments{experiment}, image, Ms(m), matrices{matrix}, -1, true, skip_done);
        end
    end
end
