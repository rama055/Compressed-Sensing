[y, fs] = audioread('guitar.wav');
t = (1:fs/8)'/fs; 
n = length(y);
m = ceil(n/1000); 
k = randperm(n)';
k = sort(k(1:m));
b = y(k);
axf = [0 max(t)/4 -1.2 1.2];
axd = [0 n/8 -10 10];
figure(1);
subplot(2,1,1)
%plot(t,y,'b-',t(k),b,'k.')
axis(axf);
set(gca,'xtick',.005:.005:.030,'ytick',-1:1, ...
   'xticklabel',{'.005','.010','.015','.020','.025','.030'})
title('y = signal, b = random sample')
subplot(2,1,2)
plot(idct(y))
axis(axd);
set(gca,'xtick',0:100:600)
title('c = idct(y)')
drawnow
% A = rows of DCT matrix with indices of random sample.

A = zeros(m,n);
for i = 1:m
   ek = zeros(1,n);
   ek(k(i)) = 1;
   A(i,:) = idct(ek);
end


z = pinv(A)*b;


x = l1eq_pd(z,A,A',b,5e-3,32,1,1);
figure(2)
subplot(2,1,1)
plot(x)
axis(axd);
set(gca,'xtick',0:100:600)
title('x = {\it l}_1 solution, A*x = b ')
subplot(2,1,2)
plot(t,dct(x))
axis(axf);
set(gca,'xtick',.005:.005:.030,'ytick',-1:1, ...
   'xticklabel',{'.005','.010','.015','.020','.025','.030'})
title('dct(x)')


figure(3)
subplot(2,1,1)
plot(z)
axis(axd);
set(gca,'xtick',0:100:600)
title('y = {\it l}_2 solution, A*y = b ')
subplot(2,1,2)
plot(t,dct(z))
axis(axf);
set(gca,'xtick',.005:.005:.030,'ytick',-1:1, ...
   'xticklabel',{'.005','.010','.015','.020','.025','.030'})
title('dct(z)')

% Play three sounds.

sound(y,fs)
pause(1)
sound(dct(x),fs)
pause(1)
sound(dct(z),fs)


