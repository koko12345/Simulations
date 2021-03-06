function [ Eini , Eplus , Eminus, DeltaNi ] = GetRateMatchParametersNonTurbo ( DeltaNij , Nij , Fi )
% GetRateMatchParameters
%
% This function calculates the parameters used for the rate matching algorithm
%
% Usage :
%
% [Eini , Eplus , Eminus ] = GetRateMatchParameters ( DeltaNij , Nij , Fi )
%
% Where		DeltaNij	= Number of bits to puncture / repeat in each radio frame of TTI
%
%				Nij		= Number of bits in radio frame before rate matching
%
%				Fi			= Number of radio frame in TTI
%
%				Eini		= Initial value of e in rate matching algorithm
%							  This is different for each frame in the TTI therefore
%							  a vector is returned with each element containing
%							  the parameter value for each parameter.

a=2;
DeltaNi=DeltaNij;
Xi=Nij;
R=mod(DeltaNij,Nij);

if R~=0 && 2*R<=Nij
   q=ceil(Nij./R);
else
   q=ceil(Nij./(R-Nij));
end

if mod(q,2) == 0       % iseven(q)
   qprime=q+gcd(abs(q),Fi)/Fi;
else
   qprime=q;
end

S=zeros(1,Fi);
for xx=0:Fi-1
    % mod(abs(floor(xx*qprime)),Fi)+1 Determines the posistion
    % rounds down to nearist integer and divides by frame size
   S(mod(abs(floor(xx*qprime)),Fi)+1)=fix(abs(floor(xx*qprime))./Fi);   
end

switch Fi
case 1
   PermPattern= 0;
case 2
   PermPattern=[0,1];
case 4
   PermPattern=[0,2,1,3];
case 8
   PermPattern=[0,4,2,6,1,5,3,7];
otherwise
   error('Incorrect TTI specified, must be either 1, 2, 4, 8.');
end


Eini=mod(a*abs(DeltaNi).*S(PermPattern+1)+1,a*Nij);
Eplus=a*Xi;
Eminus=a*abs(DeltaNi);