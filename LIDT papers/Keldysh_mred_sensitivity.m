% KELDYSH_MRED_SENSITIVITY
% Sensitivity of the Keldysh parameter gamma to the uncertain reduced mass.
% Uses I = (1/2)*c*n*epsilon0*E^2, matching the Keldsyh Python scripts.
% This is a gamma-only sensitivity study; it does not recompute PI + II rates.

clear; clc;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

C0 = 299792458.0;             % m/s
EPS0 = 8.8541878188e-12;      % F/m
E_CHARGE = 1.602176634e-19;   % C = J/eV
ME0 = 9.1093837139e-31;       % kg

% Change this range to test a different plausible interval for m_r / m_0.
mredMinOverMe = 0.05;
mredMaxOverMe = 1.00;
nMassPoints = 160;
mredOverMe = logspace(log10(mredMinOverMe), log10(mredMaxOverMe), nMassPoints);

% Current cases used in the Keldysh and Gamaly comparisons.
% BaF2 and NaCl F0 values are calculated from pulse energy and full 1/e^2
% elliptical spot diameters, as in the Python scripts.
cases = struct( ...
    'name', {"ZnSe NIR", "ZnS NIR", "BaF2 NIR", "NaCl NIR", "ZnSe LWIR", "ZnS LWIR"}, ...
    'material', {"ZnSe", "ZnS", "BaF2", "NaCl", "ZnSe", "ZnS"}, ...
    'wavelength_um', {0.8, 0.8, 0.8, 0.8, 9.2, 9.2}, ...
    'tau_fs', {100, 100, 100, 100, 2000, 2000}, ...
    'F0_jcm2', {0.112, 0.170, nan, nan, 0.83, 1.19}, ...
    'pulse_energy_uj', {nan, nan, 361, 150, nan, nan}, ...
    'spot_a_diameter_um', {nan, nan, 226.6, 226.6, nan, nan}, ...
    'spot_b_diameter_um', {nan, nan, 429.7, 429.7, nan, nan}, ...
    'Eg_ev', {2.7, 3.6, 10.6, 8.5, 2.7, 3.6}, ...
    'mred_nominal_over_me', {0.17, 0.34, 1.0, 1.0, 0.17, 0.34}, ...
    'n0', {2.52417563, 2.31318551, 1.47039522, 1.53559571, 2.41115081, 2.21050915}, ...
    'color', {[0.0000 0.4470 0.7410], [0.8500 0.3250 0.0980], ...
              [0.4660 0.6740 0.1880], [0.4940 0.1840 0.5560], ...
              [0.0000 0.4470 0.7410], [0.8500 0.3250 0.0980]}, ...
    'line_style', {'-', '-', '-', '-', '--', '--'});

for k = 1:numel(cases)
    if isnan(cases(k).F0_jcm2)
        cases(k).F0_jcm2 = ellipticalGaussianPeakFluence( ...
            cases(k).pulse_energy_uj, cases(k).spot_a_diameter_um, ...
            cases(k).spot_b_diameter_um);
    end
    cases(k).I0_wcm2 = peakIntensityFromFluence(cases(k).F0_jcm2, cases(k).tau_fs);
end

fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100 100 1220 610]);
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');

% (a) Absolute gamma values across the chosen mred range.
ax1 = nexttile(layout);
hold(ax1, 'on');
lineHandles = gobjects(1, numel(cases));
for k = 1:numel(cases)
    gammaValues = keldyshGamma(cases(k), mredOverMe, C0, EPS0, E_CHARGE, ME0);
    lineHandles(k) = plot(ax1, mredOverMe, gammaValues, ...
        'Color', cases(k).color, 'LineStyle', cases(k).line_style, 'LineWidth', 2.4, ...
        'DisplayName', cases(k).name);
    gammaNominal = keldyshGamma(cases(k), cases(k).mred_nominal_over_me, C0, EPS0, E_CHARGE, ME0);
    plot(ax1, cases(k).mred_nominal_over_me, gammaNominal, 'o', ...
        'MarkerSize', 6.5, 'MarkerFaceColor', cases(k).color, ...
        'MarkerEdgeColor', cases(k).color, 'HandleVisibility', 'off');
