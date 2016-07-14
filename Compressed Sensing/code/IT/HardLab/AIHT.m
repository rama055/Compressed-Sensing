function [s, Count, err_mse, iter_time]=AIHT(x,A,m,M,thresh,varargin)
% Accelerated iterative Hard thresholding algorithm that keeps exactly M elements 
% in each iteration. This algorithm includes an additional double
% overrelaxation step that significantly improves convergence speed without
% destroiing any of the theoretical guarantees of the IHT algorithm
% detrived in [1], [2] and [3].
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Usage
%
%   [s, err_mse, iter_time]=AIHT(x,P,m,M,'option_name','option_value')
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Input
%
%   Mandatory:
%               x   Observation vector to be decomposed
%               P   Either:
%                       1) An nxm matrix (n must be dimension of x)
%                       2) A function handle (type "help function_format" 
%                          for more information)
%                          Also requires specification of P_trans option.
%                       3) An object handle (type "help object_format" for 
%                          more information)
%               m   length of s 
%               M   non-zero elements to keep in each iteration
%
%   Possible additional options:
%   (specify as many as you want using 'option_name','option_value' pairs)
%   See below for explanation of options:
%__________________________________________________________________________
%   option_name    |     available option_values                | default
%--------------------------------------------------------------------------
%   stopTol        | number (see below)                         | 1e-16
%   P_trans        | function_handle (see below)                | 
%   maxIter        | positive integer (see below)               | n^2
%   verbose        | true, false                                | false
%   start_val      | vector of length m                         | zeros
%   step_size      | number                                     | 0 (auto)
%   Acc            | number: 0 = Double Relaxation, 
%                  |    integer n = n Conjugate Gradient steps  | 0                            | 1
%   stopping criteria used : (OldRMS-NewRMS)/RMS(x) < stopTol
%
%   stopTol: Value for stopping criterion.
%
%   P_trans: If P is a function handle, then P_trans has to be specified and 
%            must be a function handle. 
%
%   maxIter: Maximum number of allowed iterations.
%
%   verbose: Logical value to allow algorithm progress to be displayed.
%
%   start_val: Allows algorithms to start from partial solution.
%
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Outputs
%
%    s              Solution vector 
%    err_mse        Vector containing mse of approximation error for each 
%                   iteration
%    iter_time      Vector containing computation times for each iteration
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Description
%
%   Implements the M-sparse algorithm described in [1], [2] and [3].
%   This algorithm takes a gradient step and then thresholds to only retain
%   M non-zero elements. It allows the step-size to be calculated
%   automatically as described in [3] and is therefore now independent from 
%   a rescaling of P.
%   
%   
% References
%   [1]  T. Blumensath and M.E. Davies, "Iterative Thresholding for Sparse 
%        Approximations", submitted, 2007
%   [2]  T. Blumensath and M. Davies; "Iterative Hard Thresholding for 
%        Compressed Sensing" to appear Applied and Computational Harmonic 
%        Analysis 
%   [3]  T. Blumensath and M. Davies; "A modified Iterative Hard 
%        Thresholding algorithm with guaranteed performance and stability" 
%        in preparation (title may change) 
% See Also
%   hard_l0_reg
%
% Copyright (c) 2007 Thomas Blumensath
%
% The University of Edinburgh
% Email: thomas.blumensath@ed.ac.uk
% Comments and bug reports welcome
%
% This file is part of sparsity Version 0.4
% Created: April 2007
% Modified January 2009
%
% Part of this toolbox was developed with the support of EPSRC Grant
% D000246/1
%
% Please read COPYRIGHT.m for terms and conditions.


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    Default values and initialisation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



[n1 n2]=size(x);
if n2 == 1
    n=n1;
elseif n1 == 1
    x=x';
    n=n2;
else
   error('x must be a vector.');
end
    
sigsize     = x'*x/n;
oldERR      = sigsize;
err_mse     = [];
iter_time   = [];
STOPTOL     = 1e-16;
MAXITER     = n^2;
verbose     = false;
initial_given=0;
s_initial   = zeros(m,1);
MU          = 0;
acceleration= 0;

%ADDED by Kun Qiu
% thresh=1e-10;
Count=0;

