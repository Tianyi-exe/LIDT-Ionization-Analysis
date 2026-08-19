% GAMALY_FLUENCE_THRESHOLD
% Standalone MATLAB version of the Gamaly fluence-threshold comparison.
% Computes F_th = [3*n_a*lambda/(16*pi)]*(epsilon_b + E_g), reports the
% configured cases, and saves all material wavelength curves on one plot.
%
% Material inputs are synchronized with
% Gamaly_Threshold_Fluence_Parameter.docx.  ZnSe, ZnS, BaF2, NaCl, and Ge
% have complete, usable inputs.  IRG207, KRS-5, and CdTe have no epsilon_b,
% so those incomplete entries are intentionally excluded here.

clear; clc; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

AVOGADRO = 6.02214076e23;       % mol^-1
E_CHARGE = 1.602176634e-19;    % J/eV

% epsilon_b is a cohesive/binding energy on a per-atom basis.  BaF2 uses
% the calculated bulk value 18.04 eV per formula unit / 3 = 6.0133 eV/atom.
materials = struct( ...
    'name', {"ZnSe", "ZnS", "BaF2", "NaCl", "Ge"}, ...
    'molar_mass_kg_mol', {0.14434, 0.09744, 0.175323806, 0.058443, 0.072630}, ...
    'atoms_per_formula_unit', {2, 2, 3, 2, 1}, ...
    'mass_density_kg_m3', {5270.0, 4090.0, 4890.0, 2165.0, 5323.0}, ...
    'binding_energy_ev_per_atom', {2.6, 3.1, 6.013333333333334, 3.2, 3.85}, ...
    'bandgap_ev', {2.7, 3.6, 10.6, 8.5, 0.660}, ...
    'color', {[0.0000 0.4470 0.7410], [0.8500 0.3250 0.0980], ...
              [0.4660 0.6740 0.1880], [0.4940 0.1840 0.5560], ...
              [0.3010 0.7450 0.9330]});

% F0 is the case-input fluence in J/cm^2. BaF2 and NaCl LWIR values are the
% user-supplied LIDT fluences at 9.2 um with 2-ps pulses. Pulse duration is
% metadata only: it does not enter the Gamaly fluence formula.
cases = struct( ...
    'short', {"ZnSe_NIR", "ZnS_NIR", "ZnSe_LWIR", "ZnS_LWIR", ...
              "BaF2_NIR", "NaCl_NIR", "Ge_NIR", "BaF2_LWIR", "NaCl_LWIR"}, ...
    'material', {"ZnSe", "ZnS", "ZnSe", "ZnS", "BaF2", "NaCl", ...
                 "Ge", "BaF2", "NaCl"}, ...
    'region', {"NIR", "NIR", "LWIR", "LWIR", "NIR", "NIR", "NIR", "LWIR", "LWIR"}, ...
    'wavelength_um', {0.8, 0.8, 9.2, 9.2, 0.8, 0.8, 0.8, 9.2, 9.2}, ...
    'F0_jcm2', {0.15, 0.170, 0.83, 1.19, 0.9441088, 0.3922889852754974, ...
                0.0485, 2.62, 4.57});

fprintf('Fluence Threshold: F_th = [3 n_a lambda/(16 pi)] (epsilon_b + E_g)\n\n');
for k = 1:numel(cases)
    material = getMaterial(materials, cases(k).material);
    n_a_m3 = totalAtomicDensity(material, AVOGADRO);
    Fth_jcm2 = gamalyThreshold(material, cases(k).wavelength_um, AVOGADRO, E_CHARGE);
    Fth_jm2 = Fth_jcm2 * 1e4;
    ratio = cases(k).F0_jcm2 / Fth_jcm2;
    fprintf('%s (%s, %.1f um)\n', cases(k).short, cases(k).material, cases(k).wavelength_um);
    fprintf('  n_a       = %.4e m^-3\n', n_a_m3);
    fprintf('  F_th      = %.4e J/m^2 = %.4f J/cm^2\n', Fth_jm2, Fth_jcm2);
    fprintf('  F0/F_th   = %.4f\n\n', ratio);
