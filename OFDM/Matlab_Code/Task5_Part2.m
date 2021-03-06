clear all
close all
% Modulation Scheme
Bandwith = 4.5e6;
deltaF = 15e3;
Nfft = 512;
T = 1/deltaF;
Ts = T/Nfft;
Nsubcarriers = 300; 
TimeSample = (0:Nsubcarriers-1)*Ts;
OverSampleRate = Nfft/Nsubcarriers;
% n = -Nsubcarriers/2:1:Nsubcarriers/2;
% n(n==0) =[];
% k = 0:Nsubcarriers-1;
% Tk = Ts*k;
SubCarrierIndex = [-Nsubcarriers/2:-1 1: Nsubcarriers/2];
fs = Bandwith/(Nsubcarriers-1);
% T =0:fs:Bandwith;
f = 0:fs:Bandwith; 
temp = fs(end);
M = [4];
TransmitTime = 10e-3;
NumberOfOFDMSymbols = TransmitTime/T;
NumberOfFrames = 1;
NumM = length(M);         % Number of M-arys to be tested


ZeroPadding = zeros(1,(Nfft - Nsubcarriers)/2);

% Configure Test
% --------------
EsNo_dB(:,1) = 35;%linspace(35, 0, 10); % Noise density dB
EsNo_lin = 10.^(EsNo_dB / 10);      % Noise density linear   
NumEsNo = length(EsNo_lin);         % Numb of Iterations
EsNo_dBArray = zeros(NumEsNo,NumM);
EbNo_dBArray = zeros(NumEsNo,NumM);

OFDMSymbol = zeros(1,Nfft);
Ncp = 36;
ReferenceSymbol = zeros(1,Nfft);
Ref = ones(1,Nsubcarriers); 
ReferenceSymbol(SubCarrierIndex+Nfft/2+1) = Ref;

powerRef = mean(abs(Ref).^2);
Lref = fftshift(ReferenceSymbol);
ReferenceSymbol = ifft(fftshift(ReferenceSymbol),Nfft)*sqrt(Nfft);

RefPrefix = ReferenceSymbol((Nfft-Ncp)+1:Nfft);
LocalReplica = ReferenceSymbol;
ReferenceSymbol = [ RefPrefix ReferenceSymbol];
% ReferenceSymbol = ReferenceSymbol*sqrt(OverSampleRate)*sqrt(Nfft);
powerReferenceSymbol = mean(abs(ReferenceSymbol).^2);

