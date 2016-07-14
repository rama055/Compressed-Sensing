% [J, WcOut, description] = image_experiment(type, image, M, matrix_type, save_output, skip_done)
%
% Performs an image experiment
%     type is 'lp' or 'tv
%
%     image contains image.name, image.wavelet, image.wavelevel, image.I,
%                    image.Wc, image.Wl 
%
%     M is the number of measurements
%
%     matrix_type is the type of matrix (e.g. 'sparse8')
%
%     recovery_sparsity is needed for some types of recoveries (see
%                                                             recovery.m)
%
%     save_output is optional, when true the following files will be saved:
%         Experiments/<filename>.mat
%         Experiments/<filename>.log
%         Images/<filename>.jpg
%       where <filename> is <image.name>-<type>-<M>-<matrix_type>
%
%     skip_done is optional (false by default); only used if save_output is true:
%       skips the experiment if the output files are already there. Return values 
%     should not be used in this case.
%
% Returns the recovered image, the recovered wavelet vector and the description
% of the experiment.  See end of code for what the mat file contains
% Written by Radu Berinde, MIT, Jan. 2008

function [J, WcOut, description] = image_experiment(type, image, M, matrix_type, recovery_sparsity, save_output, skip_done)
init

if nargin < 5
    recovery_sparsity = -1;
end

if nargin < 6
    save_output = false;
end

if ~save_output || nargin < 7
    skip_done = false;
end

if (strcmp(lower(type), 'tv'))
    % no wavelet for TV, remove it to prevent confusion
    image.wavelet = '<none>';
    image.wavelevel = 0;
    image.dwtmode = '';
    image.Wc = [];
    image.Wl = [];
    WcOut = [];
end

description = sprintf('\nExperiment: %s\nImage name: %s\nWavelet: %s, level %d\nM = %d Matrix = %s\n', ...
                      upper(type), image.name, image.wavelet, image.wavelevel, M, matrix_type);
disp(description);                      

if save_output
    filename = sprintf('%s-%s-%d-%s', image.name, lower(type), M, lower(matrix_type));
    diaryfile = [ 'Experiments/' filename '.log' ];
    savefile =  [ 'Experiments/' filename '.mat' ];
    imagefile = [ 'Images/' filename '.jpg' ];

    if skip_done && exist(diaryfile) && exist(savefile) && exist(imagefile)
        disp('Skip_done is on, output files already exist, skipping..');
        return;
    end
    diary off; % just in case a diary() command is left over, with the same file..
    if exist(diaryfile)
        delete(diaryfile);
    end
    diary(diaryfile);
end

switch lower(type)
    case 'tv' 
        n = length(image.I);
        x = reshape(image.I, n*n, 1);

        % y = x;
        matrix = gen_matrix(length(x), M, matrix_type);
        y = recovery('tv', x, matrix, recovery_sparsity);

        y = y - min(y);  % TV norm addition-invariant, "normalize" the image

        J = reshape(y, n, n); 

    otherwise
        matrix = gen_matrix(length(image.Wc), M, matrix_type);
        WcOut = recovery(type, image.Wc', matrix, recovery_sparsity);

        J = waverec2(WcOut, image.Wl, image.wavelet);
end

if save_output
    diary off;
    imwrite(J, imagefile, 'jpg');
    save(savefile, 'description', 'image', 'J', 'WcOut');
end
