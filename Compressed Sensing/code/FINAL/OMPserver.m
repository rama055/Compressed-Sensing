clientIp = server(3000,'C:\Users\Chai\t2.txt')
disp('Reconstructing signal! Please wait...')
s=cell(100000,1);
sizS = 100000;
lineCt = 1;
fid = fopen('C:\Users\Chai\t2.txt');
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
%lenf=str2double(s(4));
b=str2double(s(4:(lenb+3))); 
k=str2double(s(lenb+4:(lenb+lenk+3))); 
n=str2double(s(lenb+lenk+4)); 
m=str2double(s(lenb+lenk+5)); 
Fs=str2double(s(lenb+lenk+6));
t=str2double(s((lenb+lenk+7):(lenb+lenk+6+lent))); 
f=str2double(s((lenb+lenk+7+lent):end));
%A=str2double(s((lenb+lenk+8+lent+lenf):end));

A = zeros(m,n);
for i = 1:m
   ek = zeros(1,n);
   ek(k(i)) = 1;
   A(i,:) = idct(ek);
end

%opts=[];
%opts.slowMode=false;
%opts.printEvery=25;

%[x,r,normR,residHist,errHist,f,n,t,Fs]=OMP( A, b, k, [], opts,f,n,t,Fs);
[x,r,normR,residHist, n, t, Fs] = OMP( A, b, k, n, t, Fs );
err=mean((x-f).*(x-f));
fprintf('Mean square error in OMP: %.4f',err);

