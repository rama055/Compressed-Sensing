% Runs a demo recovery of a sparse signal using a binary sparse matrix (d=8)
%
% Written by Radu Berinde, MIT, Jan. 2008

signal = gen_sparse_signal(10000, 40);

% % Example recovery with l1magic (need to download the package first)
% matrix = gen_matrix(10000, 400, 'countmin8');
% recovered_signal = recovery('lp', signal, matrix, 40);

matrix = gen_matrix(10000, 2000, 'countmin8');
%recovered_signal = recovery('smp', signal, matrix, 40);
recovered_signal = recovery('ssmp(400,10,2k)', signal, matrix, 40);

a = [1 length(signal) -1.2 1.2];
subplot(4, 3, 1), plot(signal), title('Original signal'), axis(a);
subplot(4, 3, 4), plot(recovered_signal), title('Recovered signal'), axis(a);
subplot(4, 3, 7), plot(recovered_signal - signal), title('Difference'), axis(a);


image = load_image('boat', 'db8', 4);



% Use SMP to recover the image. Use convergence control factor 0.3, necessary
% because the number of measurements is too small relative to the sparsity of
% the recovery (the measurement matrix is not an expander with sufficient
% parameters)
J = image_experiment('smp(10,1,0.3)', image, 30000, 'sparse10', 10000);
subplot(4, 3, [2 5 8]);
imshow(J);

% Now use SSMP to recover the image, in the "fast" regime: 10000 inner
% iterations, one outer iteration.
J = image_experiment('ssmp(k,1,k)', image, 30000, 'sparse10', 10000);
subplot(4, 3, [3 6 9]);
imshow(J);
