%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% iht_fft.m
%
% Implements iterative hard thresholding with FFT basis
%
% Inputs:
% y - CS measurements (Mx1)
% Phi - CS matrix (MxN)
% K - Signal Sparsity
% epsilon - Convergence parameter
% numiter - Max number of iterations
%
% Outputs:
% x - output estimate
%
% Written by Marco F. Duarte, Program in Applied and Computational Mathematics, Princeton Univeristy
% January 2010
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function x = iht_fft(y,Phi,K,epsilon,numiter)

N = size(Phi,2); % Signal length
xf = zeros(N,1); % Signal estimate
x = zeros(N,numiter);

res = y; % residual

iter = 0;
resnorm = 0;
while norm(res) >= norm(y)*epsilon && iter <= numiter,
    xf = xf+fft(Phi'*res)/sqrt(N); % Projection estimate
    [~,idx] = sort(abs(xf),'descend'); % Thresholding
    xf = xf.*(abs(xf) >= abs(xf(idx(K))));
    x(:,iter+1) = ifft(xf(:))*sqrt(N); % Obtain signal estimate
    res = y-Phi*x(:,iter+1); % Update residual
    if resnorm == norm(res)/norm(y),
        break
    else
        resnorm = norm(res)/norm(y);
    end
    iter = iter+1;
end
% Pick best approximation
resnorm = sum(abs(y*ones(1,size(x,2))-Phi*x).^2);
[~,idx] = min(resnorm);
x = x(:,idx);
