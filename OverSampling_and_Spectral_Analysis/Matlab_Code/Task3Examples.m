clear all 
close all
Fs = 8;


M = 4;

[ k, Es, Esnorm, Eb, Ebnorm, SymbolArray ] = GetSymbolArrayData( M );
numBits = k*(2^8);
% TxSymbol= (rand(numBits,1)<0.5)*2-1;
Txbits = double(rand(1,numBits) > 0.5);
[ TxSymbolIdx, TrCHFrameSize ] = SymbolIndex( Txbits, k );
[ TxSymbol ] = SymbolArray(TxSymbolIdx);
numSymbols = length(TxSymbol);
n = numSymbols;
t = 0:n-1;
freq_res = Fs/n;
f = freq_res*(0:n-1);
% Bandwidth = f(end);

txUpSample = zeros(Fs*numSymbols,1);
txUpSample(1:Fs:end) = TxSymbol;

N = length(txUpSample);
T = (0:N-1)/Fs;
freq_resUp = Fs/N;
F = freq_resUp*(0:N-1);
% BandwidthUpSample = F(end);

figure
subplot(2,1,1); plot(t,real(TxSymbol))
axis([0 20 -1 1])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain Transmitted Bits');

subplot(2,1,2); plot(T,real(txUpSample))
axis([0 20 -1 1])
xlabel('Time');
ylabel('Amplitude');
title(['Time Domain Over Sampled Fs = ',num2str(Fs)]);
pause

figure
subplot(2,1,1); plot(f,10*log10(abs(fftshift(fft(TxSymbol)))))
% axis([0 20 -1 1])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Transmitted Bits');

subplot(2,1,2); plot(F,10*log10(abs(fft(txUpSample))))
% axis([0 20 -1 1])
xlabel('Frequency');
ylabel('dB');
title(['Frequency Domain Over Sampled Fs = ',num2str(Fs)]);
pause

FilterRec = ones(1,Fs);
FilterRecOutput = conv(FilterRec,txUpSample);
t= T;
f= F;

N = length(FilterRecOutput);
T = (0:N-1)/Fs;
freq_resUp = Fs/N;
F = freq_resUp*(0:N-1);

figure
subplot(2,1,1); plot(t,real(txUpSample))
axis([0 20 -1 1])
xlabel('Time');
ylabel('Amplitude');
title(['Time Domain Over Sampled Fs = ',num2str(Fs)]);

subplot(2,1,2); plot(T,real(FilterRecOutput))
axis([0 20 -1 1])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain Rectangular Filter');
pause

figure
txUpSampledB =10*log10(abs(fft(txUpSample)));
subplot(2,1,1); plot(f,txUpSampledB)
% axis([0 f(end)/2 min(txUpSampledB) max(txUpSampledB)])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Transmitted Bits');

FilterRecOutputdB = 10*log10(abs(fft(FilterRecOutput)));
subplot(2,1,2); plot(F,FilterRecOutputdB)
Ftmp = F;
% axis([0 20 -1 1])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Rectangular Filter');
pause

% PSD
% ---
NfftArray = [2^7 2^8 2^9 2^10];

for j = 1:2
    if j ==1
        x = txUpSample;
        xTitle = 'Over Sampled Singal   ';
    elseif j ==2
        x = FilterRecOutput;
        xTitle = 'Rectangular Filtered Singal   ';
    end
    for i = 1:length(NfftArray)
        Nfft = NfftArray(i);
        [ win ] = Hanning( Nfft );
        [Pxx,F] = pwelch(x,win,[],Nfft,Fs);

        figure
        subplot(2,1,1); plot(win)
        axis([0 length(win) 0 1])
        title([xTitle,'Hanning Window']);
        if j == 1
            tempPlot = txUpSampledB;
            tempF = f;
        elseif j == 2
            tempPlot = FilterRecOutputdB;
            tempF = Ftmp;
        end
        subplot(2,1,2); plot(F,10*log10(fftshift(Pxx)),'r')
        hold on
        plot(tempF,tempPlot)
        hold off
        title([xTitle,'PSD Estimate Fs = ', num2str(Fs),'  Overlap percentage = 50%','  NFFT = ',num2str(Nfft)]);
        xlabel('Frequency');
        ylabel('dB');
        pause
    end
end