end

wavelength_um = linspace(0.7, 11.0, 401);
fig = figure('Color', 'w', 'Units', 'pixels', 'Position', [100 100 1150 760]);
ax = axes(fig);
hold(ax, 'on');
lineHandles = gobjects(1, numel(materials));

for k = 1:numel(materials)
    material = materials(k);
    Fth_curve = arrayfun(@(lambda) gamalyThreshold(material, lambda, AVOGADRO, E_CHARGE), ...
        wavelength_um);
    lineHandles(k) = plot(ax, wavelength_um, Fth_curve, '-', ...
        'Color', material.color, 'LineWidth', 2.7, ...
        'DisplayName', sprintf('%s Gamaly threshold', material.name));

    for j = 1:numel(cases)
        if ~strcmp(string(cases(j).material), string(material.name))
            continue;
        end
        if strcmp(cases(j).region, "NIR")
            plot(ax, cases(j).wavelength_um, cases(j).F0_jcm2, '*', ...
                'Color', material.color, 'MarkerEdgeColor', material.color, ...
                'MarkerSize', 11, 'LineWidth', 0.8, ...
                'HandleVisibility', 'off');
        else
            plot(ax, cases(j).wavelength_um, cases(j).F0_jcm2, 'p', ...
                'Color', material.color, 'MarkerEdgeColor', material.color, ...
                'MarkerFaceColor', material.color, 'MarkerSize', 11, 'LineWidth', 0.8, ...
                'HandleVisibility', 'off');
        end
    end
end

nirHandle = plot(ax, nan, nan, 'k*', 'MarkerSize', 11, ...
    'LineWidth', 0.8, 'DisplayName', 'NIR case-input fluence, F_0');
lwirHandle = plot(ax, nan, nan, 'kp', 'MarkerFaceColor', 'k', 'MarkerSize', 11, ...
    'LineWidth', 0.8, ...
    'DisplayName', 'LWIR case-input fluence, F_0');
set(ax, 'YScale', 'log', 'FontSize', 16, 'LineWidth', 1.0);
xlim(ax, [0.7 11.0]);
ylim(ax, [1e-2 1e1]);
xlabel(ax, 'Wavelength \lambda (\mum)', 'FontSize', 16);
ylabel(ax, 'Fluence (J/cm^2)', 'FontSize', 16);
title(ax, 'Gamaly fluence threshold versus wavelength', 'FontWeight', 'bold', 'FontSize', 16);
legend(ax, [lineHandles nirHandle lwirHandle], 'Location', 'northwest', 'Box', 'off');
grid(ax, 'on');
grid(ax, 'minor');


scriptDir = fileparts(mfilename('fullpath'));
outputDir = fullfile(scriptDir, 'figures_Gamaly_Fluence_Threshold');
if ~isfolder(outputDir), mkdir(outputDir); end
baseName = fullfile(outputDir, 'Gamaly_threshold_vs_wavelength_all_materials_matlab');
exportgraphics(fig, [baseName '.png'], 'Resolution', 300);
savefig(fig, [baseName '.fig']);
fprintf('Saved MATLAB wavelength comparison: %s.png\n', baseName);

function material = getMaterial(materials, name)
index = find(string({materials.name}) == string(name), 1);
assert(~isempty(index), 'Unknown material: %s', name);
material = materials(index);
end

function n_a_m3 = totalAtomicDensity(material, avogadro)
n_a_m3 = material.atoms_per_formula_unit * material.mass_density_kg_m3 ...
    * avogadro / material.molar_mass_kg_mol;
end

function Fth_jcm2 = gamalyThreshold(material, wavelength_um, avogadro, e_charge)
n_a_m3 = totalAtomicDensity(material, avogadro);
energy_j = (material.binding_energy_ev_per_atom + material.bandgap_ev) * e_charge;
Fth_jm2 = 3.0 * n_a_m3 * wavelength_um * 1e-6 * energy_j / (16.0 * pi);
Fth_jcm2 = Fth_jm2 * 1e-4;
end
