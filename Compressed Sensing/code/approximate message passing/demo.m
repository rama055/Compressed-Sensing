
[f,Fs]=wavread('E:\test');
t = (1:Fs/8)'/Fs; %sampling rate
n = length(f); %n=5000
m = ceil(n/10); %m=500
k = randperm(n)';
k = sort(k(1:m));
b = f(k); %random samples

% Number of iterations
T = 1000;

% Tolerance
tol = 0.001;


A = zeros(m,n);
for i = 1:m
   ek = zeros(1,n);
   ek(k(i)) = 1;
   A(i,:) = idct(ek);
end
x=reconstructAmp(A, b, T, tol, f, 0);
sound(dct(x),Fs)
erramp = mean((x - f).*(x - f));

% Print the result
fprintf(1, 'Mean-Squared Error AMP: %.4f\n', erramp);