Filter = ...
    [   
   -0.0000
   -0.0003
   -0.0007
   -0.0010
   -0.0013
   -0.0015
   -0.0014
   -0.0009
    0.0000
    0.0013
    0.0029
    0.0045
    0.0058
    0.0063
    0.0056
    0.0036
   -0.0000
   -0.0048
   -0.0101
   -0.0153
   -0.0190
   -0.0203
   -0.0180
   -0.0113
    0.0000
    0.0156
    0.0347
    0.0558
    0.0770
    0.0963
    0.1118
    0.1218
    0.1253
    0.1218
    0.1118
    0.0963
    0.0770
    0.0558
    0.0347
    0.0156
    0.0000
   -0.0113
   -0.0180
   -0.0203
   -0.0190
   -0.0153
   -0.0101
   -0.0048
   -0.0000
    0.0036
    0.0056
    0.0063
    0.0058
    0.0045
    0.0029
    0.0013
    0.0000
   -0.0009
   -0.0014
   -0.0015
   -0.0013
   -0.0010
   -0.0007
   -0.0003
   -0.0000
];
FAnalogue = ...
    [    
    0.0008
    0.0005
   -0.0000
   -0.0006
   -0.0012
   -0.0015
   -0.0011
    0.0000
    0.0017
    0.0033
    0.0039
    0.0029
   -0.0000
   -0.0040
   -0.0076
   -0.0088
   -0.0063
    0.0000
    0.0084
    0.0157
    0.0181
    0.0129
   -0.0000
   -0.0173
   -0.0327
   -0.0387
   -0.0288
    0.0000
    0.0451
    0.0989
    0.1500
    0.1867
    0.2000
    0.1867
    0.1500
    0.0989
    0.0451
    0.0000
   -0.0288
   -0.0387
   -0.0327
   -0.0173
   -0.0000
    0.0129
    0.0181
    0.0157
    0.0084
    0.0000
   -0.0063
   -0.0088
   -0.0076
   -0.0040
   -0.0000
    0.0029
    0.0039
    0.0033
    0.0017
    0.0000
   -0.0011
   -0.0015
   -0.0012
   -0.0006
   -0.0000
    0.0005
    0.0008
];

figure
subplot(3,1,1); plot(FilterRec)
title('Rect Filter');

subplot(3,1,2); plot(FAnalogue)
title('Analogue Filter');

subplot(3,1,3); plot(Filter)
title('Filter');
pause

%-----------------------------------------------------------
FilterOutput_Up_Analogue = conv(FAnalogue,txUpSample);
FilterOutput_Rect_Analogue = conv(FAnalogue,FilterRecOutput);
%-----------------------------------------------------------

n = length(FilterOutput_Up_Analogue);
t = (0:n-1)/Fs;
freq_res = Fs/n;
f = freq_res*(0:n-1);

N = length(FilterOutput_Rect_Analogue);
T = (0:N-1)/Fs;
freq_resUp = Fs/N;
F = freq_resUp*(0:N-1);

figure
subplot(2,1,1); plot(t,real(FilterOutput_Up_Analogue))
axis([0 20 min(real(FilterOutput_Up_Analogue)) max(real(FilterOutput_Up_Analogue))])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain Analogue Filtered Zero Padded Signal');

subplot(2,1,2); plot(T,real(FilterOutput_Rect_Analogue))
axis([0 20 min(real(FilterOutput_Rect_Analogue)) max(real(FilterOutput_Rect_Analogue))])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain Analogue Filter + Rect Filtered Signal(Pulse Shaping)');
pause

figure
FilterOutput_Up_AnaloguedB = 10*log10(abs(fft(FilterOutput_Up_Analogue)));
subplot(2,1,1); plot(f,FilterOutput_Up_AnaloguedB)
axis([0 f(end)/2 min(FilterOutput_Up_AnaloguedB) max(FilterOutput_Up_AnaloguedB)])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Analogue Filtered Zero Padded Signal');

FilterOutput_Rect_AnaloguedB = 10*log10(abs(fft(FilterOutput_Rect_Analogue)));
subplot(2,1,2); plot(F,FilterOutput_Rect_AnaloguedB)
axis([0 F(end)/2 min(FilterOutput_Rect_AnaloguedB) max(FilterOutput_Rect_AnaloguedB)])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Analogue Filter + Rect Filtered Signal(Pulse Shaping)');
pause

val = 65;

[eyeDZeroPad] = eyeDiagram( val , FilterOutput_Up_Analogue );
[eyeDRect] = eyeDiagram( val , FilterOutput_Rect_Analogue );

figure
subplot(2,1,1); plot(eyeDZeroPad,'b')
title('Eye Diagram Zero Padded');
subplot(2,1,2); plot(eyeDRect,'b')
title('Eye Diagram Rect Filtered Signal');
pause

% ------------------------------------------
FilterOutput = conv(Filter,txUpSample);
FilterOutput2 = conv(FAnalogue,FilterOutput);
%-------------------------------------------

n = length(FilterOutput);
t = (0:n-1)/Fs;
freq_res = Fs/n;
f = freq_res*(0:n-1);
Bandwidth = f(end);

N = length(FilterOutput2);
T = (0:N-1)/Fs;
freq_resUp = Fs/N;
F = freq_resUp*(0:N-1);
BandwidthUpSample = F(end);

figure
subplot(2,1,1); plot(t,real(FilterOutput))
axis([0 20 min(real(FilterOutput)) max(real(FilterOutput))])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain Filtered Output(pulse Shaping)');

