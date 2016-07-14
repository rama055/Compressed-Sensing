function x = lmp_re_ls(A,y,group,m,p)

% Solution to the non-convex group sparse optimization problem min||x||_m,p 
% subject to y = Ax
% This algorithm is based upon the Reweighted Least-squares method
% 
% Copyright (c) Angshul Majumdar 2009

% Input
% A = N X d dimensional measurement matrix
% y = N dimensional observation vector
% group = labels
% m = inner norm (default 2)
% p = outer norm (default 1)

% Output
% x = estimated group sparse signal

if nargin < 4
    m = 2; p = 1;
end

if nargin < 5
    p = 1;
end

explicitA = ~(ischar(A) || isa(A, 'function_handle'));
if (explicitA)
    AOp = opMatrix(A);
else
    AOp = A;
end

% Set LSQR parameters
damp   = 0;
atol   = 1.0e-6;
btol   = 1.0e-6;
conlim = 1.0e+10;
itnlim = length(y);
show   = 0;
OptTol = 1e-5;

MaxIter = 500;
epsilon = 1;
NGroup = max(group);
for i = 1:NGroup
    GInd{i} = find(group == i);
end
% u_0 is the L_2 solution which would be exact if m = n,
% but in Compressed expactations are that m is less than n
[u_0,temp] = lsqr(@lsqrAOp,y,OptTol,20);
u_old = u_0; 
j=0;
while (epsilon > 1e-5) && (j < MaxIter)
	j = j + 1;
    for i = 1:NGroup
        tw1(GInd{i}) = norm(u_old(GInd{i})).^(p-m);
    end
	tw2 = abs(u_old).^(m-2);
    w = tw1'.*tw2 + epsilon;
	v = 1./sqrt(w); 
	ROp = opDiag(v); 
	MOp = opFoG(AOp, ROp); 
	[t,temp] = lsqr(@lsqrMOp,y,[],20); 
    u_new = ROp(t,2); 
	if lt(norm(u_new - u_old,2),epsilon^(1/2)/100)
		epsilon = epsilon /10;
	end
	u_old = u_new;
end
x = u_new;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function y = lsqrAOp(x,transpose)
        switch transpose
            case 'transp'
                y = AOp(x,2);
            case 'notransp'
                y = AOp(x,1);
        end
    end
    function y = lsqrMOp(x,transpose)
        switch transpose
            case 'transp'
                y = MOp(x,2);
            case 'notransp'
                y = MOp(x,1);
        end
    end
end