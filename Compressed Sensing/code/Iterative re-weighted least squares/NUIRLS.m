
% NUIRLS Non-negative Under-determined Iteratively Reweighted Least
% Squares. Recover Non-negative minimum sparse Lp-norm, 0<=p<=1, solutions using
% Under-determined Iterative Reweighted Least Squares (UIRLS) in an
% Non-negative Matrix Factorisation framework.
%
%  [X,objhistory,SNR] = NUIRLS(Y,PHI,p,NMFIter,IRLSIter,SHOWFLAG)
%
%  OUTPUTS
%  X : Non-negative RxT matrix
%  objhistory : Objective function at each iteration
%  SNR : Reconstruction Signal-to-Noise Ratio
%
%  INPUTS
%  Y : Compressively-sampled Non-negative MxT matrix Y=PHI*X
%  PHI : Non-negative MxN Sensing/Sampling Matrix
%  p : p-norm  0<=p<=1 or p =2
%  NMFIter :  No of iterations for NMF
%  IRLSIter :  No of iterations for IRLS
%			-For each NMFIter there are IRLSIter iterations
%  SHOWFLAG : Display convergence plot to screen
% 
%
% Paul D. O'Grady  14-January-2008
% Complex and Adaptive Systems Laboratory, University College Dublin, Ireland.
% An Col iste Ollscoile Baile  tha Cliath,  ire.
% (paul.d.ogrady@ucd.ie)


function [X,objhistory,SNR] = NUIRLS(Y,PHI,p,NMFIter,IRLSIter,SHOWFLAG)


% Dimensions
R = size(PHI,2);
T = size(Y,2);

% Check for errors
if (min(Y(:))<0 || min(PHI(:))<0) 
  error('<<<< NUIRLS: Negative values in input!... exiting.>>>>');
elseif (size(PHI,1) >= size(PHI,2))
  error('<<<< NUIRLS: PHI not Under-determined!... exiting.>>>>'); 
elseif (p~=2 &&(p<0 || p>1))
  error('<<<< NUIRLS: p out of range!... exiting.>>>>');  
end


% Seed random number generator using time
randn('state',sum(clock*100));

% Initialise G
G = abs(randn(R,T));


% Initialize displays
if SHOWFLAG,
   figure(1);
   clf;
   drawnow;
end

% Calculate initial objective
objhistory = objective(Y,PHI,G,p);

% Display message
fprintf(['NUIRLS Algorithm: p=' num2str(p) ' NMFIter=' num2str(NMFIter) ' IRLSIter=' num2str(IRLSIter) '\n\n']);

for iter = 1:NMFIter

    % Show progress
    fprintf('[%d]: %.5f \n',iter,objhistory(end)); 
        
  
    % Show stats
    if SHOWFLAG & iter > 1
      figure(1);
      plot(objhistory(2:end));
      title('Objective History');
      xlabel('Iterations');
      axis tight;
      drawnow;
    end

    
    % X update; (Y-PHI*Q*G)
    for col = 1:T
      Q = eye(R);
      for k = 1:IRLSIter
	G(:,col) = G(:,col).*(Q'*PHI'*Y(:,col))./(Q'*PHI'*PHI*Q*G(:,col) + 1e-9);
	q = (G(:,col)).^(1-(p/2));
	Q = diag(q);
      end
      X(:,col) = Q*G(:,col);
    end

    
    % Calculate objective
    obj = objective(Y,PHI,X,p);
    objhistory = [objhistory obj];

      
end
SNR = snr(Y,(PHI*X));
disp(' ');
display(['Reconstruction SNR = ' num2str(SNR)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Note norm may not exactly be p-norm due to approximative nature
% of IRLS
function val = objective(Y,PHI,X,p)
for count  = 1:size(Y,2)
  Yest = Y(:,count)-PHI*X(:,count);
  error(count) = sum(abs(Yest).^p)^(1/p);
end
val = sum(error);

function SNR = snr(Vorig,Vest)
SNR = 20*log10(norm(Vorig,'fro')./norm(Vest-Vorig,'fro'));
  