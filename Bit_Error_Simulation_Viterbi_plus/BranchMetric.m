function [ BMetric, BlockCode ] = BranchMetric( Decision, BlockCode, BranchLogic, BranchRows, numGenPoly,txPacketLength )
% BranchMetric
%
% This function calculates the Branch Metric parameters for soft or hard
% decoding
%
% Usage :
%
% [ BMetric, BlockCode ] = BranchMetric( Decision, BlockCode,
% BranchLogic, BranchRows, numGenPoly,txCRCPacketLength )
%
% Where         Decision            = Soft or Hard Decision
%
%				BlockCode           = Codeword for each branch
%
%				BranchLogic         = Branch Logic Values
%
%				BranchRows          = Number of Rows in Branch
%
%				numGenPoly			= Number of Polynomials used for
%                                     encoding
%
%				txPacketLength      = Length of Transmitted packet
switch Decision
    case 'SoftDecision'
        % LLR Branch Metric
        % -----------------
        LLRBitMatrix = zeros(numGenPoly,txPacketLength);
        LLRforState = zeros(BranchRows,txPacketLength);

        for i = 1:BranchRows
            for ii = 1:numGenPoly
                if BranchLogic(i,ii)==0             % Sums LLRs for each bit b0,b1,b2...bn
                   temp = -BlockCode(:,:,ii);       % Where BlockCode zeros is negative LLR and BlockCode one is Positive LLR
                else                                % For example BlockCode 101 is sum(+LLRb0 -LRRb1 +LRRb2)
                    temp = +BlockCode(:,:,ii);
                end
                LLRBitMatrix(ii,:)=temp;
            end
            LLRforState(i,:) = sum(LLRBitMatrix);
        end
        BMetric = LLRforState;
        BlockCode = squeeze(BlockCode);
    case 'HardDecision'
        BMetric = BranchLogic;
        BlockCode = squeeze(BlockCode);
end
end

