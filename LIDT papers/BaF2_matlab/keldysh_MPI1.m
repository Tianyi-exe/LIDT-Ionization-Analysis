function [W] = keldysh_MPI1(w,me,delta,n,I)
% Function to calculate the Keldysh tunneling rate (eq 41 from Keldysh paper(1965))
%
% Inputs:
% w: radial frequency of light (omega) [rad/s]
% me: effective electron mass [kg]
% delta: bandgap of material [J]
% n: refractive index [unitless]===from matFlag
% I: Laser Irradiance [W/mˆ2]
% Outputs:
% W: Keldysh MPI Rate [electrons/s/mˆ3]


%% Constants:
% Electron Charge [C]
e = 1.6e-19;
% Planck Constant [J s]
hbar = 1.054e-34;
% Speed of light (m/s)
c = 3e8;
% Permittivity of Free Space (F/m)
ep0 = 8.85e-12;

%% Calculations
% Electric Field Strength [V/m]
%F = sqrt((2*I)./(c*n*ep0));
F = sqrt((2*I)./(c*n*ep0));
delta_tau = delta + (e^2.*F.^2)./(4*me*w^2);

X = fix(delta_tau./(hbar.*w) +1);

Wmpi1 = (2*w)/(9*pi()) * ((me*w)/hbar)^(3/2);

Wmpi2 = dawson(((2.*X-(2.*delta_tau)./(hbar*w)).^(1/2)));
Wmpi3 = exp(2.*X.*(1-(e^2.*F.^2)./(4*me*w^2*delta)));
Wmpi4 = ((e^2.*F.^2)./(16*me*w^2*delta)).^X;

W = Wmpi1 .* Wmpi2 .* Wmpi3 .* Wmpi4; % [electrons/s/mˆ3]
end