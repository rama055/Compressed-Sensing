clientIp = server(3000,'C:\Users\Chai\t3.txt')
disp('Reconstructing signal! Please wait...')
s=cell(100000,1);
sizS = 100000;
lineCt = 1;
fid = fopen('C:\Users\Chai\t3.txt');
tline = fgetl(fid);
while ischar(tline)
   s{lineCt} = tline;
   lineCt = lineCt + 1;
   %# grow s if necessary
   if lineCt > sizS
       s = [s;cell(100000,1)];
       sizS = sizS + 100000;
   end
   tline = fgetl(fid);
end
%# remove empty entries in s
s(lineCt:end) = [];
lenb=str2double(s(1));
lenk=str2double(s(2));
lent=str2double(s(3));
b=str2double(s(4:(lenb+3)));
k=str2double(s(lenb+4:(lenb+lenk+3)));
n=str2double(s(lenb+lenk+4));
m=str2double(s(lenb+lenk+5));
Fs=str2double(s(lenb+lenk+6));
T=str2double(s(lenb+lenk+7));
tol=str2double(s(lenb+lenk+8));
t=str2double(s((lenb+lenk+9):(lenb+lenk+lent+8)));
f=str2double(s((lenb+lenk+lent+9):end));

% A = rows of DCT matrix with indices of random sample.
A = zeros(m,n);
for i = 1:m
   ek = zeros(1,n);
   ek(k(i)) = 1;
   A(i,:) = idct(ek);
end

x=reconstructAmp(A, b, T, tol, f);
axf=[0 max(t)/4 -1 1];
axd=[0 n/8 -10 10];
figure(2)
subplot(2,1,1)
plot(x)
axis(axd);
set(gca,'xtick',0:100:600)
title('x = AMP solution')
subplot(2,1,2)
plot(t,dct(x))
axis(axf);
set(gca,'xtick',.005:.005:.030,'ytick',-1:1, ...
   'xticklabel',{'.005','.010','.015','.020','.025','.030'})
title('dct(x)')
drawnow

sound(dct(x),Fs);
err=mean((x-f).*(x-f));
fprintf('Mean square error in AMP: %.4f ',err);
