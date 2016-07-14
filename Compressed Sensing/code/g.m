
% "Magic" Reconstruction: Compressed Sensing.

% f = signal = tone from "1" key on touch tone phone.
% b = random subsample.

Fs = 40000; %sampling frequency
t = (1:Fs/8)'/Fs; %sampling rate
f = (sin(2*pi*697*t) + sin(2*pi*1633*t))/2; %average of frequency components of the two sinusoids
n = length(f); %n=5000
m = ceil(n/10); %m=500
k = randperm(n)';
k = sort(k(1:m));
b = f(k); %random samples

% Plot f and b.
% Plot idct(f) = inverse discrete cosine transform.

axf = [0 max(t)/4 -1.2 1.2];
axd = [0 n/8 -10 10];
figure(1);
subplot(2,1,1)
plot(t,f,'b-',t(k),b,'k.')
axis(axf);
set(gca,'xtick',.005:.005:.030,'ytick',-1:1, ...
   'xticklabel',{'.005','.010','.015','.020','.025','.030'})
title('f = signal, b = random sample')
subplot(2,1,2)
plot(idct(f))
axis(axd);
set(gca,'xtick',0:100:600)
title('c = idct(f)')
drawnow

% A = rows of DCT matrix with indices of random sample.

A = zeros(m,n);
for i = 1:m
   ek = zeros(1,n);
   ek(k(i)) = 1;
   A(i,:) = idct(ek);
end

err_func=[];
opts=[];
opts.printEvery     = 25;
opts.slowMode       = true;
x=OMP( A, b,k, err_func, opts );

