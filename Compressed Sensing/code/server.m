
% A = rows of DCT matrix with indices of random sample.

A = zeros(m,n);
for i = 1:m
   ek = zeros(1,n);
   ek(k(i)) = 1;
   A(i,:) = idct(ek);
end

% y = l_2 solution to A*y = b.

y = pinv(A)*b;

% x = l_1 solution to A*x = b.
% Use "L1 magic".

x = l1eq_pd(y,A,A',b,5e-3,32,1,1);%last two args are ignored if %A is a matrix,which it is in this case,hence any arguements may 
%be passed,A' is also ignored when A is a matrix

% Plot x and dct(x).
% Good comparison with f.

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

% Plot y and dct(y).
% Lousy comparison with f.

figure(3)
subplot(2,1,1)
plot(y)
axis(axd);
set(gca,'xtick',0:100:600)
title('y = {\it l}_2 solution, A*y = b ')
subplot(2,1,2)
plot(t,dct(y))
axis(axf);
set(gca,'xtick',.005:.005:.030,'ytick',-1:1, ...
   'xticklabel',{'.005','.010','.015','.020','.025','.030'})
title('dct(y)')



sound(dct(x),Fs);
pause(1)
sound(dct(y),Fs)
