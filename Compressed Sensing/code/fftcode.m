propertyeditor('on');
[wave,fs]=wavread('E:\project\code\failure');
sound(wave,fs);

t=0:1/fs:(length(wave)-1)/fs;
figure(1);
plot(t,wave);
title('Wave File');
ylabel('Amplitude');
xlabel('Length (in seconds)');

n=length(wave)-1;
f=0:fs/n:fs;
wavefft=abs(fft(wave));
save('E:\matlab\fftval.mat','wavefft','-ascii','-double','-tabs') 
figure(2);
plot(f,wavefft);
xlabel('Frequency in Hz');
ylabel('Magnitude');
title('The Wave FFT');
 