if verbose
   display('Initialising...') 
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                           Output variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

switch nargout 
    case 3
        comp_err=true;
        comp_time=true;
    case 2 
        comp_err=true;
        comp_time=false;
    case 1
        comp_err=false;
        comp_time=false;
    case 0
        error('Please assign output variable.')        
    otherwise
        error('Too many output arguments specified')
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                       Look through options
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Put option into nice format
Options={};
% OS=nargin-4;
OS=nargin-5;
c=1;
for i=1:OS
    if isa(varargin{i},'cell')
        CellSize=length(varargin{i});
        ThisCell=varargin{i};
        for j=1:CellSize
            Options{c}=ThisCell{j};
            c=c+1;
        end
    else
        Options{c}=varargin{i};
        c=c+1;
    end
end
OS=length(Options);
if rem(OS,2)
   error('Something is wrong with argument name and argument value pairs.') 
end
for i=1:2:OS
   switch Options{i}
        case {'stopTol'}
            if isa(Options{i+1},'numeric') ; STOPTOL     = Options{i+1};   
            else error('stopTol must be number. Exiting.'); end
        case {'P_trans'} 
            if isa(Options{i+1},'function_handle'); Pt = Options{i+1};   
            else error('P_trans must be function _handle. Exiting.'); end
        case {'maxIter'}
            if isa(Options{i+1},'numeric'); MAXITER     = Options{i+1};             
            else error('maxIter must be a number. Exiting.'); end
        case {'verbose'}
            if isa(Options{i+1},'logical'); verbose     = Options{i+1};   
            else error('verbose must be a logical. Exiting.'); end 
        case {'start_val'}
            if isa(Options{i+1},'numeric') && length(Options{i+1}) == m ;
                s_initial     = Options{i+1};  
                initial_given=1;
            else error('start_val must be a vector of length m. Exiting.'); end
        case {'step_size'}
            if isa(Options{i+1},'numeric') && (Options{i+1}) >= 0 ;
                MU     = Options{i+1};   
            else error('Stepsize must be between a positive number. Exiting.'); end
       case {'Acc'} 
           if rem(Options{i+1},1)==0 
                acceleration     = Options{i+1};
                CGSteps          = Options{i+1};
           else
               error('Acc must be 1 or 2.') 
           end
       otherwise
            error('Unrecognised option. Exiting.') 
   end
end

if nargout >=3
    err_mse = zeros(MAXITER,1);
end
if nargout ==4
    iter_time = zeros(MAXITER,1);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Make P and Pt functions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if          isa(A,'float')      P =@(z) A*z;  Pt =@(z) A'*z;
elseif      isobject(A)         P =@(z) A*z;  Pt =@(z) A'*z;
elseif      isa(A,'function_handle') 
    try
        if          isa(Pt,'function_handle'); P=A;
        else        error('If P is a function handle, Pt also needs to be a function handle. Exiting.'); end
    catch error('If P is a function handle, Pt needs to be specified. Exiting.'); end
else        error('P is of unsupported type. Use matrix, function_handle or object. Exiting.'); end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Do we start from zero or not?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



if initial_given ==1;
    
    if length(find(s_initial)) > M
        display('Initial vector has more than M non-zero elements. Keeping only M largest.')
    
    end
    s                   =   s_initial;
    [ssort sortind]     =   sort(abs(s),'descend');
    s(sortind(M+1:end)) =   0;
    Ps                  =   P(s);
    Residual            =   x-Ps;
    oldERR      = Residual'*Residual/n;
else
    s_initial   = zeros(m,1);
    Residual    = x;
    s           = s_initial;
    Ps          = zeros(n,1);
    oldERR      = sigsize;
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                 Random Check to see if dictionary norm is below 1 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        
        x_test=randn(m,1);
        x_test=x_test/norm(x_test);
        nP=norm(P(x_test));
        if abs(MU*nP)>1;
            display('WARNING! Algorithm likely to become unstable.')
            display('Use smaller step-size or || P ||_2 < 1.')
        end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Main algorithm
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if verbose
   display('Main iterations...') 
end
tic
t=0;
done = 0;
iter=1;
min_mu = 100000;
max_mu = 0;
%O = [];

