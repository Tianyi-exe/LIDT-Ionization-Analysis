function [W] = keldysh_tunneling1(w,me,delta,n,I)
% Function to calculate the Keldysh tunneling rate (eq 40 from ...
%Keldysh paper(1965))
 %
 % Inputs:
 % w: radial frequency of light (omega) [rad/s]
 % me: effective electron mass [kg]
 % delta: bandgap of material [J]
 % n: refractive index [unitless]
 % I: Laser Irradiance [W/mˆ2]
 % Outputs:
 % W: Keldysh Tunneling Rate [electrons/s/mˆ3]
 

 %% Constants:
 % Speed of light [m/s]
 c = 3e8;
 % Electron Charge [C]
 e = 1.6e-19;
 % Permittivity of Free Space [F/m]
 ep0 = 8.85e-12;
 % Planck Constant [J.s]
 hbar = 1.054*10^(-34);

 %% Calculations
 % Electric Field Strength [V/m]
 F = sqrt((2*I)./(c*n*ep0));

Wtun1 = (2*delta)/(9*hbar*pi()^2) * ((me*delta)/hbar^2)^(3/2);%first part of equation in Keldysh relationship for tunneling
Wtun2 = ((e*hbar*F)./(me^(1/2)*delta^(3/2))).^(5/2);%2nd part of equation
Wtun3 = exp(-(pi()*me^(1/2)*delta^(3/2))./(2*e*hbar*F) .* (1-(me*w...
    ^2*delta)./(8*e^2*F.^2)));%3rd part of equation

W = Wtun1 .* Wtun2 .*Wtun3; % [electrons/s/mˆ3]....combined terms for whole equation

end