end
yline(ax1, 1.0, ':k', '\gamma = 1', 'LineWidth', 1.2, ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
set(ax1, 'XScale', 'log', 'YScale', 'log', 'FontSize', 16, 'LineWidth', 1.0);
xlim(ax1, [mredMinOverMe mredMaxOverMe]);
xlabel(ax1, 'Reduced mass m_r / m_0');
ylabel(ax1, 'Keldysh parameter \gamma at input F_0');
title(ax1, '(a) Absolute \gamma sensitivity');
legend(ax1, lineHandles, 'Location', 'northwest', 'Box', 'off', 'FontSize', 16);
grid(ax1, 'on'); grid(ax1, 'minor');

% (b) Relative sensitivity.  With all other inputs fixed, this follows
% gamma/gamma_nominal = sqrt(mred/mred_nominal).
ax2 = nexttile(layout);
hold(ax2, 'on');
for k = 1:numel(cases)
    gammaValues = keldyshGamma(cases(k), mredOverMe, C0, EPS0, E_CHARGE, ME0);
    gammaNominal = keldyshGamma(cases(k), cases(k).mred_nominal_over_me, C0, EPS0, E_CHARGE, ME0);
    plot(ax2, mredOverMe, gammaValues ./ gammaNominal, ...
        'Color', cases(k).color, 'LineStyle', cases(k).line_style, 'LineWidth', 2.4, ...
        'HandleVisibility', 'off');
    plot(ax2, cases(k).mred_nominal_over_me, 1.0, 'o', ...
        'MarkerSize', 6.5, 'MarkerFaceColor', cases(k).color, ...
        'MarkerEdgeColor', cases(k).color, 'HandleVisibility', 'off');
end
yline(ax2, 1.0, ':k', 'nominal m_r', 'LineWidth', 1.2, ...
    'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
set(ax2, 'XScale', 'log', 'YScale', 'log', 'FontSize', 16, 'LineWidth', 1.0);
xlim(ax2, [mredMinOverMe mredMaxOverMe]);
xlabel(ax2, 'Reduced mass m_r / m_0');
ylabel(ax2, '\gamma / \gamma_{nominal}');
title(ax2, '(b) Relative \gamma sensitivity');
grid(ax2, 'on'); grid(ax2, 'minor');

title(layout, 'Keldysh reduced-mass sensitivity at the configured input fluence', ...
    'FontWeight', 'bold', 'FontSize', 16);

scriptDir = fileparts(mfilename('fullpath'));
outputDir = fullfile(scriptDir, 'figures_Keldsyh_II');
if ~isfolder(outputDir), mkdir(outputDir); end
baseName = fullfile(outputDir, 'combined_06_keldysh_mred_sensitivity');
exportgraphics(fig, [baseName '.png'], 'Resolution', 300);
savefig(fig, [baseName '.fig']);
fprintf('Saved reduced-mass sensitivity figure: %s.png\n', baseName);

function F0_jcm2 = ellipticalGaussianPeakFluence(energy_uj, diameterA_um, diameterB_um)
% Peak fluence F0 = 2E/(pi*a*b), where a and b are 1/e^2 radii in cm.
energy_j = energy_uj * 1e-6;
radiusA_cm = 0.5 * diameterA_um * 1e-4;
radiusB_cm = 0.5 * diameterB_um * 1e-4;
F0_jcm2 = 2.0 * energy_j / (pi * radiusA_cm * radiusB_cm);
end

function I0_wcm2 = peakIntensityFromFluence(F0_jcm2, tau_fs)
% Gaussian temporal pulse: I0 = (2F0/tau)*sqrt(ln(2)/pi).
I0_wcm2 = (2.0 * F0_jcm2 * 1e4 / (tau_fs * 1e-15)) ...
    * sqrt(log(2.0) / pi) * 1e-4;
end

function gamma = keldyshGamma(caseData, mredOverMe, c0, eps0, eCharge, me0)
% Keldysh gamma using I = (1/2)c*n*eps0*E^2.
omega = 2.0 * pi * c0 / (caseData.wavelength_um * 1e-6);
electricField = sqrt(2.0 * caseData.I0_wcm2 * 1e4 / (c0 * caseData.n0 * eps0));
Eg_j = caseData.Eg_ev * eCharge;
gamma = omega ./ (eCharge * electricField) .* sqrt((mredOverMe * me0) * Eg_j);
end
