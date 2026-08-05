%PLOT_3D_W_I_NE_REVIEW Display four W_total(I0, ne) surface plots from CSV.
%   Opens one 2-by-2 figure for ZnSe/ZnS in NIR and LWIR.  Each surface has
%   an independent colorbar and no figure or data file is written. This
%   script does not require MATLAB Python support or NumPy.
clc;clear;close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);
surfaceCsv = fullfile('saved_variables', 'pi_ii_14_surface3d_long.csv');
assert(isfile(surfaceCsv), ['Missing 3D CSV data file: %s\n' ...
    'Run Keldsyh_II_various.py once to create it.'], surfaceCsv);
surfaceData = readtable(surfaceCsv);

cases = ["ZnSe_NIR", "ZnS_NIR", "ZnSe_LWIR", "ZnS_LWIR"];
figure('Name', 'Wtotal(I0, ne): four 3D surfaces (not saved)', ...
    'Color', 'w', 'Units', 'pixels', 'Position', [50 50 1550 940]);

for k = 1:numel(cases)
    caseName = cases(k);
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

    ax = subplot(2, 2, k);
    surf(ax, x, y, z, z, 'EdgeColor', 'none', 'FaceAlpha', 0.95);
    colormap(ax, jet(256));
    axis(ax, 'tight');
    grid(ax, 'on');
    view(ax, 135, 28);
    xlabel(ax, 'log_{10}(I_0) [W/cm^2]');
    ylabel(ax, 'log_{10}(n_e) [cm^{-3}]');
    zlabel(ax, 'log_{10}(W_{total}) [cm^{-3} fs^{-1}]');
    title(ax, strrep(caseName, '_', '\_'));

    cb = colorbar(ax);
    cb.Label.String = 'log_{10}(W_{total}) [cm^{-3} fs^{-1}]';
end

sgtitle('Total ionization surfaces: W_{total}(I_0, n_e) - review only (no files saved)', ...
    'FontWeight', 'bold', 'FontSize', 16);
drawnow;
fprintf('Displayed four 3D W_total(I0, ne) surfaces with independent colorbars. No file was saved.\n');
