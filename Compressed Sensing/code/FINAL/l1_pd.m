% l1_pd.m
%
% Solve
% min_x ||x||_1  s.t.  Ax = b
%
% Recast as linear program
% min_{x,u} sum(u)  s.t.  -u <= x <= u,  Ax=b
% and use primal-dual interior point method
%
% Usage: xp = l1_pd(x0, A, b, pdtol, pdmaxiter)
%
% x0 - Nx1 vector, initial point.
%
% A - MxN matrix

% b - Mx1 vector of observations.
%
% pdtol - Tolerance for primal-dual algorithm (algorithm terminates if
%     the duality gap is less than pdtol).  
%     Default = 1e-3.
%
% pdmaxiter - Maximum number of primal-dual iterations.  
%     Default = 50.

function xp = l1_pd(x0, A,  b, pdtol, pdmaxiter)


if (nargin < 5), pdtol = 1e-3;  end
if (nargin < 6), pdmaxiter = 50;  end


N = length(x0);

alpha = 0.01;%step size
beta = 0.5;%backtracking
mu = 10;

gradf0 = [zeros(N,1); ones(N,1)];

x = x0;
u = 1.01*max(abs(x))*ones(N,1) + 1e-2;%lagrange multiplier

fu1 = x - u;
fu2 = -x - u;

%lagrange functions
lamu1 = -1./fu1;
lamu2 = -1./fu2;

  v = -A*(lamu1-lamu2);
  Atv = A'*v;
  rpri = A*x - b;


sdg = -(fu1'*lamu1 + fu2'*lamu2); %sdg - surrogate dual gap
tau = mu*2*N/sdg;

rcent = [-lamu1.*fu1; -lamu2.*fu2] - (1/tau);
rdual = gradf0 + [lamu1-lamu2; -lamu1-lamu2] + [Atv; zeros(N,1)];
resnorm = norm([rdual; rcent; rpri]);

pditer = 0;
done = (sdg < pdtol) | (pditer >= pdmaxiter);
while (~done)
  
  pditer = pditer + 1;
  
  w1 = -1/tau*(-1./fu1 + 1./fu2) - Atv;
  w2 = -1 - 1/tau*(1./fu1 + 1./fu2);
  w3 = -rpri;
  
  sig1 = -lamu1./fu1 - lamu2./fu2;
  sig2 = lamu1./fu1 - lamu2./fu2;
  sigx = sig1 - sig2.^2./sig1;
  
    H11p = -A*diag(1./sigx)*A';
    w1p = w3 - A*(w1./sigx - w2.*sig2./(sigx.*sig1));
    [dv,hcond] = linsolve(H11p,w1p);
    if (hcond < 1e-14)
      disp('Primal-dual: Matrix ill-conditioned.  Returning previous iterate.');
      xp = x;
      return
    end
    dx = (w1 - w2.*sig2./sig1 - A'*dv)./sigx;
    Adx = A*dx;
    Atdv = A'*dv;
 
  
  du = (w2 - sig2.*dx)./sig1;
  
  dlamu1 = (lamu1./fu1).*(-dx+du) - lamu1 - (1/tau)*1./fu1;
  dlamu2 = (lamu2./fu2).*(dx+du) - lamu2 - 1/tau*1./fu2;
  
  % make sure that the step is feasible: keeps lamu1,lamu2 > 0, fu1,fu2 < 0
  indp = find(dlamu1 < 0);  indn = find(dlamu2 < 0);
  s = min([1; -lamu1(indp)./dlamu1(indp); -lamu2(indn)./dlamu2(indn)]);
  indp = find((dx-du) > 0);  indn = find((-dx-du) > 0);
  s = (0.99)*min([s; -fu1(indp)./(dx(indp)-du(indp)); -fu2(indn)./(-dx(indn)-du(indn))]);
  
  % backtracking line search 
  backiter = 0;
  xp = x + s*dx;  up = u + s*du; 
  vp = v + s*dv;  Atvp = Atv + s*Atdv; 
  lamu1p = lamu1 + s*dlamu1;  lamu2p = lamu2 + s*dlamu2;
  fu1p = xp - up;  fu2p = -xp - up;  
  rdp = gradf0 + [lamu1p-lamu2p; -lamu1p-lamu2p] + [Atvp; zeros(N,1)];
  rcp = [-lamu1p.*fu1p; -lamu2p.*fu2p] - (1/tau);
  rpp = rpri + s*Adx;
  while(norm([rdp; rcp; rpp]) > (1-alpha*s)*resnorm)
    s = beta*s;
    xp = x + s*dx;  up = u + s*du; 
    vp = v + s*dv;  Atvp = Atv + s*Atdv; 
    lamu1p = lamu1 + s*dlamu1;  lamu2p = lamu2 + s*dlamu2;
    fu1p = xp - up;  fu2p = -xp - up;  
    rdp = gradf0 + [lamu1p-lamu2p; -lamu1p-lamu2p] + [Atvp; zeros(N,1)];
    rcp = [-lamu1p.*fu1p; -lamu2p.*fu2p] - (1/tau);
    rpp = rpri + s*Adx;
    backiter = backiter+1;
    if (backiter > 32)
      disp('Stuck backtracking, returning last iterate.')
      xp = x;
      return
    end
  end
  
  
  % next iteration
  x = xp;  u = up;
  v = vp;  Atv = Atvp; 
  lamu1 = lamu1p;  lamu2 = lamu2p;
  fu1 = fu1p;  fu2 = fu2p;
  
  % surrogate duality gap
  sdg = -(fu1'*lamu1 + fu2'*lamu2);
  tau = mu*2*N/sdg;
  rpri = rpp;
  rcent = [-lamu1.*fu1; -lamu2.*fu2] - (1/tau);
  rdual = gradf0 + [lamu1-lamu2; -lamu1-lamu2] + [Atv; zeros(N,1)];
  resnorm = norm([rdual; rcent; rpri]);
  
  done = (sdg < pdtol) | (pditer >= pdmaxiter);
  
 end


