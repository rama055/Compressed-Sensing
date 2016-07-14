% [x1 time_secs] = recovery(type, x, matrix, recovery_sparsity)
%
%   Performs a recovery experiment.
%
%     type is the method of the recovery. Can be 'lp', 'tv', 'lp_positive',
%     'gpsr', 'countmin', 'countmin_positive', 'smp' or 'smp(<it>)' or
%     'smp(<it>,<lfactor>)' or 'smp(<it>,<lfactor>,<convergence_factor>). See
%     the code below for details.
%     
%     x is the signal
%
%     matrix is the measurement matrix (should be generated with gen_matrix.m)
%
%     recovery_sparsity is only used for some algorithms; it is necessary for
%                       SMP and optional for countmin variants.
%
%   Returns the recovered vector x1, and the recovery cpu time in seconds.
%
% Written by Radu Berinde, MIT, Jan. 2008

function [x1 time_secs] = recovery(type, x, matrix, recovery_sparsity)
init

if nargin < 4
    recovery_sparsity = -1;
else
    K = recovery_sparsity;
end

[type, type_remainder] = strtok(type, '(');

parameters = [];
if length(type_remainder) > 0
    if type_remainder(1) ~= '(' || type_remainder(length(type_remainder)) ~= ')'
        error('Invalid type string');
    end
    parameters_string = type_remainder(2:(length(type_remainder)-1));
    while true
        [str, parameters_string] = strtok(parameters_string, ',');
        if isempty(str)
            break;
        end
        param = sscanf(str, '%f');
        if length(param) == 0
            param = 1;
        end
        c = str(length(str));
        if c == 'N' || c == 'n'
            param = param * N;
        end

        if c == 'M' || c == 'm'
            param = param * M;
        end

        if c == 'K' || c == 'k'
            param = param * K;
        end
        parameters = [ parameters param ];
    end
end

disp(['Parameters: ', num2str(parameters)]);


N = length(x);

% measure vector
b = matrix.Afun(x);

cputimebefore = cputime;

if strcmp(lower(type), 'lp') || strcmp(lower(type), 'tv')
    % generate starting solution
    disp('Computing initial solution...');
    % solve A * A' * sol = b
    cgfun = @(z) matrix.Afun(matrix.Atfun(z));
    sol = cgsolve(cgfun, b, 1e-10, 200, 10);
    % A' * sol is a solution to A * x = b
    x0 = matrix.Atfun(sol);
    disp([ 'Done. Sanity check - Linf norm (A*x0 - b): ' num2str(norm(matrix.Afun(x0) - b, inf))]);
end


switch lower(type)
    case 'lp'
        %x1 = l1eq_pd(x0, matrix.Afun, matrix.Atfun, b, 1e-4, 75, 1e-9, 500);% , EPS, 50, 1e-8, 300);
        x1 = l1eq_pd(x0, matrix.Afun, matrix.Atfun, b);% , EPS, 50, 1e-8, 300);

    case 'lp_positive'
        x1 = linprog(ones(1, N), [], [], matrix.A, b, zeros(1, N), Inf * ones(1, N), [], optimset('Display', 'iter', 'MaxIter', 100));
%        x1 = l1eq_pd(x0, matrix.Afun, matrix.Atfun, b);% , EPS, 50, 1e-8, 300);

    case 'gpsr'
        x1 = GPSR_BB(b, matrix.Afun, 0.001 * norm(matrix.Atfun(b), inf), 'AT', matrix.Atfun, 'MaxiterA', 300, 'Continuation', 1);

    case 'tv' 
        %  In the case of 'tv', x should be the result of reshape(I, n*n, 1), where I
        %  is an nxn image.
        x1 = tveq_logbarrier(x0, matrix.Afun, matrix.Atfun, b); %, 1e-3, 10, EPS, 100);

    case 'countmin'
        x1 = matrix.MedianRecoveryFun(b);
        if (recovery_sparsity > 0)
            x1 = sparsify(x1, recovery_sparsity);
        end

    case 'countmin_positive'
        x1 = recover_countmin_positive(matrix, b);
        if (recovery_sparsity > 0)
            x1 = sparsify(x1, recovery_sparsity);
        end

    case 'smp'
        % Name should be either smp or smp(it) or smp(it,lfactor)
        %   it       is the number of iterations (default is 10)
        %   lfactor  determines l; smp parameter l is equal to recovery_sparsity * lfactor.
        %            (lfactor is optional and defaults to 1)
        if (length(parameters) > 0)
            num_iterations = parameters(1);
        else
            num_iterations = 10;
        end
        if (recovery_sparsity < 0)
            error('SMP requires a recovery_sparsity argument');
        end
        l = recovery_sparsity;
        if (length(parameters) > 1)
            l = l * parameters(2);
        end
        if (length(parameters) > 2)
            convergence_factor = parameters(3);
        else
            convergence_factor = 0;
        end
        x1 = smp(matrix, b, l, num_iterations, convergence_factor);

   case 'ssmp'
        num_inner_iterations = parameters(1);
        num_outer_iterations = parameters(2);
        if recovery_sparsity < 0 && length(parameters) <= 1
            error('SSMP requires a recovery_sparsity argument or parameter');
        end
        if (length(parameters) > 2)
            l = parameters(3);
        else
            l = recovery_sparsity;
        end
        x1 = smp_queue(matrix.N, matrix.M, matrix.D, matrix.neighbors, b, ...
                       num_inner_iterations, num_outer_iterations, l);

    otherwise
        error(['Unknown recovery type ' type '.']);
end

% recover the vector

time_secs = cputime - cputimebefore;
disp([ upper(type) ' decoding took CPU time: ' num2str(time_secs) ' seconds' ]);
disp([ 'Recovery done. M = ' num2str(matrix.M) ', Matrix type = ' matrix.type ]);
disp([ type '/' matrix.type ' L1 error: ' num2str(norm(x1-x, 1)) ]);
disp([ type '/' matrix.type ' L2 error: ' num2str(norm(x1-x, 2)) ]);
disp([ type '/' matrix.type ' Linf error: ' num2str(norm(x1-x, inf)) ]);