refPower = abs(sum(ReferenceSymbol))^2;
RefIndex = 1:8:NumberOfOFDMSymbols;
RefNumb = length(RefIndex);
for m = 1:NumM
    [ k, Es, Esnorm, Eb, Ebnorm, SymbolArray ] = GetSymbolArrayData( M(m) );
    for i = 1:NumEsNo
        Frame = [];
        Frame_Aligned = [];
        for numFrame = 1:NumberOfFrames
            count = 1;
            for ii = 1:NumberOfOFDMSymbols
                TxPacket = double(rand(1,Nsubcarriers*k) > 0.5);
                [ TxSymbolIdx, TrCHFrameSize ] = SymbolIndex( TxPacket, k );
                [ TxSymbol ] = SymbolArray(TxSymbolIdx); 
                OFDMSymbol(SubCarrierIndex+Nfft/2+1) = TxSymbol;
                
                powerOFDMSymbol = mean(abs(OFDMSymbol).^2);
                outputIDFT = ifft(fftshift(OFDMSymbol),Nfft)*sqrt(Nfft);
                poweroutputIDFT = mean(abs(outputIDFT).^2);
                CyclicPrefix = outputIDFT((Nfft-Ncp)+1:Nfft);
                outputIDFT_CP = [CyclicPrefix outputIDFT];
                poweroutputIDFT_CP = mean(abs(outputIDFT_CP).^2);
                if ii== RefIndex(count) 
                        outputIDFT_CP = ReferenceSymbol;
                        if count<length(RefIndex)
                            count = count+1;
                        end
                end

                Frame = [Frame outputIDFT_CP];
                NumSymbols = length(Frame);
                
            end
            powerFrame = mean(abs(Frame).^2);
             
            % Channel 
            % ------- 
            ChannelSize = 37;
            Taps = 2;
            x = randn(1, Taps); y = randn(1, Taps); % Random Variables X and Y with Gaussian Distribution mean zero variance one
            rayleighFade =(1 + 1i.*y)/sqrt(2);       % Normalised Ralyiegh random Variable
            Delay = randi(Ncp,1,Taps); % Shifted by Delay OFDM symbol
            h = zeros(1,ChannelSize);
            h(Delay) = rayleighFade; % Delay Unit Power
            NormalisationTerm = 1/sqrt(Taps);
            h = h*NormalisationTerm; % Normalised to unit power
            powerh = sum(abs(h).^2);
            Frame_Channel = Frame;%conv(Frame,h);
            
            figure
            subplot(2,1,1)
            t= (0:ChannelSize-1)*Ts*1e6;
            stem(t,abs(h))
            DeltaT = abs(Delay(1)-Delay(2))*Ts*1e6;
            axis([0 t(end) 0 max(abs(h))]);
            set(gca, 'FontSize',14); 
            title(['Channel Time Domain, Delta T =  ',num2str(DeltaT), 'us']);
            xlabel('Time (us)', 'FontSize',14);
            ylabel('Magnitude', 'FontSize',14);
            subplot(2,1,2)
            hFFT = 20*log10(abs(fft(h,Nfft)));
            f = 1/(ChannelSize*Ts*1e6);
            F = linspace(0,f,Nfft);
            plot(F,hFFT)
            axis([0 F(end) min(hFFT) max(hFFT)]);
            set(gca, 'FontSize',14); 
            title('Channel Frequency Domain');
            xlabel('Frequency (MHz)', 'FontSize',14);
            ylabel('Magnitude dB', 'FontSize',14);

            % AWGN
            % ----
            N = length(Frame_Channel);
            No = (Es./EsNo_lin(i));    % Noise Spectral Density
            NoiseVar = No;             % Noise Variance
            AWGN = sqrt(No)*(randn(1,N)+1i*randn(1,N))*(1/sqrt(2));     % Normalised AWGN in respect to Esnorm
            
            powerFrameChannel = mean(abs(Frame_Channel).^2);
            FrameRecieved = Frame_Channel;%+AWGN;
                                 
            % Reciever
            % --------
            rPoint = Ncp+1;  
            checkpoint = Nfft*7;
            FrameTest= FrameRecieved(rPoint:end);
            NumberOfPackets = 150;
            NumberOfPacketsLeft = floor(length(FrameRecieved)/(Nfft+Ncp));
            while NumberOfPacketsLeft
                RefSymobl = FrameTest(1:Nfft);
                Rxref = fft(RefSymobl,Nfft)*1/sqrt(Nfft);
                Hchannel = Rxref./Lref; 
                Hchannel = [Hchannel(2:151) Hchannel(363:end)];
                Hn = Hchannel;
                rPoint = Nfft+Ncp+1; 
                FrameTest = FrameTest(rPoint:end);
                NumberOfPacketsLeft = floor(length(FrameTest)/(Nfft+Ncp));
                if NumberOfPacketsLeft >= 8
                    for sync = 1:7
                        SampledSymbol = FrameTest(1:Nfft);
                        Yn =fft(SampledSymbol,Nfft)*1/sqrt(Nfft);
                        Yn = [Yn(2:151) Yn(363:end)];
                        Xn = Yn./Hn;
                        Frame_Aligned = [Frame_Aligned Xn];
                       FrameTest = FrameTest(rPoint:end);
                       NumberOfPacketsLeft = floor(length(FrameTest)/(Nfft+Ncp));
                    end
                else
                    for sync = 1:NumberOfPacketsLeft
                        SampledSymbol = FrameTest(1:Nfft);
                        Yn =fft(SampledSymbol,Nfft)*1/sqrt(Nfft);
                        Yn = [Yn(2:151) Yn(363:end)];
                        Xn = Yn./Hn;
                        Frame_Aligned = [Frame_Aligned Xn];

                        if sync < NumberOfPacketsLeft
                            FrameTest = FrameTest(rPoint:end);
                        end
                    end
                end
            end 
            
        end


    x=FrameRecieved.';
    [ Pxx ] = Welch( x, Nfft, 1 );
        
        figure

        HF = fft(x,length(x));
         f = 7.68;