while ~done
    Count=Count+1;
       
    if MU == 0

        %Calculate optimal step size and do line search
        if Count >1 && acceleration ==0 
            s_very_old      =   s_old;
        end
        s_old               =   s;
        
        IND                 =   s~=0;
        d                   =   Pt(Residual);
        % If the current vector is zero, we take the largest elements in d
        if sum(IND)==0
            [dsort sortdind]    =   sort(abs(d),'descend');
            IND(sortdind(1:M))  =   1;    
         end  

        id                  =   (IND.*d);
        Pd                  =   P(id);
        mu                  =   id'*id/(Pd'*Pd);
        max_mu              =   max([mu max_mu]);
        min_mu              =   min([mu min_mu]);
        mu                  =   min_mu;
        s                   =   s_old + mu * d;
        [ssort sortind]     =   sort(abs(s),'descend');
        s(sortind(M+1:end)) =   0;
        if Count>1 && acceleration ==0 
            very_old_Ps     =   old_Ps;
        end
        old_Ps              =   Ps;
        Ps                  =   P(s);
        Residual            =   x-Ps;
        
        
       
        if Count>2 && acceleration ==0 
            % 1st over-relaxation
            Dif                 = (Ps-old_Ps);
            a1                  = Dif'*Residual/ (Dif'*Dif);
            z1                  = s + a1 * (s-s_old);
            Pz1                 = (1+a1)*Ps-a1*old_Ps;
            Residual_z1         = x-Pz1;

            % 2nd over-relaxation
            Dif                 = (Pz1-very_old_Ps);
            a2                  = Dif'*Residual_z1 / (Dif'*Dif);
            z2                  = z1 + a2 * (z1-s_very_old);

            % Threshold z2
            [z2sort sortind]     =   sort(abs(z2),'descend');
            z2(sortind(M+1:end)) =   0;
            Pz2                 = P(z2);
            Residual_z2         = x-Pz2;

            % Decide if z2 is any good 

 
            if (Residual_z2'*Residual_z2)/(Residual'*Residual)<1
                s = z2;
                Residual = Residual_z2;
                Ps = Pz2;
            end
    
        end
        
        if acceleration >0
               [s Residual] =MySubsetCG(x,s,P,Pt,find(s~=0),1e-9,0,CGSteps); 
               Ps           = P(s);
        end
        
        % Calculate step-size requirement 
        omega               =   (norm(s-s_old)/norm(Ps-old_Ps))^2;
        %O                   =   [O omega];

        % As long as the support changes and mu > omega, we decrease mu
        while mu >= 1.5*omega && sum(xor(IND,s~=0))~=0 && sum(IND)~=0
             display(['decreasing mu'])
             
              % We use a simple line search, halving mu in each step
                mu                  =   mu/2;
                s                   =   s_old + mu * d;
                [ssort sortind]     =   sort(abs(s),'descend');
                s(sortind(M+1:end)) =   0;
                Ps                  =   P(s);
                  %Calculate optimal step size and do line search
                Residual            =   x-Ps;
                if Count>2 && acceleration ==0 
                    % 1st over-relaxation
                    Dif                 = (Ps-old_Ps);
                    a1                  = Dif'*Residual/ (Dif'*Dif);
                    z1                  = s + a1 * (s-s_old);
                    Pz1                 = (1+a1)*Ps-a1*old_Ps;
                    Residual_z1         = x-Pz1;

                    % 2nd over-relaxation
                    Dif                 = (Pz1-very_old_Ps);
                    a2                  = Dif'*Residual_z1 / (Dif'*Dif);
                    z2                  = z1 + a2 * (z1-s_very_old);

                    % Threshold z2
                    [z2sort sortind]     =   sort(abs(z2),'descend');
                    z2(sortind(M+1:end)) =   0;
                    Pz2                 = P(z2);
                    Residual_z2         = x-Pz2;

                    % Decide if z2 is any good 


                    if (Residual_z2'*Residual_z2)/(Residual'*Residual)<1
                        s = z2;
                        Residual = Residual_z2;
                        Ps = Pz2;
                    end

                end
                
                if acceleration >0
                    [s Residual] = MySubsetCG(x,s,P,Pt,find(s~=0),1e-9,0,CGSteps);  
                    Ps           = P(s);
                   
                end
                    
             
                    % Calculate step-size requirement 
                    omega               =   (norm(s-s_old)/norm(Ps-old_Ps))^2;
        end
        
        
        
        
    else %Mu ~=0;
        % Use fixed step size

        if Count >1 && acceleration ==0 
            s_very_old      =   s_old;
        end
        s_old               =   s;
        s                   =   s + MU * Pt(Residual);
        [ssort sortind]     =   sort(abs(s),'descend');
        s(sortind(M+1:end)) =   0;
        if Count>1 && acceleration ==0 
            very_old_Ps         =   old_Ps;
        end
        old_Ps              =   Ps;

        Ps                  =   P(s);
        Residual            =   x-Ps;
              
        if Count>2 && acceleration ==0 
            % 1st over-relaxation
            Dif                 = (Ps-old_Ps);
            a1                  = Dif'*Residual/ (Dif'*Dif);
            z1                  = s + a1 * (s-s_old);
            Pz1                 = (1+a1)*Ps-a1*old_Ps;
            Residual_z1         = x-Pz1;

            % 2nd over-relaxation
            Dif                 = (Pz1-very_old_Ps);
            a2                  = Dif'*Residual_z1 / (Dif'*Dif);
            z2                  = z1 + a2 * (z1-s_very_old);

            % Threshold z2
            [z2sort sortind]     =   sort(abs(z2),'descend');
            z2(sortind(M+1:end)) =   0;
            Pz2                 = P(z2);
            Residual_z2         = x-Pz2;

            % Decide if z2 is any good 

 
            if (Residual_z2'*Residual_z2)/(Residual'*Residual)<1
                s = z2;
                Residual = Residual_z2;
                Ps = Pz2;
            end
        end
        
        if acceleration >0
           [s Residual] = MySubsetCG(x,s,P,Pt,find(s~=0),1e-9,0,CGSteps); 
           Ps           = P(s);
        end
     
        
        end

    
        
        
     ERR=Residual'*Residual/n;
     if comp_err
         err_mse(iter)=ERR;
     end
     
     if comp_time
         iter_time(iter)=toc;
     end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                        Are we done yet?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     
