clc; clear; close all;
% Laser intensity range (in W/m^2)
%A broader range takes longer to compute
I_min = 1e14;  % Minimum intensity (W/m^2)%
I_max = 1e19;  % Maximum intensity (W/m^2)%

I_values = logspace(log10(I_min), log10(I_max), 200);  % Intensities from I_min to I_max on a logarithmic scale, the more the values the longer it takes

% Define necessary physical constants
c = 2.99 * 10^8;  % Speed of light in m/s
%n = 2.5242;          % Refractive index for ZnSe @800 nm)
n = 2.4112;          % Refractive index for ZnSe @9.2 um)
%n=2.3132;           %Refractive index of ZnS @0.8 um
%n=2.2105;        %Refractive index of ZnS @9.2 um
ep0 = 8.85 * 10^-12; % Permittivity of free space in F/m
%lambda = 1.7; % Wavelength in micrometers (µm)
lambda = 9.2; % Wavelength in micrometers (µm)
%lambda = 0.8; % Wavelength in micrometers (µm)
w = 2 * pi * c / (lambda * 10^(-6)); % Radial frequency in rad/s
e = 1.6e-19;  % Elementary charge in C
delta_eV = 2.7; % Bandgap in eV for ZnSe
%delta_eV = 3.6; % Bandgap in eV for ZnS
delta = delta_eV * e; % Bandgap in J
me0 = 9.11e-31; % Electron mass in kg
me = 0.17 * me0; % Effective electron mass for ZnSe
%me = 0.34 * me0; % Effective electron mass for ZnS


% Initialize arrays to store the rates
keldysh_tunneling_rate = zeros(1, length(I_values));
keldysh_MPI_rate = zeros(1, length(I_values));
keldysh_full_rate = zeros(1, length(I_values));

% Loop over the intensity values to calculate the rates
for i = 1:length(I_values)
    I = I_values(i);  % Current laser intensity
    
    
    % Calculate the Keldysh tunneling rate for the current intensity
    keldysh_tunneling_rate(i) = keldysh_tunneling1(w, me, delta, n, I);  % Pass required parameters
    
    % Calculate the Keldysh multiphoton ionization (MPI) rate for the current intensity
    keldysh_MPI_rate(i) = keldysh_MPI1(w, me, delta, n, I);  % Pass required parameters
    
    % Calculate the full rate (combined tunneling and MPI) for the current intensity
    keldysh_full_rate(i) = keldysh_full1(w, me, delta, n, I);  % Pass required parameters
    
    % Convert ionization rates to 1/fs/cm^3
      
    keldysh_tunneling_rate(i) = keldysh_tunneling_rate(i) * 10^-15 / 10^6;  % Convert to 1/fs/cm^3
    keldysh_MPI_rate(i) = keldysh_MPI_rate(i) * 10^-15 / 10^6;  % Convert to 1/fs/cm^3
    keldysh_full_rate(i) = keldysh_full_rate(i) * 10^-15 / 10^6;  % Convert to 1/fs/cm^3
end

% Plotting the results
figure;
loglog(I_values * 10^-4, keldysh_tunneling_rate, 'r-', 'LineWidth', 3); % Plot Keldysh tunneling rate
hold on;
loglog(I_values * 10^-4, keldysh_MPI_rate, 'g--', 'LineWidth', 3);     % Plot Keldysh MPI rate
loglog(I_values * 10^-4, keldysh_full_rate, 'b:', 'LineWidth', 3);     % Plot Full rate (tunneling + MPI)


% Adding labels and legend
xlabel('Laser Intensity (W/cm^2)', 'FontSize', 14);
ylabel('Ionization Rate (1/fs/cm^3)', 'FontSize', 14);
title('Ionization Rates vs Laser Intensity', 'FontSize', 14);



legend({'Keldysh Tunneling', 'Keldysh MPI', 'Full Rate'}, 'FontSize', 14);
legend boxoff;
grid on;
hold off;
set(gca,'FontSize',14);