subplot(2,1,2); plot(T,real(FilterOutput2))
axis([0 20 min(real(FilterOutput2)) max(real(FilterOutput2))])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain Filtered Output(Pulse Shaping) + Analogue Filter');
pause

figure
FilterOutputdB = 10*log10(abs(fft(FilterOutput)));
subplot(2,1,1); plot(f,FilterOutputdB)
axis([0 f(end)/2 min(FilterOutputdB) max(FilterOutputdB)])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Filtered Output');

FilterOutput2dB = 10*log10(abs(fft(FilterOutput2)));
subplot(2,1,2); plot(F,FilterOutput2dB)
axis([0 F(end)/2 min(FilterOutput2dB) max(FilterOutput2dB)])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Filtered Output + Analogue Filter');
pause

[eyeDFilterOutput] = eyeDiagram( val , FilterOutput );
[eyeDFilterOutput2] = eyeDiagram( val , FilterOutput2 );

figure
subplot(2,1,1); plot(eyeDFilterOutput,'b')
title('Eye Diagram Zero Padded');
subplot(2,1,2); plot(eyeDFilterOutput2,'b')
title('Eye Diagram Rect Filtered Signal');
pause

[ FilterRRC ] = RootRaiseCosine( 0.22, Fs );
FilterOutputRRC = conv(FilterRRC,txUpSample);

N = length(FilterOutputRRC);
T = (0:N-1)/Fs;
freq_resUp = Fs/N;
F = freq_resUp*(0:N-1);

figure
subplot(2,1,1); plot(T,real(FilterOutputRRC))
axis([0 20 min(real(FilterOutputRRC)) max(real(FilterOutputRRC))])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain RRC Filtered Signal');
FilterOutputRRCdB = 10*log10(abs(fft(FilterOutputRRC)));
subplot(2,1,2); plot(F,FilterOutputRRCdB)
axis([0 F(end)/4 min(FilterOutputRRCdB) max(FilterOutputRRCdB)])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Filtered Signal');
pause

[eyeDRRC1] = eyeDiagram( val , FilterOutputRRC );
figure; plot(eyeDRRC1,'b')
title('Eye Diagram RRC Filtered Signal');
pause

FilterOutputRRC2 = conv(FilterRRC,FilterOutputRRC);

N = length(FilterOutputRRC2);
T = (0:N-1)/Fs;
freq_resUp = Fs/N;
F = freq_resUp*(0:N-1);

figure
subplot(2,1,1); plot(T,real(FilterOutputRRC2))
axis([0 20 min(real(FilterOutputRRC2)) max(real(FilterOutputRRC2))])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain RRC Filtered Signal');
FilterOutputRRC2dB = 10*log10(abs(fft(FilterOutputRRC2)));
subplot(2,1,2); plot(F,FilterOutputRRC2dB)
axis([0 F(end)/4 min(FilterOutputRRC2dB) max(FilterOutputRRC2dB)])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Filtered Signal');
pause

[eyeDRRC2] = eyeDiagram( 2*val , FilterOutputRRC2 );
figure; plot(eyeDRRC2,'b')
title('Eye Diagram RRC Filtered Signal');
%%
clear all 
close all
Fs = 8;


M = 4;

[ k, Es, Esnorm, Eb, Ebnorm, SymbolArray ] = GetSymbolArrayData( M );
numBits = k*(2^8);

Txbits = double(rand(1,numBits) > 0.5);
[ TxSymbolIdx, TrCHFrameSize ] = SymbolIndex( Txbits, k );
[ TxSymbol ] = SymbolArray(TxSymbolIdx);
numSymbols = length(TxSymbol);
n = numSymbols;
t = 0:n-1;
freq_res = Fs/n;
f = freq_res*(0:n-1);
% Bandwidth = f(end);

txUpSample = zeros(Fs*numSymbols,1);
txUpSample(1:Fs:end) = TxSymbol;

N = length(txUpSample);
T = (0:N-1)/Fs;
freq_resUp = Fs/N;
F = freq_resUp*(0:N-1);
% BandwidthUpSample = F(end);

figure
subplot(2,1,1); plot(t,real(TxSymbol))
axis([0 20 -1 1])
xlabel('Time');
ylabel('Amplitude');
title('Time Domain Transmitted Bits');

subplot(2,1,2); plot(T,real(txUpSample))
axis([0 20 -1 1])
xlabel('Time');
ylabel('Amplitude');
title(['Time Domain Over Sampled Fs = ',num2str(Fs)]);
pause

figure
subplot(2,1,1); plot(f,10*log10(abs(fft(TxSymbol))))
% axis([0 20 -1 1])
xlabel('Frequency');
ylabel('dB');
title('Frequency Domain Transmitted Bits');

subplot(2,1,2); plot(F,10*log10(abs(fft(txUpSample))))
% axis([0 20 -1 1])
xlabel('Frequency');
ylabel('dB');
title(['Frequency Domain Over Sampled Fs = ',num2str(Fs)]);
pause
