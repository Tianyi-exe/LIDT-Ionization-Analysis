%PLOT_3D_W_I_NE_REVIEW Display four W_total(I0, ne) surface plots from NPZ.
%   Opens one 2-by-2 figure for ZnSe/ZnS in NIR and LWIR.  Each surface has
%   an independent colorbar and no figure or data file is written.
clc;clear;close all;

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);
npzFile = fullfile('saved_variables', 'pi_ii_14_variables.npz');
assert(isfile(npzFile), 'Missing NPZ data file: %s', npzFile);

try
    npz = py.numpy.load(npzFile);
catch ME
    error(['Unable to load the NPZ file through MATLAB Python support. ', ...
        'Configure Python with NumPy, then run this script again.\n%s'], ME.message);
end

cases = ["ZnSe_NIR", "ZnS_NIR", "ZnSe_LWIR", "ZnS_LWIR"];
figure('Name', 'Wtotal(I0, ne): four 3D surfaces (not saved)', ...
    'Color', 'w', 'Units', 'pixels', 'Position', [50 50 1550 940]);

for k = 1:numel(cases)
    caseName = cases(k);
    x = readNpzArray(npz, "surface3d__" + caseName + "__log10_I_grid_wcm2");
    y = readNpzArray(npz, "surface3d__" + caseName + "__log10_ne_grid_cm3");
    z = readNpzArray(npz, "surface3d__" + caseName + "__log10_Wtotal_grid_cm3_fs");

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
    'FontWeight', 'bold', 'FontSize', 15);
drawnow;
fprintf('Displayed four 3D W_total(I0, ne) surfaces with independent colorbars. No file was saved.\n');

function values = readNpzArray(npz, key)
values = double(npz.get(char(key)));
assert(~isempty(values), 'Missing array in NPZ: %s', key);
end
