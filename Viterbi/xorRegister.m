function [ xorIndex, numGenPoly, genPolyElements ] = xorRegister( genPoly )
% Index for XOR gates
% -------------------
[numGenPoly, genPolyElements] = size(genPoly);

xorIndex = cell(1,numGenPoly);

for i = 1:numGenPoly
    arrayIndex = 1;
    for ii = 1:genPolyElements
        if (genPoly(i,ii))
            xorIndex{i}(arrayIndex) = ii;
            arrayIndex = arrayIndex+1;
        end
    end
end


end

