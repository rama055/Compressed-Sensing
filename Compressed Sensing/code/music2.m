 Fs=8000;
 Ts=1/Fs;
 t=[0:Ts:0.3];
 F_A = 440; %Frequency of note A is 440 Hz
 F_B = 493.88;
 F_Csharp = 554.37; 
 F_D = 587.33;
 F_E = 659.26;
 F_Fsharp = 739.9;
 notes = [F_A ; F_B; F_Csharp; F_D; F_E; F_Fsharp];
 x = cos(2*pi*notes*t); 
 sig = reshape(x',6*length(t),1);
 soundsc(sig,1/Ts)

