% Script to calculate the electron density growth as a function of laser and material inputs. 

%% Clear Variable Space
clear all; clc; clear;

%% Laser Properties
% Laser Wavelength [um]
%lambda = 0.8;
lambda = 9.2;
%speed of light
c=3e8;
% Radial Frequency [rad/s]
omega = 2*pi*c/(lambda * 10^(-6));
% Pulse Duration (FWHM) [fs]
tau = 2e3;% pulse duration fs
%tau = 100;% pulse duration fs
w0=698e-6;% Beam radius in m
%w0=160e-6;% Beam radius in m


%%Material Properties
% Select material using parameter matFlag.
% Values for matFlag:

% 1: ZnSe

% 2: ZnS

matFlag = 1;
% Electron Rest Mass [kg]
me0 = 9.11e-31;
% Electron Charge [C]
e = 1.6e-19;
% Function that returns material refractive index, nonlinear refractive index, bandgap, effective mass, avalanche ...
%coefficient, effective recombination time, and reflectivity.
[n0, n2, delta, me] = material_flag1(matFlag, lambda, me0, e);

%% Peak Intensity Adjustments and Conversion


Ep=11.0e-3;%pulse energy in J   %for 9.2 um for ZnSe searching theoretical LIDT--works
%Ep=31.4e-3;%pulse energy in J   %for 9.2 um for ZnS at LWIR
%Ep=0.043e-3; % for ZnSe 0% damage 0.8 um
%Ep=0.065e-3; % for ZnS 100% damage 0.8 um

I_0 = (4.*Ep.*sqrt(log(2)/pi))./(pi.*w0.^2.*tau*1e-15);%correct intensity expression. use for all calculations

I = I_0;

F=2*Ep/(pi*(w0^2)); %Fluence % use for NIR

D = 610;   % diameter in micrometers or LWIR cases for ZnSe--works
F_th = F .* (0.84.*exp(-2.*(D./2000./0.532).^2) + 0.16.*exp(-2.*(D./2000./1.25).^2));%for LWIR

I_p=(0.9394*F_th)/(tau*1e-15); %Uses measured F_th for LWIR cases

% Calculate refractive index using nonlinear term
n = n0 + n2.* I;

%% Calculate Electron Density


% Define timescale over which the pulse is defined [fs]
% Value of tau*3 chosen as max to assure the tails of the gaussian approach 0
t_span = [0, tau*3];
% Offset gaussian distribution to be in the center of t span
offset = (t_span(2)-t_span(1))/2; % [fs]
% Initialize time and electron density variables
T = cell(1,length(I)); % [fs]
T2 = T;
Ne = cell(1,1); % [electrons/cmˆ3]
Ne2 = Ne;
% Variable to track final density values for each cell when I is an array.
FinalDensity = zeros(1,length(I));

% Calculate electron density for all intensity values
for i = 1:length(I)

It = @(t) I(i).*exp(-4*log(2)*(t-offset).^2./tau^2); % On-axis (r=0) intensity [W/mˆ2]
%It = @(t) I(i).*exp(-4*log(2)*(t-offset).^2./tau^2)*10^-4; % On?axis (r=0) intensity [W/cmˆ2]

% This function calculates the full and photoexcitation rate with time [fs] and Ne as the only inputs. 
%Because it is an anonymous function, any function calls here have access to all variables in the workspace.
% Inputs:
% t: time [fs]
% Ne: Free electron density [electrons/cmˆ3]
% Outputs:
%  Photoexcitation Rate and Full Rate [electrons/fs/cmˆ3]

% Full rate equation 
fullRate = @(t,Ne) (It(t) * Ne).*10^-19 + ...
    keldysh_full1(omega,me,delta,n(i),It(t)).*10^(-15)./100^3;
%  fullRate = @(t,Ne) (alpha * It(t) * Ne).*10^-19 + ...
%      keldysh_full(omega,me,delta,n(i),It(t)).*10^(-15)./100^3- ...
%      Ne./T_recombination;

% Photoionization rate equation [electrons/fs/cmˆ3]
photoexcitationRate = @(t2,Ne2)keldysh_full1(omega,me,delta,n(i...
    ),It(t2)).*10^(-15)./100^3;

% Solve the differential equation to get the density of ...
%electrons. 
[T{i},Ne{i}] = ode45(fullRate,t_span,0);
[T2{i},Ne2{i}] = ode45(photoexcitationRate,t_span,0);

FinalDensity(i) = Ne{i}(end);
end

%% Find the total electron densities. Used to adjust plot limits.
% choose desired cell
get_array = Ne{1,1};
get_array2 = Ne2{1,1};
% get final density for total and photoionization only electron densitites
density = get_array(end);
density2 = get_array2(end);

%% Plotting the Evolution of Electron Density
t = linspace(t_span(1),t_span(2),1000);
[AX,H1,H2] = plotyy(T2{1}-offset,Ne2{1},t-offset,It(t),'semilogy','plot');
set(AX,'xlim',[-t_span(2) t_span(2)]);
hold all
AX2 = semilogy(T{1}-offset,Ne{1},'k','LineWidth', 3); 
ylim([density2/100 density*10])
% Labels, legend, and plot styles are adjusted
xlabel('Time (fs)','FontSize',14);
set(H1,'LineStyle','--','color','g', 'LineWidth', 5) 
set(H1,'color','k', 'LineWidth', 3)
set(H2,'color','b', 'LineWidth', 3)
set(AX(1),'ycolor','k', 'LineWidth', 3)
ylabel(AX(1),'Electron Density (1/cmˆ3)','FontSize',14)
set(AX(2),'ycolor','b', 'LineWidth', 3)
ylabel(AX(2),'Pulse Intensity (W/cmˆ2)', 'FontSize',14)
[legh, objh] = legend([AX2 H1 H2],'Total Electron Density','Photoionization Density', 'Pulse Intensity'); 
[legh, objh] = legend([H1 H2],'Photoionization Density', 'Pulse Intensity');
set(legend('Location','NorthWest'));
set(legend,'FontSize',14)
legend boxoff
%title('xxx');

title('ZnSe-9.2 \mum');
%title('ZnS');
grid off
box on
set(gca,'FontSize',14);


% display final density value
disp('Density');
disp(density2);
disp ('Fluence');
disp(F);
disp(F_th);%for LWIR case
disp('Intensity');
disp(I_0);
disp(I_p);%for LWIR case

