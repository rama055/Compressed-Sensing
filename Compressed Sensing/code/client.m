
  disp(' 1  2  3');
  disp(' 4  5  6');
  disp(' 7  8  9');
  disp(' *  0  #');
choice=input('please choose a key: ');
switch(choice)
    case 1
        a=697;
        b=1209;
    case 2
        a=697;
        b=1336;
    case 3
        a=697;
        b=1477;
    case 4
        a=770;
        b=1209;
    case 5
        a=770;
        b=1336;
    case 6
        a=770;
        b=1477;
     case 7
        a=852;
        b=1209;
     case 8
        a=852;
        b=1336;
     case 9
        a=852;
        b=1477;
      case '*'
        a=941;
        b=1209; 
      case 0
        a=941;
        b=1336;
      case '#'
        a=941;
        b=1477;
    otherwise
        fprintf('invalid key entered');
end

Fs = 40000; %sampling frequency
t = (1:Fs/8)'/Fs; %sampling rate
f = (sin(2*pi*a*t) + sin(2*pi*b*t))/2; %average of frequency components of the two sinusoids
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

sound(f,Fs)
save('all.mat','b','k','n','m','Fs','-ascii','-double','-tabs')
