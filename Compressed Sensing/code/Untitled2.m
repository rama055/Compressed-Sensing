[y,fs]=wavread('failure');

k=0;
for i=1:length(y)
 if(y(i)==0)
     continue;
 else
     k=k+1;
 end
end
disp(length(y))
k