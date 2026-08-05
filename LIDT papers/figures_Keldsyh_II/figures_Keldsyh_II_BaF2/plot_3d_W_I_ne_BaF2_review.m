%PLOT_3D_W_I_NE_BAF2_REVIEW Display the BaF2 W_total(I0, ne) surface from CSV.
%   This script requires only MATLAB; it does not use MATLAB Python support
%   or NumPy. No figure or data file is written.
clc; clear; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);
surfaceCsv = fullfile('saved_variables', 'baf2_surface3d_long.csv');
assert(isfile(surfaceCsv), ['Missing BaF2 3D CSV data file: %s\n' ...
    'Run Keldsyh_II_BaF2.py once to create it.'], surfaceCsv);
surfaceData = readtable(surfaceCsv);

caseName = "BaF2_NIR";
rows = surfaceData(string(surfaceData.short) == caseName, :);
assert(~isempty(rows), 'Missing 3D CSV rows for %s.', caseName);
rows = sortrows(rows, {'density_index', 'intensity_index'});

nDensity = numel(unique(rows.density_index));
nIntensity = numel(unique(rows.intensity_index));
assert(height(rows) == nDensity * nIntensity, ...
    'Incomplete 3D grid for %s.', caseName);

x = reshape(rows.log10_I_grid_wcm2, nIntensity, nDensity).';
y = reshape(rows.log10_ne_grid_cm3, nIntensity, nDensity).';
z = reshape(rows.log10_Wtotal_grid_cm3_fs, nIntensity, nDensity).';

figure('Name', 'BaF2 Wtotal(I0, ne) 3D surface (not saved)', ...
    'Color', 'w', 'Units', 'pixels', 'Position', [120 80 1000 760]);
ax = axes();
surf(ax, x, y, z, z, 'EdgeColor', 'none', 'FaceAlpha', 0.95);
colormap(ax, jet(256));
axis(ax, 'tight');
grid(ax, 'on');
view(ax, 135, 28);
xlabel(ax, 'log_{10}(I_0) [W/cm^2]');
ylabel(ax, 'log_{10}(n_e) [cm^{-3}]');
zlabel(ax, 'log_{10}(W_{total}) [cm^{-3} fs^{-1}]');
title(ax, 'BaF2 NIR: W_{total}(I_0, n_e)');

cb = colorbar(ax);
cb.Label.String = 'log_{10}(W_{total}) [cm^{-3} fs^{-1}]';
drawnow;
fprintf('Displayed the BaF2 NIR 3D W_total(I0, ne) surface. No file was saved.\n');