%         subplot(4,1,1);
%         F = -f/2:f/(length(HF)-1):f/2;
%         plot(F,20*log10((abs(HF))));
% %         axis([-f/2 f/2 -40 40])
%         set(gca, 'FontSize',14); 
%         title('FFT, One Frame (10ms)')
%         xlabel('Frequency (MHz)', 'FontSize',14);
%         ylabel('Magnitude dB', 'FontSize',14);

        subplot(3,1,1);
        F = -f/2:f/(length(Pxx)-1):f/2;
        plot(F,20*log10(abs((Pxx))))
%         axis([-f/2 f/2 -80 10])
        set(gca, 'FontSize',14); 
        title(['Welch Power Spectrum Estimate = ','  Overlap Percentage = 50%','  NFFT = ',num2str(Nfft)]);
        xlabel('Frequency (MHz)', 'FontSize',14);
        ylabel('Magnitude dB', 'FontSize',14);
        
        subplot(3,1,2); 
        
        F = -f/2:f/(Nfft-1):f/2;
        plot(F,20*log10((abs(fft(SampledSymbol,Nfft)))));
        set(gca, 'FontSize',14); 
        title('FFT, OFDM Symbol')
        xlabel('Frequency (MHz)', 'FontSize',14);
        ylabel('Magnitude dB', 'FontSize',14);
%         axis([-f/2 f/2 -400 10])
        hold off
        subplot(3,1,3); 
        plot(Frame_Aligned,'o')
        set(gca, 'FontSize',14); 
        title( ' QPSK Constellation OFDM ')
        xlabel('I', 'FontSize',14);
        ylabel('Q', 'FontSize',14);
%         axis([-1 1 -1 1])
    end
end
    

% figure
% Ts_us = Ts*1e6;
% T_us = T*1e6;
% t = 0:(T*1e6)/length(DelayedSymbol):T_us;
% t = t(1:end-1);
% plot(t,real(DelayedSymbol))
% set(gca, 'FontSize',14); 
% title('OFDM Symbol')
% xlabel('Time (us)', 'FontSize',14);
% ylabel('Amplitude', 'FontSize',14);
% axis([0 t(end) min(outputIDFT) max(outputIDFT)])
% 
% figure
% Ts = T/Nfft;
% Ts_us = Ts*1e6;
% T_us = T*1e6;
% t = 0:(T*1e6)/length(x):T_us;
% t = t(1:end-1);
% plot(t,real(x))
% set(gca, 'FontSize',14); 
% title('One Frame (10ms)')
% xlabel('Time (us)', 'FontSize',14);
% ylabel('Amplitude', 'FontSize',14);
% axis([0 t(end)*150 min(x) max(x)])

% figure
% subplot(2,1,1)
% plot(fft(outputIDFT,Nfft),'o')
% set(gca, 'FontSize',14); 
% title('QPSK Constellation Diagram For OFDM')
% xlabel('I', 'FontSize',14);
% ylabel('Q', 'FontSize',14);
% subplot(2,1,2)
% % test = fft(SampledSymbol,Nfft);
% % test2=test(107:407);
% % test2(151)=[];
% 
% plot(test,'or')
% set(gca, 'FontSize',14); 
% title('Channel Delayed Constellation Diagram')
% xlabel('I', 'FontSize',14);
% ylabel('Q', 'FontSize',14);
% axis([-1 1 -1 1])
% 
% figure
% plot(fft(SampledSymbol,Nfft),'o')
% set(gca, 'FontSize',14); 
% title('QPSK Constellation Diagram For OFDM')
% xlabel('I', 'FontSize',14);
% ylabel('Q', 'FontSize',14);