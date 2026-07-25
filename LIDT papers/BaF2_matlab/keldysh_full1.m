function W = keldysh_full1(w,me,delta,n,I)
% Function to calculate the full Keldysh rate (eq 37 from Keldysh paper(1965))
%
% Inputs:
% w: radial frequency of light (omega) [rad/s]
% me: effective electron mass [kg]
% delta: bandgap of material [J]
% n: refractive index [unitless]
% I: Laser Irradiance [W/mˆ2]
% Outputs:
%W: Keldysh photoionization rate [electrons/s/mˆ3]

 %% Constants:
 % Speed of light [m/s]
 c = 3e8;
 % Electron Charge [C]
 e = 1.6e-19;
 % Permittivity of Free Space [F/m]
 ep0 = 8.85e-12;
% Planck Constant [J s]
hbar = 1.054*10^(-34);

 %% Calculations
 % Electric Field Strength
 F = sqrt((2*I)./(c*n*ep0)); %[V/m]
 % Gamma, Keldysh Parameter
 gamma = (w./(e.*F)).*sqrt(me*delta); % [unitless]
% Create variables for common terms
 gg = gamma.^2./(1+gamma.^2);
g1 = 1./(1+gamma.^2);

 % Elliptic Integrals
 
[Kg,Eg] = ellipke(gg);
[K1,E1] = ellipke(g1);

delta_tau = 2*delta*sqrt(1+gamma.^2).*E1./(pi()*gamma);
X = floor(delta_tau./(hbar*w)+1);

Wf1 = 2*w/(9*pi()) .* (sqrt(1+gamma.^2) * me * w ./ (gamma * ...
hbar)).^(3/2);
Wf2 = Qfun(gamma,delta_tau./(hbar*w));
Wf3 = exp(-pi().*X.*(Kg-Eg)./E1);

W = Wf1 .* Wf2 .* Wf3; % [electrons/s/mˆ3]

 % Set all NaN values to 0. NaNs can occur if the value of the ...
%intensity is too small. In this case, the photoionization rate...
%is negligible.
W(isnan(W)) = 0;


%% Q function (from Keldysh)

 function Q = Qfun(gamma,x)
 Q1 = sqrt(pi()./(2.*K1));
 Q2 = zeros(1,length(gamma));

 for i = 1:length(gamma)
 j = 0;
 tol = 1e-3;
err = 1;
OldQ2 = 0;
while err > tol
Q2(i) = Q2(i) + exp(-pi() .* (Kg(i)-Eg(i)) .* ...
    j ./ E1(i)) .* dawson(sqrt(pi()^2.* ...
    (2*floor(x(i)+1)-2.*x(i) + j) ./(2*K1(i) .* E1(i))));
 err = abs(Q2(i)-OldQ2);
j = j + 1;
OldQ2 = Q2(i);
end
end
Q = Q1.*Q2;
end
end