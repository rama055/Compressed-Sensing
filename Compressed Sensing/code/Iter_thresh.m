Fs = 40000; %sampling frequency
t = (1:Fs/8)'/Fs; %sampling rate
f = (sin(2*pi*697*t) + sin(2*pi*1633*t))/2; %average of frequency components of the two sinusoids
n = length(f); %n=5000
m = ceil(n/10); %m=500
k = randperm(n)';
k = sort(k(1:m));
b = f(k); %random samples


A = zeros(m,n);
for i = 1:m
   ek = zeros(1,n);
   ek(k(i)) = 1;
   A(i,:) = idct(ek);
end

x=pinv(A)*b;
lam=0.04;
[s_est, err_mse, iter_time]=hard_l0_reg(x,A,n,lam);
sound(f,Fs);
pause(2)
sound(s_est,Fs)



        