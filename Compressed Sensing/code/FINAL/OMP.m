function [x,r,normR,residHist, n, t, Fs] = OMP( A, b, k, n, t, Fs)

% What stopping criteria to use? either a fixed # of iterations,
%   or a desired size of residual:
target_resid    = -Inf;
if iscell(k)
    target_resid = k{1};
    k   = size(b,1); %number of rows specified.
elseif k ~= round(k)
    target_resid = k;
    k   = size(b,1); %no of rows=500
end
% (the residual is always guaranteed to decrease)
if target_resid == 0 
    %if printEvery > 0 && printEvery < Inf
        disp('Warning: target_resid set to 0. This is difficult numerically: changing to 1e-12 instead');
    %end
    target_resid    = 1e-12;
end

    LARGESCALE  = false;
    Af  = @(x) A*x;
    At  = @(x) A'*x;

% -- Intitialize --
% start at x = 0, so r = b - A*x = b

r           = b;
normR       = norm(r);
Ar          = At(r);
N           = size(Ar,1);       % number of atoms=5000
M           = size(r,1);        % size of atoms=500
if k > M
    error('K cannot be larger than the dimension of the atoms');
end
unitVector  = zeros(N,1);
x           = zeros(N,1);

indx_set    = zeros(k,1);
indx_set_sorted = zeros(k,1);
A_T         = zeros(M,k);
A_T_nonorth = zeros(M,k);
residHist   = zeros(k,1);

for kk = 1:k
    
    % -- Step 1: find new index and atom to add
    [dummy,ind_new] = max(abs(Ar));
    % Check if this index is already in
%     if ismember( ind_new, indx_set_sorted(1:kk-1) )
%         disp('Shouldn''t happen... entering debug');
%         keyboard
%     end
    
    
    indx_set(kk) = ind_new;
    indx_set_sorted(1:kk)   = sort( indx_set(1:kk) );
    
        atom_new    = A(:,ind_new);
    
    A_T_nonorth(:,kk)   = atom_new;     % before orthogonalizing and such
    
    
    
    % -- Step 2: update residual
    
        % First, orthogonalize 'atom_new' against all previous atoms
        % We use MGS
        for j = 1:(kk-1)
%             atom_new    = atom_new - (atom_new'*A_T(:,j))*A_T(:,j);
            % Thanks to Noam Wagner for spotting this bug. The above line
            % is wrong when the data is complex. Use this:
            atom_new    = atom_new - (A_T(:,j)'*atom_new)*A_T(:,j);
        end
        % Second, normalize:
        atom_new        = atom_new/norm(atom_new);
        A_T(:,kk)       = atom_new;
        % Third, solve least-squares problem (which is now very easy
        %   since A_T(:,1:kk) is orthogonal )
        x_T     = A_T(:,1:kk)'*b;
        x( indx_set(1:kk) )   = x_T;      % note: indx_set is guaranteed to never shrink
        % Fourth, update residual:
        %     r       = b - Af(x); % wrong!
        r       = b - A_T(:,1:kk)*x_T;
        
        % N.B. This err is unreliable, since this "x" is not the same
        %   (since it relies on A_T, which is the orthogonalized version).
   % end
    
    
    normR   = norm(r);
    
    residHist(kk)   = normR;
    
    if kk < k
        Ar  = At(r); % prepare for next round
    end
    
end


 x_T = A_T_nonorth(:,1:kk)\b;
 x( indx_set(1:kk) )   = x_T;
 
r       = b - A_T_nonorth(1:kk)*x_T;
normR   = norm(r);

sound(dct(x),Fs);

    axf=[0 max(t)/4 -1.2 1.2];
    axd=[0 n/8 -10 10];
    figure(3)
    subplot(2,1,1);
    plot(x)
    axis(axd);
    set(gca,'xtick',0:100:1000);
    title('x = OMP solution ')
    drawnow
    
    subplot(2,1,2);
    plot(t,dct(x))
    axis(axf);
    set(gca,'xtick',0.005:0.005:0.030,'ytick',-1:1,'xticklabel',{'0.005','0.010','0.015','0.020','0.025','0.030'});
    title('dct(x)')
    drawnow

end % end of main function
