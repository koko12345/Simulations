clc; clear all;
nt = 4; nr = 4; d = 1000; MinErrs = 100; MaxData = 1e6; chs = 10;
snr_dB = 0:3:21; snr = 10.^(snr_dB/10); Lsnr = length(snr);
berZF = zeros(1,Lsnr); berMMSE = zeros(1,Lsnr);
for e = 1:chs
    disp(['ch ' num2str(e) '/' num2str(chs)]);
    H = (randn(nr,nt)+sqrt(-1)*randn(nr,nt))/sqrt(2);
    G_ZF = inv(H'*H)*H';
    nErZF = zeros(1,Lsnr); nErMMSE = zeros(1,Lsnr); data = zeros(1,Lsnr);
        for z = 1:Lsnr
        disp([' step ' num2str(z) '/' num2str(Lsnr) ': SNR(dB) = ' num2str(snr_dB(z))]);
        G_MMSE = inv(H'*H + (1/snr(z))*eye(nt))*H';
        while((nErZF(z)<MinErrs || nErMMSE(z)<MinErrs) && data(z)<MaxData)
            data(z) = data(z) + 2*nt*d;
            a = randsrc(nt,d,[-1 1]) + sqrt(-1)*randsrc(nt,d,[-1 1]);
            v = NoiseGen(nr,d,2/snr(z));
            r = H*a + v; r_zf = r; r_mmse = r;
            aTempZF = G_ZF*r; aTempMMSE = G_MMSE*r;
            aHatZF = FnDecodeQAM(aTempZF,'QPSK',1);
            aHatMMSE = FnDecodeQAM(aTempMMSE,'QPSK',1);
            [dumy dumy nBerZF dumy] = FnSerBerQAM(a,aHatZF,4,'gray');
            [dumy dumy nBerMMSE dumy] = FnSerBerQAM(a,aHatMMSE,4,'gray');
            nErZF(z) = nErZF(z) + nBerZF;
            nErMMSE(z) = nErMMSE(z) + nBerMMSE;
        end
        berZF(z) = berZF(z) + nErZF(z)/data(z);
        berMMSE(z) = berMMSE(z) + nErMMSE(z)/data(z);
        end
end
berZF = berZF/chs; berMMSE = berMMSE/chs;
semilogy(snr_dB,berZF,'k-s',snr_dB,berMMSE,'m-o'); grid on
legend('ZF','MMSE'); grid on; xlabel('SNR (dB)'); ylabel('BER');