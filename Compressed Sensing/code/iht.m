[f,Fs]=wavread('E:\test');
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
C=0;
for i=1:n
    if(f(i)==0)
        continue;
    else
        C=C+1;
    end
end
length(f)
C