%          if comp_err && iter >=2
%              if ((err_mse(iter-1)-err_mse(iter))/sigsize<STOPTOL);
%                  if verbose
%                     display(['Stopping. Approximation error changed less than ' num2str(STOPTOL)])
%                  end
%                 done = 1; 
%              elseif verbose && toc-t>10
%                 display(sprintf('Iteration %i. --- %i mse change',iter ,(err_mse(iter-1)-err_mse(iter))/sigsize)) 
%                 t=toc;
%              end
%          else
%              if ((oldERR - ERR)/sigsize < STOPTOL) && iter >=2;
%                  if verbose
%                     display(['Stopping. Approximation error changed less than ' num2str(STOPTOL)])
%                  end
%                 done = 1; 
%              elseif verbose && toc-t>10
%                 display(sprintf('Iteration %i. --- %i mse change',iter ,(oldERR - ERR)/sigsize)) 
%                 t=toc;
%              end
%          end
%          
%     % Also stop if residual gets too small or maxIter reached
%      if comp_err
%          if err_mse(iter)<1e-16
%              display('Stopping. Exact signal representation found!')
%              done=1;
%          end
%      elseif iter>1 
%          if ERR<1e-16
%              display('Stopping. Exact signal representation found!')
%              done=1;
%          end
%      end
% 
%      if iter >= MAXITER
%          display('Stopping. Maximum number of iterations reached!')
%          done = 1; 
%      end
 
    %Convergence criterion modified by Kun Qiu
    gap=norm(s-s_old)^2/m;
    if gap<thresh 
        done=1;
    end
    
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    If not done, take another round
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
     if verbose
          clc;
          display(['Iteration=',num2str(Count),', gap=',num2str(gap),' (target=',num2str(thresh),')']);
     end
     if ~done
        iter=iter+1; 
        oldERR=ERR;        
     end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Only return as many elements as iterations
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if nargout >=2
    err_mse = err_mse(1:iter);
end
if nargout ==3
    iter_time = iter_time(1:iter);
end
if verbose
   display('Done') 
end

