Consolidated code and README file
Generated: 2026-08-06 22:17:42 -04:00
Root: D:\OneDrive - The City University of New York\Tasks\BNL2026\LIDT2026\LIDT papers

Included workspace files:
- Keldysh\figures_Keldysh_II\figures_Keldsyh_II_BaF2\plot_3d_W_I_ne_BaF2_review.m
- Keldysh\figures_Keldysh_II\figures_Keldsyh_II_BaF2\plot_BaF2_from_csv_review.m
- Keldysh\figures_Keldysh_II\figures_Keldsyh_II_various\plot_14_from_csv_review.m
- Keldysh\figures_Keldysh_II\figures_Keldsyh_II_various\plot_3d_W_I_ne_review.m
- Keldysh\figures_Keldysh_II\plot_all_materials_from_csv_review.m
- Gamaly\Gamaly_Fluence_Threshold.m
- Gamaly\Gamaly_Fluence_Threshold.py
- Keldysh\Keldsyh_II_BaF2.py
- Keldysh\Keldsyh_II_NaCl.py
- Keldysh\Keldsyh_II_various.ipynb
- Keldysh\Keldsyh_II_various.py
- Keldysh_mred_sensitivity.m

Included archive files from Dismas-matlab.zip:
- Keldysh\Dismas-matlab.zip::Electron_density_growth1.m
- Keldysh\Dismas-matlab.zip::keldysh_full1.m
- Keldysh\Dismas-matlab.zip::keldysh_MPI1.m
- Keldysh\Dismas-matlab.zip::keldysh_rate2.m
- Keldysh\Dismas-matlab.zip::keldysh_tunneling1.m
- Keldysh\Dismas-matlab.zip::material_flag1.m

====================================================================================================
FILE: Keldysh\figures_Keldysh_II\figures_Keldsyh_II_BaF2\plot_3d_W_I_ne_BaF2_review.m
====================================================================================================

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

====================================================================================================
FILE: Keldysh\figures_Keldysh_II\figures_Keldsyh_II_BaF2\plot_BaF2_from_csv_review.m
====================================================================================================

%PLOT_BAF2_FROM_CSV_REVIEW BaF2 counterpart of the 14-panel CSV review.
%   It follows the original 14-panel order and creates only panels whose
%   data exist in the BaF2 CSV files.  The available BaF2 input is NIR only:
%     Figure 1, NIR total-ionization comparison: one BaF2 curve;
%     Figure 2, BaF2 NIR scaling: rate components and density/total rate.
%   LWIR and multi-material comparison panels are skipped, not replaced by
%   empty placeholders.  No figure or data file is written.
clc; clear; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);
dataDir = 'saved_variables';
componentFile = fullfile(dataDir, 'baf2_component_scaling_long.csv');
totalFile = fullfile(dataDir, 'baf2_total_comparison_long.csv');

assert(isfile(componentFile), 'Missing component CSV: %s', componentFile);
assert(isfile(totalFile), 'Missing total-comparison CSV: %s', totalFile);

fprintf('Reading and validating BaF2 CSV data...\n');
component = readtable(componentFile, 'VariableNamingRule', 'preserve');
total = readtable(totalFile, 'VariableNamingRule', 'preserve');
component.short = string(component.short);
total.short = string(total.short);
component.region = string(component.region);
total.region = string(total.region);

requiredComponent = ["short", "region", "point_index", "I_wcm2", ...
    "gamma_baf2_reference", "Wpi_peak_cm3_fs", "Wav_peak_cm3_fs", ...
    "Wtotal_peak_cm3_fs", "ne_max_cm3", "I0_wcm2", ...
    "material", "wavelength_um", "tau_fs"];
requiredTotal = ["short", "region", "point_index", "I_wcm2", ...
    "gamma_baf2_reference", "Wtotal_peak_cm3_fs", "I0_wcm2", ...
    "material", "wavelength_um"];
assertRequiredColumns(component, requiredComponent, componentFile);
assertRequiredColumns(total, requiredTotal, totalFile);

caseName = "BaF2_NIR";
componentCase = sortedCaseRows(component, caseName);
totalCase = sortedCaseRows(total, caseName);
assert(height(componentCase) == 50, 'Expected 50 component rows for %s.', caseName);
assert(height(totalCase) == 50, 'Expected 50 total-comparison rows for %s.', caseName);

% 14-panel counterpart: Figure 1, panel (a), NIR total-ionization plot.
newReviewFigure('01 Total ionization comparison: NIR', ...
    '14-panel counterpart: available NIR total-ionization panel');
plotTotalComparisonPanel(gca, totalCase);
drawnow;

% 14-panel counterpart: Figure 2, the two panels for the available BaF2 case.
newReviewFigure('02 BaF2_NIR scaling', ...
    '14-panel counterpart: BaF2 NIR irradiance scaling');
plotComponentPanel(subplot(1, 2, 1), componentCase);
plotDensityRatePanel(subplot(1, 2, 2), componentCase);
drawnow;

fprintf(['Displayed 3 available panels corresponding to the 14-panel review: ', ...
    'NIR total ionization plus BaF2 NIR components and density/rate.\n']);
fprintf('Skipped 11 panels because BaF2 LWIR and ZnSe/ZnS data are absent. No files were saved.\n');

function fig = newReviewFigure(name, superTitle)
fig = figure('Name', name, 'Color', 'w', 'Units', 'pixels', ...
    'Position', [80 180 1250 520]);
sgtitle(fig, superTitle, 'FontWeight', 'bold', 'FontSize', 16);
end

function plotTotalComparisonPanel(ax, r)
hold(ax, 'on');
loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'b-', 'LineWidth', 2.6, ...
    'DisplayName', char(r.material(1)));
lidtRate = logInterpolate(r.I_wcm2, r.Wtotal_peak_cm3_fs, r.I0_wcm2(1));
plot(ax, r.I0_wcm2(1), lidtRate, 'kx', 'MarkerSize', 8.5, ...
    'LineWidth', 2.0, 'DisplayName', 'I_0 at LIDT');
gammaOneI = gammaToIntensity(r.gamma_baf2_reference, r.I_wcm2, 1);
xline(ax, gammaOneI, 'k--', 'LineWidth', 1.7, 'HandleVisibility', 'off');
text(ax, gammaOneI * 1.12, max(r.Wtotal_peak_cm3_fs) / 5, '\gamma=1', ...
    'FontSize', 16, 'VerticalAlignment', 'middle');
ax.XScale = 'log';
ax.YScale = 'log';
xlim(ax, [5e10, 1e15]);
ylim(ax, logPaddedLimits(r.Wtotal_peak_cm3_fs));
xlabel(ax, 'Laser intensity I (W/cm^2)');
ylabel(ax, 'Peak total ionization rate W_{total} (cm^{-3} fs^{-1})');
title(ax, '(a) NIR', 'FontWeight', 'bold');
legend(ax, 'Location', 'southeast', 'Box', 'off');
grid(ax, 'on'); grid(ax, 'minor');
end

function plotComponentPanel(ax, r)
hold(ax, 'on');
loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'b--', 'LineWidth', 2.5, ...
    'DisplayName', 'W_{total}');
loglog(ax, r.I_wcm2, r.Wpi_peak_cm3_fs, 'k:', 'LineWidth', 2.3, ...
    'DisplayName', 'W_{PI}');
loglog(ax, r.I_wcm2, r.Wav_peak_cm3_fs, '-.', 'Color', [1.0 0.5 0.0], ...
    'LineWidth', 2.3, 'DisplayName', 'W_{av}');
xline(ax, r.I0_wcm2(1), '--', 'Color', [0.35 0.35 0.35], ...
    'DisplayName', 'I_0 at LIDT');
ax.XScale = 'log';
ax.YScale = 'log';
xlim(ax, [1e10, 1e15]);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
ylabel(ax, 'Ionization rate (cm^{-3} fs^{-1})');
title(ax, sprintf('(a) %s, lambda=%g um, tau=%g fs', ...
    char(string(r.material(1))), r.wavelength_um(1), r.tau_fs(1)));
legend(ax, 'Location', 'best', 'Box', 'off');
grid(ax, 'on'); grid(ax, 'minor');
end

function plotDensityRatePanel(ax, r)
hold(ax, 'on');
yyaxis(ax, 'left');
loglog(ax, r.I_wcm2, r.ne_max_cm3, 'r-', 'LineWidth', 2.5, ...
    'DisplayName', 'n_e');
ylabel(ax, 'Electron density n_e (cm^{-3})');

yyaxis(ax, 'right');
loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'b--', 'LineWidth', 2.5, ...
    'DisplayName', 'W_{total}');
ylabel(ax, 'Total ionization rate (cm^{-3} fs^{-1})');
xline(ax, r.I0_wcm2(1), '--', 'Color', [0.35 0.35 0.35], ...
    'HandleVisibility', 'off');

% yyaxis has two independent y axes; set both to logarithmic explicitly.
yyaxis(ax, 'left');
ax.YScale = 'log';
ylim(ax, logPaddedLimits(r.ne_max_cm3));
yyaxis(ax, 'right');
ax.YScale = 'log';
ylim(ax, logPaddedLimits(r.Wtotal_peak_cm3_fs));
ax.XScale = 'log';
xlim(ax, [1e10, 1e15]);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
title(ax, '(b) Density and total ionization rate');
grid(ax, 'on'); grid(ax, 'minor');
end

function r = sortedCaseRows(rows, caseName)
r = rows(rows.short == string(caseName), :);
assert(~isempty(r), 'No data found for case %s.', caseName);
r = sortrows(r, 'point_index');
end

function value = logInterpolate(x, y, xq)
value = 10.^interp1(log10(x), log10(y), log10(xq), 'linear', 'extrap');
end

function intensity = gammaToIntensity(gamma, intensityGrid, targetGamma)
[g, order] = sort(gamma(:));
i = intensityGrid(order);
intensity = 10.^interp1(log10(g), log10(i), log10(targetGamma), 'linear', 'extrap');
end

function limits = logPaddedLimits(values)
finitePositive = values(isfinite(values) & values > 0);
assert(~isempty(finitePositive), 'Cannot determine log-scale limits from empty data.');
logMin = log10(min(finitePositive));
logMax = log10(max(finitePositive));
margin = max(0.05 * (logMax - logMin), 0.05);
limits = 10.^([logMin - margin, logMax + margin]);
end

function assertRequiredColumns(T, names, fileName)
missing = names(~ismember(names, string(T.Properties.VariableNames)));
assert(isempty(missing), 'CSV %s is missing column(s): %s', fileName, ...
    strjoin(missing, ', '));
end

====================================================================================================
FILE: Keldysh\figures_Keldysh_II\figures_Keldsyh_II_various\plot_14_from_csv_review.m
====================================================================================================

%PLOT_14_FROM_CSV_REVIEW Review the 14 PI/II panels directly from CSV data.
%   This script deliberately does not save figures or data.  It opens one
%   7-by-2 review window containing all 14 panels:
%     row 1: total-ionization NIR and LWIR comparisons;
%     rows 2--5: the two panels for each individual material/wavelength;
%     rows 6--7: ZnSe and ZnS NIR-versus-LWIR comparisons.
clc; clear; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

scriptDir = fileparts(mfilename('fullpath'));
cd(scriptDir);
dataDir = 'saved_variables';
componentFile = fullfile(dataDir, 'pi_ii_14_component_scaling_long.csv');
totalFile = fullfile(dataDir, 'pi_ii_14_total_comparison_long.csv');

assert(isfile(componentFile), 'Missing component CSV: %s', componentFile);
assert(isfile(totalFile), 'Missing total-comparison CSV: %s', totalFile);

fprintf('Reading and validating CSV data...\n');
component = readtable(componentFile, 'VariableNamingRule', 'preserve');
total = readtable(totalFile, 'VariableNamingRule', 'preserve');
component.short = string(component.short);
total.short = string(total.short);
component.region = string(component.region);
total.region = string(total.region);

requiredComponent = ["short", "region", "point_index", "I_wcm2", ...
    "gamma_zns_reference", "Wpi_peak_cm3_fs", "Wav_peak_cm3_fs", ...
    "Wtotal_peak_cm3_fs", "ne_max_cm3", "I_lidt_wcm2", ...
    "material", "wavelength_um", "tau_fs"];
requiredTotal = ["short", "region", "point_index", "I_wcm2", ...
    "gamma_zns_reference", "Wtotal_peak_cm3_fs", "I_lidt_wcm2", ...
    "material", "wavelength_um"];
assertRequiredColumns(component, requiredComponent, componentFile);
assertRequiredColumns(total, requiredTotal, totalFile);

caseOrder = ["ZnSe_NIR", "ZnS_NIR", "ZnSe_LWIR", "ZnS_LWIR"];
validateData(component, caseOrder, 50, 'component CSV');
validateData(total, caseOrder, 50, 'total-comparison CSV');

fig = figure('Name', 'PI/II: 14-panel CSV review (not saved)', ...
    'Visible', 'off', 'Color', 'w', 'Units', 'pixels', 'Position', [40 40 1200 900]);
sgtitle(fig, 'PI/II plots reconstructed from CSV data — review only (no files saved)', ...
    'FontWeight', 'bold', 'FontSize', 16);

close(fig);

% Figure 1: NIR and LWIR total-ionization comparisons.
fig = newReviewFigure('01 Total ionization comparison', ...
    'Total ionization including avalanche: W_{total} = W_{PI} + (sigma I/E_g)n_e');
plotTotalComparisonPanel(subplot(1, 2, 1), total, "NIR", [10, 3, 1, 0.3]);
plotTotalComparisonPanel(subplot(1, 2, 2), total, "LWIR", [1, 0.3, 0.1]);
drawnow;

% Figures 2--5: two panels for each individual material/wavelength case.
for k = 1:numel(caseOrder)
    thisCase = caseOrder(k);
    fig = newReviewFigure(sprintf('%02d %s scaling', k + 1, thisCase), ...
        sprintf('%s: irradiance scaling', thisCase));
    plotComponentPanel(subplot(1, 2, 1), component, thisCase);
    plotDensityRatePanel(subplot(1, 2, 2), component, thisCase);
    drawnow;
end

% Figures 6--7: NIR-versus-LWIR comparisons for each material.
for materialName = ["ZnSe", "ZnS"]
    fig = newReviewFigure(sprintf('%s NIR vs LWIR', materialName), ...
        sprintf('%s: NIR 100 fs versus LWIR 2 ps irradiance scaling', materialName));
    plotMaterialDensityPanel(subplot(1, 2, 1), component, materialName);
    plotMaterialRatePanel(subplot(1, 2, 2), component, materialName);
    drawnow;
end

fprintf('Displayed 7 two-panel figures (14 panels total). No figure or data file was saved.\n');

function plotTotalComparisonPanel(ax, total, regime, gammaTicks)
rows = total(total.region == regime, :);
caseNames = unique(rows.short, 'stable');
hold(ax, 'on');
for k = 1:numel(caseNames)
    r = sortedCaseRows(rows, caseNames(k));
    loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'LineWidth', 2.6, ...
        'DisplayName', char(r.material(1)));
    lidtRate = logInterpolate(r.I_wcm2, r.Wtotal_peak_cm3_fs, r.I_lidt_wcm2(1));
    plot(ax, r.I_lidt_wcm2(1), lidtRate, 'kx', 'MarkerSize', 8.5, ...
        'LineWidth', 2.0, 'HandleVisibility', 'off');
end

representative = sortedCaseRows(rows, caseNames(1));
gammaOneI = gammaToIntensity(representative.gamma_zns_reference, ...
    representative.I_wcm2, 1);
xline(ax, gammaOneI, 'k--', 'LineWidth', 1.7, 'HandleVisibility', 'off');
text(ax, gammaOneI * 1.12, 1e30 / 8, '\gamma=1', 'FontSize', 16, ...
    'VerticalAlignment', 'middle', 'Interpreter', 'tex');
ax.XScale = 'log';
ax.YScale = 'log';
xlim(ax, [5e10, 1e15]);
ylim(ax, [1e0, 1e30]);
xlabel(ax, 'Laser intensity I (W/cm^2)');
ylabel(ax, 'Peak total ionization rate W_{total} (cm^{-3} fs^{-1})');
title(ax, sprintf('(%s) %s', panelLetter(regime), regime), 'FontWeight', 'bold');
legend(ax, 'Location', 'southeast', 'Box', 'off');
grid(ax, 'on'); grid(ax, 'minor');
addGammaReferenceLabels(ax, representative.I_wcm2, representative.gamma_zns_reference, gammaTicks);
end

function plotComponentPanel(ax, component, caseName)
r = sortedCaseRows(component, caseName);
hold(ax, 'on');
loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'b--', 'LineWidth', 2.5, ...
    'DisplayName', 'W_{total}');
loglog(ax, r.I_wcm2, r.Wpi_peak_cm3_fs, 'k:', 'LineWidth', 2.3, ...
    'DisplayName', 'W_{PI}');
loglog(ax, r.I_wcm2, r.Wav_peak_cm3_fs, '-.', 'Color', [1.0 0.5 0.0], ...
    'LineWidth', 2.3, 'DisplayName', 'W_{av}');
xline(ax, r.I_lidt_wcm2(1), '--', 'Color', [0.35 0.35 0.35], ...
    'DisplayName', 'I_0 at LIDT');
ax.XScale = 'log';
ax.YScale = 'log';
xlim(ax, [1e10, 1e15]);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
ylabel(ax, 'Ionization rate (cm^{-3} fs^{-1})');
title(ax, sprintf('(a) %s, lambda=%g um, tau=%g fs', ...
    char(string(r.material(1))), r.wavelength_um(1), r.tau_fs(1)));
legend(ax, 'Location', 'best', 'Box', 'off');
grid(ax, 'on'); grid(ax, 'minor');
end

function plotDensityRatePanel(ax, component, caseName)
r = sortedCaseRows(component, caseName);
hold(ax, 'on');
yyaxis(ax, 'left');
loglog(ax, r.I_wcm2, r.ne_max_cm3, 'r-', 'LineWidth', 2.5, 'DisplayName', 'n_e');
ylabel(ax, 'Electron density n_e (cm^{-3})');

yyaxis(ax, 'right');
loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'b--', 'LineWidth', 2.5, ...
    'DisplayName', 'W_{total}');
ylabel(ax, 'Total ionization rate (cm^{-3} fs^{-1})');
xline(ax, r.I_lidt_wcm2(1), '--', 'Color', [0.35 0.35 0.35], ...
    'HandleVisibility', 'off');
yyaxis(ax, 'left');
ax.YScale = 'log';
ylim(ax, logPaddedLimits(r.ne_max_cm3));
yyaxis(ax, 'right');
ax.YScale = 'log';
ylim(ax, logPaddedLimits(r.Wtotal_peak_cm3_fs));
ax.XScale = 'log';
xlim(ax, [1e10, 1e15]);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
title(ax, '(b) Density and total ionization rate');
grid(ax, 'on'); grid(ax, 'minor');
end

function plotMaterialDensityPanel(ax, component, materialName)
rows = component(string(component.material) == materialName, :);
plotMaterialPanel(ax, rows, 'ne_max_cm3', 'Electron density n_e (cm^{-3})', ...
    sprintf('(a) %s: electron density', materialName));
end

function plotMaterialRatePanel(ax, component, materialName)
rows = component(string(component.material) == materialName, :);
plotMaterialPanel(ax, rows, 'Wtotal_peak_cm3_fs', ...
    'Total ionization rate (cm^{-3} fs^{-1})', ...
    sprintf('(b) %s: total ionization rate', materialName));
end

function plotMaterialPanel(ax, rows, yName, yLabelText, titleText)
hold(ax, 'on');
for regime = ["NIR", "LWIR"]
    caseNames = unique(rows.short(rows.region == regime), 'stable');
    assert(numel(caseNames) == 1, 'Expected exactly one %s case.', regime);
    r = sortedCaseRows(rows, caseNames(1));
    if regime == "NIR"
        style = '-';
    else
        style = '-.';
    end
    loglog(ax, r.I_wcm2, r.(yName), style, 'LineWidth', 2.3, ...
        'DisplayName', sprintf('%g um, tau=%g fs', r.wavelength_um(1), r.tau_fs(1)));
    xline(ax, r.I_lidt_wcm2(1), '--', 'Color', [0.5 0.5 0.5], ...
        'HandleVisibility', 'off');
end
ax.XScale = 'log';
ax.YScale = 'log';
xlim(ax, [1e10, 1e15]);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
ylabel(ax, yLabelText);
title(ax, titleText);
legend(ax, 'Location', 'best', 'Box', 'off');
grid(ax, 'on'); grid(ax, 'minor');
end

function fig = newReviewFigure(name, superTitle)
fig = figure('Name', name, 'Color', 'w', 'Units', 'pixels', ...
    'Position', [80 180 1250 520]);
sgtitle(fig, superTitle, 'FontWeight', 'bold', 'FontSize', 16);
end

function addGammaReferenceLabels(ax, intensity, gamma, gammaTicks)
% Keep the gamma reference visible without creating a second axes object.
gammaIntensity = gammaToIntensity(gamma, intensity, gammaTicks);
xLim = ax.XLim;
for k = 1:numel(gammaTicks)
    xNorm = (log10(gammaIntensity(k)) - log10(xLim(1))) / ...
        (log10(xLim(2)) - log10(xLim(1)));
    text(ax, xNorm, 1.05, sprintf('%g', gammaTicks(k)), ...
        'Units', 'normalized', 'HorizontalAlignment', 'center', ...
        'VerticalAlignment', 'bottom', 'FontSize', 16, 'Clipping', 'off');
end
text(ax, 0.5, 1.16, 'Keldysh parameter gamma (ZnS reference)', ...
    'Units', 'normalized', 'HorizontalAlignment', 'center', ...
    'VerticalAlignment', 'bottom', 'FontSize', 16, 'Clipping', 'off');
end

function intensity = gammaToIntensity(gamma, intensityGrid, targetGamma)
[g, order] = sort(gamma(:));
i = intensityGrid(order);
intensity = 10.^interp1(log10(g), log10(i), log10(targetGamma), 'linear', 'extrap');
end

function value = logInterpolate(x, y, xq)
value = 10.^interp1(log10(x), log10(y), log10(xq), 'linear', 'extrap');
end

function limits = logPaddedLimits(values)
% Match Matplotlib's default 5 percent margin in logarithmic coordinates.
finitePositive = values(isfinite(values) & values > 0);
logMin = log10(min(finitePositive));
logMax = log10(max(finitePositive));
margin = 0.05 * (logMax - logMin);
limits = 10.^([logMin - margin, logMax + margin]);
end

function r = sortedCaseRows(rows, caseName)
caseName = string(caseName);
r = rows(rows.short == caseName, :);
assert(~isempty(r), 'No data found for case %s.', caseName);
r = sortrows(r, 'point_index');
end

function assertRequiredColumns(T, names, fileName)
missing = names(~ismember(names, string(T.Properties.VariableNames)));
assert(isempty(missing), 'CSV %s is missing column(s): %s', fileName, strjoin(missing, ', '));
end

function validateData(T, caseOrder, expectedRows, label)
for caseName = caseOrder
    r = sortedCaseRows(T, caseName);
    assert(height(r) == expectedRows, '%s: %s has %d rather than %d rows.', ...
        label, caseName, height(r), expectedRows);
    assert(all(isfinite(r.I_wcm2) & r.I_wcm2 > 0), '%s: invalid intensities in %s.', label, caseName);
end
end

function out = panelLetter(regime)
if regime == "NIR"
    out = 'a';
else
    out = 'b';
end
end

====================================================================================================
FILE: Keldysh\figures_Keldysh_II\figures_Keldsyh_II_various\plot_3d_W_I_ne_review.m
====================================================================================================

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

====================================================================================================
FILE: Keldysh\figures_Keldysh_II\plot_all_materials_from_csv_review.m
====================================================================================================

%PLOT_ALL_MATERIALS_FROM_CSV_REVIEW Compare ZnSe, ZnS, BaF2, and NaCl from CSV.
%   Combines the two existing review workflows and saves PNG plus editable
%   MATLAB .fig files beside this script.
%   Matching NIR and LWIR plots include ZnSe, ZnS, BaF2, and NaCl together.
%
%   Figure 1: total W_total comparison (NIR and LWIR: 4 materials each)
%   Figure 2: NIR W_PI, W_av, W_total for each material (four panels)
%   Figure 3: side-by-side NIR and LWIR n_e/W_total comparisons
%   Figure 4: NIR/LWIR comparison per material
%   Figure 5: unified 3D W_total surfaces for all available material cases
%   Figure 1 calculates gamma from each material's own n0, Eg, and mred
%   values, then shows a distinct gamma = 1 dashed line for every material.
clc; clear; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

scriptDir = fileparts(mfilename('fullpath'));
variousDir = fullfile(scriptDir, 'figures_Keldsyh_II_various');
baf2Dir = fullfile(scriptDir, 'figures_Keldsyh_II_BaF2');
naclDir = fullfile(scriptDir, 'figures_Keldsyh_II_NaCl');

varComponent = readCsv(fullfile(variousDir, 'saved_variables', ...
    'pi_ii_14_component_scaling_long.csv'));
varTotal = readCsv(fullfile(variousDir, 'saved_variables', ...
    'pi_ii_14_total_comparison_long.csv'));
bafComponent = readCsv(fullfile(baf2Dir, 'saved_variables', ...
    'baf2_component_scaling_long.csv'));
bafTotal = readCsv(fullfile(baf2Dir, 'saved_variables', ...
    'baf2_total_comparison_long.csv'));
naclComponent = readCsv(fullfile(naclDir, 'saved_variables', ...
    'nacl_component_scaling_long.csv'));
naclTotal = readCsv(fullfile(naclDir, 'saved_variables', ...
    'nacl_total_comparison_long.csv'));
varSurface = readSurfaceCsv(fullfile(variousDir, 'saved_variables', ...
    'pi_ii_14_surface3d_long.csv'));
bafSurface = readSurfaceCsv(fullfile(baf2Dir, 'saved_variables', ...
    'baf2_surface3d_long.csv'));
naclSurface = readSurfaceCsv(fullfile(naclDir, 'saved_variables', ...
    'nacl_surface3d_long.csv'));

% The existing ZnSe/ZnS CSV has a ZnS-reference gamma column.  Recalculate
% gamma from each row's own material properties for an apples-to-apples plot.
varTotal = addMaterialGamma(varTotal);
bafTotal = addMaterialGamma(bafTotal);
naclTotal = addMaterialGamma(naclTotal);

cases = [ ...
    makeCase(varComponent, varTotal, "ZnSe_NIR", "I_lidt_wcm2", ...
        "gamma_material", "ZnSe", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(varComponent, varTotal, "ZnS_NIR",  "I_lidt_wcm2", ...
        "gamma_material", "ZnS", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(bafComponent, bafTotal, "BaF2_NIR", "I0_wcm2", ...
        "gamma_material", "BaF2", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(naclComponent, naclTotal, "NaCl_NIR", "I0_wcm2", ...
        "gamma_material", "NaCl", "Wtotal_direct_at_reference_cm3_fs"); ...
    makeCase(varComponent, varTotal, "ZnSe_LWIR", "I_lidt_wcm2", ...
        "gamma_material", "ZnSe", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(varComponent, varTotal, "ZnS_LWIR", "I_lidt_wcm2", ...
        "gamma_material", "ZnS", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(bafComponent, bafTotal, "BaF2_LWIR", "I0_wcm2", ...
        "gamma_material", "BaF2", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(naclComponent, naclTotal, "NaCl_LWIR", "I0_wcm2", ...
        "gamma_material", "NaCl", "Wtotal_direct_at_reference_cm3_fs")];

nIR = cases(strcmp({cases.region}, 'NIR'));
lwir = cases(strcmp({cases.region}, 'LWIR'));
materials = ["ZnSe", "ZnS", "BaF2", "NaCl"];

% A shared gamma axis would be misleading because gamma is material-specific.
% Instead, Figure 1 uses individually labeled gamma = 1 vertical lines.
fig = newFigure('01 Total ionization comparison', ...
    'Total ionization comparison; black x = model value at LIDT');
tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
plotTotalComparison(nexttile, nIR, '(a) NIR: ZnSe, ZnS, BaF2, NaCl');
plotTotalComparison(nexttile, lwir, '(b) LWIR: ZnSe, ZnS, BaF2, NaCl');
saveFigurePair(scriptDir, 'combined_01_total_ionization_comparison');

fig = newFigure('02 NIR rate components', ...
    'NIR rate components for the four available materials');
tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for k = 1:numel(nIR)
    plotComponentPanel(nexttile, nIR(k));
end
saveFigurePair(scriptDir, 'combined_02_NIR_rate_components');

fig = newFigure('03 NIR and LWIR density and total rate', ...
    'NIR and LWIR electron density and total ionization rate');
fig.Position = [35 35 2200 1050];
layout = tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
axNir = nexttile(layout);
legendHandles = plotCombinedDensityRatePanel(axNir, nIR, 'NIR');
plotCombinedDensityRatePanel(nexttile(layout), lwir, 'LWIR');
lgd = legend(axNir, legendHandles, 'Box', 'off', ...
    'Orientation', 'horizontal', 'FontSize', 16, 'NumColumns', 5);
lgd.Layout.Tile = 'south';
saveFigurePair(scriptDir, 'combined_03_NIR_LWIR_density_total_rate');

fig = newFigure('04 Material NIR/LWIR comparisons', ...
    'Material comparison at NIR and LWIR');
tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for material = materials
    plotMaterialComparison(nexttile, cases(strcmp({cases.material}, char(material))));
end
saveFigurePair(scriptDir, 'combined_04_material_NIR_LWIR_comparison');

surfaceCases = [ ...
    makeSurfaceCase(varSurface, cases, "ZnSe_NIR"); ...
    makeSurfaceCase(varSurface, cases, "ZnS_NIR"); ...
    makeSurfaceCase(bafSurface, cases, "BaF2_NIR"); ...
    makeSurfaceCase(naclSurface, cases, "NaCl_NIR"); ...
    makeSurfaceCase(varSurface, cases, "ZnSe_LWIR");...
    makeSurfaceCase(varSurface, cases, "ZnS_LWIR");...
    makeSurfaceCase(bafSurface, cases, "BaF2_LWIR");...
    makeSurfaceCase(naclSurface, cases, "NaCl_LWIR")];


fig = newSurfaceFigure('05 Combined 3D total-ionization surfaces', ...
    'Total ionization surfaces: all available material and wavelength cases');
plotCombined3dSurfaces(fig, surfaceCases);
saveFigurePair(scriptDir, 'combined_05_all_materials_3d_total_ionization');

fig = newHeatmapFigure('06 Combined total-ionization heatmaps', ...
    'Total ionization-rate heatmaps: dotted = \gamma = 1; dashed = LIDT');
plotCombinedHeatmaps(fig, surfaceCases);
saveFigurePair(scriptDir, 'combined_06_all_materials_total_ionization_heatmaps');

drawnow;
fprintf(['Displayed unified CSV-review figures: NIR uses ZnSe, ZnS, BaF2, NaCl; ', ...
    'LWIR uses ZnSe, ZnS, BaF2, NaCl. PNG and .fig files were saved in %s.\n'], scriptDir);

function T = readCsv(fileName)
assert(isfile(fileName), 'Missing CSV: %s', fileName);
T = readtable(fileName, 'VariableNamingRule', 'preserve');
assert(ismember('short', T.Properties.VariableNames), 'Missing short column: %s', fileName);
T.short = string(T.short);
T.material = string(T.material);
T.region = string(T.region);
end

function T = readSurfaceCsv(fileName)
assert(isfile(fileName), 'Missing 3D surface CSV: %s', fileName);
T = readtable(fileName, 'VariableNamingRule', 'preserve');
required = ["short", "density_index", "intensity_index", ...
    "log10_I_grid_wcm2", "log10_ne_grid_cm3", "log10_Wtotal_grid_cm3_fs"];
assertRequiredColumns(T, required, "3D surface CSV");
T.short = string(T.short);
end

function out = makeCase(component, total, shortName, markerColumn, gammaColumn, gammaReference, directRateColumn)
c = sortedCaseRows(component, shortName);
t = sortedCaseRows(total, shortName);
requiredComponent = ["I_wcm2", "Wpi_peak_cm3_fs", "Wav_peak_cm3_fs", ...
    "Wtotal_peak_cm3_fs", "ne_max_cm3", markerColumn];
requiredTotal = ["I_wcm2", "Wtotal_peak_cm3_fs", markerColumn, gammaColumn, directRateColumn];
assertRequiredColumns(c, requiredComponent, shortName + " component");
assertRequiredColumns(t, requiredTotal, shortName + " total");
assert(height(c) == 50 && height(t) == 50, ...
    'Expected 50 rows in both CSV datasets for %s.', shortName);
markerLabel = 'LIDT';
out = struct( ...
    'short', char(shortName), ...
    'material', char(c.material(1)), ...
    'region', char(c.region(1)), ...
    'wavelength_um', c.wavelength_um(1), ...
    'tau_fs', c.tau_fs(1), ...
    'markerI', c.(markerColumn)(1), ...
    'markerLabel', markerLabel, ...
    'markerWtotal', t.(directRateColumn)(1), ...
    'gamma', t.(gammaColumn), ...
    'gammaReference', char(gammaReference), ...
    'component', c, ...
    'total', t);
end

function out = makeSurfaceCase(surfaceTable, cases, shortName)
s = surfaceTable(surfaceTable.short == string(shortName), :);
assert(~isempty(s), 'No 3D data found for %s.', shortName);
baseIndex = find(strcmp({cases.short}, char(shortName)), 1);
assert(~isempty(baseIndex), 'No matching case metadata found for %s.', shortName);
baseCase = cases(baseIndex);
neAtInputLidt = logCurveValue(baseCase.component.I_wcm2, ...
    baseCase.component.ne_max_cm3, baseCase.markerI);
out = struct('short', char(shortName), 'material', baseCase.material, ...
    'region', baseCase.region, 'markerI', baseCase.markerI, ...
    'markerLabel', baseCase.markerLabel, ...
    'gammaOneI', gammaToIntensity(baseCase.gamma, baseCase.total.I_wcm2, 1.0), ...
    'markerNe_cm3', neAtInputLidt, 'surface', s);
end

function plotTotalComparison(ax, caseList, titleText)
hold(ax, 'on');
for k = 1:numel(caseList)
    c = caseList(k);
    color = materialColor(c.material);
    plot(ax, c.total.I_wcm2, c.total.Wtotal_peak_cm3_fs, '-', ...
        'Color', color, 'LineWidth', 2.6, 'DisplayName', c.material);
    plot(ax, c.markerI, c.markerWtotal, 'kx', 'MarkerSize', 10, ...
        'LineWidth', 2.3, 'HandleVisibility', 'off');
end
addGammaOneLines(ax, caseList);
plot(ax, nan, nan, 'kx', 'MarkerSize', 9, 'LineWidth', 2.0, ...
    'DisplayName', 'model at input I_0');
ax.XScale = 'log'; ax.YScale = 'log';
% The ZnSe gamma = 1 crossing is at 3.51e10 W/cm^2.  Keep it inside
% the displayed range so that its blue dotted line is not clipped.
xlim(ax, [3e10, 1e15]);
ylim(ax, combinedLogLimits(caseList, 'total'));
xlabel(ax, 'Laser intensity I (W/cm^2)');
ylabel(ax, 'Peak total ionization rate W_{total} (cm^{-3} fs^{-1})');
title(ax, titleText, 'FontWeight', 'bold');
legend(ax, 'Location', 'southeast', 'Box', 'off');
grid(ax, 'on'); grid(ax, 'minor');
end

function hGamma = addGammaOneLines(ax, caseList)
shownReferences = strings(0);
hGamma = gobjects(1, 0);
for k = 1:numel(caseList)
    c = caseList(k);
    reference = string(c.gammaReference);
    if any(shownReferences == reference), continue; end
    gammaOneI = gammaToIntensity(c.gamma, c.total.I_wcm2, 1.0);
    if gammaOneI < ax.XLim(1) || gammaOneI > ax.XLim(2), continue; end
    if reference == "ZnSe"
        color = materialColor('ZnSe');
        label = '\gamma_{ZnSe}=1';
    elseif reference == "ZnS"
        color = materialColor('ZnS');
        label = '\gamma_{ZnS}=1';
    elseif reference == "BaF2"
        color = materialColor('BaF2');
        label = '\gamma_{BaF_2}=1';
    else
        color = materialColor('NaCl');
        label = '\gamma_{NaCl}=1';
    end
    hGamma(end + 1) = xline(ax, gammaOneI, ':', 'Color', color, ...
        'LineWidth', 1.9, 'DisplayName', label); %#ok<AGROW>
    shownReferences(end + 1) = reference; %#ok<AGROW>
end
end

function plotComponentPanel(ax, c)
r = c.component;
hold(ax, 'on');
loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'b--', 'LineWidth', 2.3, ...
    'DisplayName', 'W_{total}');
loglog(ax, r.I_wcm2, r.Wpi_peak_cm3_fs, 'k:', 'LineWidth', 2.1, ...
    'DisplayName', 'W_{PI}');
loglog(ax, r.I_wcm2, r.Wav_peak_cm3_fs, '-.', 'Color', [1 .5 0], ...
    'LineWidth', 2.1, 'DisplayName', 'W_{av}');
hLidt = xline(ax, c.markerI, '--', 'Color', [.35 .35 .35], ...
    'DisplayName', 'input I_0');
ax.XScale = 'log'; ax.YScale = 'log'; xlim(ax, [1e10, 1e15]);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
ylabel(ax, 'Ionization rate (cm^{-3} fs^{-1})');
title(ax, sprintf('%s: components', c.material));
legend(ax, 'Location', 'best', 'Box', 'off'); grid(ax, 'on'); grid(ax, 'minor');
end

function plotDensityRatePanel(ax, c)
r = c.component;
hold(ax, 'on');
yyaxis(ax, 'left');
hDensity = loglog(ax, r.I_wcm2, r.ne_max_cm3, 'r-', 'LineWidth', 2.3, ...
    'DisplayName', 'n_e');
ylabel(ax, 'Electron density n_e (cm^{-3})');
ax.YScale = 'log'; ylim(ax, logPaddedLimits(r.ne_max_cm3));
yyaxis(ax, 'right');
hRate = loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, 'b--', 'LineWidth', 2.3, ...
    'DisplayName', 'W_{total}');
ylabel(ax, 'Total ionization rate (cm^{-3} fs^{-1})');
ax.YScale = 'log'; ylim(ax, logPaddedLimits(r.Wtotal_peak_cm3_fs));
hLidt = xline(ax, c.markerI, '--', 'Color', [.35 .35 .35], ...
    'DisplayName', 'input I_0');
ax.XScale = 'log'; xlim(ax, [1e10, 1e15]);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
title(ax, sprintf('%s: density and total rate', c.material));
legend(ax, [hDensity, hRate, hLidt], {'n_e', 'W_{total}', 'input I_0'}, ...
    'Location', 'best', 'Box', 'off');
grid(ax, 'on'); grid(ax, 'minor');
end

function legendHandles = plotCombinedDensityRatePanel(ax, caseList, regionLabel)
% Use one fixed color per material; solid is density and dashed is total rate.
% Black x marks the density value at each material's damage/input fluence.
nCases = numel(caseList);
hDensity = gobjects(1, nCases);
hRate = gobjects(1, nCases);
hDamage = gobjects(1, 1);
densityValues = [];
rateValues = [];

hold(ax, 'on');
yyaxis(ax, 'left');
for k = 1:nCases
    c = caseList(k);
    r = c.component;
    hDensity(k) = loglog(ax, r.I_wcm2, r.ne_max_cm3, '-', ...
        'Color', materialColor(c.material), 'LineWidth', 2.6, ...
        'DisplayName', sprintf('%s n_e', c.material));
    densityAtDamage = logCurveValue(r.I_wcm2, r.ne_max_cm3, c.markerI);
    h = plot(ax, c.markerI, densityAtDamage, 'kx', 'MarkerSize', 10, ...
        'LineWidth', 2.3, 'HandleVisibility', 'off');
    if k == 1
        h.HandleVisibility = 'on';
        h.DisplayName = 'damage point at input F_0';
        hDamage = h;
    end
    densityValues = [densityValues; r.ne_max_cm3]; %#ok<AGROW>
end
ylabel(ax, 'Electron density n_e (cm^{-3})');
ax.YScale = 'log';
ylim(ax, logPaddedLimits(densityValues));

yyaxis(ax, 'right');
for k = 1:nCases
    c = caseList(k);
    r = c.component;
    hRate(k) = loglog(ax, r.I_wcm2, r.Wtotal_peak_cm3_fs, '--', ...
        'Color', materialColor(c.material), 'LineWidth', 2.6, ...
        'DisplayName', sprintf('%s W_{total}', c.material));
    rateValues = [rateValues; r.Wtotal_peak_cm3_fs]; %#ok<AGROW>
end
ylabel(ax, 'Total ionization rate W_{total} (cm^{-3} fs^{-1})');
ax.YScale = 'log';
ylim(ax, logPaddedLimits(rateValues));

ax.XScale = 'log';
xlim(ax, [1e10, 1e15]);
% Dotted vertical lines show gamma = 1 using each material's own n0, Eg,
% and reduced mass. Their colors match the material curves.
hGamma = addGammaOneLines(ax, caseList);
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
title(ax, [regionLabel ' (' num2str(caseList(1).wavelength_um) ' \mum)'], ...
    'FontWeight', 'bold');
legendHandles = [hDensity hRate hDamage hGamma];
grid(ax, 'on'); grid(ax, 'minor');
end

function value = logCurveValue(x, y, xQuery)
% Log-log interpolation keeps the damage marker on the sampled model curve.
value = 10.^interp1(log10(x), log10(y), log10(xQuery), 'linear', 'extrap');
end

function plotMaterialComparison(ax, caseList)
hold(ax, 'on');
for k = 1:numel(caseList)
    c = caseList(k);
    if strcmp(c.region, 'NIR'), style = '-'; else, style = '-.'; end
    plot(ax, c.component.I_wcm2, c.component.Wtotal_peak_cm3_fs, style, ...
        'Color', materialColor(c.material), 'LineWidth', 2.4, ...
        'DisplayName', sprintf('%s, %g um, %g fs', c.region, c.wavelength_um, c.tau_fs));
    if k == 1
        xline(ax, c.markerI, '--', 'Color', [.5 .5 .5], ...
            'DisplayName', 'LIDT');
    else
        xline(ax, c.markerI, '--', 'Color', [.5 .5 .5], ...
            'HandleVisibility', 'off');
    end
end
ax.XScale = 'log'; ax.YScale = 'log'; xlim(ax, [1e10, 1e15]);
ylim(ax, combinedLogLimits(caseList, 'component'));
xlabel(ax, 'Peak laser irradiance I_0 (W/cm^2)');
ylabel(ax, 'Total ionization rate (cm^{-3} fs^{-1})');
title(ax, sprintf('%s: available wavelength regimes', caseList(1).material));
legend(ax, 'Location', 'best', 'Box', 'off'); grid(ax, 'on'); grid(ax, 'minor');
end

function plotCombined3dSurfaces(fig, surfaceCases)
% All panels use one log(W_total) color scale for quantitative comparison.
surfaceGrids = cell(1, numel(surfaceCases));
zMin = inf;
zMax = -inf;
for k = 1:numel(surfaceCases)
    [X, Y, Z] = surfaceGrid(surfaceCases(k).surface);
    surfaceGrids{k} = struct('X', X, 'Y', Y, 'Z', Z);
    zMin = min(zMin, min(Z, [], 'all'));
    zMax = max(zMax, max(Z, [], 'all'));
end

layout = tiledlayout(fig, 2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
axesList = gobjects(1, numel(surfaceCases));
markerLift = 0.75;
for k = 1:numel(surfaceCases)
    c = surfaceCases(k);
    g = surfaceGrids{k};
    ax = nexttile(layout, k);
    axesList(k) = ax;
    surf(ax, g.X, g.Y, g.Z, g.Z, 'EdgeColor', 'none', 'FaceAlpha', 0.96);
    hold(ax, 'on');
    clim(ax, [zMin zMax]);
    zlim(ax, [zMin zMax + markerLift]);
    view(ax, 135, 28);
    addSurfaceLidtMarker(ax, g, c, zMin, markerLift);
    xlabel(ax, 'log_{10}(I_0) [W/cm^2]');
    ylabel(ax, 'log_{10}(n_e) [cm^{-3}]');
    zlabel(ax, 'log_{10}(W_{total}) [cm^{-3} fs^{-1}]');
    title(ax, sprintf('%s %s', c.material, c.region), ...
        'Color', materialColor(c.material), 'FontWeight', 'bold');
    grid(ax, 'on');
end
colormap(fig, jet(256));
cb = colorbar(axesList(end));
cb.Layout.Tile = 'east';
cb.Label.String = 'log_{10}(W_{total}) [cm^{-3} fs^{-1}]';
end

function addSurfaceLidtMarker(ax, gridData, surfaceCase, zMin, markerLift)
% Mark the model-predicted density at the input LIDT and project the point
% to the three coordinate directions with subtle dotted guide lines.
hold(ax, 'on');
xMark = log10(surfaceCase.markerI);
yMark = log10(surfaceCase.markerNe_cm3);
xMin = min(gridData.X, [], 'all');
yMin = min(gridData.Y, [], 'all');
xMax = max(gridData.X, [], 'all');
yMax = max(gridData.Y, [], 'all');
if xMark < xMin || xMark > xMax || yMark < yMin || yMark > yMax
    return;
end
zMark = interp2(gridData.X, gridData.Y, gridData.Z, xMark, yMark, 'linear');
if ~isfinite(zMark)
    return;
end
zDisplay = zMark + markerLift;
guideColor = [0.15 0.15 0.15];
plot3(ax, [xMark xMark], [yMark yMark], [zMin zDisplay], ':', ...
    'Color', guideColor, 'LineWidth', 1.2, 'HandleVisibility', 'off');
plot3(ax, [xMin xMark], [yMark yMark], [zMin zMin], ':', ...
    'Color', guideColor, 'LineWidth', 1.2, 'HandleVisibility', 'off');
plot3(ax, [xMark xMark], [yMin yMark], [zMin zMin], ':', ...
    'Color', guideColor, 'LineWidth', 1.2, 'HandleVisibility', 'off');
plot3(ax, xMark, yMark, zDisplay, 'wx', 'MarkerSize', 14, ...
    'LineWidth', 3.4, 'HandleVisibility', 'off');
plot3(ax, xMark, yMark, zDisplay, 'kx', 'MarkerSize', 10, ...
    'LineWidth', 2.2, 'HandleVisibility', 'off');
end

function [X, Y, Z] = surfaceGrid(T)
T = sortrows(T, {'density_index', 'intensity_index'});
nDensity = max(T.density_index) + 1;
nIntensity = max(T.intensity_index) + 1;
assert(height(T) == nDensity * nIntensity, 'Incomplete 3D surface grid.');
X = reshape(T.log10_I_grid_wcm2, nIntensity, nDensity)';
Y = reshape(T.log10_ne_grid_cm3, nIntensity, nDensity)';
Z = reshape(T.log10_Wtotal_grid_cm3_fs, nIntensity, nDensity)';
end

function plotCombinedHeatmaps(fig, surfaceCases)
% Two-dimensional counterpart to the 3D surfaces.  The x/y axes are only
% labelled once on the outside of the tiled figure.  Gamma and LIDT line
% styles are explained in one shared legend rather than repeated in panels.
surfaceGrids = cell(1, numel(surfaceCases));
zMin = inf;
zMax = -inf;
for k = 1:numel(surfaceCases)
    [X, Y, Z] = surfaceGrid(surfaceCases(k).surface);
    surfaceGrids{k} = struct('X', X, 'Y', Y, 'Z', Z);
    zMin = min(zMin, min(Z, [], 'all'));
    zMax = max(zMax, max(Z, [], 'all'));
end

layout = tiledlayout(fig, 2, 4, 'TileSpacing', 'compact', 'Padding', 'compact');
axesList = gobjects(1, numel(surfaceCases));
for k = 1:numel(surfaceCases)
    c = surfaceCases(k);
    g = surfaceGrids{k};
    ax = nexttile(layout, k);
    axesList(k) = ax;
    imagesc(ax, g.X(1, :), g.Y(:, 1), g.Z);
set(ax, 'YDir', 'normal', 'FontSize', 16, 'LineWidth', 1.0);
    clim(ax, [zMin zMax]);
    xlim(ax, [min(g.X, [], 'all') max(g.X, [], 'all')]);
    ylim(ax, [min(g.Y, [], 'all') max(g.Y, [], 'all')]);
    hold(ax, 'on');
    addHeatmapReferenceLines(ax, c);
    title(ax, sprintf('%s %s', c.material, c.region), ...
    'Color', materialColor(c.material), 'FontWeight', 'bold', 'FontSize', 16);
    grid(ax, 'off');
end
xlabel(layout, 'log_{10}(I) [W/cm^2]', 'FontSize', 16);
ylabel(layout, 'log_{10}(n_e) [cm^{-3}]', 'FontSize', 16);

% Use invisible reference handles so the legend describes the line styles
% without adding a duplicate line to any heatmap panel.
hGamma = plot(axesList(1), nan, nan, ':', 'Color', [0 0 0], 'LineWidth', 1.8);
hLidt = plot(axesList(1), nan, nan, '--', 'Color', [0.15 0.15 0.15], 'LineWidth', 1.8);
lgd = legend(axesList(1), [hGamma hLidt], {'\gamma = 1', 'LIDT'}, ...
    'Box', 'off', 'Orientation', 'horizontal', 'FontSize', 16);
lgd.Layout.Tile = 'south';

colormap(fig, turbo(1024));
cb = colorbar(axesList(end));
cb.Layout.Tile = 'east';
cb.FontSize = 16;
cb.Label.String = 'log_{10}(W_{total}) [cm^{-3} fs^{-1}]';
cb.Label.FontSize = 16;
end

function addHeatmapReferenceLines(ax, surfaceCase)
% Overlay gamma = 1 and LIDT/reference-intensity lines on a log-intensity map.
% A white underlay keeps both line styles visible over every colormap color.
xGamma = log10(surfaceCase.gammaOneI);
xMarker = log10(surfaceCase.markerI);

if xGamma >= ax.XLim(1) && xGamma <= ax.XLim(2)
    drawOutlinedXline(ax, xGamma, ':', [0 0 0]);
end
if xMarker >= ax.XLim(1) && xMarker <= ax.XLim(2)
    drawOutlinedXline(ax, xMarker, '--', [0.15 0.15 0.15]);
end
end

function drawOutlinedXline(ax, xValue, lineStyle, lineColor)
% Draw a high-contrast vertical reference line; the shared legend labels it.
xline(ax, xValue, '-', 'Color', [1 1 1], 'LineWidth', 4.0, ...
    'HandleVisibility', 'off');
xline(ax, xValue, lineStyle, 'Color', lineColor, 'LineWidth', 1.8, ...
    'HandleVisibility', 'off');
end

function color = materialColor(material)
switch string(material)
    case "ZnSe", color = [0.0000 0.4470 0.7410];
    case "ZnS",  color = [0.8500 0.3250 0.0980];
    case "BaF2", color = [0.4660 0.6740 0.1880];
    case "NaCl", color = [0.4940 0.1840 0.5560];
    otherwise,    color = [0 0 0];
end
end

function T = addMaterialGamma(T)
% Add the Keldysh parameter evaluated using each row's own material values.
required = ["I_wcm2", "wavelength_um", "n0", "Eg_eV", "mred_over_me"];
assertRequiredColumns(T, required, "material gamma inputs");

C0 = 299792458.0;
EPS0 = 8.8541878188e-12;
E_CHARGE = 1.602176634e-19;
ME0 = 9.1093837139e-31;
omega = 2 * pi * C0 ./ (T.wavelength_um * 1e-6);
Eg_J = T.Eg_eV * E_CHARGE;
mred_kg = T.mred_over_me * ME0;
I_wm2 = T.I_wcm2 * 1e4;

% Match the Python model convention I = (1/2)c*n*eps0*E^2.
T.gamma_material = (omega / E_CHARGE) .* sqrt( ...
    (mred_kg .* C0 .* T.n0 .* EPS0 .* Eg_J) ./ (2 * I_wm2));
end

function limits = combinedLogLimits(caseList, dataKind)
values = [];
for k = 1:numel(caseList)
    if strcmp(dataKind, 'total')
        values = [values; caseList(k).total.Wtotal_peak_cm3_fs]; %#ok<AGROW>
    else
        values = [values; caseList(k).component.Wtotal_peak_cm3_fs]; %#ok<AGROW>
    end
end
limits = logPaddedLimits(values);
end

function limits = logPaddedLimits(values)
values = values(isfinite(values) & values > 0);
logMin = log10(min(values)); logMax = log10(max(values));
margin = max(0.05 * (logMax - logMin), 0.05);
limits = 10.^([logMin - margin, logMax + margin]);
end

function intensity = gammaToIntensity(gamma, intensityGrid, targetGamma)
[g, order] = sort(gamma(:));
i = intensityGrid(order);
intensity = 10.^interp1(log10(g), log10(i), log10(targetGamma), 'linear', 'extrap');
end

function r = sortedCaseRows(T, shortName)
r = T(T.short == string(shortName), :);
assert(~isempty(r), 'No data found for %s.', shortName);
r = sortrows(r, 'point_index');
end

function assertRequiredColumns(T, names, label)
missing = names(~ismember(names, string(T.Properties.VariableNames)));
assert(isempty(missing), '%s is missing column(s): %s', label, strjoin(missing, ', '));
end

function fig = newFigure(name, superTitle)
fig = figure('Name', name, 'Color', 'w', 'Units', 'pixels', ...
    'Position', [70 80 1450 740]);
sgtitle(fig, superTitle, 'FontWeight', 'bold', 'FontSize', 16);
end

function fig = newSurfaceFigure(name, superTitle)
fig = figure('Name', name, 'Color', 'w', 'Units', 'pixels', ...
    'Position', [35 35 2200 900]);
sgtitle(fig, superTitle, 'FontWeight', 'bold', 'FontSize', 16);
end

function fig = newHeatmapFigure(name, superTitle)
fig = figure('Name', name, 'Color', 'w', 'Units', 'pixels', ...
    'Position', [35 35 2200 1050]);
sgtitle(fig, superTitle, 'FontWeight', 'bold', 'FontSize', 16);
end

function saveFigurePair(outputDir, baseName)
% Save a presentation PNG and an editable MATLAB figure file.
fig = gcf;
drawnow;
exportgraphics(fig, fullfile(outputDir, baseName + ".png"), 'Resolution', 220);
savefig(fig, fullfile(outputDir, baseName + ".fig"));
end

====================================================================================================
FILE: Gamaly\Gamaly_Fluence_Threshold.m
====================================================================================================

% GAMALY_FLUENCE_THRESHOLD
% Standalone MATLAB version of the Gamaly fluence-threshold comparison.
% Computes F_th = [3*n_a*lambda/(16*pi)]*(epsilon_b + E_g), reports the
% configured cases, and saves all material wavelength curves on one plot.

clear; clc; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

AVOGADRO = 6.02214076e23;       % mol^-1
E_CHARGE = 1.602176634e-19;    % J/eV

materials = struct( ...
    'name', {"ZnSe", "ZnS", "BaF2", "NaCl"}, ...
    'molar_mass_kg_mol', {0.14434, 0.09744, 0.175323806, 0.058443}, ...
    'atoms_per_formula_unit', {2, 2, 3, 2}, ...
    'mass_density_kg_m3', {5270.0, 4090.0, 4890.0, 2165.0}, ...
    'binding_energy_ev_per_atom', {2.755, 3.55, 6.013333333333334, 3.2}, ...
    'bandgap_ev', {2.7, 3.6, 10.6, 8.5}, ...
    'color', {[0.0000 0.4470 0.7410], [0.8500 0.3250 0.0980], ...
              [0.4660 0.6740 0.1880], [0.4940 0.1840 0.5560]});

% F0 is the case-input fluence in J/cm^2. BaF2 and NaCl LWIR values are the
% user-supplied LIDT fluences at 9.2 um with 2-ps pulses. Pulse duration is
% metadata only: it does not enter the Gamaly fluence formula.
cases = struct( ...
    'short', {"ZnSe_NIR", "ZnS_NIR", "ZnSe_LWIR", "ZnS_LWIR", ...
              "BaF2_NIR", "NaCl_NIR", "BaF2_LWIR", "NaCl_LWIR"}, ...
    'material', {"ZnSe", "ZnS", "ZnSe", "ZnS", "BaF2", "NaCl", ...
                 "BaF2", "NaCl"}, ...
    'region', {"NIR", "NIR", "LWIR", "LWIR", "NIR", "NIR", "LWIR", "LWIR"}, ...
    'wavelength_um', {0.8, 0.8, 9.2, 9.2, 0.8, 0.8, 9.2, 9.2}, ...
    'F0_jcm2', {0.15, 0.170, 0.83, 1.19, 0.9441088, 0.3922889852754974, ...
                2.62, 4.57});

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

====================================================================================================
FILE: Gamaly\Gamaly_Fluence_Threshold.py
====================================================================================================

"""Standalone fluence-threshold comparison for ZnSe, ZnS, BaF2, and NaCl.

The model is evaluated in SI units:

    F_th = [3 n_a lambda / (16 pi)] (epsilon_b + E_g)

where n_a is the total atomic number density (m^-3), lambda is the vacuum
wavelength (m), and epsilon_b and E_g are energies in joules.  F_th is
reported in J/m^2 and J/cm^2, together with the dimensionless ratio F0/F_th.

This file is intentionally independent of the Keldysh PI/II model. It uses
only the case-input fluence and the threshold-fluence model inputs. The LWIR
cases use lambda = 9.2 um and the user-supplied 2 ps LIDT fluences where
available. Pulse duration is retained as case metadata only: it does not
enter the Gamaly fluence formula.
"""

from __future__ import annotations

from math import pi
from pathlib import Path
from typing import Any, Dict, Iterable, List


AVOGADRO = 6.02214076e23  # mol^-1
E_CHARGE = 1.602176634e-19  # J/eV

# Keep the material colors consistent with the Keldysh comparison figures.
MATERIAL_COLORS = {
    "ZnSe": "#0072BD",
    "ZnS": "#D95319",
    "BaF2": "#77AC30",
    "NaCl": "#7E2F8E",
}

# NIR uses an eight-ray asterisk (米字星); LWIR uses a solid five-point star.
NIR_MARKER = (8, 2, 0)
LWIR_MARKER = (5, 1, 0)

MaterialDict = Dict[str, Any]
CaseDict = Dict[str, Any]


# Enter energies on a per-atom basis.  Density is in kg/m^3 and molar mass is
# in kg/mol.  ``atoms_per_formula_unit`` converts formula-unit density to the
# total atomic number density required by the threshold model.
MATERIALS: Dict[str, MaterialDict] = {
    "ZnSe": {
        "molar_mass_kg_mol": 0.14434,
        "atoms_per_formula_unit": 2,
        "mass_density_kg_m3": 5270.0,
        "binding_energy_ev_per_atom": 2.755,
        "bandgap_ev": 2.7,
        "input_status": "Inputs confirmed in Threshold_Fluence_Parameter.docx.",
    },
    "ZnS": {
        "molar_mass_kg_mol": 0.09744,
        "atoms_per_formula_unit": 2,
        "mass_density_kg_m3": 4090.0,
        "binding_energy_ev_per_atom": 3.55,
        "bandgap_ev": 3.6,
        "input_status": "Inputs confirmed in Threshold_Fluence_Parameter.docx.",
    },
    "BaF2": {
        "molar_mass_kg_mol": 0.175323806,
        "atoms_per_formula_unit": 3,
        "mass_density_kg_m3": 4890.0,
        "binding_energy_ev_per_atom": 6.013333333333334,
        "bandgap_ev": 10.6,
        "input_status": (
            "Binding energy = 18.04 eV per BaF2 formula unit / 3 atoms."
        ),
    },
    "NaCl": {
        "molar_mass_kg_mol": 0.058443,
        "atoms_per_formula_unit": 2,
        "mass_density_kg_m3": 2165.0,
        "binding_energy_ev_per_atom": 3.2,
        "bandgap_ev": 8.5,
        "input_status": (
            "Eg = 8.5 eV from NaCl_Keldysh_Parameter.docx; cohesive/binding "
            "energy = 3.2 eV/atom, as specified in "
            "Gamaly_Threshold_Fluence_Parameter.docx."
        ),
    },
}


# F0 values are case-input fluences in J/cm^2. Do not interpret every F0
# value as a directly measured damage threshold. The BaF2 and NaCl LWIR
# entries below are the user-supplied LIDT fluences at 9.2 um, 2 ps.
CASES: List[CaseDict] = [
    {"short": "ZnSe_NIR", "material": "ZnSe", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.150},
    {"short": "ZnS_NIR", "material": "ZnS", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.170},
    {"short": "ZnSe_LWIR", "material": "ZnSe", "region": "LWIR", "wavelength_um": 9.2, "F0_jcm2": 0.83},
    {"short": "ZnS_LWIR", "material": "ZnS", "region": "LWIR", "wavelength_um": 9.2, "F0_jcm2": 1.19},
    {"short": "BaF2_NIR", "material": "BaF2", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.9441088},
    {"short": "NaCl_NIR", "material": "NaCl", "region": "NIR", "wavelength_um": 0.8, "F0_jcm2": 0.3922889852754974},
    {
        "short": "BaF2_LWIR",
        "material": "BaF2",
        "region": "LWIR",
        "wavelength_um": 9.2,
        "pulse_duration_ps": 2.0,
        "F0_jcm2": 2.62,
        "input_status": "User-supplied LWIR LIDT fluence: 9.2 um, 2 ps.",
    },
    {
        "short": "NaCl_LWIR",
        "material": "NaCl",
        "region": "LWIR",
        "wavelength_um": 9.2,
        "pulse_duration_ps": 2.0,
        "F0_jcm2": 4.57,
        "input_status": "User-supplied LWIR LIDT fluence: 9.2 um, 2 ps.",
    },
]


def total_atomic_density_m3(material: MaterialDict) -> float:
    """Return total atomic density n_a from density and formula composition."""

    density = material["mass_density_kg_m3"]
    if density is None:
        raise ValueError("mass_density_kg_m3 is not set.")

    molar_mass = float(material["molar_mass_kg_mol"])
    atoms_per_formula_unit = int(material["atoms_per_formula_unit"])
    if float(density) <= 0.0 or molar_mass <= 0.0 or atoms_per_formula_unit <= 0:
        raise ValueError("Density, molar mass, and atom count must be positive.")

    return float(atoms_per_formula_unit * float(density) * AVOGADRO / molar_mass)


def gamaly_threshold_fluence_jcm2(material: MaterialDict, wavelength_um: float) -> float:
    """Return the Gamaly threshold fluence F_th in J/cm^2 at one wavelength."""

    wavelength_m = float(wavelength_um) * 1.0e-6
    if wavelength_m <= 0.0:
        raise ValueError("wavelength_um must be positive.")
    energy_j = (
        float(material["binding_energy_ev_per_atom"])
        + float(material["bandgap_ev"])
    ) * E_CHARGE
    Fth_jm2 = 3.0 * total_atomic_density_m3(material) * wavelength_m * energy_j / (
        16.0 * pi
    )
    return Fth_jm2 * 1.0e-4


def calculate_case(case: CaseDict) -> Dict[str, Any]:
    """Calculate F_th and F0/F_th for one material and laser condition."""

    material = MATERIALS[case["material"]]
    missing = [
        key
        for key in ("mass_density_kg_m3", "binding_energy_ev_per_atom")
        if material[key] is None
    ]
    result: Dict[str, Any] = dict(case)
    result["missing_inputs"] = missing
    if missing:
        return result

    n_a_m3 = total_atomic_density_m3(material)
    Fth_jcm2 = gamaly_threshold_fluence_jcm2(
        material, float(case["wavelength_um"])
    )
    Fth_jm2 = Fth_jcm2 * 1.0e4
    F0_jcm2 = float(case["F0_jcm2"])

    result.update(
        {
            "n_a_m3": n_a_m3,
            "Fth_jm2": Fth_jm2,
            "Fth_jcm2": Fth_jcm2,
            "F0_over_Fth": F0_jcm2 / Fth_jcm2,
        }
    )
    return result


def calculate_all(cases: Iterable[CaseDict] = CASES) -> List[Dict[str, Any]]:
    """Calculate all configured material/laser cases."""

    return [calculate_case(case) for case in cases]


def print_report(results: Iterable[Dict[str, Any]]) -> None:
    """Print a compact, unit-labeled threshold-fluence report."""

    print("Fluence Threshold: F_th = [3 n_a lambda/(16 pi)] (epsilon_b + E_g)\n")
    for result in results:
        label = f"{result['short']} ({result['material']}, {result['wavelength_um']:g} um)"
        if result["missing_inputs"]:
            missing = ", ".join(result["missing_inputs"])
            print(f"{label}: not calculated; set {missing}.")
            continue

        print(label)
        print(f"  n_a       = {result['n_a_m3']:.4e} m^-3")
        print(f"  F_th      = {result['Fth_jm2']:.4e} J/m^2 = {result['Fth_jcm2']:.4f} J/cm^2")
        print(f"  F0/F_th   = {result['F0_over_Fth']:.4f}\n")


def plot_threshold_vs_wavelength(
    results: Iterable[Dict[str, Any]], output_path: Path | None = None
) -> Path:
    """Save all wavelength-dependent Gamaly thresholds on one set of axes.

    Each solid curve is F_th(lambda).  Stars are the configured case-input
    fluences, plotted at their respective wavelengths; they are not additional
    threshold measurements.
    """

    try:
        import matplotlib.pyplot as plt
    except ModuleNotFoundError as exc:
        raise RuntimeError(
            "Plotting requires matplotlib. Install it in the Python environment "
            "used to run this script."
        ) from exc

    results = list(results)
    wavelength_grid = [0.7 + 10.3 * index / 400 for index in range(401)]
    material_order = ["ZnSe", "ZnS", "BaF2", "NaCl"]
    fig, ax = plt.subplots(figsize=(9.0, 6.2))

    for material_name in material_order:
        material = MATERIALS[material_name]
        color = MATERIAL_COLORS[material_name]
        thresholds = [
            gamaly_threshold_fluence_jcm2(material, wavelength_um)
            for wavelength_um in wavelength_grid
        ]
        ax.plot(
            wavelength_grid,
            thresholds,
            color=color,
            linewidth=2.5,
            label=f"{material_name} Gamaly threshold",
        )

        for result in results:
            if result["material"] != material_name or result["missing_inputs"]:
                continue
            is_nir = result["region"] == "NIR"
            marker = NIR_MARKER if is_nir else LWIR_MARKER
            ax.plot(
                result["wavelength_um"],
                result["F0_jcm2"],
                marker=marker,
                markersize=11,
                color=color,
                markeredgecolor=color,
                markeredgewidth=0.6,
                markerfacecolor="none" if is_nir else color,
                linestyle="None",
            )

    ax.plot(
        [], [], marker=NIR_MARKER, markersize=11, color="black", markeredgecolor="black",
        markerfacecolor="none", linestyle="None", label="NIR case-input fluence, F0",
    )
    ax.plot(
        [], [], marker=LWIR_MARKER, markersize=11, color="black", markeredgecolor="black",
        markerfacecolor="black", linestyle="None", label="LWIR case-input fluence, F0",
    )
    ax.set_xlim(0.7, 11.0)
    ax.set_ylim(1.0e-2, 1.0e1)
    ax.set_yscale("log")
    ax.set_xlabel("Wavelength λ (µm)")
    ax.set_ylabel("Fluence (J/cm²)")
    ax.set_title("Gamaly fluence threshold versus wavelength", fontweight="bold")
    ax.legend(frameon=False, loc="upper left")
    ax.grid(which="major", alpha=0.35)
    ax.grid(which="minor", alpha=0.18, linestyle=":")
    fig.text(
        0.5,
        0.01,
        "BaF₂ and NaCl LWIR stars use the supplied 9.2-µm, 2-ps LIDT fluences.",
        ha="center",
        va="bottom",
        fontsize=8,
    )
    fig.tight_layout(rect=(0.0, 0.05, 1.0, 1.0))

    if output_path is None:
        output_path = Path(__file__).resolve().parent / "figures_Gamaly_Fluence_Threshold" / (
            "Gamaly_threshold_vs_wavelength_all_materials.png"
        )
    output_path.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(output_path, dpi=300, bbox_inches="tight")
    plt.close(fig)
    return output_path


if __name__ == "__main__":
    all_results = calculate_all()
    print_report(all_results)
    wavelength_figure_path = plot_threshold_vs_wavelength(all_results)
    print(f"Saved wavelength comparison: {wavelength_figure_path}")

====================================================================================================
FILE: Keldysh\Keldsyh_II_BaF2.py
====================================================================================================

# BaF2-only Keldysh + avalanche-ionization workflow.
# Standalone BaF2 Keldysh + avalanche-ionization workflow.

# %%
# Cell 0
"""
Reconciled Keldysh + avalanche ionization model for BaF2.

The script evaluates
--------------------
1. Full Keldysh photoionization rate, W_PI.
2. Avalanche/impact ionization using a Drude absorption cross section,

       W_av(I, n_e) = [sigma(I, n_e) I / E_g] n_e,

   with

       sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2),

       tau_C = 16 pi eps0^2 sqrt[m_r (0.1 E_g)^3]
               / [sqrt(2) e^4 n_e].

3. Time-dependent carrier-density growth,

       dn_e/dt = W_PI(t) + W_av(I(t), n_e(t)).

Model assumptions
-----------------
* Recombination and trapping are neglected.
* Carrier depletion and saturation are neglected.
* Propagation, self-focusing, and laser-induced changes in optical constants
  are neglected.
* The same linear refractive index is used in the Keldysh and Drude terms.
* The temporal pulse is Gaussian and centered at t = 0.
* The integration window is from -3 tau to +3 tau, where tau is the
  intensity FWHM duration.

Units
-----
* Internal calculations: SI units.
* Input fluence: J/cm^2.
* Input irradiance for scaling plots: W/cm^2.
* Wavelength: micrometers.
* Pulse duration: femtoseconds.
* Summary densities: cm^-3.
* Final rate plot: cm^-3 fs^-1.

Default workflow
----------------
The default ``--mode all`` execution produces BaF2 NIR (0.8 um, 100 fs)
and LWIR (9.2 um, 2 ps) results using their supplied LIDT fluences.
"""


from __future__ import annotations

import argparse
import csv
import json
import os
import pickle
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple, Union

# CODEX MODIFICATION START: shared colormap normalization for 3D colorbar
from matplotlib import cm, colors
# CODEX MODIFICATION END: shared colormap normalization for 3D colorbar
import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import dawsn, ellipe, ellipk

try:
    import pandas as pd
except ImportError:
    pd = None

try:
    from IPython.display import display as ipython_display
except ImportError:
    ipython_display = None


# ============================================================
# Constants
# ============================================================

# CODEX MODIFICATION START: constants from BaF2 verified reference / CODATA
C0 = 299792458.0
EPS0 = 8.8541878188e-12
E_CHARGE = 1.602176634e-19
HBAR = 1.054571817e-34
ME0 = 9.1093837139e-31
AVOGADRO = 6.02214076e23
# CODEX MODIFICATION END: constants from BaF2 verified reference / CODATA

CM3_PER_M3 = 1.0e-6
WCM2_PER_WM2 = 1.0e-4
WM2_PER_WCM2 = 1.0e4
RATE_CM3_FS_PER_M3_S = 1.0e-21

CaseDict = Dict[str, Any]
ArrayLike = Union[np.ndarray, float]

# CODEX MODIFICATION START: optional deferred Matplotlib display
DEFER_FIGURE_SHOW = False
# CODEX MODIFICATION END: optional deferred Matplotlib display

# CODEX MODIFICATION START: automatic editable figure exports
# Every saved PNG is accompanied by a Matplotlib-editable .mplfig.pkl file.
SAVE_EDITABLE_FIGURES = True
# CODEX MODIFICATION END: automatic editable figure exports

# CODEX MODIFICATION START: optional open saved image preview
OPEN_SAVED_FIGURES = False
# CODEX MODIFICATION END: optional open saved image preview


# ============================================================
# Material properties
# ============================================================

# CODEX MODIFICATION START: explicit BaF2 input block used by this script
BAF2_INPUT: Dict[str, Any] = {
    "reference_file": "BaF2_Keldysh_Parameter.docx",
    "threshold_fluence_reference_file": "BaF2_Threshold_Fluence_Parameter.docx",
    "material": {
        "name": "BaF2",
        "mat_flag": 1,
        "bandgap_ev": 10.6,
        "mred_over_me": 1.0,
        "parameter_status": (
            "User-confirmed fixed calculation inputs: mred = 1.0 m0 and "
            "Eg = 10.6 eV."
        ),
        "n2_m2_per_w": np.nan,
        "sellmeier": {
            "wavelength_unit": "um",
            "terms": (
                (0.643356, 0.057789),
                (0.506762, 0.10968),
                (3.8261, 46.3864),
            ),
        },
    },
    "threshold_fluence": {
        "model": "F_th = [3*n_a*lambda/(16*pi)]*(epsilon_b + E_g)",
        "mass_density_kg_m3": 4890.0,
        "molar_mass_kg_mol": 0.175323806,
        "binding_energy_ev_per_atom": 6.013333333333334,
        "binding_energy_note": (
            "BaF2 cohesive/binding energy = 18.04 eV per formula unit, "
            "converted to 18.04/3 = 6.0133 eV per atom."
        ),
        "atomic_density_note": (
            "n_a is the total atomic number density: "
            "n_a = 3*rho*N_A/M_BaF2."
        ),
    },
    "cases": [
        {
            "name": r"BaF$_2$, 0.8 $\mu$m",
            "short": "BaF2_NIR",
            "material": "BaF2",
            "region": "NIR",
            "mat_flag": 1,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "pulse_energy_uj": 361.0,
            "beam_diameter_a_um": 226.6,
            "beam_diameter_b_um": 429.7,
            "reference_I0_wcm2": None,
            "F0_jcm2": None,
            "input_note": (
                "The 0.8 um, 100 fs laser condition uses a 361 uJ pulse. "
                "Its elliptical Gaussian-beam peak fluence is calculated as "
                "F = 2E/(pi a b), where a = 113.3 um and b = 214.85 um "
                "are radii derived from the measured diameters."
            ),
        },
        {
            "name": r"BaF$_2$, 9.2 $\mu$m",
            "short": "BaF2_LWIR",
            "material": "BaF2",
            "region": "LWIR",
            "mat_flag": 1,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "reference_I0_wcm2": None,
            "F0_jcm2": 4.57,
            "input_note": (
                "User-supplied LWIR LIDT condition: 9.2 um, 2 ps, "
                "F0 = 4.57 J/cm^2."
            ),
        },
    ],
}
# CODEX MODIFICATION END: explicit BaF2 input block used by this script

# CODEX MODIFICATION START: BaF2-only material parameters
def material_flag1(
    mat_flag: int,
    wavelength_um: float,
) -> Tuple[float, float, float, float, float]:
    """
    Return wavelength-dependent material parameters for BaF2.

    Parameters
    ----------
    mat_flag:
        Material selector. This BaF2-optimized script uses only 1 for BaF2.
    wavelength_um:
        Vacuum wavelength in micrometers.

    Returns
    -------
    n0:
        Linear refractive index.
    n2:
        Nonlinear refractive index in m^2/W. This field is retained for
        compatibility with the original script; it is not specified in the
        BaF2 Keldysh-parameter reference document.
    Eg_J:
        Bandgap energy in joules.
    mred:
        Reduced electron-hole effective mass in kilograms.
    trans:
        Approximate transmission factor, 1 - R.

    Raises
    ------
    ValueError
        If the material flag is not 1, or if the Sellmeier expression
        becomes nonphysical at the requested wavelength.
    """

    lam = float(wavelength_um)
    if lam <= 0.0:
        raise ValueError("wavelength_um must be positive.")

    if mat_flag != 1:
        raise ValueError("mat_flag must be 1 for BaF2.")

    material_input = BAF2_INPUT["material"]
    bandgap_ev = float(material_input["bandgap_ev"])
    mred = float(material_input["mred_over_me"]) * ME0
    n_squared = 1.0
    for coefficient, resonance_um in material_input["sellmeier"]["terms"]:
        n_squared += coefficient * lam**2 / (lam**2 - resonance_um**2)

    n2 = float(material_input["n2_m2_per_w"])

    if not np.isfinite(n_squared) or n_squared <= 0.0:
        raise ValueError(
            f"Nonphysical Sellmeier result n^2={n_squared!r} at {lam} um."
        )

    n0 = np.sqrt(n_squared)
    reflectance = ((n0 - 1.0) / (n0 + 1.0)) ** 2
    Eg_J = bandgap_ev * E_CHARGE
    trans = 1.0 - reflectance

    return float(n0), float(n2), float(Eg_J), float(mred), float(trans)
# CODEX MODIFICATION END: BaF2-only material parameters


# ============================================================
# Case definitions
# ============================================================

def baf2_total_atomic_density_m3(
    mass_density_kg_m3: float,
    molar_mass_kg_mol: float,
) -> float:
    """Return the total Ba and F atomic number density of BaF2 in m^-3."""

    density = float(mass_density_kg_m3)
    molar_mass = float(molar_mass_kg_mol)
    if density <= 0.0:
        raise ValueError("mass_density_kg_m3 must be positive.")
    if molar_mass <= 0.0:
        raise ValueError("molar_mass_kg_mol must be positive.")

    # One BaF2 formula unit contains three atoms (one Ba and two F).
    return float(3.0 * density * AVOGADRO / molar_mass)


def threshold_fluence_comparison(case: CaseDict) -> Dict[str, float]:
    """Evaluate the standalone BaF2 threshold-fluence comparison.

    The model is

        F_th = [3 n_a lambda / (16 pi)] (epsilon_b + E_g).

    ``n_a`` is the total atomic density in m^-3, ``lambda`` is in m, and
    both energies are in J.  The calculation is intentionally independent of
    the Keldysh PI/II rates and of the pulse duration.
    """

    threshold_input = BAF2_INPUT["threshold_fluence"]
    mass_density_kg_m3 = float(threshold_input["mass_density_kg_m3"])
    molar_mass_kg_mol = float(threshold_input["molar_mass_kg_mol"])
    binding_energy_ev_per_atom = float(
        threshold_input["binding_energy_ev_per_atom"]
    )
    wavelength_um = float(case["wavelength_um"])
    F0_jcm2 = float(case["F0_jcm2"])

    if wavelength_um <= 0.0:
        raise ValueError("wavelength_um must be positive.")
    if binding_energy_ev_per_atom < 0.0:
        raise ValueError("binding_energy_ev_per_atom must be nonnegative.")
    if F0_jcm2 < 0.0:
        raise ValueError("F0_jcm2 must be nonnegative.")

    atomic_density_m3 = baf2_total_atomic_density_m3(
        mass_density_kg_m3=mass_density_kg_m3,
        molar_mass_kg_mol=molar_mass_kg_mol,
    )
    wavelength_m = wavelength_um * 1.0e-6
    Eg_ev = float(BAF2_INPUT["material"]["bandgap_ev"])
    threshold_fluence_jm2 = (
        3.0
        * atomic_density_m3
        * wavelength_m
        * (binding_energy_ev_per_atom + Eg_ev)
        * E_CHARGE
        / (16.0 * np.pi)
    )
    threshold_fluence_jcm2 = threshold_fluence_jm2 * 1.0e-4

    return {
        "atomic_density_m3": float(atomic_density_m3),
        "binding_energy_ev_per_atom": float(binding_energy_ev_per_atom),
        "threshold_fluence_jm2": float(threshold_fluence_jm2),
        "threshold_fluence_jcm2": float(threshold_fluence_jcm2),
        "F0_jcm2": float(F0_jcm2),
        "F0_over_Fth": float(F0_jcm2 / threshold_fluence_jcm2),
    }


# CODEX MODIFICATION START: BaF2-only case definitions
def get_cases() -> List[CaseDict]:
    """
    Return the currently enabled BaF2 NIR and LWIR cases.

    Returns
    -------
    list of dict
        Two BaF2 material/laser case dictionaries.
    """

    cases: List[CaseDict] = []
    for case_input in BAF2_INPUT["cases"]:
        case = dict(case_input)
        if case.get("pulse_energy_uj") is not None:
            case["F0_jcm2"] = elliptical_gaussian_peak_fluence_jcm2(
                pulse_energy_uj=float(case["pulse_energy_uj"]),
                beam_diameter_a_um=float(case["beam_diameter_a_um"]),
                beam_diameter_b_um=float(case["beam_diameter_b_um"]),
            )
        if case.get("F0_jcm2") is not None:
            case["threshold_fluence"] = threshold_fluence_comparison(case)
        cases.append(case)
    return cases
# CODEX MODIFICATION END: BaF2-only case definitions


# ============================================================
# Laser pulse conversion
# ============================================================

def elliptical_gaussian_peak_fluence_jcm2(
    pulse_energy_uj: float,
    beam_diameter_a_um: float,
    beam_diameter_b_um: float,
) -> float:
    """Return peak fluence for an elliptical Gaussian beam in J/cm^2.

    The measured diameters are converted to radii before evaluating

        F = 2 E / (pi a b),

    where ``a`` and ``b`` are the supplied beam radii. This is the on-axis
    (peak) spatial fluence, which is then converted to peak temporal
    intensity by :func:`peak_intensity_from_fluence_wm2`.
    """

    energy_j = float(pulse_energy_uj) * 1.0e-6
    radius_a_cm = 0.5 * float(beam_diameter_a_um) * 1.0e-4
    radius_b_cm = 0.5 * float(beam_diameter_b_um) * 1.0e-4

    if energy_j <= 0.0:
        raise ValueError("pulse_energy_uj must be positive.")
    if radius_a_cm <= 0.0 or radius_b_cm <= 0.0:
        raise ValueError("Both beam diameters must be positive.")

    return float(2.0 * energy_j / (np.pi * radius_a_cm * radius_b_cm))


def peak_intensity_from_fluence_wm2(F0_jcm2: float, tau_fs: float) -> float:
    """
    Convert peak fluence to peak intensity for a Gaussian temporal pulse.

    For a Gaussian intensity envelope with FWHM duration tau,

        I0 = (2 F0 / tau) sqrt[ln(2)/pi].

    Parameters
    ----------
    F0_jcm2:
        Peak fluence in J/cm^2.
    tau_fs:
        Intensity FWHM duration in femtoseconds.

    Returns
    -------
    float
        Peak intensity in W/m^2.
    """

    F0_jm2 = float(F0_jcm2) * 1.0e4
    tau_s = float(tau_fs) * 1.0e-15

    if F0_jm2 < 0.0:
        raise ValueError("Fluence must be nonnegative.")
    if tau_s <= 0.0:
        raise ValueError("Pulse duration must be positive.")

    return float((2.0 * F0_jm2 / tau_s) * np.sqrt(np.log(2.0) / np.pi))


def gaussian_intensity_time(t_s: float, I0_wm2: float, tau_s: float) -> float:
    """
    Evaluate a Gaussian temporal intensity profile.

    The profile is

        I(t) = I0 exp[-4 ln(2) (t/tau)^2],

    where tau is the intensity FWHM duration.

    Parameters
    ----------
    t_s:
        Time in seconds.
    I0_wm2:
        Peak intensity in W/m^2.
    tau_s:
        Intensity FWHM duration in seconds.

    Returns
    -------
    float
        Instantaneous intensity in W/m^2.
    """

    if tau_s <= 0.0:
        raise ValueError("tau_s must be positive.")

    return float(I0_wm2 * np.exp(-4.0 * np.log(2.0) * (t_s / tau_s) ** 2))


# ============================================================
# Keldysh photoionization model
# ============================================================

def qfun_keldysh(
    gamma: np.ndarray,
    x: np.ndarray,
    Kg: np.ndarray,
    Eg: np.ndarray,
    K1: np.ndarray,
    E1: np.ndarray,
    tol: float = 1.0e-3,
    max_terms: int = 10000,
) -> np.ndarray:
    """
    Evaluate the Keldysh Q-function series.

    Parameters
    ----------
    gamma:
        Keldysh parameter array.
    x:
        Effective photon-order argument.
    Kg, Eg, K1, E1:
        Complete elliptic-integral terms appearing in the Keldysh expression.
    tol:
        Absolute change in the partial sum used as the convergence criterion.
    max_terms:
        Maximum number of series terms.

    Returns
    -------
    np.ndarray
        Keldysh Q-function values.
    """

    gamma = np.atleast_1d(np.asarray(gamma, dtype=float))
    x = np.atleast_1d(np.asarray(x, dtype=float))
    Kg = np.atleast_1d(np.asarray(Kg, dtype=float))
    Eg = np.atleast_1d(np.asarray(Eg, dtype=float))
    K1 = np.atleast_1d(np.asarray(K1, dtype=float))
    E1 = np.atleast_1d(np.asarray(E1, dtype=float))

    arrays = [gamma, x, Kg, Eg, K1, E1]
    if len({arr.size for arr in arrays}) != 1:
        raise ValueError("All qfun_keldysh input arrays must have the same size.")

    q_values = np.zeros_like(gamma)

    for i in range(gamma.size):
        values = [gamma[i], x[i], Kg[i], Eg[i], K1[i], E1[i]]
        if not all(np.isfinite(v) for v in values) or K1[i] <= 0.0 or E1[i] <= 0.0:
            continue

        q_prefactor = np.sqrt(np.pi / (2.0 * K1[i]))
        q_sum = 0.0

        for j in range(max_terms):
            old_sum = q_sum
            exponent = -np.pi * (Kg[i] - Eg[i]) * j / E1[i]
            arg_inside = (
                np.pi**2
                * (2.0 * np.floor(x[i] + 1.0) - 2.0 * x[i] + j)
                / (2.0 * K1[i] * E1[i])
            )
            arg_inside = max(float(arg_inside), 0.0)

            with np.errstate(over="ignore", invalid="ignore", under="ignore"):
                term = np.exp(exponent) * dawsn(np.sqrt(arg_inside))

            if not np.isfinite(term):
                term = 0.0

            q_sum += float(term)

            if abs(q_sum - old_sum) <= tol:
                break

        q_values[i] = q_prefactor * q_sum

    return np.nan_to_num(q_values, nan=0.0, posinf=0.0, neginf=0.0)


def keldysh_full_rate_m3_s(
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
    intensity_wm2: ArrayLike,
) -> ArrayLike:
    """
    Evaluate the full Keldysh photoionization rate.

    Parameters
    ----------
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.
    intensity_wm2:
        Scalar or array of laser intensities in W/m^2.

    Returns
    -------
    float or np.ndarray
        Photoionization rate in m^-3 s^-1.
    """

    intensity = np.asarray(intensity_wm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    rate = np.zeros_like(intensity)
    positive = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(positive):
        I = intensity[positive]

        with np.errstate(divide="ignore", invalid="ignore", over="ignore", under="ignore"):
            # I is the cycle-averaged intensity; Keldysh gamma uses the
            # peak electric-field amplitude E0, for which
            # I = (1/2) c n0 eps0 E0^2.
            electric_field = np.sqrt((2.0 * I) / (C0 * n0 * EPS0))
            gamma = (omega / (E_CHARGE * electric_field)) * np.sqrt(mred * delta_J)
            gamma_sq = gamma**2

            gg = gamma_sq / (1.0 + gamma_sq)
            g1 = 1.0 / (1.0 + gamma_sq)

            Kg = ellipk(gg)
            Eg = ellipe(gg)
            K1 = ellipk(g1)
            E1 = ellipe(g1)

            delta_tilde = (
                2.0
                * delta_J
                * np.sqrt(1.0 + gamma_sq)
                * E1
                / (np.pi * gamma)
            )
            x_order = delta_tilde / (HBAR * omega)
            X = np.floor(x_order + 1.0)

            prefactor = (
                2.0
                * omega
                / (9.0 * np.pi)
                * (
                    (np.sqrt(1.0 + gamma_sq) * mred * omega)
                    / (gamma * HBAR)
                )
                ** 1.5
            )

            q_values = qfun_keldysh(gamma, x_order, Kg, Eg, K1, E1)
            exponential = np.exp(-np.pi * X * (Kg - Eg) / E1)
            rate_positive = prefactor * q_values * exponential

        rate[positive] = np.nan_to_num(
            rate_positive,
            nan=0.0,
            posinf=0.0,
            neginf=0.0,
        )

    if scalar_input:
        return float(rate[0])
    return rate


# ============================================================
# Avalanche / impact-ionization model
# ============================================================

def collision_time_s(ne_m3: float, mred: float, delta_J: float) -> float:
    """
    Evaluate the electron collision time used in the Drude model.

    Parameters
    ----------
    ne_m3:
        Conduction-band electron density in m^-3.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.

    Returns
    -------
    float
        Collision time in seconds. Returns infinity at zero density.
    """

    ne = max(float(ne_m3), 0.0)
    if ne <= 0.0:
        return np.inf

    numerator = 16.0 * np.pi * EPS0**2 * np.sqrt(mred * (0.1 * delta_J) ** 3)
    denominator = np.sqrt(2.0) * E_CHARGE**4 * ne
    # CODEX MODIFICATION START: avoid divide-by-zero warning at tiny density
    if denominator <= 0.0 or not np.isfinite(denominator):
        return np.inf
    # CODEX MODIFICATION END: avoid divide-by-zero warning at tiny density
    tau_c = numerator / denominator

    if not np.isfinite(tau_c) or tau_c <= 0.0:
        return np.inf

    return float(tau_c)


def drude_cross_section_m2(
    omega: float,
    mred: float,
    n0: float,
    tau_c_s: float,
) -> float:
    """
    Evaluate the Drude single-photon absorption cross section safely.

    The direct expression is

        sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2).

    To avoid overflow for very large collision times, it is evaluated as

        sigma = [e^2/(c eps0 n0 m_r)] / omega
                * [(omega tau_C)/(1 + (omega tau_C)^2)].

    Parameters
    ----------
    omega:
        Angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    n0:
        Linear refractive index.
    tau_c_s:
        Collision time in seconds.

    Returns
    -------
    float
        Drude absorption cross section in m^2.
    """

    tau_c = float(tau_c_s)

    if (
        not np.isfinite(tau_c)
        or tau_c <= 0.0
        or not np.isfinite(omega)
        or omega <= 0.0
        or mred <= 0.0
        or n0 <= 0.0
    ):
        return 0.0

    prefactor = E_CHARGE**2 / (C0 * EPS0 * n0 * mred)
    x = omega * tau_c

    if not np.isfinite(x) or x <= 0.0:
        return 0.0

    if x > 1.0e100:
        drude_factor = 1.0 / x
    else:
        drude_factor = x / (1.0 + x * x)

    sigma = (prefactor / omega) * drude_factor

    if not np.isfinite(sigma) or sigma < 0.0:
        return 0.0

    return float(sigma)


def avalanche_generation_rate_m3_s(
    intensity_wm2: float,
    ne_m3: float,
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
) -> float:
    """
    Evaluate the avalanche/impact-ionization carrier-generation rate.

    The implemented relation is

        W_av = (sigma I / E_g) n_e.

    Parameters
    ----------
    intensity_wm2:
        Instantaneous laser intensity in W/m^2.
    ne_m3:
        Instantaneous electron density in m^-3.
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.

    Returns
    -------
    float
        Avalanche generation rate in m^-3 s^-1.
    """

    I = max(float(intensity_wm2), 0.0)
    ne = max(float(ne_m3), 0.0)

    if I <= 0.0 or ne <= 0.0 or delta_J <= 0.0:
        return 0.0

    tau_c = collision_time_s(ne, mred, delta_J)
    sigma = drude_cross_section_m2(
        omega=omega,
        mred=mred,
        n0=n0,
        tau_c_s=tau_c,
    )

    if sigma <= 0.0:
        return 0.0

    W_av = (sigma * I / delta_J) * ne

    if not np.isfinite(W_av) or W_av < 0.0:
        return 0.0

    return float(W_av)


# ============================================================
# General helpers
# ============================================================

def positive_for_log(y: np.ndarray, min_value: float = 1.0e-300) -> np.ndarray:
    """
    Replace nonfinite and nonpositive values with NaN for logarithmic plotting.
    """

    y_plot = np.asarray(y, dtype=float).copy()
    y_plot[~np.isfinite(y_plot)] = np.nan
    y_plot[y_plot <= min_value] = np.nan
    return y_plot


# CODEX MODIFICATION START: optional LIDT fluence and reference peak intensity
def case_has_reference_peak_intensity(case: CaseDict) -> bool:
    """Return True when a case has a verified/reference point intensity."""

    return case.get("reference_I0_wcm2") is not None or case.get("F0_jcm2") is not None


def report_case_input_uncertainties(cases: Sequence[CaseDict]) -> None:
    """Report cases whose inputs are incomplete instead of silently assuming them."""

    uncertain_cases = [
        case for case in cases if not case_has_reference_peak_intensity(case)
    ]
    if not uncertain_cases:
        return

    print("\n================ Input uncertainty report ================\n")
    for case in uncertain_cases:
        note = case.get(
            "input_note",
            "No verified reference_I0_wcm2 or measured F0_jcm2 is provided.",
        )
        print(f"{case['short']}: {note}")
        print(
            "  Reference-point density table entries, time-domain Fig. 3, "
            "and reference markers will be skipped for this case."
        )
        print(
            "  Intensity-scan plots and 3D surfaces can still run because "
            "their intensities are explicit plot axes.\n"
        )


def report_threshold_fluence_comparison(cases: Sequence[CaseDict]) -> None:
    """Print the standalone threshold-fluence result for each enabled case."""

    print("\n================ Threshold-fluence comparison ================\n")
    for case in cases:
        comparison = case.get("threshold_fluence")
        if comparison is None:
            print(f"{case['short']}: threshold-fluence inputs are unavailable.")
            continue

        print(f"{case['short']}:")
        print(
            f"  n_a = {comparison['atomic_density_m3']:.4e} m^-3 "
            "(total atomic density)"
        )
        print(
            f"  epsilon_b = {comparison['binding_energy_ev_per_atom']:.4f} eV/atom"
        )
        print(
            f"  F_th = {comparison['threshold_fluence_jm2']:.4e} J/m^2 "
            f"= {comparison['threshold_fluence_jcm2']:.4f} J/cm^2"
        )
        print(
            f"  F0/F_th = {comparison['F0_over_Fth']:.4f} "
            f"(F0 = {comparison['F0_jcm2']:.4f} J/cm^2)\n"
        )


def case_reference_peak_intensity_wcm2(case: CaseDict) -> float:
    """
    Return the peak intensity used for time-domain density calculations.

    BaF2_Keldysh_Parameter_verified_English.docx specifies peak intensity
    directly, not a measured LIDT fluence. If reference_I0_wcm2 is absent,
    fall back to the original fluence-to-peak-intensity conversion.
    """

    reference_I0 = case.get("reference_I0_wcm2")
    if reference_I0 is not None:
        reference_I0 = float(reference_I0)
        if reference_I0 <= 0.0:
            raise ValueError("reference_I0_wcm2 must be positive.")
        return reference_I0

    I_lidt = case_lidt_peak_intensity_wcm2(case)
    if I_lidt is None:
        raise ValueError(
            f"Case {case['short']} must define reference_I0_wcm2 or F0_jcm2."
        )
    return I_lidt


def case_peak_intensity_source(case: CaseDict) -> str:
    """Return a short label describing the peak-intensity input source."""

    if case.get("reference_I0_wcm2") is not None:
        return "reference_I0_wcm2"
    if case.get("F0_jcm2") is not None:
        return "F0_jcm2"
    return "missing"


def case_marker_peak_intensity_wcm2(case: CaseDict) -> Optional[Tuple[float, str]]:
    """Return the intensity marker and label used in scaling plots."""

    I_lidt = case_lidt_peak_intensity_wcm2(case)
    if I_lidt is not None:
        return I_lidt, r"$I_0$ at LIDT"
    if case.get("reference_I0_wcm2") is not None:
        return case_reference_peak_intensity_wcm2(case), r"$I_0$ reference"
    return None


def case_lidt_peak_intensity_wcm2(case: CaseDict) -> Optional[float]:
    """
    Return the Gaussian peak intensity at the measured LIDT in W/cm^2.

    Returns None when the case has no measured LIDT fluence.
    """

    F0_jcm2 = case.get("F0_jcm2")
    if F0_jcm2 is None:
        return None

    return (
        peak_intensity_from_fluence_wm2(
            F0_jcm2=F0_jcm2,
            tau_fs=case["tau_fs"],
        )
        * WCM2_PER_WM2
    )
# CODEX MODIFICATION END: optional LIDT fluence and reference peak intensity


def interpolate_log_y(
    x: np.ndarray,
    y: np.ndarray,
    x0: float,
) -> Optional[float]:
    """
    Interpolate y(x0) in log-log space.

    Returns None when x0 lies outside the valid positive data range.
    """

    x_arr = np.asarray(x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    valid = np.isfinite(x_arr) & np.isfinite(y_arr) & (x_arr > 0.0) & (y_arr > 0.0)

    if np.count_nonzero(valid) < 2:
        return None

    x_valid = x_arr[valid]
    y_valid = y_arr[valid]
    order = np.argsort(x_valid)
    x_valid = x_valid[order]
    y_valid = y_valid[order]

    if x0 < x_valid[0] or x0 > x_valid[-1]:
        return None

    log_y0 = np.interp(
        np.log10(x0),
        np.log10(x_valid),
        np.log10(y_valid),
    )
    return float(10.0**log_y0)


def save_or_show(
    fig: plt.Figure,
    save_dir: Optional[Path],
    filename: str,
    apply_tight_layout: bool = True,
) -> None:
    """
    Apply tight layout and either save or display a Matplotlib figure.
    """

    # CODEX MODIFICATION START: allow manually arranged 3D figures
    if apply_tight_layout:
        # Reserve space for figure-level titles; otherwise long LWIR axis
        # labels can push a suptitle against the top edge of a saved PNG.
        fig.tight_layout(rect=(0.0, 0.0, 1.0, 0.96))
    # CODEX MODIFICATION END: allow manually arranged 3D figures

    if save_dir is not None:
        save_dir.mkdir(parents=True, exist_ok=True)
        output_path = save_dir / filename
        fig.savefig(output_path, dpi=300, bbox_inches="tight")
        print(f"Saved {output_path}")
        # CODEX MODIFICATION START: optional open saved image preview
        if OPEN_SAVED_FIGURES and hasattr(os, "startfile"):
            os.startfile(output_path)
        # CODEX MODIFICATION END: optional open saved image preview
        # Temporarily disabled: editable Matplotlib .mplfig.pkl export.
        # Uncomment this block to restore Python-figure saving.
        # if SAVE_EDITABLE_FIGURES:
        #     editable_path = output_path.with_suffix(".mplfig.pkl")
        #     with editable_path.open("wb") as editable_file:
        #         pickle.dump(fig, editable_file)
        #     print(f"Saved editable Matplotlib figure {editable_path}")
        # CODEX MODIFICATION START: allow saved figures to display at end
        if DEFER_FIGURE_SHOW:
            print(f"Prepared saved figure for display: {filename}")
        else:
            plt.close(fig)
        # CODEX MODIFICATION END: allow saved figures to display at end
    else:
        # CODEX MODIFICATION START: optional deferred Matplotlib display
        if DEFER_FIGURE_SHOW:
            print(f"Prepared figure for display: {filename}")
        else:
            plt.show()
        # CODEX MODIFICATION END: optional deferred Matplotlib display


# ============================================================
# Time-dependent dynamics
# ============================================================

def solve_dynamics_from_peak_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 1000,
) -> Dict[str, Any]:
    """
    Solve total carrier-density dynamics at a specified peak intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I0_wcm2:
        Peak laser intensity in W/cm^2.
    n_time_points:
        Number of points used for post-processing the dense ODE solution.

    Returns
    -------
    dict
        Time-dependent photoionization, avalanche, total rates, and density.
    """

    if I0_wcm2 < 0.0:
        raise ValueError("I0_wcm2 must be nonnegative.")
    if n_time_points < 2:
        raise ValueError("n_time_points must be at least 2.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = float(I0_wcm2) * WM2_PER_WCM2

    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )

        derivative = W_pi + W_av
        if not np.isfinite(derivative) or derivative < 0.0:
            derivative = 0.0

        return [float(derivative)]

    solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-5,
        atol=1.0e6,
        max_step=tau_s / 350.0,
        dense_output=True,
    )

    t_eval = np.linspace(t0, t1, n_time_points)

    if solution.sol is not None:
        ne = np.maximum(solution.sol(t_eval)[0], 0.0)
    else:
        ne = np.maximum(np.interp(t_eval, solution.t, solution.y[0]), 0.0)

    intensity = np.asarray([intensity_at_time(t) for t in t_eval], dtype=float)
    Wpi = np.asarray([photo_rate_at_time(t) for t in t_eval], dtype=float)
    Wav = np.asarray(
        [
            avalanche_generation_rate_m3_s(
                intensity_wm2=I_now,
                ne_m3=ne_now,
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )
            for I_now, ne_now in zip(intensity, ne)
        ],
        dtype=float,
    )
    Wtotal = Wpi + Wav

    return {
        "case": case,
        "t_s": t_eval,
        "intensity_wm2": intensity,
        "Wpi_m3_s": Wpi,
        "Wav_m3_s": Wav,
        "Wtotal_m3_s": Wtotal,
        "Wpi_cm3_fs": Wpi * RATE_CM3_FS_PER_M3_S,
        "Wav_cm3_fs": Wav * RATE_CM3_FS_PER_M3_S,
        "Wtotal_cm3_fs": Wtotal * RATE_CM3_FS_PER_M3_S,
        "ne_m3": ne,
        "ne_cm3": ne * CM3_PER_M3,
        "solver_success": bool(solution.success),
        "solver_message": str(solution.message),
    }


SCALING_CACHE: Dict[Tuple[str, int, float, float, int], Dict[str, np.ndarray]] = {}


def compute_case_scaling(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 600,
) -> Dict[str, np.ndarray]:
    """
    Compute the peak total ionization rate versus peak laser intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        One-dimensional array of peak intensities in W/cm^2.
    n_time_points:
        Number of post-processing time points per ODE solution.

    Returns
    -------
    dict
        Intensity array and peak total ionization-rate array.
    """

    intensity_values = np.asarray(I_values_wcm2, dtype=float)

    if intensity_values.ndim != 1 or intensity_values.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensity_values)) or np.any(intensity_values <= 0.0):
        raise ValueError("All intensity values must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensity_values.size),
        float(intensity_values[0]),
        float(intensity_values[-1]),
        int(n_time_points),
    )

    if cache_key in SCALING_CACHE:
        return SCALING_CACHE[cache_key]

    Wtotal_peak = np.zeros_like(intensity_values)
    print(f"\nComputing intensity scaling for {case['short']} ...")

    report_interval = max(1, intensity_values.size // 10)

    for index, I0_wcm2 in enumerate(intensity_values):
        if index % report_interval == 0 or index == intensity_values.size - 1:
            print(
                f"  {index + 1:3d}/{intensity_values.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2 reported: {result['solver_message']}"
            )

        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(
                result["Wtotal_cm3_fs"],
                nan=0.0,
                posinf=0.0,
                neginf=0.0,
            )
        )

    output = {
        "I_wcm2": intensity_values,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
    }
    SCALING_CACHE[cache_key] = output
    return output


def direct_peak_total_rate_at_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 600,
) -> float:
    """Solve at one specified intensity instead of interpolating a scan."""

    scaling = compute_case_scaling(
        case=case,
        I_values_wcm2=np.asarray([float(I0_wcm2)]),
        n_time_points=n_time_points,
    )
    return float(scaling["Wtotal_peak_cm3_fs"][0])


def solve_density_case(case: CaseDict) -> Dict[str, Any]:
    """
    Solve photoionization-only and photoionization-plus-avalanche density growth.

    Parameters
    ----------
    case:
        Material/laser case dictionary.

    Returns
    -------
    dict
        Material parameters, peak intensity, final densities, and solver status.
    """

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = case_reference_peak_intensity_wcm2(case) * WM2_PER_WCM2

    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_photo(t: float, _y: np.ndarray) -> List[float]:
        return [photo_rate_at_time(t)]

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )
        derivative = W_pi + W_av
        return [float(max(derivative, 0.0)) if np.isfinite(derivative) else 0.0]

    photo_solution = solve_ivp(
        rhs_photo,
        (t0, t1),
        y0=[0.0],
        method="RK45",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 200.0,
    )

    total_solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 500.0,
    )

    ne_photo_final_m3 = float(max(photo_solution.y[0, -1], 0.0))
    ne_total_final_m3 = float(max(total_solution.y[0, -1], 0.0))

    return {
        "case": case,
        "n0": n0,
        "n2": n2,
        "trans": trans,
        "Eg_eV": Eg_J / E_CHARGE,
        "mred_over_me": mred / ME0,
        "I0_wm2": I0_wm2,
        "I0_wcm2": I0_wm2 * WCM2_PER_WM2,
        "ne_photo_m3": ne_photo_final_m3,
        "ne_total_m3": ne_total_final_m3,
        "ne_photo_cm3": ne_photo_final_m3 * CM3_PER_M3,
        "ne_total_cm3": ne_total_final_m3 * CM3_PER_M3,
        "ne_avalanche_added_cm3": (
            max(ne_total_final_m3 - ne_photo_final_m3, 0.0) * CM3_PER_M3
        ),
        "sol_photo_success": bool(photo_solution.success),
        "sol_photo_message": str(photo_solution.message),
        "sol_total_success": bool(total_solution.success),
        "sol_total_message": str(total_solution.message),
    }


# ============================================================
# Summary table
# ============================================================

def build_summary_table(results: Sequence[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Convert density-solver results into rows for display.
    """

    rows: List[Dict[str, Any]] = []

    for result in results:
        case = result["case"]
        rows.append(
            {
                "Case": case["short"],
                "Material": case["material"],
                "Regime": case["region"],
                "lambda_um": case["wavelength_um"],
                "tau_fs": case["tau_fs"],
                "F0_Jcm2": case["F0_jcm2"],
                "Fth_Jcm2": case["threshold_fluence"]["threshold_fluence_jcm2"],
                "F0_over_Fth": case["threshold_fluence"]["F0_over_Fth"],
                "I0_source": case_peak_intensity_source(case),
                "I0_Wcm2": result["I0_wcm2"],
                "n_photo_cm3": result["ne_photo_cm3"],
                "n_avalanche_added_cm3": result["ne_avalanche_added_cm3"],
                "n_total_cm3": result["ne_total_cm3"],
                "n0": result["n0"],
                "Eg_eV": result["Eg_eV"],
                "mred_over_me": result["mred_over_me"],
                "solver": (
                    "OK"
                    if result["sol_photo_success"] and result["sol_total_success"]
                    else "CHECK"
                ),
            }
        )

    return rows


def display_summary_table(rows: Sequence[Dict[str, Any]]) -> None:
    """
    Display the density-growth summary table in Jupyter or plain text.
    """

    print("\n================ Density-growth summary table ================\n")

    if pd is None:
        for row in rows:
            print(row)
        return

    dataframe = pd.DataFrame(rows)
    display_frame = dataframe.copy()

    scientific_columns = [
        "I0_Wcm2",
        "n_photo_cm3",
        "n_avalanche_added_cm3",
        "n_total_cm3",
    ]
    compact_columns = [
        "lambda_um",
        "tau_fs",
        "F0_Jcm2",
        "n0",
        "Eg_eV",
        "mred_over_me",
    ]

    # CODEX MODIFICATION START: display optional BaF2 reference fields cleanly
    for column in scientific_columns:
        display_frame[column] = display_frame[column].map(
            lambda value: "N/A" if value is None else f"{value:.4e}"
        )

    for column in compact_columns:
        display_frame[column] = display_frame[column].map(
            lambda value: "N/A" if value is None else f"{value:.4g}"
        )
    # CODEX MODIFICATION END: display optional BaF2 reference fields cleanly

    if ipython_display is not None:
        ipython_display(display_frame)
    else:
        print(display_frame.to_string(index=False))


# ============================================================
# First graph set: Keldysh photoionization curves
# ============================================================

def plot_keldysh_rate_curves(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot Keldysh photoionization-rate curves for all default cases.

    The case reference peak intensity is marked by a black cross.
    """

    I_values_wm2 = np.logspace(14, 19, 900)
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes_flat = axes.ravel()

    for ax, case in zip(axes_flat, cases):
        wavelength_um = float(case["wavelength_um"])
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        n0, _n2, Eg_J, mred, _trans = material_flag1(
            mat_flag=int(case["mat_flag"]),
            wavelength_um=wavelength_um,
        )

        Wpi = np.asarray(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=I_values_wm2,
            ),
            dtype=float,
        )

        keep = np.isfinite(Wpi) & (Wpi > 0.0)

        ax.loglog(
            I_values_wm2[keep],
            Wpi[keep],
            linewidth=2.4,
            label=r"$W_{\rm PI}$",
        )

        marker_info = case_marker_peak_intensity_wcm2(case)
        if marker_info is not None and np.any(keep):
            I_marker_wcm2, marker_label = marker_info
            I_marker_wm2 = I_marker_wcm2 * WM2_PER_WCM2
            W_marker = interpolate_log_y(
                x=I_values_wm2[keep],
                y=Wpi[keep],
                x0=I_marker_wm2,
            )
            if W_marker is not None:
                ax.plot(
                    I_marker_wm2,
                    W_marker,
                    "kx",
                    markersize=9,
                    markeredgewidth=2,
                    label=marker_label,
                )

        ax.set_title(case["name"])
        ax.set_xlabel(r"Laser intensity $I$ (W/m$^2$)")
        ax.set_ylabel(r"$W_{\rm PI}$ (m$^{-3}$ s$^{-1}$)")
        ax.grid(True, which="both", alpha=0.25)
        ax.legend(frameon=False)

    for ax in axes_flat[len(cases):]:
        ax.set_visible(False)

    fig.suptitle("Keldysh photoionization-rate curves", fontsize=15)
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="01_first_graph_set_keldysh_rate_curves.png",
    )


# ============================================================
# BaF2-reference Keldysh parameter axis
# ============================================================

# CODEX MODIFICATION START: BaF2-reference Keldysh parameter axis
def gamma_baf2_reference_from_intensity_wcm2(
    I_wcm2: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Evaluate the Keldysh parameter using BaF2 as the reference material.

    Parameters
    ----------
    I_wcm2:
        Scalar or array of intensities in W/cm^2.
    wavelength_um:
        Wavelength in micrometers.
    include_field_factor_two:
        If True, include the factor of two associated with
        I = (1/2) c n eps0 E^2 in the denominator.

    Returns
    -------
    float or np.ndarray
        Keldysh parameter values.
    """

    intensity = np.asarray(I_wcm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    gamma = np.full_like(intensity, np.inf)
    valid = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(valid):
        I_wm2 = intensity[valid] * WM2_PER_WCM2
        n_baf2, _n2, Eg_baf2_J, mred_baf2, _trans = material_flag1(1, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            gamma_valid = (omega / E_CHARGE) * np.sqrt(
                (mred_baf2 * C0 * n_baf2 * EPS0 * Eg_baf2_J)
                / (field_factor * I_wm2)
            )

        gamma[valid] = np.nan_to_num(
            gamma_valid,
            nan=np.inf,
            posinf=np.inf,
            neginf=np.inf,
        )

    if scalar_input:
        return float(gamma[0])
    return gamma


def intensity_wcm2_from_gamma_baf2_reference(
    gamma: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Convert a BaF2-reference Keldysh parameter to intensity in W/cm^2.
    """

    gamma_values = np.asarray(gamma, dtype=float)
    scalar_input = gamma_values.ndim == 0
    gamma_values = np.atleast_1d(gamma_values)

    intensity = np.full_like(gamma_values, np.inf)
    valid = np.isfinite(gamma_values) & (gamma_values > 0.0)

    if np.any(valid):
        n_baf2, _n2, Eg_baf2_J, mred_baf2, _trans = material_flag1(1, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            I_wm2 = (
                (omega / E_CHARGE) ** 2
                * (mred_baf2 * C0 * n_baf2 * EPS0 * Eg_baf2_J)
                / (field_factor * gamma_values[valid] ** 2)
            )

        intensity[valid] = I_wm2 * WCM2_PER_WM2

    if scalar_input:
        return float(intensity[0])
    return intensity


def add_baf2_gamma_top_axis(
    ax: plt.Axes,
    wavelength_um: float,
    gamma_ticks: Tuple[float, ...],
    include_field_factor_two: bool = True,
) -> None:
    """
    Add a BaF2-reference Keldysh-parameter axis above an intensity axis.
    """

    ax_top = ax.twiny()
    ax_top.set_xscale("log")
    ax_top.set_xlim(ax.get_xlim())

    tick_positions = np.asarray(
        intensity_wcm2_from_gamma_baf2_reference(
            gamma=np.asarray(gamma_ticks, dtype=float),
            wavelength_um=wavelength_um,
            include_field_factor_two=include_field_factor_two,
        ),
        dtype=float,
    )

    x_min, x_max = ax.get_xlim()
    valid_ticks: List[float] = []
    valid_labels: List[str] = []

    for gamma_value, tick_position in zip(gamma_ticks, tick_positions):
        if np.isfinite(tick_position) and x_min <= tick_position <= x_max:
            valid_ticks.append(float(tick_position))
            valid_labels.append(f"{gamma_value:g}")

    ax_top.set_xticks(valid_ticks)
    ax_top.set_xticklabels(valid_labels)
    ax_top.set_xlabel(r"Keldysh parameter $\gamma$ (BaF$_2$ reference)")
    ax_top.tick_params(axis="x", which="both", direction="in")
# CODEX MODIFICATION END: BaF2-reference Keldysh parameter axis


# ============================================================
# Last graph set: total ionization comparison
# ============================================================

def plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 50,
    I_min_wcm2: float = 5.0e10,
    I_max_wcm2: float = 1.0e15,
    y_min: float = 1.0e0,
    y_max: float = 1.0e30,
    include_field_factor_two: bool = True,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot peak total ionization rate for the enabled BaF2 wavelength regimes.

    Each panel includes a BaF2-reference Keldysh-parameter top axis and a
    dashed vertical line at gamma = 1.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Intensity limits must satisfy 0 < I_min < I_max.")

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )

    regime_order = ["NIR", "LWIR"]
    enabled_regimes = [
        regime for regime in regime_order
        if any(case["region"] == regime for case in cases)
    ]
    if not enabled_regimes:
        raise ValueError("At least one BaF2 NIR or LWIR case is required.")
    panel_labels = {"NIR": "(a) NIR", "LWIR": "(b) LWIR"}
    gamma_ticks_by_regime = {
        "NIR": (10.0, 3.0, 1.0, 0.3),
        "LWIR": (1.0, 0.3, 0.1),
    }
    material_order = {"BaF2": 0}

    fig, axes = plt.subplots(
        1,
        len(enabled_regimes),
        figsize=(6.8 * len(enabled_regimes), 5.2),
        sharey=True,
    )
    axes = np.atleast_1d(axes)

    print("\nCalculating enabled-regime total-ionization comparison ...\n")

    for ax, regime in zip(axes, enabled_regimes):
        regime_cases = sorted(
            [case for case in cases if case["region"] == regime],
            key=lambda case: material_order.get(case["material"], 99),
        )

        wavelength_um = float(regime_cases[0]["wavelength_um"])

        for case in regime_cases:
            print(f"  {regime}: {case['short']}")
            scaling = compute_case_scaling(
                case=case,
                I_values_wcm2=I_values_wcm2,
                n_time_points=600,
            )

            I = scaling["I_wcm2"]
            Wtotal = scaling["Wtotal_peak_cm3_fs"]

            ax.loglog(
                I,
                positive_for_log(Wtotal),
                linewidth=2.6,
                label=case["material"],
            )

            marker_info = case_marker_peak_intensity_wcm2(case)
            W_marker = None
            if marker_info is not None:
                I_marker, _marker_label = marker_info
                W_marker = direct_peak_total_rate_at_intensity(case, I_marker)

            if W_marker is not None:
                ax.plot(
                    I_marker,
                    W_marker,
                    "kx",
                    markersize=8.5,
                    markeredgewidth=2.0,
                )

        I_gamma_1 = float(
            intensity_wcm2_from_gamma_baf2_reference(
                gamma=1.0,
                wavelength_um=wavelength_um,
                include_field_factor_two=include_field_factor_two,
            )
        )

        if I_min_wcm2 <= I_gamma_1 <= I_max_wcm2:
            ax.axvline(
                I_gamma_1,
                color="k",
                linestyle="--",
                linewidth=1.7,
            )
            ax.text(
                I_gamma_1 * 1.12,
                y_max / 8.0,
                r"$\gamma=1$",
                fontsize=11,
                verticalalignment="center",
            )

        ax.text(
            0.03,
            0.90,
            panel_labels[regime],
            transform=ax.transAxes,
            fontsize=14,
            fontweight="bold",
        )
        ax.set_xlabel(r"Laser intensity $I$ (W/cm$^2$)")
        ax.set_xlim(I_min_wcm2, I_max_wcm2)
        ax.set_ylim(y_min, y_max)
        ax.grid(True, which="major", alpha=0.28)
        ax.grid(True, which="minor", alpha=0.14, linestyle=":")
        ax.legend(frameon=False, fontsize=14, loc="lower right")

        add_baf2_gamma_top_axis(
            ax=ax,
            wavelength_um=wavelength_um,
            gamma_ticks=gamma_ticks_by_regime[regime],
            include_field_factor_two=include_field_factor_two,
        )

    axes[0].set_ylabel(
        r"Peak total ionization rate $W_{\rm total}$ (cm$^{-3}$ fs$^{-1}$)"
    )

    fig.suptitle(
        r"Total ionization including avalanche: "
        r"$W_{\rm total}=W_{\rm PI}+(\sigma I/E_g)n_e$",
        fontsize=14,
    )

    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="02_last_graph_set_total_ionization_gamma_axis.png",
    )



# ============================================================
# BaF2 plots
# ============================================================

COMPONENT_SCALING_CACHE: Dict[
    Tuple[str, int, float, float, int], Dict[str, np.ndarray]
] = {}


def normalize_curve(values: np.ndarray) -> np.ndarray:
    """Normalize a nonnegative curve to its maximum value."""

    array = np.asarray(values, dtype=float)
    array = np.nan_to_num(array, nan=0.0, posinf=0.0, neginf=0.0)
    maximum = float(np.max(array)) if array.size else 0.0
    if maximum <= 0.0:
        return np.zeros_like(array)
    return array / maximum


def compute_case_scaling_components(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 700,
) -> Dict[str, np.ndarray]:
    """
    Compute peak photoionization, avalanche, total rates, and density.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        Peak intensities in W/cm^2.
    n_time_points:
        Number of time samples used to post-process each ODE solution.

    Returns
    -------
    dict
        Arrays of peak W_PI, W_av, W_total, and maximum electron density.
    """

    intensities = np.asarray(I_values_wcm2, dtype=float)
    if intensities.ndim != 1 or intensities.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensities)) or np.any(intensities <= 0.0):
        raise ValueError("All intensities must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensities.size),
        float(intensities[0]),
        float(intensities[-1]),
        int(n_time_points),
    )
    if cache_key in COMPONENT_SCALING_CACHE:
        return COMPONENT_SCALING_CACHE[cache_key]

    Wpi_peak = np.zeros_like(intensities)
    Wav_peak = np.zeros_like(intensities)
    Wtotal_peak = np.zeros_like(intensities)
    ne_max = np.zeros_like(intensities)

    print(f"\nComputing rate-component scaling for {case['short']} ...")
    report_interval = max(1, intensities.size // 10)

    for index, I0_wcm2 in enumerate(intensities):
        if index % report_interval == 0 or index == intensities.size - 1:
            print(
                f"  {index + 1:3d}/{intensities.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2: {result['solver_message']}"
            )

        Wpi_peak[index] = np.nanmax(
            np.nan_to_num(result["Wpi_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wav_peak[index] = np.nanmax(
            np.nan_to_num(result["Wav_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(result["Wtotal_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        ne_max[index] = np.nanmax(
            np.nan_to_num(result["ne_cm3"], nan=0.0, posinf=0.0, neginf=0.0)
        )

    output = {
        "I_wcm2": intensities,
        "Wpi_peak_cm3_fs": Wpi_peak,
        "Wav_peak_cm3_fs": Wav_peak,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
        "ne_max_cm3": ne_max,
    }
    COMPONENT_SCALING_CACHE[cache_key] = output
    return output


def plot_case_figure_1_style(
    case: CaseDict,
    save_dir: Optional[Path] = None,
) -> None:
    """Plot Keldysh photoionization rate versus peak irradiance."""

    I_values_wcm2 = np.logspace(10, 15, 900)
    I_values_wm2 = I_values_wcm2 * WM2_PER_WCM2
    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        int(case["mat_flag"]), wavelength_um
    )

    Wpi_cm3_fs = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_values_wm2,
        ),
        dtype=float,
    ) * RATE_CM3_FS_PER_M3_S

    marker_info = case_marker_peak_intensity_wcm2(case)
    fig, ax = plt.subplots(figsize=(7.0, 5.0))
    ax.loglog(
        I_values_wcm2,
        positive_for_log(Wpi_cm3_fs),
        "k-",
        linewidth=2.2,
        label=r"$W_{\rm PI}$",
    )

    if marker_info is not None:
        I_marker, marker_label = marker_info
        W_marker = interpolate_log_y(I_values_wcm2, Wpi_cm3_fs, I_marker)
        if W_marker is not None:
            ax.plot(
                I_marker,
                W_marker,
                "kx",
                markersize=9,
                markeredgewidth=2.0,
                label=marker_label,
            )

    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Photoionization rate $W_{\rm PI}$ (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"{case['material']}: $W_{{\rm PI}}$ vs irradiance, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    save_or_show(
        fig,
        save_dir,
        f"BaF2_fig1_{case['region']}.png",
    )


def plot_case_figure_2_style(
    case: CaseDict,
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot rate components, electron density, and total rate versus irradiance.
    """

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    scaling = compute_case_scaling_components(
        case=case,
        I_values_wcm2=I_values_wcm2,
        n_time_points=600,
    )

    I = scaling["I_wcm2"]
    Wpi = scaling["Wpi_peak_cm3_fs"]
    Wav = scaling["Wav_peak_cm3_fs"]
    Wtotal = scaling["Wtotal_peak_cm3_fs"]
    ne = scaling["ne_max_cm3"]
    marker_info = case_marker_peak_intensity_wcm2(case)

    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))

    ax = axes[0]
    ax.loglog(I, positive_for_log(Wtotal), "b--", linewidth=2.5, label=r"$W_{\rm total}$")
    ax.loglog(I, positive_for_log(Wpi), "k:", linewidth=2.3, label=r"$W_{\rm PI}$")
    ax.loglog(
        I,
        positive_for_log(Wav),
        color="orange",
        linestyle="-.",
        linewidth=2.3,
        label=r"$W_{\rm av}$",
    )
    if marker_info is not None:
        I_marker, marker_label = marker_info
        ax.axvline(I_marker, color="0.4", linestyle="--", linewidth=1.3, label=marker_label)
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"(a) {case['material']}, $\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    ax = axes[1]
    ax_rate = ax.twinx()
    line_density, = ax.loglog(I, positive_for_log(ne), "r-", linewidth=2.5, label=r"$n_e$")
    line_rate, = ax_rate.loglog(
        I,
        positive_for_log(Wtotal),
        "b--",
        linewidth=2.5,
        label=r"$W_{\rm total}$",
    )
    if marker_info is not None:
        I_marker, _marker_label = marker_info
        ax.axvline(I_marker, color="0.4", linestyle="--", linewidth=1.3)
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    ax_rate.set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title("(b) Density and total ionization rate")
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(
        [line_density, line_rate],
        [line_density.get_label(), line_rate.get_label()],
        frameon=False,
        fontsize=9,
    )
    ax.set_xlim(1.0e10, 1.0e15)

    fig.suptitle(f"{case['short']}: irradiance scaling", fontsize=14)
    save_or_show(
        fig,
        save_dir,
        f"BaF2_fig2_{case['region']}.png",
    )


def plot_case_figure_3_style(
    case: CaseDict,
    intensity_factors: Tuple[float, float, float, float] = (0.25, 0.5, 1.0, 2.0),
    save_dir: Optional[Path] = None,
) -> None:
    """Plot normalized time-domain carrier and ionization dynamics."""

    I_reference_wcm2 = case_reference_peak_intensity_wcm2(case)
    fig, axes = plt.subplots(4, 2, figsize=(13.0, 14.0), sharey=True)

    for row, factor in enumerate(intensity_factors):
        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=factor * I_reference_wcm2,
            n_time_points=1800,
        )

        if float(case["tau_fs"]) >= 1000.0:
            time_axis = result["t_s"] * 1.0e12
            time_label = "Time (ps)"
        else:
            time_axis = result["t_s"] * 1.0e15
            time_label = "Time (fs)"

        I_norm = normalize_curve(result["intensity_wm2"])
        ne_norm = normalize_curve(result["ne_cm3"])
        Wpi_norm = normalize_curve(result["Wpi_cm3_fs"])
        Wav_norm = normalize_curve(result["Wav_cm3_fs"])
        Wtotal_norm = normalize_curve(result["Wtotal_cm3_fs"])

        ax = axes[row, 0]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(time_axis, ne_norm, "r-", linewidth=2.0, label=r"$n_e$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm ref}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.set_ylabel("Normalized value")
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

        ax = axes[row, 1]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(
            time_axis,
            Wav_norm,
            color="goldenrod",
            linestyle="-.",
            linewidth=2.0,
            label=r"$W_{\rm av}$",
        )
        ax.plot(time_axis, Wpi_norm, "k:", linewidth=2.0, label=r"$W_{\rm PI}$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm ref}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

    axes[-1, 0].set_xlabel(time_label)
    axes[-1, 1].set_xlabel(time_label)
    fig.suptitle(
        rf"{case['material']} time-domain dynamics, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"BaF2_fig3_{case['region']}.png",
    )


def plot_material_figure_4_style(
    material_name: str,
    material_cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Plot density/rate scaling for the supplied cases of one material."""

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))
    linestyles = {"NIR": "-", "LWIR": "-."}

    for case in material_cases:
        scaling = compute_case_scaling_components(
            case=case,
            I_values_wcm2=I_values_wcm2,
            n_time_points=600,
        )
        I = scaling["I_wcm2"]
        ne = scaling["ne_max_cm3"]
        Wtotal = scaling["Wtotal_peak_cm3_fs"]
        label = rf"{case['wavelength_um']:g} $\mu$m, $\tau={case['tau_fs']:g}$ fs"
        style = linestyles.get(case["region"], "-")

        axes[0].loglog(I, positive_for_log(ne), linestyle=style, linewidth=2.3, label=label)
        axes[1].loglog(I, positive_for_log(Wtotal), linestyle=style, linewidth=2.3, label=label)

        marker_info = case_marker_peak_intensity_wcm2(case)
        if marker_info is not None:
            I_marker, _marker_label = marker_info
            axes[0].axvline(I_marker, color="0.5", linestyle="--", linewidth=1.0)
            axes[1].axvline(I_marker, color="0.5", linestyle="--", linewidth=1.0)

    axes[0].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[0].set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    axes[0].set_title(f"(a) {material_name}: electron density")
    axes[0].grid(True, which="both", alpha=0.3)
    axes[0].legend(frameon=False, fontsize=9)
    axes[0].set_xlim(1.0e10, 1.0e15)

    axes[1].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[1].set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    axes[1].set_title(f"(b) {material_name}: total ionization rate")
    axes[1].grid(True, which="both", alpha=0.3)
    axes[1].legend(frameon=False, fontsize=9)
    axes[1].set_xlim(1.0e10, 1.0e15)

    fig.suptitle(rf"{material_name}: irradiance scaling", fontsize=14)
    save_or_show(
        fig,
        save_dir,
        "BaF2_fig4_NIR_scaling.png",
    )


# CODEX MODIFICATION START: BaF2-only plotting workflow
def plot_baf2_figures(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Generate all Figs. 1-4 for BaF2."""

    print("\n============================================================")
    print("Generating BaF2 plots")
    print("Case: 0.8 um, 100 fs")
    print("============================================================\n")

    for case in cases:
        plot_case_figure_1_style(case, save_dir=save_dir)
        plot_case_figure_2_style(
            case,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )
        if case_has_reference_peak_intensity(case):
            plot_case_figure_3_style(case, save_dir=save_dir)
        else:
            print(
                f"Skipping Fig. 3 for {case['short']}: no verified "
                "reference_I0_wcm2 or measured F0_jcm2 is available."
            )

    for material_name in sorted({case["material"] for case in cases}):
        material_cases = [
            case for case in cases if case["material"] == material_name
        ]
        if not material_cases:
            continue
        plot_material_figure_4_style(
            material_name=material_name,
            material_cases=material_cases,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )
# CODEX MODIFICATION END: BaF2-only plotting workflow


# ============================================================
# CODEX MODIFICATION START: 3D total-ionization surface plot
# ============================================================

def plot_total_ionization_3d_surface(
    case: CaseDict,
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """
    Plot total ionization rate versus peak laser intensity and electron density.

    Axes are log10(I0), log10(ne), and log10(W_total), where W_total includes
    Keldysh photoionization plus avalanche/impact ionization.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)

    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3),
        np.log10(ne_max_cm3),
        n_density_points,
    )

    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3

    Wpi_grid = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_grid_wm2,
        ),
        dtype=float,
    )

    Wav_grid = np.zeros_like(I_grid_wm2)
    for row_index in range(I_grid_wm2.shape[0]):
        for column_index in range(I_grid_wm2.shape[1]):
            Wav_grid[row_index, column_index] = avalanche_generation_rate_m3_s(
                intensity_wm2=I_grid_wm2[row_index, column_index],
                ne_m3=ne_grid_m3[row_index, column_index],
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )

    Wtotal_grid = (Wpi_grid + Wav_grid) * RATE_CM3_FS_PER_M3_S
    Wtotal_grid = np.maximum(
        np.nan_to_num(Wtotal_grid, nan=0.0, posinf=0.0, neginf=0.0),
        1.0e-300,
    )

    X = np.log10(I_grid_wcm2)
    Y = np.log10(ne_grid_cm3)
    Z = np.log10(Wtotal_grid)

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection="3d")
    surface = ax.plot_surface(
        X,
        Y,
        Z,
        cmap="jet",
        linewidth=0,
        antialiased=True,
        alpha=0.95,
    )

    ax.set_xlabel(r"$\log_{10}(I_0)$  [W/cm$^2$]")
    ax.set_ylabel(r"$\log_{10}(n_e)$  [cm$^{-3}$]")
    ax.set_zlabel(r"$\log_{10}(W_{\rm total})$  [cm$^{-3}$ fs$^{-1}$]")
    ax.set_title(f"Total ionization surface: {case['short']}")

    fig.colorbar(
        surface,
        ax=ax,
        shrink=0.65,
        pad=0.12,
        label=r"$\log_{10}(W_{\rm total})$",
    )

    ax.view_init(elev=28, azim=135)
    fig.tight_layout()
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename=f"05_total_ionization_3d_{case['short']}.png",
    )


def plot_total_ionization_3d_surface_grid(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """Plot all BaF2 total-ionization 3D surfaces in one figure."""

    if not cases:
        raise ValueError("At least one case is required for the 3D grid.")
    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3),
        np.log10(ne_max_cm3),
        n_density_points,
    )
    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3
    X = np.log10(I_grid_wcm2)
    Y = np.log10(ne_grid_cm3)

    z_grids: List[np.ndarray] = []
    for index, case in enumerate(cases):
        wavelength_um = float(case["wavelength_um"])
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        n0, _n2, Eg_J, mred, _trans = material_flag1(
            mat_flag=int(case["mat_flag"]),
            wavelength_um=wavelength_um,
        )

        Wpi_grid = np.asarray(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=I_grid_wm2,
            ),
            dtype=float,
        )

        Wav_grid = np.zeros_like(I_grid_wm2)
        for row_index in range(I_grid_wm2.shape[0]):
            for column_index in range(I_grid_wm2.shape[1]):
                Wav_grid[row_index, column_index] = avalanche_generation_rate_m3_s(
                    intensity_wm2=I_grid_wm2[row_index, column_index],
                    ne_m3=ne_grid_m3[row_index, column_index],
                    omega=omega,
                    mred=mred,
                    delta_J=Eg_J,
                    n0=n0,
                )

        Wtotal_grid = (Wpi_grid + Wav_grid) * RATE_CM3_FS_PER_M3_S
        Wtotal_grid = np.maximum(
            np.nan_to_num(Wtotal_grid, nan=0.0, posinf=0.0, neginf=0.0),
            1.0e-300,
        )
        Z = np.log10(Wtotal_grid)
        z_grids.append(Z)

    z_min = min(float(np.nanmin(Z)) for Z in z_grids)
    z_max = max(float(np.nanmax(Z)) for Z in z_grids)
    norm = colors.Normalize(vmin=z_min, vmax=z_max)
    cmap = plt.get_cmap("jet")

    n_cases = len(cases)
    n_cols = 1 if n_cases == 1 else min(2, n_cases)
    n_rows = int(np.ceil(n_cases / n_cols))

    fig = plt.figure(figsize=(7.5 * n_cols, 5.7 * n_rows))
    fig.subplots_adjust(
        left=0.04,
        right=0.88,
        bottom=0.08,
        top=0.86,
        wspace=0.10,
        hspace=0.20,
    )

    for index, (case, Z) in enumerate(zip(cases, z_grids)):
        ax = fig.add_subplot(n_rows, n_cols, index + 1, projection="3d")
        ax.plot_surface(
            X,
            Y,
            Z,
            facecolors=cmap(norm(Z)),
            linewidth=0,
            antialiased=True,
            shade=False,
            alpha=0.95,
        )
        ax.set_xlabel(r"$\log_{10}(I_0)$")
        ax.set_ylabel(r"$\log_{10}(n_e)$")
        ax.set_zlabel(r"$\log_{10}(W_{\rm total})$")
        ax.set_title(case["short"])
        ax.view_init(elev=28, azim=135)

    colorbar_axis = fig.add_axes([0.91, 0.18, 0.018, 0.64])
    colorbar_mappable = cm.ScalarMappable(norm=norm, cmap=cmap)
    colorbar_mappable.set_array([])
    fig.colorbar(
        colorbar_mappable,
        cax=colorbar_axis,
        label=r"$\log_{10}(W_{\rm total})$ [cm$^{-3}$ fs$^{-1}$]",
    )

    enabled_regions = " / ".join(str(case["region"]) for case in cases)
    fig.suptitle(
        rf"Total ionization surfaces: BaF$_2$ {enabled_regions}",
        fontsize=15,
    )
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename=f"05_total_ionization_3d_BaF2_{'_'.join(str(case['region']) for case in cases)}.png",
        apply_tight_layout=False,
    )

# ============================================================
# CODEX MODIFICATION END: 3D total-ionization surface plot
# ============================================================


# ============================================================
# Saved numerical variables
# ============================================================

def compute_total_ionization_surface_data(
    case: CaseDict,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> Dict[str, np.ndarray]:
    """Return the numerical arrays used by a total-ionization 3D surface."""

    if n_intensity_points < 2 or n_density_points < 2:
        raise ValueError("Surface grids require at least two points per axis.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2), np.log10(I_max_wcm2), n_intensity_points
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3), np.log10(ne_max_cm3), n_density_points
    )
    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3

    Wpi_grid_m3_s = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_grid_wm2,
        ),
        dtype=float,
    )
    Wav_grid_m3_s = np.zeros_like(I_grid_wm2)
    for row_index in range(I_grid_wm2.shape[0]):
        for column_index in range(I_grid_wm2.shape[1]):
            Wav_grid_m3_s[row_index, column_index] = avalanche_generation_rate_m3_s(
                intensity_wm2=I_grid_wm2[row_index, column_index],
                ne_m3=ne_grid_m3[row_index, column_index],
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )

    Wtotal_grid_cm3_fs = (Wpi_grid_m3_s + Wav_grid_m3_s) * RATE_CM3_FS_PER_M3_S
    return {
        "I_values_wcm2": I_values_wcm2,
        "ne_values_cm3": ne_values_cm3,
        "I_grid_wcm2": I_grid_wcm2,
        "ne_grid_cm3": ne_grid_cm3,
        "Wpi_grid_m3_s": Wpi_grid_m3_s,
        "Wav_grid_m3_s": Wav_grid_m3_s,
        "Wtotal_grid_cm3_fs": Wtotal_grid_cm3_fs,
        "log10_I_grid_wcm2": np.log10(I_grid_wcm2),
        "log10_ne_grid_cm3": np.log10(ne_grid_cm3),
        "log10_Wtotal_grid_cm3_fs": np.log10(
            np.maximum(
                np.nan_to_num(Wtotal_grid_cm3_fs, nan=0.0, posinf=0.0, neginf=0.0),
                1.0e-300,
            )
        ),
    }


def _case_export_metadata(case: CaseDict) -> Dict[str, Any]:
    """Return JSON-safe inputs and derived material values for one case."""

    wavelength_um = float(case["wavelength_um"])
    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )
    metadata: Dict[str, Any] = {
        "short": str(case["short"]),
        "name": str(case["name"]),
        "material": str(case["material"]),
        "region": str(case["region"]),
        "mat_flag": int(case["mat_flag"]),
        "wavelength_um": wavelength_um,
        "tau_fs": float(case["tau_fs"]),
        "F0_jcm2": None if case.get("F0_jcm2") is None else float(case["F0_jcm2"]),
        "reference_I0_wcm2": case.get("reference_I0_wcm2"),
        "I0_wcm2": case_reference_peak_intensity_wcm2(case),
        "n0": float(n0),
        "n2_m2_per_w": float(n2) if np.isfinite(n2) else None,
        "Eg_eV": float(Eg_J / E_CHARGE),
        "mred_over_me": float(mred / ME0),
        "transmission_factor": float(trans),
        "threshold_fluence": case.get("threshold_fluence"),
    }
    for key in ("pulse_energy_uj", "beam_diameter_a_um", "beam_diameter_b_um"):
        if case.get(key) is not None:
            metadata[key] = float(case[key])
    return metadata


def _write_csv(path: Path, rows: Sequence[Dict[str, Any]]) -> None:
    """Write a long-format CSV with stable columns and UTF-8 encoding."""

    if not rows:
        return
    fieldnames = list(rows[0])
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def save_baf2_plot_variables(
    cases: Sequence[CaseDict],
    output_dir: Path,
    component_n_intensity_points: int = 50,
    total_n_intensity_points: int = 50,
    surface_n_intensity_points: int = 50,
    surface_n_density_points: int = 80,
) -> None:
    """Save BaF2 plot arrays, metadata, and long-format tables.

    Files mirror the ``various`` workflow: a compressed NPZ archive, a JSON
    manifest containing units and figure mappings, and CSV tables for scaling
    data. Only currently enabled cases are exported.
    """

    output_dir.mkdir(parents=True, exist_ok=True)
    component_I_values_wcm2 = np.logspace(10, 15, component_n_intensity_points)
    total_I_values_wcm2 = np.logspace(
        np.log10(5.0e10), np.log10(1.0e15), total_n_intensity_points
    )
    arrays: Dict[str, np.ndarray] = {}
    component_rows: List[Dict[str, Any]] = []
    total_rows: List[Dict[str, Any]] = []
    surface_rows: List[Dict[str, Any]] = []
    component_manifest: Dict[str, Any] = {}
    total_manifest: Dict[str, Any] = {}
    surface_manifest: Dict[str, Any] = {}
    case_metadata: Dict[str, Any] = {}

    print("\nSaving labeled BaF2 plot variables ...")
    for case in cases:
        short = str(case["short"])
        metadata = _case_export_metadata(case)
        case_metadata[short] = metadata
        Wtotal_direct_at_lidt_cm3_fs = direct_peak_total_rate_at_intensity(
            case,
            case_lidt_peak_intensity_wcm2(case),
            n_time_points=600,
        )

        component = compute_case_scaling_components(
            case=case,
            I_values_wcm2=component_I_values_wcm2,
            n_time_points=600,
        )
        component_manifest[short] = {
            "used_by": ["BaF2_fig2_NIR.png", "BaF2_fig4_NIR_scaling.png"],
            "arrays": {},
        }
        for name, values in component.items():
            array_name = f"component__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            component_manifest[short]["arrays"][name] = array_name

        component_gamma = np.asarray(
            gamma_baf2_reference_from_intensity_wcm2(
                component["I_wcm2"],
                wavelength_um=float(case["wavelength_um"]),
                include_field_factor_two=True,
            ),
            dtype=float,
        )
        component_gamma_name = f"component__{short}__gamma_baf2_reference"
        arrays[component_gamma_name] = component_gamma
        component_manifest[short]["arrays"]["gamma_baf2_reference"] = component_gamma_name

        for index, intensity in enumerate(component["I_wcm2"]):
            component_rows.append(
                {
                    **metadata,
                    "dataset": "component_scaling",
                    "point_index": int(index),
                    "I_wcm2": float(intensity),
                    "gamma_baf2_reference": float(component_gamma[index]),
                    "Wpi_peak_cm3_fs": float(component["Wpi_peak_cm3_fs"][index]),
                    "Wav_peak_cm3_fs": float(component["Wav_peak_cm3_fs"][index]),
                    "Wtotal_peak_cm3_fs": float(component["Wtotal_peak_cm3_fs"][index]),
                    "ne_max_cm3": float(component["ne_max_cm3"][index]),
                }
            )

        total = compute_case_scaling_components(
            case=case,
            I_values_wcm2=total_I_values_wcm2,
            n_time_points=600,
        )
        total_manifest[short] = {
            "used_by": ["NIR total-ionization scaling"],
            "arrays": {},
        }
        for name, values in total.items():
            array_name = f"total_comparison__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            total_manifest[short]["arrays"][name] = array_name

        total_gamma = np.asarray(
            gamma_baf2_reference_from_intensity_wcm2(
                total["I_wcm2"],
                wavelength_um=float(case["wavelength_um"]),
                include_field_factor_two=True,
            ),
            dtype=float,
        )
        total_gamma_name = f"total_comparison__{short}__gamma_baf2_reference"
        arrays[total_gamma_name] = total_gamma
        total_manifest[short]["arrays"]["gamma_baf2_reference"] = total_gamma_name

        for index, intensity in enumerate(total["I_wcm2"]):
            total_rows.append(
                {
                    **metadata,
                    "dataset": "total_comparison",
                    "point_index": int(index),
                    "I_wcm2": float(intensity),
                    "gamma_baf2_reference": float(total_gamma[index]),
                    "Wtotal_peak_cm3_fs": float(total["Wtotal_peak_cm3_fs"][index]),
                    "Wtotal_direct_at_lidt_cm3_fs": Wtotal_direct_at_lidt_cm3_fs,
                }
            )

        surface = compute_total_ionization_surface_data(
            case=case,
            n_intensity_points=surface_n_intensity_points,
            n_density_points=surface_n_density_points,
        )
        surface_manifest[short] = {
            "used_by": [f"05_total_ionization_3d_{short}.png"],
            "arrays": {},
        }
        for name, values in surface.items():
            array_name = f"surface3d__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            surface_manifest[short]["arrays"][name] = array_name

        for density_index in range(surface["I_grid_wcm2"].shape[0]):
            for intensity_index in range(surface["I_grid_wcm2"].shape[1]):
                surface_rows.append(
                    {
                        **metadata,
                        "dataset": "surface3d",
                        "density_index": density_index,
                        "intensity_index": intensity_index,
                        "I_wcm2": float(
                            surface["I_grid_wcm2"][density_index, intensity_index]
                        ),
                        "ne_cm3": float(
                            surface["ne_grid_cm3"][density_index, intensity_index]
                        ),
                        "log10_I_grid_wcm2": float(
                            surface["log10_I_grid_wcm2"][density_index, intensity_index]
                        ),
                        "log10_ne_grid_cm3": float(
                            surface["log10_ne_grid_cm3"][density_index, intensity_index]
                        ),
                        "Wpi_grid_cm3_fs": float(
                            surface["Wpi_grid_m3_s"][density_index, intensity_index]
                            * RATE_CM3_FS_PER_M3_S
                        ),
                        "Wav_grid_cm3_fs": float(
                            surface["Wav_grid_m3_s"][density_index, intensity_index]
                            * RATE_CM3_FS_PER_M3_S
                        ),
                        "Wtotal_grid_cm3_fs": float(
                            surface["Wtotal_grid_cm3_fs"][density_index, intensity_index]
                        ),
                        "log10_Wtotal_grid_cm3_fs": float(
                            surface["log10_Wtotal_grid_cm3_fs"][density_index, intensity_index]
                        ),
                    }
                )

    manifest = {
        "description": "Labeled variables for BaF2 Keldysh and avalanche-ionization plots.",
        "enabled_cases": list(case_metadata),
        "case_metadata": case_metadata,
        "units": {
            "I_wcm2": "W/cm^2",
            "F0_jcm2": "J/cm^2",
            "Wpi_peak_cm3_fs": "cm^-3 fs^-1",
            "Wav_peak_cm3_fs": "cm^-3 fs^-1",
            "Wtotal_peak_cm3_fs": "cm^-3 fs^-1",
            "Wtotal_direct_at_lidt_cm3_fs": "cm^-3 fs^-1",
            "ne_max_cm3": "cm^-3",
            "Wpi_grid_m3_s": "m^-3 s^-1",
            "Wav_grid_m3_s": "m^-3 s^-1",
            "Wtotal_grid_cm3_fs": "cm^-3 fs^-1",
            "ne_grid_cm3": "cm^-3",
            "gamma_baf2_reference": "dimensionless",
        },
        "files": {
            "numpy_arrays": "baf2_variables.npz",
            "manifest": "baf2_manifest.json",
            "component_scaling_csv": "baf2_component_scaling_long.csv",
            "total_comparison_csv": "baf2_total_comparison_long.csv",
            "surface3d_csv": "baf2_surface3d_long.csv",
        },
        "component_scaling": component_manifest,
        "total_comparison": total_manifest,
        "surface3d": surface_manifest,
    }
    np.savez_compressed(output_dir / "baf2_variables.npz", **arrays)
    with (output_dir / "baf2_manifest.json").open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2, allow_nan=False)
    _write_csv(output_dir / "baf2_component_scaling_long.csv", component_rows)
    _write_csv(output_dir / "baf2_total_comparison_long.csv", total_rows)
    _write_csv(output_dir / "baf2_surface3d_long.csv", surface_rows)
    print(f"Saved BaF2 variables to {output_dir}")


# ============================================================
# Workflow and command-line interface
# ============================================================

def solve_and_display_summary(cases: Sequence[CaseDict]) -> None:
    """Solve the BaF2 cases and display the summary table."""

    results: List[Dict[str, Any]] = []
    for case in cases:
        if not case_has_reference_peak_intensity(case):
            print(
                f"Skipping density table entry for {case['short']}: no verified "
                "reference_I0_wcm2 or measured F0_jcm2 is available."
            )
            continue

        print(f"Solving density table entry for {case['short']} ...")
        result = solve_density_case(case)
        results.append(result)

        if not result["sol_photo_success"]:
            print(
                f"  WARNING: photo-only solver for {case['short']}: "
                f"{result['sol_photo_message']}"
            )
        if not result["sol_total_success"]:
            print(
                f"  WARNING: total solver for {case['short']}: "
                f"{result['sol_total_message']}"
            )

    if results:
        display_summary_table(build_summary_table(results))
    else:
        print("No density table entries were solved because no reference inputs are available.")


def run_first_last_table_workflow(
    cases: Sequence[CaseDict],
    points: int,
    save_dir: Optional[Path],
) -> None:
    """Run the enabled NIR workflow: rate curves and density table."""

    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    solve_and_display_summary(cases)
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=points,
        include_field_factor_two=True,
        save_dir=save_dir,
    )


def run_all_plots_workflow(
    cases: Sequence[CaseDict],
    points: int,
    save_dir: Optional[Path],
) -> None:
    """Run the compact workflow plus all plots."""

    # Save the complete 2D figure set before the slower density-summary and
    # 3D calculations.  This makes a normal VS Code run populate the output
    # folder promptly, rather than leaving only the first graph while the
    # long numerical stages are still running.
    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    plot_baf2_figures(
        cases=cases,
        n_intensity_points=points,
        save_dir=save_dir,
    )
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=points,
        include_field_factor_two=True,
        save_dir=save_dir,
    )
    solve_and_display_summary(cases)
    plot_total_ionization_3d_surface_grid(
        cases=cases,
        save_dir=save_dir,
        n_intensity_points=points,
        n_density_points=80,
    )


def build_argument_parser() -> argparse.ArgumentParser:
    """Construct the command-line argument parser."""

    parser = argparse.ArgumentParser(
        description=(
            "Run the reconciled BaF2 Keldysh + avalanche model and "
            "generate the requested graph sets."
        )
    )
    # CODEX MODIFICATION START: add 3D plotting mode
    parser.add_argument(
        "--mode",
        choices=("all", "summary", "figures", "3d", "first-last", "dis"),
        default="all",
        help=(
            "all: all BaF2 plots and table; summary: first/last graph sets "
            "and table; figures: BaF2 Figs. 1-4; 3d: total-ionization "
            "surface. first-last and dis are retained as legacy aliases."
        ),
    )
    # CODEX MODIFICATION END: add 3D plotting mode
    parser.add_argument(
        "--points",
        type=int,
        default=50,
        help="Number of intensity points used in scaling plots.",
    )
    parser.add_argument(
        "--save",
        action="store_true",
        default=True,
        help=(
            "Save every currently enabled BaF2 figure and labeled numerical variables "
            "(the default behavior)."
        ),
    )
    parser.add_argument(
        "--no-save",
        action="store_false",
        dest="save",
        help="Do not save files; use --mode for an interactive, selective plot run.",
    )
    # CODEX MODIFICATION START: optional open saved image preview
    parser.add_argument(
        "--open-after-save",
        action="store_true",
        help="Open saved PNG figures with the system image viewer after saving.",
    )
    # CODEX MODIFICATION END: optional open saved image preview
    # CODEX MODIFICATION START: optional editable figure exports
    parser.add_argument(
        "--editable",
        action="store_true",
        help=(
            "Retained for compatibility. Saved figures automatically include "
            "a .mplfig.pkl editable Matplotlib file."
        ),
    )
    # CODEX MODIFICATION END: optional editable figure exports
    # CODEX MODIFICATION START: display all Matplotlib windows after plotting
    parser.add_argument(
        "--show-at-end",
        action="store_true",
        help=(
            "Generate all requested figures first, then display them together. "
            "Can be combined with --save."
        ),
    )
    # CODEX MODIFICATION END: display all Matplotlib windows after plotting
    parser.add_argument(
        "--outdir",
        type=str,
        default=str(
            Path(__file__).resolve().parent
            / "figures_Keldysh_II"
            / "figures_Keldsyh_II_BaF2"
        ),
        help="Directory used for the default automatic saving behavior.",
    )
    # CODEX MODIFICATION START: CLI support for 3D surface plot
    parser.add_argument(
        "--case-index",
        type=int,
        default=None,
        choices=range(2),
        metavar="{0,1}",
        help=(
            "Optional case used by --mode 3d: 0 BaF2_NIR, 1 BaF2_LWIR. "
            "If omitted, all enabled cases are plotted."
        ),
    )
    parser.add_argument(
        "--density-points",
        type=int,
        default=80,
        help="Number of electron-density points used by --mode 3d.",
    )
    # CODEX MODIFICATION END: CLI support for 3D surface plot
    return parser


def main(argv: Optional[List[str]] = None) -> None:
    """
    Parse command-line options and run the selected workflow.

    In Jupyter, use ``main([])`` for the default all-plots workflow or, for
    a faster test, ``main(["--mode", "first-last", "--points", "12"])``.
    """

    parser = build_argument_parser()
    args, _unknown = parser.parse_known_args(argv)

    if args.points < 2:
        parser.error("--points must be at least 2.")
    # CODEX MODIFICATION START: validate 3D density grid size
    if args.density_points < 2:
        parser.error("--density-points must be at least 2.")
    # CODEX MODIFICATION END: validate 3D density grid size

    cases = get_cases()
    report_case_input_uncertainties(cases)
    report_threshold_fluence_comparison(cases)
    save_dir = Path(args.outdir) if args.save else None

    # CODEX MODIFICATION START: display all Matplotlib windows after plotting
    global DEFER_FIGURE_SHOW
    DEFER_FIGURE_SHOW = bool(args.show_at_end)
    # CODEX MODIFICATION END: display all Matplotlib windows after plotting

    # CODEX MODIFICATION START: automatic editable figure exports
    global SAVE_EDITABLE_FIGURES
    SAVE_EDITABLE_FIGURES = bool(args.save)
    # CODEX MODIFICATION END: automatic editable figure exports

    # CODEX MODIFICATION START: optional open saved image preview
    global OPEN_SAVED_FIGURES
    OPEN_SAVED_FIGURES = bool(args.open_after_save and args.save)
    # CODEX MODIFICATION END: optional open saved image preview

    # Saving is deliberately comprehensive, matching the various-material
    # workflow: one saved run updates every currently enabled figure as well
    # as the corresponding numerical exports.  Selective --mode choices are
    # retained for interactive, non-saving use.
    if args.save:
        run_all_plots_workflow(cases, args.points, save_dir)
    elif args.mode in ("summary", "first-last"):
        run_first_last_table_workflow(cases, args.points, save_dir)
    elif args.mode in ("figures", "dis"):
        plot_baf2_figures(cases, args.points, save_dir)
    # CODEX MODIFICATION START: CLI support for 3D surface plot
    elif args.mode == "3d":
        if args.case_index is None:
            plot_total_ionization_3d_surface_grid(
                cases=cases,
                save_dir=save_dir,
                n_intensity_points=args.points,
                n_density_points=args.density_points,
            )
        else:
            plot_total_ionization_3d_surface(
                case=cases[args.case_index],
                save_dir=save_dir,
                n_intensity_points=args.points,
                n_density_points=args.density_points,
            )
    # CODEX MODIFICATION END: CLI support for 3D surface plot
    else:
        run_all_plots_workflow(cases, args.points, save_dir)

    if args.save:
        assert save_dir is not None
        save_baf2_plot_variables(
            cases=cases,
            output_dir=save_dir / "saved_variables",
            component_n_intensity_points=args.points,
            total_n_intensity_points=args.points,
            surface_n_intensity_points=args.points,
            surface_n_density_points=args.density_points,
        )

    # CODEX MODIFICATION START: display all Matplotlib windows after plotting
    if DEFER_FIGURE_SHOW:
        plt.show(block=True)
    # CODEX MODIFICATION END: display all Matplotlib windows after plotting


if __name__ == "__main__":
    main()


====================================================================================================
FILE: Keldysh\Keldsyh_II_NaCl.py
====================================================================================================

# NaCl-only Keldysh + avalanche-ionization workflow.
# Standalone NaCl Keldysh + avalanche-ionization workflow.

# %%
# Cell 0
"""
Reconciled Keldysh + avalanche ionization model for NaCl.

The script evaluates
--------------------
1. Full Keldysh photoionization rate, W_PI.
2. Avalanche/impact ionization using a Drude absorption cross section,

       W_av(I, n_e) = [sigma(I, n_e) I / E_g] n_e,

   with

       sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2),

       tau_C = 16 pi eps0^2 sqrt[m_r (0.1 E_g)^3]
               / [sqrt(2) e^4 n_e].

3. Time-dependent carrier-density growth,

       dn_e/dt = W_PI(t) + W_av(I(t), n_e(t)).

Model assumptions
-----------------
* Recombination and trapping are neglected.
* Carrier depletion and saturation are neglected.
* Propagation, self-focusing, and laser-induced changes in optical constants
  are neglected.
* The same linear refractive index is used in the Keldysh and Drude terms.
* The temporal pulse is Gaussian and centered at t = 0.
* The integration window is from -3 tau to +3 tau, where tau is the
  intensity FWHM duration.

Units
-----
* Internal calculations: SI units.
* Input fluence: J/cm^2.
* Input irradiance for scaling plots: W/cm^2.
* Wavelength: micrometers.
* Pulse duration: femtoseconds.
* Summary densities: cm^-3.
* Final rate plot: cm^-3 fs^-1.

Default workflow
----------------
The default ``--mode all`` execution produces the NaCl 0.8-um reference
case specified in ``NaCl_Keldysh_Parameter.docx``.  The document supplies
the peak intensity but not a pulse duration; 100 fs is therefore a clearly
marked provisional duration used only by the time-domain calculations.
"""


from __future__ import annotations

import argparse
import csv
import json
import os
import pickle
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple, Union

# CODEX MODIFICATION START: shared colormap normalization for 3D colorbar
from matplotlib import cm, colors
# CODEX MODIFICATION END: shared colormap normalization for 3D colorbar
import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import dawsn, ellipe, ellipk

try:
    import pandas as pd
except ImportError:
    pd = None

try:
    from IPython.display import display as ipython_display
except ImportError:
    ipython_display = None


# ============================================================
# Constants
# ============================================================

# CODEX MODIFICATION START: constants from NaCl verified reference / CODATA
C0 = 299792458.0
EPS0 = 8.8541878188e-12
E_CHARGE = 1.602176634e-19
HBAR = 1.054571817e-34
ME0 = 9.1093837139e-31
# CODEX MODIFICATION END: constants from NaCl verified reference / CODATA

CM3_PER_M3 = 1.0e-6
WCM2_PER_WM2 = 1.0e-4
WM2_PER_WCM2 = 1.0e4
RATE_CM3_FS_PER_M3_S = 1.0e-21

CaseDict = Dict[str, Any]
ArrayLike = Union[np.ndarray, float]

# CODEX MODIFICATION START: optional deferred Matplotlib display
DEFER_FIGURE_SHOW = False
# CODEX MODIFICATION END: optional deferred Matplotlib display

# CODEX MODIFICATION START: automatic editable figure exports
# Every saved PNG is accompanied by a Matplotlib-editable .mplfig.pkl file.
SAVE_EDITABLE_FIGURES = True
# CODEX MODIFICATION END: automatic editable figure exports

# CODEX MODIFICATION START: optional open saved image preview
OPEN_SAVED_FIGURES = False
# CODEX MODIFICATION END: optional open saved image preview


# ============================================================
# Material properties
# ============================================================

# Source: NaCl_Keldysh_Parameter.docx (297 K, reference example).
# mred = m0 is an explicitly documented reference assumption, not a uniquely
# measured NaCl electron-hole reduced mass.
# The document reports gamma = 2.34 when I = (1/2)c*n*eps0*E^2 is used and
# gamma = 3.30 under the alternate convention without the factor of two.
# This model uses the first convention throughout, matching its electric-field
# conversion in keldysh_full_rate_m3_s.
NACL_INPUT: Dict[str, Any] = {
    "reference_file": "NaCl_Keldysh_Parameter.docx",
    "material": {
        "name": "NaCl",
        "mat_flag": 1,
        "bandgap_ev": 8.5,
        "mred_over_me": 1.0,
        "parameter_status": (
            "Reference calculation inputs from NaCl_Keldysh_Parameter.docx: "
            "mred = 1.0 m0 and Eg = 8.5 eV. The document identifies mred "
            "as a reference assumption; replace it with band-specific "
            "electron and hole effective masses for final simulations."
        ),
        "n2_m2_per_w": np.nan,
        "li_dispersion_297k": {
            "wavelength_unit": "um",
            "valid_wavelength_um": (0.20, 30.0),
            "constant": 0.00055,
            "terms": (
                (0.19800, 0.050),
                (0.48398, 0.100),
                (0.38696, 0.128),
                (0.25998, 0.158),
                (0.08796, 40.50),
                (3.17064, 60.98),
                (0.30038, 120.34),
            ),
        },
    },
    "cases": [
        {
            "name": r"NaCl, 0.8 $\mu$m",
            "short": "NaCl_NIR",
            "material": "NaCl",
            "region": "NIR",
            "mat_flag": 1,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "pulse_energy_uj": 150.0,
            "beam_diameter_a_um": 226.6,
            "beam_diameter_b_um": 429.7,
            "reference_I0_wcm2": None,
            "F0_jcm2": None,
            "input_note": (
                "NaCl case: 150 uJ pulse energy and the BaF2 elliptical "
                "beam diameters a = 226.6 um and b = 429.7 um. Peak "
                "fluence is calculated as F0 = 2E/(pi*r_a*r_b). The "
                "100 fs duration is provisional because it is not specified "
                "in NaCl_Keldysh_Parameter.docx."
            ),
        },
        {
            "name": r"NaCl, 9.2 $\mu$m",
            "short": "NaCl_LWIR",
            "material": "NaCl",
            "region": "LWIR",
            "mat_flag": 1,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "reference_I0_wcm2": None,
            "F0_jcm2": 2.63,
            "input_note": (
                "User-supplied LWIR LIDT condition: 9.2 um, 2 ps, "
                "F0 = 2.63 J/cm^2."
            ),
        },
    ],
}

# CODEX MODIFICATION START: NaCl-only material parameters
def material_flag1(
    mat_flag: int,
    wavelength_um: float,
) -> Tuple[float, float, float, float, float]:
    """
    Return wavelength-dependent material parameters for NaCl.

    Parameters
    ----------
    mat_flag:
        Material selector. This NaCl-optimized script uses only 1 for NaCl.
    wavelength_um:
        Vacuum wavelength in micrometers.

    Returns
    -------
    n0:
        Linear refractive index.
    n2:
        Nonlinear refractive index in m^2/W. This field is retained for
        compatibility with the original script; it is not specified in the
        NaCl Keldysh-parameter reference document.
    Eg_J:
        Bandgap energy in joules.
    mred:
        Reduced electron-hole effective mass in kilograms.
    trans:
        Approximate transmission factor, 1 - R.

    Raises
    ------
    ValueError
        If the material flag is not 1, or if the Li dispersion expression
        becomes nonphysical at the requested wavelength.
    """

    lam = float(wavelength_um)
    if lam <= 0.0:
        raise ValueError("wavelength_um must be positive.")

    if mat_flag != 1:
        raise ValueError("mat_flag must be 1 for NaCl.")

    material_input = NACL_INPUT["material"]
    bandgap_ev = float(material_input["bandgap_ev"])
    mred = float(material_input["mred_over_me"]) * ME0
    dispersion = material_input["li_dispersion_297k"]
    valid_min, valid_max = dispersion["valid_wavelength_um"]
    if not valid_min <= lam <= valid_max:
        raise ValueError(
            f"NaCl Li dispersion is validated for {valid_min}-{valid_max} um; "
            f"received {lam} um."
        )

    n_squared = 1.0 + float(dispersion["constant"])
    for coefficient, resonance_um in dispersion["terms"]:
        n_squared += coefficient * lam**2 / (lam**2 - resonance_um**2)

    n2 = float(material_input["n2_m2_per_w"])

    if not np.isfinite(n_squared) or n_squared <= 0.0:
        raise ValueError(
            f"Nonphysical Li-dispersion result n^2={n_squared!r} at {lam} um."
        )

    n0 = np.sqrt(n_squared)
    reflectance = ((n0 - 1.0) / (n0 + 1.0)) ** 2
    Eg_J = bandgap_ev * E_CHARGE
    trans = 1.0 - reflectance

    return float(n0), float(n2), float(Eg_J), float(mred), float(trans)
# CODEX MODIFICATION END: NaCl-only material parameters


# CODEX MODIFICATION START: NaCl-only case definitions
def get_cases() -> List[CaseDict]:
    """
    Return the currently enabled NaCl NIR and LWIR cases.

    Returns
    -------
    list of dict
        Two NaCl material/laser case dictionaries.
    """

    cases: List[CaseDict] = []
    for case_input in NACL_INPUT["cases"]:
        case = dict(case_input)
        if case.get("pulse_energy_uj") is not None:
            case["F0_jcm2"] = elliptical_gaussian_peak_fluence_jcm2(
                pulse_energy_uj=float(case["pulse_energy_uj"]),
                beam_diameter_a_um=float(case["beam_diameter_a_um"]),
                beam_diameter_b_um=float(case["beam_diameter_b_um"]),
            )
        cases.append(case)
    return cases
# CODEX MODIFICATION END: NaCl-only case definitions


# ============================================================
# Laser pulse conversion
# ============================================================

def elliptical_gaussian_peak_fluence_jcm2(
    pulse_energy_uj: float,
    beam_diameter_a_um: float,
    beam_diameter_b_um: float,
) -> float:
    """Return peak fluence for an elliptical Gaussian beam in J/cm^2.

    The measured diameters are converted to radii before evaluating

        F = 2 E / (pi a b),

    where ``a`` and ``b`` are the supplied beam radii. This is the on-axis
    (peak) spatial fluence, which is then converted to peak temporal
    intensity by :func:`peak_intensity_from_fluence_wm2`.
    """

    energy_j = float(pulse_energy_uj) * 1.0e-6
    radius_a_cm = 0.5 * float(beam_diameter_a_um) * 1.0e-4
    radius_b_cm = 0.5 * float(beam_diameter_b_um) * 1.0e-4

    if energy_j <= 0.0:
        raise ValueError("pulse_energy_uj must be positive.")
    if radius_a_cm <= 0.0 or radius_b_cm <= 0.0:
        raise ValueError("Both beam diameters must be positive.")

    return float(2.0 * energy_j / (np.pi * radius_a_cm * radius_b_cm))


def peak_intensity_from_fluence_wm2(F0_jcm2: float, tau_fs: float) -> float:
    """
    Convert peak fluence to peak intensity for a Gaussian temporal pulse.

    For a Gaussian intensity envelope with FWHM duration tau,

        I0 = (2 F0 / tau) sqrt[ln(2)/pi].

    Parameters
    ----------
    F0_jcm2:
        Peak fluence in J/cm^2.
    tau_fs:
        Intensity FWHM duration in femtoseconds.

    Returns
    -------
    float
        Peak intensity in W/m^2.
    """

    F0_jm2 = float(F0_jcm2) * 1.0e4
    tau_s = float(tau_fs) * 1.0e-15

    if F0_jm2 < 0.0:
        raise ValueError("Fluence must be nonnegative.")
    if tau_s <= 0.0:
        raise ValueError("Pulse duration must be positive.")

    return float((2.0 * F0_jm2 / tau_s) * np.sqrt(np.log(2.0) / np.pi))


def gaussian_intensity_time(t_s: float, I0_wm2: float, tau_s: float) -> float:
    """
    Evaluate a Gaussian temporal intensity profile.

    The profile is

        I(t) = I0 exp[-4 ln(2) (t/tau)^2],

    where tau is the intensity FWHM duration.

    Parameters
    ----------
    t_s:
        Time in seconds.
    I0_wm2:
        Peak intensity in W/m^2.
    tau_s:
        Intensity FWHM duration in seconds.

    Returns
    -------
    float
        Instantaneous intensity in W/m^2.
    """

    if tau_s <= 0.0:
        raise ValueError("tau_s must be positive.")

    return float(I0_wm2 * np.exp(-4.0 * np.log(2.0) * (t_s / tau_s) ** 2))


# ============================================================
# Keldysh photoionization model
# ============================================================

def qfun_keldysh(
    gamma: np.ndarray,
    x: np.ndarray,
    Kg: np.ndarray,
    Eg: np.ndarray,
    K1: np.ndarray,
    E1: np.ndarray,
    tol: float = 1.0e-3,
    max_terms: int = 10000,
) -> np.ndarray:
    """
    Evaluate the Keldysh Q-function series.

    Parameters
    ----------
    gamma:
        Keldysh parameter array.
    x:
        Effective photon-order argument.
    Kg, Eg, K1, E1:
        Complete elliptic-integral terms appearing in the Keldysh expression.
    tol:
        Absolute change in the partial sum used as the convergence criterion.
    max_terms:
        Maximum number of series terms.

    Returns
    -------
    np.ndarray
        Keldysh Q-function values.
    """

    gamma = np.atleast_1d(np.asarray(gamma, dtype=float))
    x = np.atleast_1d(np.asarray(x, dtype=float))
    Kg = np.atleast_1d(np.asarray(Kg, dtype=float))
    Eg = np.atleast_1d(np.asarray(Eg, dtype=float))
    K1 = np.atleast_1d(np.asarray(K1, dtype=float))
    E1 = np.atleast_1d(np.asarray(E1, dtype=float))

    arrays = [gamma, x, Kg, Eg, K1, E1]
    if len({arr.size for arr in arrays}) != 1:
        raise ValueError("All qfun_keldysh input arrays must have the same size.")

    q_values = np.zeros_like(gamma)

    for i in range(gamma.size):
        values = [gamma[i], x[i], Kg[i], Eg[i], K1[i], E1[i]]
        if not all(np.isfinite(v) for v in values) or K1[i] <= 0.0 or E1[i] <= 0.0:
            continue

        q_prefactor = np.sqrt(np.pi / (2.0 * K1[i]))
        q_sum = 0.0

        for j in range(max_terms):
            old_sum = q_sum
            exponent = -np.pi * (Kg[i] - Eg[i]) * j / E1[i]
            arg_inside = (
                np.pi**2
                * (2.0 * np.floor(x[i] + 1.0) - 2.0 * x[i] + j)
                / (2.0 * K1[i] * E1[i])
            )
            arg_inside = max(float(arg_inside), 0.0)

            with np.errstate(over="ignore", invalid="ignore", under="ignore"):
                term = np.exp(exponent) * dawsn(np.sqrt(arg_inside))

            if not np.isfinite(term):
                term = 0.0

            q_sum += float(term)

            if abs(q_sum - old_sum) <= tol:
                break

        q_values[i] = q_prefactor * q_sum

    return np.nan_to_num(q_values, nan=0.0, posinf=0.0, neginf=0.0)


def keldysh_full_rate_m3_s(
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
    intensity_wm2: ArrayLike,
) -> ArrayLike:
    """
    Evaluate the full Keldysh photoionization rate.

    Parameters
    ----------
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.
    intensity_wm2:
        Scalar or array of laser intensities in W/m^2.

    Returns
    -------
    float or np.ndarray
        Photoionization rate in m^-3 s^-1.
    """

    intensity = np.asarray(intensity_wm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    rate = np.zeros_like(intensity)
    positive = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(positive):
        I = intensity[positive]

        with np.errstate(divide="ignore", invalid="ignore", over="ignore", under="ignore"):
            # I is the cycle-averaged intensity; Keldysh gamma uses the
            # peak electric-field amplitude E0, for which
            # I = (1/2) c n0 eps0 E0^2.
            electric_field = np.sqrt((2.0 * I) / (C0 * n0 * EPS0))
            gamma = (omega / (E_CHARGE * electric_field)) * np.sqrt(mred * delta_J)
            gamma_sq = gamma**2

            gg = gamma_sq / (1.0 + gamma_sq)
            g1 = 1.0 / (1.0 + gamma_sq)

            Kg = ellipk(gg)
            Eg = ellipe(gg)
            K1 = ellipk(g1)
            E1 = ellipe(g1)

            delta_tilde = (
                2.0
                * delta_J
                * np.sqrt(1.0 + gamma_sq)
                * E1
                / (np.pi * gamma)
            )
            x_order = delta_tilde / (HBAR * omega)
            X = np.floor(x_order + 1.0)

            prefactor = (
                2.0
                * omega
                / (9.0 * np.pi)
                * (
                    (np.sqrt(1.0 + gamma_sq) * mred * omega)
                    / (gamma * HBAR)
                )
                ** 1.5
            )

            q_values = qfun_keldysh(gamma, x_order, Kg, Eg, K1, E1)
            exponential = np.exp(-np.pi * X * (Kg - Eg) / E1)
            rate_positive = prefactor * q_values * exponential

        rate[positive] = np.nan_to_num(
            rate_positive,
            nan=0.0,
            posinf=0.0,
            neginf=0.0,
        )

    if scalar_input:
        return float(rate[0])
    return rate


# ============================================================
# Avalanche / impact-ionization model
# ============================================================

def collision_time_s(ne_m3: float, mred: float, delta_J: float) -> float:
    """
    Evaluate the electron collision time used in the Drude model.

    Parameters
    ----------
    ne_m3:
        Conduction-band electron density in m^-3.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.

    Returns
    -------
    float
        Collision time in seconds. Returns infinity at zero density.
    """

    ne = max(float(ne_m3), 0.0)
    if ne <= 0.0:
        return np.inf

    numerator = 16.0 * np.pi * EPS0**2 * np.sqrt(mred * (0.1 * delta_J) ** 3)
    denominator = np.sqrt(2.0) * E_CHARGE**4 * ne
    # CODEX MODIFICATION START: avoid divide-by-zero warning at tiny density
    if denominator <= 0.0 or not np.isfinite(denominator):
        return np.inf
    # CODEX MODIFICATION END: avoid divide-by-zero warning at tiny density
    tau_c = numerator / denominator

    if not np.isfinite(tau_c) or tau_c <= 0.0:
        return np.inf

    return float(tau_c)


def drude_cross_section_m2(
    omega: float,
    mred: float,
    n0: float,
    tau_c_s: float,
) -> float:
    """
    Evaluate the Drude single-photon absorption cross section safely.

    The direct expression is

        sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2).

    To avoid overflow for very large collision times, it is evaluated as

        sigma = [e^2/(c eps0 n0 m_r)] / omega
                * [(omega tau_C)/(1 + (omega tau_C)^2)].

    Parameters
    ----------
    omega:
        Angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    n0:
        Linear refractive index.
    tau_c_s:
        Collision time in seconds.

    Returns
    -------
    float
        Drude absorption cross section in m^2.
    """

    tau_c = float(tau_c_s)

    if (
        not np.isfinite(tau_c)
        or tau_c <= 0.0
        or not np.isfinite(omega)
        or omega <= 0.0
        or mred <= 0.0
        or n0 <= 0.0
    ):
        return 0.0

    prefactor = E_CHARGE**2 / (C0 * EPS0 * n0 * mred)
    x = omega * tau_c

    if not np.isfinite(x) or x <= 0.0:
        return 0.0

    if x > 1.0e100:
        drude_factor = 1.0 / x
    else:
        drude_factor = x / (1.0 + x * x)

    sigma = (prefactor / omega) * drude_factor

    if not np.isfinite(sigma) or sigma < 0.0:
        return 0.0

    return float(sigma)


def avalanche_generation_rate_m3_s(
    intensity_wm2: float,
    ne_m3: float,
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
) -> float:
    """
    Evaluate the avalanche/impact-ionization carrier-generation rate.

    The implemented relation is

        W_av = (sigma I / E_g) n_e.

    Parameters
    ----------
    intensity_wm2:
        Instantaneous laser intensity in W/m^2.
    ne_m3:
        Instantaneous electron density in m^-3.
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.

    Returns
    -------
    float
        Avalanche generation rate in m^-3 s^-1.
    """

    I = max(float(intensity_wm2), 0.0)
    ne = max(float(ne_m3), 0.0)

    if I <= 0.0 or ne <= 0.0 or delta_J <= 0.0:
        return 0.0

    tau_c = collision_time_s(ne, mred, delta_J)
    sigma = drude_cross_section_m2(
        omega=omega,
        mred=mred,
        n0=n0,
        tau_c_s=tau_c,
    )

    if sigma <= 0.0:
        return 0.0

    W_av = (sigma * I / delta_J) * ne

    if not np.isfinite(W_av) or W_av < 0.0:
        return 0.0

    return float(W_av)


# ============================================================
# General helpers
# ============================================================

def positive_for_log(y: np.ndarray, min_value: float = 1.0e-300) -> np.ndarray:
    """
    Replace nonfinite and nonpositive values with NaN for logarithmic plotting.
    """

    y_plot = np.asarray(y, dtype=float).copy()
    y_plot[~np.isfinite(y_plot)] = np.nan
    y_plot[y_plot <= min_value] = np.nan
    return y_plot


# CODEX MODIFICATION START: optional LIDT fluence and reference peak intensity
def case_has_reference_peak_intensity(case: CaseDict) -> bool:
    """Return True when a case has a verified/reference point intensity."""

    return case.get("reference_I0_wcm2") is not None or case.get("F0_jcm2") is not None


def report_case_input_uncertainties(cases: Sequence[CaseDict]) -> None:
    """Report cases whose inputs are incomplete instead of silently assuming them."""

    uncertain_cases = [
        case for case in cases if not case_has_reference_peak_intensity(case)
    ]
    if not uncertain_cases:
        return

    print("\n================ Input uncertainty report ================\n")
    for case in uncertain_cases:
        note = case.get(
            "input_note",
            "No verified reference_I0_wcm2 or measured F0_jcm2 is provided.",
        )
        print(f"{case['short']}: {note}")
        print(
            "  Reference-point density table entries, time-domain Fig. 3, "
            "and reference markers will be skipped for this case."
        )
        print(
            "  Intensity-scan plots and 3D surfaces can still run because "
            "their intensities are explicit plot axes.\n"
        )


def case_reference_peak_intensity_wcm2(case: CaseDict) -> float:
    """
    Return the peak intensity used for time-domain density calculations.

    Use a direct reference intensity when one is supplied. Otherwise,
    calculate the Gaussian pulse peak intensity from the supplied fluence.
    """

    reference_I0 = case.get("reference_I0_wcm2")
    if reference_I0 is not None:
        reference_I0 = float(reference_I0)
        if reference_I0 <= 0.0:
            raise ValueError("reference_I0_wcm2 must be positive.")
        return reference_I0

    I_lidt = case_lidt_peak_intensity_wcm2(case)
    if I_lidt is None:
        raise ValueError(
            f"Case {case['short']} must define reference_I0_wcm2 or F0_jcm2."
        )
    return I_lidt


def case_peak_intensity_source(case: CaseDict) -> str:
    """Return a short label describing the peak-intensity input source."""

    if case.get("reference_I0_wcm2") is not None:
        return "reference_I0_wcm2"
    if case.get("F0_jcm2") is not None:
        return "F0_jcm2"
    return "missing"


def case_marker_peak_intensity_wcm2(case: CaseDict) -> Optional[Tuple[float, str]]:
    """Return the intensity marker and label used in scaling plots."""

    I_from_fluence = case_lidt_peak_intensity_wcm2(case)
    if I_from_fluence is not None:
        return I_from_fluence, r"$I_0$ from pulse energy"
    if case.get("reference_I0_wcm2") is not None:
        return case_reference_peak_intensity_wcm2(case), r"$I_0$ reference"
    return None


def case_lidt_peak_intensity_wcm2(case: CaseDict) -> Optional[float]:
    """
    Return the Gaussian peak intensity calculated from fluence in W/cm^2.

    Returns None when the case has no measured LIDT fluence.
    """

    F0_jcm2 = case.get("F0_jcm2")
    if F0_jcm2 is None:
        return None

    return (
        peak_intensity_from_fluence_wm2(
            F0_jcm2=F0_jcm2,
            tau_fs=case["tau_fs"],
        )
        * WCM2_PER_WM2
    )
# CODEX MODIFICATION END: optional LIDT fluence and reference peak intensity


def interpolate_log_y(
    x: np.ndarray,
    y: np.ndarray,
    x0: float,
) -> Optional[float]:
    """
    Interpolate y(x0) in log-log space.

    Returns None when x0 lies outside the valid positive data range.
    """

    x_arr = np.asarray(x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    valid = np.isfinite(x_arr) & np.isfinite(y_arr) & (x_arr > 0.0) & (y_arr > 0.0)

    if np.count_nonzero(valid) < 2:
        return None

    x_valid = x_arr[valid]
    y_valid = y_arr[valid]
    order = np.argsort(x_valid)
    x_valid = x_valid[order]
    y_valid = y_valid[order]

    if x0 < x_valid[0] or x0 > x_valid[-1]:
        return None

    log_y0 = np.interp(
        np.log10(x0),
        np.log10(x_valid),
        np.log10(y_valid),
    )
    return float(10.0**log_y0)


def save_or_show(
    fig: plt.Figure,
    save_dir: Optional[Path],
    filename: str,
    apply_tight_layout: bool = True,
) -> None:
    """
    Apply tight layout and either save or display a Matplotlib figure.
    """

    # CODEX MODIFICATION START: allow manually arranged 3D figures
    if apply_tight_layout:
        # Reserve space for figure-level titles; otherwise long LWIR axis
        # labels can push a suptitle against the top edge of a saved PNG.
        fig.tight_layout(rect=(0.0, 0.0, 1.0, 0.96))
    # CODEX MODIFICATION END: allow manually arranged 3D figures

    if save_dir is not None:
        save_dir.mkdir(parents=True, exist_ok=True)
        output_path = save_dir / filename
        fig.savefig(output_path, dpi=300, bbox_inches="tight")
        print(f"Saved {output_path}")
        # CODEX MODIFICATION START: optional open saved image preview
        if OPEN_SAVED_FIGURES and hasattr(os, "startfile"):
            os.startfile(output_path)
        # CODEX MODIFICATION END: optional open saved image preview
        # Temporarily disabled: editable Matplotlib .mplfig.pkl export.
        # Uncomment this block to restore Python-figure saving.
        # if SAVE_EDITABLE_FIGURES:
        #     editable_path = output_path.with_suffix(".mplfig.pkl")
        #     with editable_path.open("wb") as editable_file:
        #         pickle.dump(fig, editable_file)
        #     print(f"Saved editable Matplotlib figure {editable_path}")
        # CODEX MODIFICATION START: allow saved figures to display at end
        if DEFER_FIGURE_SHOW:
            print(f"Prepared saved figure for display: {filename}")
        else:
            plt.close(fig)
        # CODEX MODIFICATION END: allow saved figures to display at end
    else:
        # CODEX MODIFICATION START: optional deferred Matplotlib display
        if DEFER_FIGURE_SHOW:
            print(f"Prepared figure for display: {filename}")
        else:
            plt.show()
        # CODEX MODIFICATION END: optional deferred Matplotlib display


# ============================================================
# Time-dependent dynamics
# ============================================================

def solve_dynamics_from_peak_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 1000,
) -> Dict[str, Any]:
    """
    Solve total carrier-density dynamics at a specified peak intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I0_wcm2:
        Peak laser intensity in W/cm^2.
    n_time_points:
        Number of points used for post-processing the dense ODE solution.

    Returns
    -------
    dict
        Time-dependent photoionization, avalanche, total rates, and density.
    """

    if I0_wcm2 < 0.0:
        raise ValueError("I0_wcm2 must be nonnegative.")
    if n_time_points < 2:
        raise ValueError("n_time_points must be at least 2.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = float(I0_wcm2) * WM2_PER_WCM2

    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )

        derivative = W_pi + W_av
        if not np.isfinite(derivative) or derivative < 0.0:
            derivative = 0.0

        return [float(derivative)]

    solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-5,
        atol=1.0e6,
        max_step=tau_s / 350.0,
        dense_output=True,
    )

    t_eval = np.linspace(t0, t1, n_time_points)

    if solution.sol is not None:
        ne = np.maximum(solution.sol(t_eval)[0], 0.0)
    else:
        ne = np.maximum(np.interp(t_eval, solution.t, solution.y[0]), 0.0)

    intensity = np.asarray([intensity_at_time(t) for t in t_eval], dtype=float)
    Wpi = np.asarray([photo_rate_at_time(t) for t in t_eval], dtype=float)
    Wav = np.asarray(
        [
            avalanche_generation_rate_m3_s(
                intensity_wm2=I_now,
                ne_m3=ne_now,
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )
            for I_now, ne_now in zip(intensity, ne)
        ],
        dtype=float,
    )
    Wtotal = Wpi + Wav

    return {
        "case": case,
        "t_s": t_eval,
        "intensity_wm2": intensity,
        "Wpi_m3_s": Wpi,
        "Wav_m3_s": Wav,
        "Wtotal_m3_s": Wtotal,
        "Wpi_cm3_fs": Wpi * RATE_CM3_FS_PER_M3_S,
        "Wav_cm3_fs": Wav * RATE_CM3_FS_PER_M3_S,
        "Wtotal_cm3_fs": Wtotal * RATE_CM3_FS_PER_M3_S,
        "ne_m3": ne,
        "ne_cm3": ne * CM3_PER_M3,
        "solver_success": bool(solution.success),
        "solver_message": str(solution.message),
    }


SCALING_CACHE: Dict[Tuple[str, int, float, float, int], Dict[str, np.ndarray]] = {}


def compute_case_scaling(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 600,
) -> Dict[str, np.ndarray]:
    """
    Compute the peak total ionization rate versus peak laser intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        One-dimensional array of peak intensities in W/cm^2.
    n_time_points:
        Number of post-processing time points per ODE solution.

    Returns
    -------
    dict
        Intensity array and peak total ionization-rate array.
    """

    intensity_values = np.asarray(I_values_wcm2, dtype=float)

    if intensity_values.ndim != 1 or intensity_values.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensity_values)) or np.any(intensity_values <= 0.0):
        raise ValueError("All intensity values must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensity_values.size),
        float(intensity_values[0]),
        float(intensity_values[-1]),
        int(n_time_points),
    )

    if cache_key in SCALING_CACHE:
        return SCALING_CACHE[cache_key]

    Wtotal_peak = np.zeros_like(intensity_values)
    print(f"\nComputing intensity scaling for {case['short']} ...")

    report_interval = max(1, intensity_values.size // 10)

    for index, I0_wcm2 in enumerate(intensity_values):
        if index % report_interval == 0 or index == intensity_values.size - 1:
            print(
                f"  {index + 1:3d}/{intensity_values.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2 reported: {result['solver_message']}"
            )

        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(
                result["Wtotal_cm3_fs"],
                nan=0.0,
                posinf=0.0,
                neginf=0.0,
            )
        )

    output = {
        "I_wcm2": intensity_values,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
    }
    SCALING_CACHE[cache_key] = output
    return output


def direct_peak_total_rate_at_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 600,
) -> float:
    """Solve at one specified intensity instead of interpolating a scan."""

    scaling = compute_case_scaling(
        case=case,
        I_values_wcm2=np.asarray([float(I0_wcm2)]),
        n_time_points=n_time_points,
    )
    return float(scaling["Wtotal_peak_cm3_fs"][0])


def solve_density_case(case: CaseDict) -> Dict[str, Any]:
    """
    Solve photoionization-only and photoionization-plus-avalanche density growth.

    Parameters
    ----------
    case:
        Material/laser case dictionary.

    Returns
    -------
    dict
        Material parameters, peak intensity, final densities, and solver status.
    """

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = case_reference_peak_intensity_wcm2(case) * WM2_PER_WCM2

    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_photo(t: float, _y: np.ndarray) -> List[float]:
        return [photo_rate_at_time(t)]

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )
        derivative = W_pi + W_av
        return [float(max(derivative, 0.0)) if np.isfinite(derivative) else 0.0]

    photo_solution = solve_ivp(
        rhs_photo,
        (t0, t1),
        y0=[0.0],
        method="RK45",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 200.0,
    )

    total_solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 500.0,
    )

    ne_photo_final_m3 = float(max(photo_solution.y[0, -1], 0.0))
    ne_total_final_m3 = float(max(total_solution.y[0, -1], 0.0))

    return {
        "case": case,
        "n0": n0,
        "n2": n2,
        "trans": trans,
        "Eg_eV": Eg_J / E_CHARGE,
        "mred_over_me": mred / ME0,
        "I0_wm2": I0_wm2,
        "I0_wcm2": I0_wm2 * WCM2_PER_WM2,
        "ne_photo_m3": ne_photo_final_m3,
        "ne_total_m3": ne_total_final_m3,
        "ne_photo_cm3": ne_photo_final_m3 * CM3_PER_M3,
        "ne_total_cm3": ne_total_final_m3 * CM3_PER_M3,
        "ne_avalanche_added_cm3": (
            max(ne_total_final_m3 - ne_photo_final_m3, 0.0) * CM3_PER_M3
        ),
        "sol_photo_success": bool(photo_solution.success),
        "sol_photo_message": str(photo_solution.message),
        "sol_total_success": bool(total_solution.success),
        "sol_total_message": str(total_solution.message),
    }


# ============================================================
# Summary table
# ============================================================

def build_summary_table(results: Sequence[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Convert density-solver results into rows for display.
    """

    rows: List[Dict[str, Any]] = []

    for result in results:
        case = result["case"]
        rows.append(
            {
                "Case": case["short"],
                "Material": case["material"],
                "Regime": case["region"],
                "lambda_um": case["wavelength_um"],
                "tau_fs": case["tau_fs"],
                "I0_source": case_peak_intensity_source(case),
                "I0_Wcm2": result["I0_wcm2"],
                "n_photo_cm3": result["ne_photo_cm3"],
                "n_avalanche_added_cm3": result["ne_avalanche_added_cm3"],
                "n_total_cm3": result["ne_total_cm3"],
                "n0": result["n0"],
                "Eg_eV": result["Eg_eV"],
                "mred_over_me": result["mred_over_me"],
                "solver": (
                    "OK"
                    if result["sol_photo_success"] and result["sol_total_success"]
                    else "CHECK"
                ),
            }
        )

    return rows


def display_summary_table(rows: Sequence[Dict[str, Any]]) -> None:
    """
    Display the density-growth summary table in Jupyter or plain text.
    """

    print("\n================ Density-growth summary table ================\n")

    if pd is None:
        for row in rows:
            print(row)
        return

    dataframe = pd.DataFrame(rows)
    display_frame = dataframe.copy()

    scientific_columns = [
        "I0_Wcm2",
        "n_photo_cm3",
        "n_avalanche_added_cm3",
        "n_total_cm3",
    ]
    compact_columns = [
        "lambda_um",
        "tau_fs",
        "n0",
        "Eg_eV",
        "mred_over_me",
    ]

    # CODEX MODIFICATION START: display optional NaCl reference fields cleanly
    for column in scientific_columns:
        display_frame[column] = display_frame[column].map(
            lambda value: "N/A" if value is None else f"{value:.4e}"
        )

    for column in compact_columns:
        display_frame[column] = display_frame[column].map(
            lambda value: "N/A" if value is None else f"{value:.4g}"
        )
    # CODEX MODIFICATION END: display optional NaCl reference fields cleanly

    if ipython_display is not None:
        ipython_display(display_frame)
    else:
        print(display_frame.to_string(index=False))


# ============================================================
# First graph set: Keldysh photoionization curves
# ============================================================

def plot_keldysh_rate_curves(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot Keldysh photoionization-rate curves for all default cases.

    The case reference peak intensity is marked by a black cross.
    """

    I_values_wm2 = np.logspace(14, 19, 900)
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes_flat = axes.ravel()

    for ax, case in zip(axes_flat, cases):
        wavelength_um = float(case["wavelength_um"])
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        n0, _n2, Eg_J, mred, _trans = material_flag1(
            mat_flag=int(case["mat_flag"]),
            wavelength_um=wavelength_um,
        )

        Wpi = np.asarray(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=I_values_wm2,
            ),
            dtype=float,
        )

        keep = np.isfinite(Wpi) & (Wpi > 0.0)

        ax.loglog(
            I_values_wm2[keep],
            Wpi[keep],
            linewidth=2.4,
            label=r"$W_{\rm PI}$",
        )

        marker_info = case_marker_peak_intensity_wcm2(case)
        if marker_info is not None and np.any(keep):
            I_marker_wcm2, marker_label = marker_info
            I_marker_wm2 = I_marker_wcm2 * WM2_PER_WCM2
            W_marker = interpolate_log_y(
                x=I_values_wm2[keep],
                y=Wpi[keep],
                x0=I_marker_wm2,
            )
            if W_marker is not None:
                ax.plot(
                    I_marker_wm2,
                    W_marker,
                    "kx",
                    markersize=9,
                    markeredgewidth=2,
                    label=marker_label,
                )

        ax.set_title(case["name"])
        ax.set_xlabel(r"Laser intensity $I$ (W/m$^2$)")
        ax.set_ylabel(r"$W_{\rm PI}$ (m$^{-3}$ s$^{-1}$)")
        ax.grid(True, which="both", alpha=0.25)
        ax.legend(frameon=False)

    for ax in axes_flat[len(cases):]:
        ax.set_visible(False)

    fig.suptitle("Keldysh photoionization-rate curves", fontsize=15)
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="01_first_graph_set_keldysh_rate_curves.png",
    )


# ============================================================
# NaCl-reference Keldysh parameter axis
# ============================================================

# CODEX MODIFICATION START: NaCl-reference Keldysh parameter axis
def gamma_nacl_reference_from_intensity_wcm2(
    I_wcm2: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Evaluate the Keldysh parameter using NaCl as the reference material.

    Parameters
    ----------
    I_wcm2:
        Scalar or array of intensities in W/cm^2.
    wavelength_um:
        Wavelength in micrometers.
    include_field_factor_two:
        If True, include the factor of two associated with
        I = (1/2) c n eps0 E^2 in the denominator.

    Returns
    -------
    float or np.ndarray
        Keldysh parameter values.
    """

    intensity = np.asarray(I_wcm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    gamma = np.full_like(intensity, np.inf)
    valid = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(valid):
        I_wm2 = intensity[valid] * WM2_PER_WCM2
        n_nacl, _n2, Eg_nacl_J, mred_nacl, _trans = material_flag1(1, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            gamma_valid = (omega / E_CHARGE) * np.sqrt(
                (mred_nacl * C0 * n_nacl * EPS0 * Eg_nacl_J)
                / (field_factor * I_wm2)
            )

        gamma[valid] = np.nan_to_num(
            gamma_valid,
            nan=np.inf,
            posinf=np.inf,
            neginf=np.inf,
        )

    if scalar_input:
        return float(gamma[0])
    return gamma


def intensity_wcm2_from_gamma_nacl_reference(
    gamma: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Convert a NaCl-reference Keldysh parameter to intensity in W/cm^2.
    """

    gamma_values = np.asarray(gamma, dtype=float)
    scalar_input = gamma_values.ndim == 0
    gamma_values = np.atleast_1d(gamma_values)

    intensity = np.full_like(gamma_values, np.inf)
    valid = np.isfinite(gamma_values) & (gamma_values > 0.0)

    if np.any(valid):
        n_nacl, _n2, Eg_nacl_J, mred_nacl, _trans = material_flag1(1, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            I_wm2 = (
                (omega / E_CHARGE) ** 2
                * (mred_nacl * C0 * n_nacl * EPS0 * Eg_nacl_J)
                / (field_factor * gamma_values[valid] ** 2)
            )

        intensity[valid] = I_wm2 * WCM2_PER_WM2

    if scalar_input:
        return float(intensity[0])
    return intensity


def add_nacl_gamma_top_axis(
    ax: plt.Axes,
    wavelength_um: float,
    gamma_ticks: Tuple[float, ...],
    include_field_factor_two: bool = True,
) -> None:
    """
    Add a NaCl-reference Keldysh-parameter axis above an intensity axis.
    """

    ax_top = ax.twiny()
    ax_top.set_xscale("log")
    ax_top.set_xlim(ax.get_xlim())

    tick_positions = np.asarray(
        intensity_wcm2_from_gamma_nacl_reference(
            gamma=np.asarray(gamma_ticks, dtype=float),
            wavelength_um=wavelength_um,
            include_field_factor_two=include_field_factor_two,
        ),
        dtype=float,
    )

    x_min, x_max = ax.get_xlim()
    valid_ticks: List[float] = []
    valid_labels: List[str] = []

    for gamma_value, tick_position in zip(gamma_ticks, tick_positions):
        if np.isfinite(tick_position) and x_min <= tick_position <= x_max:
            valid_ticks.append(float(tick_position))
            valid_labels.append(f"{gamma_value:g}")

    ax_top.set_xticks(valid_ticks)
    ax_top.set_xticklabels(valid_labels)
    ax_top.set_xlabel(r"Keldysh parameter $\gamma$ (NaCl reference)")
    ax_top.tick_params(axis="x", which="both", direction="in")
# CODEX MODIFICATION END: NaCl-reference Keldysh parameter axis


# ============================================================
# Last graph set: total ionization comparison
# ============================================================

def plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 50,
    I_min_wcm2: float = 5.0e10,
    I_max_wcm2: float = 1.0e15,
    y_min: float = 1.0e0,
    y_max: float = 1.0e30,
    include_field_factor_two: bool = True,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot peak total ionization rate for the enabled NaCl wavelength regimes.

    Each panel includes a NaCl-reference Keldysh-parameter top axis and a
    dashed vertical line at gamma = 1.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Intensity limits must satisfy 0 < I_min < I_max.")

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )

    regime_order = ["NIR", "LWIR"]
    enabled_regimes = [
        regime for regime in regime_order
        if any(case["region"] == regime for case in cases)
    ]
    if not enabled_regimes:
        raise ValueError("At least one NaCl NIR or LWIR case is required.")
    panel_labels = {"NIR": "(a) NIR", "LWIR": "(b) LWIR"}
    gamma_ticks_by_regime = {
        "NIR": (10.0, 3.0, 1.0, 0.3),
        "LWIR": (1.0, 0.3, 0.1),
    }
    material_order = {"NaCl": 0}

    fig, axes = plt.subplots(
        1,
        len(enabled_regimes),
        figsize=(6.8 * len(enabled_regimes), 5.2),
        sharey=True,
    )
    axes = np.atleast_1d(axes)

    print("\nCalculating enabled-regime total-ionization comparison ...\n")

    for ax, regime in zip(axes, enabled_regimes):
        regime_cases = sorted(
            [case for case in cases if case["region"] == regime],
            key=lambda case: material_order.get(case["material"], 99),
        )

        wavelength_um = float(regime_cases[0]["wavelength_um"])

        for case in regime_cases:
            print(f"  {regime}: {case['short']}")
            scaling = compute_case_scaling(
                case=case,
                I_values_wcm2=I_values_wcm2,
                n_time_points=600,
            )

            I = scaling["I_wcm2"]
            Wtotal = scaling["Wtotal_peak_cm3_fs"]

            ax.loglog(
                I,
                positive_for_log(Wtotal),
                linewidth=2.6,
                label=case["material"],
            )

            marker_info = case_marker_peak_intensity_wcm2(case)
            W_marker = None
            if marker_info is not None:
                I_marker, _marker_label = marker_info
                W_marker = direct_peak_total_rate_at_intensity(case, I_marker)

            if W_marker is not None:
                ax.plot(
                    I_marker,
                    W_marker,
                    "kx",
                    markersize=8.5,
                    markeredgewidth=2.0,
                )

        I_gamma_1 = float(
            intensity_wcm2_from_gamma_nacl_reference(
                gamma=1.0,
                wavelength_um=wavelength_um,
                include_field_factor_two=include_field_factor_two,
            )
        )

        if I_min_wcm2 <= I_gamma_1 <= I_max_wcm2:
            ax.axvline(
                I_gamma_1,
                color="k",
                linestyle="--",
                linewidth=1.7,
            )
            ax.text(
                I_gamma_1 * 1.12,
                y_max / 8.0,
                r"$\gamma=1$",
                fontsize=11,
                verticalalignment="center",
            )

        ax.text(
            0.03,
            0.90,
            panel_labels[regime],
            transform=ax.transAxes,
            fontsize=14,
            fontweight="bold",
        )
        ax.set_xlabel(r"Laser intensity $I$ (W/cm$^2$)")
        ax.set_xlim(I_min_wcm2, I_max_wcm2)
        ax.set_ylim(y_min, y_max)
        ax.grid(True, which="major", alpha=0.28)
        ax.grid(True, which="minor", alpha=0.14, linestyle=":")
        ax.legend(frameon=False, fontsize=14, loc="lower right")

        add_nacl_gamma_top_axis(
            ax=ax,
            wavelength_um=wavelength_um,
            gamma_ticks=gamma_ticks_by_regime[regime],
            include_field_factor_two=include_field_factor_two,
        )

    axes[0].set_ylabel(
        r"Peak total ionization rate $W_{\rm total}$ (cm$^{-3}$ fs$^{-1}$)"
    )

    fig.suptitle(
        r"Total ionization including avalanche: "
        r"$W_{\rm total}=W_{\rm PI}+(\sigma I/E_g)n_e$",
        fontsize=14,
    )

    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="02_last_graph_set_total_ionization_gamma_axis.png",
    )



# ============================================================
# NaCl plots
# ============================================================

COMPONENT_SCALING_CACHE: Dict[
    Tuple[str, int, float, float, int], Dict[str, np.ndarray]
] = {}


def normalize_curve(values: np.ndarray) -> np.ndarray:
    """Normalize a nonnegative curve to its maximum value."""

    array = np.asarray(values, dtype=float)
    array = np.nan_to_num(array, nan=0.0, posinf=0.0, neginf=0.0)
    maximum = float(np.max(array)) if array.size else 0.0
    if maximum <= 0.0:
        return np.zeros_like(array)
    return array / maximum


def compute_case_scaling_components(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 700,
) -> Dict[str, np.ndarray]:
    """
    Compute peak photoionization, avalanche, total rates, and density.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        Peak intensities in W/cm^2.
    n_time_points:
        Number of time samples used to post-process each ODE solution.

    Returns
    -------
    dict
        Arrays of peak W_PI, W_av, W_total, and maximum electron density.
    """

    intensities = np.asarray(I_values_wcm2, dtype=float)
    if intensities.ndim != 1 or intensities.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensities)) or np.any(intensities <= 0.0):
        raise ValueError("All intensities must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensities.size),
        float(intensities[0]),
        float(intensities[-1]),
        int(n_time_points),
    )
    if cache_key in COMPONENT_SCALING_CACHE:
        return COMPONENT_SCALING_CACHE[cache_key]

    Wpi_peak = np.zeros_like(intensities)
    Wav_peak = np.zeros_like(intensities)
    Wtotal_peak = np.zeros_like(intensities)
    ne_max = np.zeros_like(intensities)

    print(f"\nComputing rate-component scaling for {case['short']} ...")
    report_interval = max(1, intensities.size // 10)

    for index, I0_wcm2 in enumerate(intensities):
        if index % report_interval == 0 or index == intensities.size - 1:
            print(
                f"  {index + 1:3d}/{intensities.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2: {result['solver_message']}"
            )

        Wpi_peak[index] = np.nanmax(
            np.nan_to_num(result["Wpi_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wav_peak[index] = np.nanmax(
            np.nan_to_num(result["Wav_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(result["Wtotal_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        ne_max[index] = np.nanmax(
            np.nan_to_num(result["ne_cm3"], nan=0.0, posinf=0.0, neginf=0.0)
        )

    output = {
        "I_wcm2": intensities,
        "Wpi_peak_cm3_fs": Wpi_peak,
        "Wav_peak_cm3_fs": Wav_peak,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
        "ne_max_cm3": ne_max,
    }
    COMPONENT_SCALING_CACHE[cache_key] = output
    return output


def plot_case_figure_1_style(
    case: CaseDict,
    save_dir: Optional[Path] = None,
) -> None:
    """Plot Keldysh photoionization rate versus peak irradiance."""

    I_values_wcm2 = np.logspace(10, 15, 900)
    I_values_wm2 = I_values_wcm2 * WM2_PER_WCM2
    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        int(case["mat_flag"]), wavelength_um
    )

    Wpi_cm3_fs = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_values_wm2,
        ),
        dtype=float,
    ) * RATE_CM3_FS_PER_M3_S

    marker_info = case_marker_peak_intensity_wcm2(case)
    fig, ax = plt.subplots(figsize=(7.0, 5.0))
    ax.loglog(
        I_values_wcm2,
        positive_for_log(Wpi_cm3_fs),
        "k-",
        linewidth=2.2,
        label=r"$W_{\rm PI}$",
    )

    if marker_info is not None:
        I_marker, marker_label = marker_info
        W_marker = interpolate_log_y(I_values_wcm2, Wpi_cm3_fs, I_marker)
        if W_marker is not None:
            ax.plot(
                I_marker,
                W_marker,
                "kx",
                markersize=9,
                markeredgewidth=2.0,
                label=marker_label,
            )

    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Photoionization rate $W_{\rm PI}$ (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"{case['material']}: $W_{{\rm PI}}$ vs irradiance, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    save_or_show(
        fig,
        save_dir,
        f"NaCl_fig1_{case['region']}.png",
    )


def plot_case_figure_2_style(
    case: CaseDict,
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot rate components, electron density, and total rate versus irradiance.
    """

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    scaling = compute_case_scaling_components(
        case=case,
        I_values_wcm2=I_values_wcm2,
        n_time_points=600,
    )

    I = scaling["I_wcm2"]
    Wpi = scaling["Wpi_peak_cm3_fs"]
    Wav = scaling["Wav_peak_cm3_fs"]
    Wtotal = scaling["Wtotal_peak_cm3_fs"]
    ne = scaling["ne_max_cm3"]
    marker_info = case_marker_peak_intensity_wcm2(case)

    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))

    ax = axes[0]
    ax.loglog(I, positive_for_log(Wtotal), "b--", linewidth=2.5, label=r"$W_{\rm total}$")
    ax.loglog(I, positive_for_log(Wpi), "k:", linewidth=2.3, label=r"$W_{\rm PI}$")
    ax.loglog(
        I,
        positive_for_log(Wav),
        color="orange",
        linestyle="-.",
        linewidth=2.3,
        label=r"$W_{\rm av}$",
    )
    if marker_info is not None:
        I_marker, marker_label = marker_info
        ax.axvline(I_marker, color="0.4", linestyle="--", linewidth=1.3, label=marker_label)
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"(a) {case['material']}, $\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    ax = axes[1]
    ax_rate = ax.twinx()
    line_density, = ax.loglog(I, positive_for_log(ne), "r-", linewidth=2.5, label=r"$n_e$")
    line_rate, = ax_rate.loglog(
        I,
        positive_for_log(Wtotal),
        "b--",
        linewidth=2.5,
        label=r"$W_{\rm total}$",
    )
    if marker_info is not None:
        I_marker, _marker_label = marker_info
        ax.axvline(I_marker, color="0.4", linestyle="--", linewidth=1.3)
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    ax_rate.set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title("(b) Density and total ionization rate")
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(
        [line_density, line_rate],
        [line_density.get_label(), line_rate.get_label()],
        frameon=False,
        fontsize=9,
    )
    ax.set_xlim(1.0e10, 1.0e15)

    fig.suptitle(f"{case['short']}: irradiance scaling", fontsize=14)
    save_or_show(
        fig,
        save_dir,
        f"NaCl_fig2_{case['region']}.png",
    )


def plot_case_figure_3_style(
    case: CaseDict,
    intensity_factors: Tuple[float, float, float, float] = (0.25, 0.5, 1.0, 2.0),
    save_dir: Optional[Path] = None,
) -> None:
    """Plot normalized time-domain carrier and ionization dynamics."""

    I_reference_wcm2 = case_reference_peak_intensity_wcm2(case)
    fig, axes = plt.subplots(4, 2, figsize=(13.0, 14.0), sharey=True)

    for row, factor in enumerate(intensity_factors):
        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=factor * I_reference_wcm2,
            n_time_points=1800,
        )

        if float(case["tau_fs"]) >= 1000.0:
            time_axis = result["t_s"] * 1.0e12
            time_label = "Time (ps)"
        else:
            time_axis = result["t_s"] * 1.0e15
            time_label = "Time (fs)"

        I_norm = normalize_curve(result["intensity_wm2"])
        ne_norm = normalize_curve(result["ne_cm3"])
        Wpi_norm = normalize_curve(result["Wpi_cm3_fs"])
        Wav_norm = normalize_curve(result["Wav_cm3_fs"])
        Wtotal_norm = normalize_curve(result["Wtotal_cm3_fs"])

        ax = axes[row, 0]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(time_axis, ne_norm, "r-", linewidth=2.0, label=r"$n_e$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm ref}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.set_ylabel("Normalized value")
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

        ax = axes[row, 1]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(
            time_axis,
            Wav_norm,
            color="goldenrod",
            linestyle="-.",
            linewidth=2.0,
            label=r"$W_{\rm av}$",
        )
        ax.plot(time_axis, Wpi_norm, "k:", linewidth=2.0, label=r"$W_{\rm PI}$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm ref}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

    axes[-1, 0].set_xlabel(time_label)
    axes[-1, 1].set_xlabel(time_label)
    fig.suptitle(
        rf"{case['material']} time-domain dynamics, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"NaCl_fig3_{case['region']}.png",
    )


def plot_material_figure_4_style(
    material_name: str,
    material_cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Plot density/rate scaling for the supplied cases of one material."""

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))
    linestyles = {"NIR": "-", "LWIR": "-."}

    for case in material_cases:
        scaling = compute_case_scaling_components(
            case=case,
            I_values_wcm2=I_values_wcm2,
            n_time_points=600,
        )
        I = scaling["I_wcm2"]
        ne = scaling["ne_max_cm3"]
        Wtotal = scaling["Wtotal_peak_cm3_fs"]
        label = rf"{case['wavelength_um']:g} $\mu$m, $\tau={case['tau_fs']:g}$ fs"
        style = linestyles.get(case["region"], "-")

        axes[0].loglog(I, positive_for_log(ne), linestyle=style, linewidth=2.3, label=label)
        axes[1].loglog(I, positive_for_log(Wtotal), linestyle=style, linewidth=2.3, label=label)

        marker_info = case_marker_peak_intensity_wcm2(case)
        if marker_info is not None:
            I_marker, _marker_label = marker_info
            axes[0].axvline(I_marker, color="0.5", linestyle="--", linewidth=1.0)
            axes[1].axvline(I_marker, color="0.5", linestyle="--", linewidth=1.0)

    axes[0].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[0].set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    axes[0].set_title(f"(a) {material_name}: electron density")
    axes[0].grid(True, which="both", alpha=0.3)
    axes[0].legend(frameon=False, fontsize=9)
    axes[0].set_xlim(1.0e10, 1.0e15)

    axes[1].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[1].set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    axes[1].set_title(f"(b) {material_name}: total ionization rate")
    axes[1].grid(True, which="both", alpha=0.3)
    axes[1].legend(frameon=False, fontsize=9)
    axes[1].set_xlim(1.0e10, 1.0e15)

    fig.suptitle(rf"{material_name}: irradiance scaling", fontsize=14)
    save_or_show(
        fig,
        save_dir,
        "NaCl_fig4_NIR_scaling.png",
    )


# CODEX MODIFICATION START: NaCl-only plotting workflow
def plot_nacl_figures(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Generate all Figs. 1-4 for NaCl."""

    print("\n============================================================")
    print("Generating NaCl plots")
    print("Case: 0.8 um, 100 fs")
    print("============================================================\n")

    for case in cases:
        plot_case_figure_1_style(case, save_dir=save_dir)
        plot_case_figure_2_style(
            case,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )
        if case_has_reference_peak_intensity(case):
            plot_case_figure_3_style(case, save_dir=save_dir)
        else:
            print(
                f"Skipping Fig. 3 for {case['short']}: no verified "
                "reference_I0_wcm2 or measured F0_jcm2 is available."
            )

    for material_name in sorted({case["material"] for case in cases}):
        material_cases = [
            case for case in cases if case["material"] == material_name
        ]
        if not material_cases:
            continue
        plot_material_figure_4_style(
            material_name=material_name,
            material_cases=material_cases,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )
# CODEX MODIFICATION END: NaCl-only plotting workflow


# ============================================================
# CODEX MODIFICATION START: 3D total-ionization surface plot
# ============================================================

def plot_total_ionization_3d_surface(
    case: CaseDict,
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """
    Plot total ionization rate versus peak laser intensity and electron density.

    Axes are log10(I0), log10(ne), and log10(W_total), where W_total includes
    Keldysh photoionization plus avalanche/impact ionization.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)

    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3),
        np.log10(ne_max_cm3),
        n_density_points,
    )

    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3

    Wpi_grid = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_grid_wm2,
        ),
        dtype=float,
    )

    Wav_grid = np.zeros_like(I_grid_wm2)
    for row_index in range(I_grid_wm2.shape[0]):
        for column_index in range(I_grid_wm2.shape[1]):
            Wav_grid[row_index, column_index] = avalanche_generation_rate_m3_s(
                intensity_wm2=I_grid_wm2[row_index, column_index],
                ne_m3=ne_grid_m3[row_index, column_index],
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )

    Wtotal_grid = (Wpi_grid + Wav_grid) * RATE_CM3_FS_PER_M3_S
    Wtotal_grid = np.maximum(
        np.nan_to_num(Wtotal_grid, nan=0.0, posinf=0.0, neginf=0.0),
        1.0e-300,
    )

    X = np.log10(I_grid_wcm2)
    Y = np.log10(ne_grid_cm3)
    Z = np.log10(Wtotal_grid)

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection="3d")
    surface = ax.plot_surface(
        X,
        Y,
        Z,
        cmap="jet",
        linewidth=0,
        antialiased=True,
        alpha=0.95,
    )

    ax.set_xlabel(r"$\log_{10}(I_0)$  [W/cm$^2$]")
    ax.set_ylabel(r"$\log_{10}(n_e)$  [cm$^{-3}$]")
    ax.set_zlabel(r"$\log_{10}(W_{\rm total})$  [cm$^{-3}$ fs$^{-1}$]")
    ax.set_title(f"Total ionization surface: {case['short']}")

    fig.colorbar(
        surface,
        ax=ax,
        shrink=0.65,
        pad=0.12,
        label=r"$\log_{10}(W_{\rm total})$",
    )

    ax.view_init(elev=28, azim=135)
    fig.tight_layout()
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename=f"05_total_ionization_3d_{case['short']}.png",
    )


def plot_total_ionization_3d_surface_grid(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """Plot all NaCl total-ionization 3D surfaces in one figure."""

    if not cases:
        raise ValueError("At least one case is required for the 3D grid.")
    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3),
        np.log10(ne_max_cm3),
        n_density_points,
    )
    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3
    X = np.log10(I_grid_wcm2)
    Y = np.log10(ne_grid_cm3)

    z_grids: List[np.ndarray] = []
    for index, case in enumerate(cases):
        wavelength_um = float(case["wavelength_um"])
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        n0, _n2, Eg_J, mred, _trans = material_flag1(
            mat_flag=int(case["mat_flag"]),
            wavelength_um=wavelength_um,
        )

        Wpi_grid = np.asarray(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=I_grid_wm2,
            ),
            dtype=float,
        )

        Wav_grid = np.zeros_like(I_grid_wm2)
        for row_index in range(I_grid_wm2.shape[0]):
            for column_index in range(I_grid_wm2.shape[1]):
                Wav_grid[row_index, column_index] = avalanche_generation_rate_m3_s(
                    intensity_wm2=I_grid_wm2[row_index, column_index],
                    ne_m3=ne_grid_m3[row_index, column_index],
                    omega=omega,
                    mred=mred,
                    delta_J=Eg_J,
                    n0=n0,
                )

        Wtotal_grid = (Wpi_grid + Wav_grid) * RATE_CM3_FS_PER_M3_S
        Wtotal_grid = np.maximum(
            np.nan_to_num(Wtotal_grid, nan=0.0, posinf=0.0, neginf=0.0),
            1.0e-300,
        )
        Z = np.log10(Wtotal_grid)
        z_grids.append(Z)

    z_min = min(float(np.nanmin(Z)) for Z in z_grids)
    z_max = max(float(np.nanmax(Z)) for Z in z_grids)
    norm = colors.Normalize(vmin=z_min, vmax=z_max)
    cmap = plt.get_cmap("jet")

    n_cases = len(cases)
    n_cols = 1 if n_cases == 1 else min(2, n_cases)
    n_rows = int(np.ceil(n_cases / n_cols))

    fig = plt.figure(figsize=(7.5 * n_cols, 5.7 * n_rows))
    fig.subplots_adjust(
        left=0.04,
        right=0.88,
        bottom=0.08,
        top=0.86,
        wspace=0.10,
        hspace=0.20,
    )

    for index, (case, Z) in enumerate(zip(cases, z_grids)):
        ax = fig.add_subplot(n_rows, n_cols, index + 1, projection="3d")
        ax.plot_surface(
            X,
            Y,
            Z,
            facecolors=cmap(norm(Z)),
            linewidth=0,
            antialiased=True,
            shade=False,
            alpha=0.95,
        )
        ax.set_xlabel(r"$\log_{10}(I_0)$")
        ax.set_ylabel(r"$\log_{10}(n_e)$")
        ax.set_zlabel(r"$\log_{10}(W_{\rm total})$")
        ax.set_title(case["short"])
        ax.view_init(elev=28, azim=135)

    colorbar_axis = fig.add_axes([0.91, 0.18, 0.018, 0.64])
    colorbar_mappable = cm.ScalarMappable(norm=norm, cmap=cmap)
    colorbar_mappable.set_array([])
    fig.colorbar(
        colorbar_mappable,
        cax=colorbar_axis,
        label=r"$\log_{10}(W_{\rm total})$ [cm$^{-3}$ fs$^{-1}$]",
    )

    enabled_regions = " / ".join(str(case["region"]) for case in cases)
    fig.suptitle(
        rf"Total ionization surfaces: NaCl {enabled_regions}",
        fontsize=15,
    )
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename=f"05_total_ionization_3d_NaCl_{'_'.join(str(case['region']) for case in cases)}.png",
        apply_tight_layout=False,
    )

# ============================================================
# CODEX MODIFICATION END: 3D total-ionization surface plot
# ============================================================


# ============================================================
# Saved numerical variables
# ============================================================

def compute_total_ionization_surface_data(
    case: CaseDict,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> Dict[str, np.ndarray]:
    """Return the numerical arrays used by a total-ionization 3D surface."""

    if n_intensity_points < 2 or n_density_points < 2:
        raise ValueError("Surface grids require at least two points per axis.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2), np.log10(I_max_wcm2), n_intensity_points
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3), np.log10(ne_max_cm3), n_density_points
    )
    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3

    Wpi_grid_m3_s = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_grid_wm2,
        ),
        dtype=float,
    )
    Wav_grid_m3_s = np.zeros_like(I_grid_wm2)
    for row_index in range(I_grid_wm2.shape[0]):
        for column_index in range(I_grid_wm2.shape[1]):
            Wav_grid_m3_s[row_index, column_index] = avalanche_generation_rate_m3_s(
                intensity_wm2=I_grid_wm2[row_index, column_index],
                ne_m3=ne_grid_m3[row_index, column_index],
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )

    Wtotal_grid_cm3_fs = (Wpi_grid_m3_s + Wav_grid_m3_s) * RATE_CM3_FS_PER_M3_S
    return {
        "I_values_wcm2": I_values_wcm2,
        "ne_values_cm3": ne_values_cm3,
        "I_grid_wcm2": I_grid_wcm2,
        "ne_grid_cm3": ne_grid_cm3,
        "Wpi_grid_m3_s": Wpi_grid_m3_s,
        "Wav_grid_m3_s": Wav_grid_m3_s,
        "Wtotal_grid_cm3_fs": Wtotal_grid_cm3_fs,
        "log10_I_grid_wcm2": np.log10(I_grid_wcm2),
        "log10_ne_grid_cm3": np.log10(ne_grid_cm3),
        "log10_Wtotal_grid_cm3_fs": np.log10(
            np.maximum(
                np.nan_to_num(Wtotal_grid_cm3_fs, nan=0.0, posinf=0.0, neginf=0.0),
                1.0e-300,
            )
        ),
    }


def _case_export_metadata(case: CaseDict) -> Dict[str, Any]:
    """Return JSON-safe inputs and derived material values for one case."""

    wavelength_um = float(case["wavelength_um"])
    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )
    metadata: Dict[str, Any] = {
        "short": str(case["short"]),
        "name": str(case["name"]),
        "material": str(case["material"]),
        "region": str(case["region"]),
        "mat_flag": int(case["mat_flag"]),
        "wavelength_um": wavelength_um,
        "tau_fs": float(case["tau_fs"]),
        "F0_jcm2": None if case.get("F0_jcm2") is None else float(case["F0_jcm2"]),
        "reference_I0_wcm2": case.get("reference_I0_wcm2"),
        "I0_wcm2": case_reference_peak_intensity_wcm2(case),
        "n0": float(n0),
        "n2_m2_per_w": float(n2) if np.isfinite(n2) else None,
        "Eg_eV": float(Eg_J / E_CHARGE),
        "mred_over_me": float(mred / ME0),
        "transmission_factor": float(trans),
    }
    return metadata


def _write_csv(path: Path, rows: Sequence[Dict[str, Any]]) -> None:
    """Write a long-format CSV with stable columns and UTF-8 encoding."""

    if not rows:
        return
    fieldnames = list(rows[0])
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def save_nacl_plot_variables(
    cases: Sequence[CaseDict],
    output_dir: Path,
    component_n_intensity_points: int = 50,
    total_n_intensity_points: int = 50,
    surface_n_intensity_points: int = 50,
    surface_n_density_points: int = 80,
) -> None:
    """Save NaCl plot arrays, metadata, and long-format tables.

    Files mirror the ``various`` workflow: a compressed NPZ archive, a JSON
    manifest containing units and figure mappings, and CSV tables for scaling
    data. Only currently enabled cases are exported.
    """

    output_dir.mkdir(parents=True, exist_ok=True)
    component_I_values_wcm2 = np.logspace(10, 15, component_n_intensity_points)
    total_I_values_wcm2 = np.logspace(
        np.log10(5.0e10), np.log10(1.0e15), total_n_intensity_points
    )
    arrays: Dict[str, np.ndarray] = {}
    component_rows: List[Dict[str, Any]] = []
    total_rows: List[Dict[str, Any]] = []
    surface_rows: List[Dict[str, Any]] = []
    component_manifest: Dict[str, Any] = {}
    total_manifest: Dict[str, Any] = {}
    surface_manifest: Dict[str, Any] = {}
    case_metadata: Dict[str, Any] = {}

    print("\nSaving labeled NaCl plot variables ...")
    for case in cases:
        short = str(case["short"])
        metadata = _case_export_metadata(case)
        case_metadata[short] = metadata
        # NaCl supplies a reference peak intensity directly rather than an
        # LIDT fluence, so use the common resolver instead of the LIDT-only
        # fluence-to-intensity conversion.
        Wtotal_direct_at_reference_cm3_fs = direct_peak_total_rate_at_intensity(
            case,
            case_reference_peak_intensity_wcm2(case),
            n_time_points=600,
        )

        component = compute_case_scaling_components(
            case=case,
            I_values_wcm2=component_I_values_wcm2,
            n_time_points=600,
        )
        component_manifest[short] = {
            "used_by": ["NaCl_fig2_NIR.png", "NaCl_fig4_NIR_scaling.png"],
            "arrays": {},
        }
        for name, values in component.items():
            array_name = f"component__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            component_manifest[short]["arrays"][name] = array_name

        component_gamma = np.asarray(
            gamma_nacl_reference_from_intensity_wcm2(
                component["I_wcm2"],
                wavelength_um=float(case["wavelength_um"]),
                include_field_factor_two=True,
            ),
            dtype=float,
        )
        component_gamma_name = f"component__{short}__gamma_nacl_reference"
        arrays[component_gamma_name] = component_gamma
        component_manifest[short]["arrays"]["gamma_nacl_reference"] = component_gamma_name

        for index, intensity in enumerate(component["I_wcm2"]):
            component_rows.append(
                {
                    **metadata,
                    "dataset": "component_scaling",
                    "point_index": int(index),
                    "I_wcm2": float(intensity),
                    "gamma_nacl_reference": float(component_gamma[index]),
                    "Wpi_peak_cm3_fs": float(component["Wpi_peak_cm3_fs"][index]),
                    "Wav_peak_cm3_fs": float(component["Wav_peak_cm3_fs"][index]),
                    "Wtotal_peak_cm3_fs": float(component["Wtotal_peak_cm3_fs"][index]),
                    "ne_max_cm3": float(component["ne_max_cm3"][index]),
                }
            )

        total = compute_case_scaling_components(
            case=case,
            I_values_wcm2=total_I_values_wcm2,
            n_time_points=600,
        )
        total_manifest[short] = {
            "used_by": ["NIR total-ionization scaling"],
            "arrays": {},
        }
        for name, values in total.items():
            array_name = f"total_comparison__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            total_manifest[short]["arrays"][name] = array_name

        total_gamma = np.asarray(
            gamma_nacl_reference_from_intensity_wcm2(
                total["I_wcm2"],
                wavelength_um=float(case["wavelength_um"]),
                include_field_factor_two=True,
            ),
            dtype=float,
        )
        total_gamma_name = f"total_comparison__{short}__gamma_nacl_reference"
        arrays[total_gamma_name] = total_gamma
        total_manifest[short]["arrays"]["gamma_nacl_reference"] = total_gamma_name

        for index, intensity in enumerate(total["I_wcm2"]):
            total_rows.append(
                {
                    **metadata,
                    "dataset": "total_comparison",
                    "point_index": int(index),
                    "I_wcm2": float(intensity),
                    "gamma_nacl_reference": float(total_gamma[index]),
                    "Wtotal_peak_cm3_fs": float(total["Wtotal_peak_cm3_fs"][index]),
                    "Wtotal_direct_at_reference_cm3_fs": Wtotal_direct_at_reference_cm3_fs,
                }
            )

        surface = compute_total_ionization_surface_data(
            case=case,
            n_intensity_points=surface_n_intensity_points,
            n_density_points=surface_n_density_points,
        )
        surface_manifest[short] = {
            "used_by": [f"05_total_ionization_3d_{short}.png"],
            "arrays": {},
        }
        for name, values in surface.items():
            array_name = f"surface3d__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            surface_manifest[short]["arrays"][name] = array_name

        for density_index in range(surface["I_grid_wcm2"].shape[0]):
            for intensity_index in range(surface["I_grid_wcm2"].shape[1]):
                surface_rows.append(
                    {
                        **metadata,
                        "dataset": "surface3d",
                        "density_index": density_index,
                        "intensity_index": intensity_index,
                        "I_wcm2": float(
                            surface["I_grid_wcm2"][density_index, intensity_index]
                        ),
                        "ne_cm3": float(
                            surface["ne_grid_cm3"][density_index, intensity_index]
                        ),
                        "log10_I_grid_wcm2": float(
                            surface["log10_I_grid_wcm2"][density_index, intensity_index]
                        ),
                        "log10_ne_grid_cm3": float(
                            surface["log10_ne_grid_cm3"][density_index, intensity_index]
                        ),
                        "Wpi_grid_cm3_fs": float(
                            surface["Wpi_grid_m3_s"][density_index, intensity_index]
                            * RATE_CM3_FS_PER_M3_S
                        ),
                        "Wav_grid_cm3_fs": float(
                            surface["Wav_grid_m3_s"][density_index, intensity_index]
                            * RATE_CM3_FS_PER_M3_S
                        ),
                        "Wtotal_grid_cm3_fs": float(
                            surface["Wtotal_grid_cm3_fs"][density_index, intensity_index]
                        ),
                        "log10_Wtotal_grid_cm3_fs": float(
                            surface["log10_Wtotal_grid_cm3_fs"][density_index, intensity_index]
                        ),
                    }
                )

    manifest = {
        "description": "Labeled variables for NaCl Keldysh and avalanche-ionization plots.",
        "enabled_cases": list(case_metadata),
        "case_metadata": case_metadata,
        "units": {
            "I_wcm2": "W/cm^2",
            "F0_jcm2": "J/cm^2",
            "Wpi_peak_cm3_fs": "cm^-3 fs^-1",
            "Wav_peak_cm3_fs": "cm^-3 fs^-1",
            "Wtotal_peak_cm3_fs": "cm^-3 fs^-1",
            "Wtotal_direct_at_reference_cm3_fs": "cm^-3 fs^-1",
            "ne_max_cm3": "cm^-3",
            "Wpi_grid_m3_s": "m^-3 s^-1",
            "Wav_grid_m3_s": "m^-3 s^-1",
            "Wtotal_grid_cm3_fs": "cm^-3 fs^-1",
            "ne_grid_cm3": "cm^-3",
            "gamma_nacl_reference": "dimensionless",
        },
        "files": {
            "numpy_arrays": "nacl_variables.npz",
            "manifest": "nacl_manifest.json",
            "component_scaling_csv": "nacl_component_scaling_long.csv",
            "total_comparison_csv": "nacl_total_comparison_long.csv",
            "surface3d_csv": "nacl_surface3d_long.csv",
        },
        "component_scaling": component_manifest,
        "total_comparison": total_manifest,
        "surface3d": surface_manifest,
    }
    np.savez_compressed(output_dir / "nacl_variables.npz", **arrays)
    with (output_dir / "nacl_manifest.json").open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2, allow_nan=False)
    _write_csv(output_dir / "nacl_component_scaling_long.csv", component_rows)
    _write_csv(output_dir / "nacl_total_comparison_long.csv", total_rows)
    _write_csv(output_dir / "nacl_surface3d_long.csv", surface_rows)
    print(f"Saved NaCl variables to {output_dir}")


# ============================================================
# Workflow and command-line interface
# ============================================================

def solve_and_display_summary(cases: Sequence[CaseDict]) -> None:
    """Solve the NaCl cases and display the summary table."""

    results: List[Dict[str, Any]] = []
    for case in cases:
        if not case_has_reference_peak_intensity(case):
            print(
                f"Skipping density table entry for {case['short']}: no verified "
                "reference_I0_wcm2 or measured F0_jcm2 is available."
            )
            continue

        print(f"Solving density table entry for {case['short']} ...")
        result = solve_density_case(case)
        results.append(result)

        if not result["sol_photo_success"]:
            print(
                f"  WARNING: photo-only solver for {case['short']}: "
                f"{result['sol_photo_message']}"
            )
        if not result["sol_total_success"]:
            print(
                f"  WARNING: total solver for {case['short']}: "
                f"{result['sol_total_message']}"
            )

    if results:
        display_summary_table(build_summary_table(results))
    else:
        print("No density table entries were solved because no reference inputs are available.")


def run_first_last_table_workflow(
    cases: Sequence[CaseDict],
    points: int,
    save_dir: Optional[Path],
) -> None:
    """Run the enabled NIR workflow: rate curves and density table."""

    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    solve_and_display_summary(cases)
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=points,
        include_field_factor_two=True,
        save_dir=save_dir,
    )


def run_all_plots_workflow(
    cases: Sequence[CaseDict],
    points: int,
    save_dir: Optional[Path],
) -> None:
    """Run the compact workflow plus all plots."""

    # Save the complete 2D figure set before the slower density-summary and
    # 3D calculations.  This makes a normal VS Code run populate the output
    # folder promptly, rather than leaving only the first graph while the
    # long numerical stages are still running.
    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    plot_nacl_figures(
        cases=cases,
        n_intensity_points=points,
        save_dir=save_dir,
    )
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=points,
        include_field_factor_two=True,
        save_dir=save_dir,
    )
    solve_and_display_summary(cases)
    plot_total_ionization_3d_surface_grid(
        cases=cases,
        save_dir=save_dir,
        n_intensity_points=points,
        n_density_points=80,
    )


def build_argument_parser() -> argparse.ArgumentParser:
    """Construct the command-line argument parser."""

    parser = argparse.ArgumentParser(
        description=(
            "Run the reconciled NaCl Keldysh + avalanche model and "
            "generate the requested graph sets."
        )
    )
    # CODEX MODIFICATION START: add 3D plotting mode
    parser.add_argument(
        "--mode",
        choices=("all", "summary", "figures", "3d", "first-last", "dis"),
        default="all",
        help=(
            "all: all NaCl plots and table; summary: first/last graph sets "
            "and table; figures: NaCl Figs. 1-4; 3d: total-ionization "
            "surface. first-last and dis are retained as legacy aliases."
        ),
    )
    # CODEX MODIFICATION END: add 3D plotting mode
    parser.add_argument(
        "--points",
        type=int,
        default=50,
        help="Number of intensity points used in scaling plots.",
    )
    parser.add_argument(
        "--save",
        action="store_true",
        default=True,
        help=(
            "Save every currently enabled NaCl figure and labeled numerical variables "
            "(the default behavior)."
        ),
    )
    parser.add_argument(
        "--no-save",
        action="store_false",
        dest="save",
        help="Do not save files; use --mode for an interactive, selective plot run.",
    )
    # CODEX MODIFICATION START: optional open saved image preview
    parser.add_argument(
        "--open-after-save",
        action="store_true",
        help="Open saved PNG figures with the system image viewer after saving.",
    )
    # CODEX MODIFICATION END: optional open saved image preview
    # CODEX MODIFICATION START: optional editable figure exports
    parser.add_argument(
        "--editable",
        action="store_true",
        help=(
            "Retained for compatibility. Saved figures automatically include "
            "a .mplfig.pkl editable Matplotlib file."
        ),
    )
    # CODEX MODIFICATION END: optional editable figure exports
    # CODEX MODIFICATION START: display all Matplotlib windows after plotting
    parser.add_argument(
        "--show-at-end",
        action="store_true",
        help=(
            "Generate all requested figures first, then display them together. "
            "Can be combined with --save."
        ),
    )
    # CODEX MODIFICATION END: display all Matplotlib windows after plotting
    parser.add_argument(
        "--outdir",
        type=str,
        default=str(
            Path(__file__).resolve().parent
            / "figures_Keldysh_II"
            / "figures_Keldsyh_II_NaCl"
        ),
        help="Directory used for the default automatic saving behavior.",
    )
    # CODEX MODIFICATION START: CLI support for 3D surface plot
    parser.add_argument(
        "--case-index",
        type=int,
        default=None,
        choices=range(2),
        metavar="{0,1}",
        help=(
            "Optional case used by --mode 3d: 0 NaCl_NIR, 1 NaCl_LWIR. "
            "If omitted, all enabled cases are plotted."
        ),
    )
    parser.add_argument(
        "--density-points",
        type=int,
        default=80,
        help="Number of electron-density points used by --mode 3d.",
    )
    # CODEX MODIFICATION END: CLI support for 3D surface plot
    return parser


def main(argv: Optional[List[str]] = None) -> None:
    """
    Parse command-line options and run the selected workflow.

    In Jupyter, use ``main([])`` for the default all-plots workflow or, for
    a faster test, ``main(["--mode", "first-last", "--points", "12"])``.
    """

    parser = build_argument_parser()
    args, _unknown = parser.parse_known_args(argv)

    if args.points < 2:
        parser.error("--points must be at least 2.")
    # CODEX MODIFICATION START: validate 3D density grid size
    if args.density_points < 2:
        parser.error("--density-points must be at least 2.")
    # CODEX MODIFICATION END: validate 3D density grid size

    cases = get_cases()
    report_case_input_uncertainties(cases)
    save_dir = Path(args.outdir) if args.save else None

    # CODEX MODIFICATION START: display all Matplotlib windows after plotting
    global DEFER_FIGURE_SHOW
    DEFER_FIGURE_SHOW = bool(args.show_at_end)
    # CODEX MODIFICATION END: display all Matplotlib windows after plotting

    # CODEX MODIFICATION START: automatic editable figure exports
    global SAVE_EDITABLE_FIGURES
    SAVE_EDITABLE_FIGURES = bool(args.save)
    # CODEX MODIFICATION END: automatic editable figure exports

    # CODEX MODIFICATION START: optional open saved image preview
    global OPEN_SAVED_FIGURES
    OPEN_SAVED_FIGURES = bool(args.open_after_save and args.save)
    # CODEX MODIFICATION END: optional open saved image preview

    # Saving is deliberately comprehensive, matching the various-material
    # workflow: one saved run updates every currently enabled figure as well
    # as the corresponding numerical exports.  Selective --mode choices are
    # retained for interactive, non-saving use.
    if args.save:
        run_all_plots_workflow(cases, args.points, save_dir)
    elif args.mode in ("summary", "first-last"):
        run_first_last_table_workflow(cases, args.points, save_dir)
    elif args.mode in ("figures", "dis"):
        plot_nacl_figures(cases, args.points, save_dir)
    # CODEX MODIFICATION START: CLI support for 3D surface plot
    elif args.mode == "3d":
        if args.case_index is None:
            plot_total_ionization_3d_surface_grid(
                cases=cases,
                save_dir=save_dir,
                n_intensity_points=args.points,
                n_density_points=args.density_points,
            )
        else:
            plot_total_ionization_3d_surface(
                case=cases[args.case_index],
                save_dir=save_dir,
                n_intensity_points=args.points,
                n_density_points=args.density_points,
            )
    # CODEX MODIFICATION END: CLI support for 3D surface plot
    else:
        run_all_plots_workflow(cases, args.points, save_dir)

    if args.save:
        assert save_dir is not None
        save_nacl_plot_variables(
            cases=cases,
            output_dir=save_dir / "saved_variables",
            component_n_intensity_points=args.points,
            total_n_intensity_points=args.points,
            surface_n_intensity_points=args.points,
            surface_n_density_points=args.density_points,
        )

    # CODEX MODIFICATION START: display all Matplotlib windows after plotting
    if DEFER_FIGURE_SHOW:
        plt.show(block=True)
    # CODEX MODIFICATION END: display all Matplotlib windows after plotting


if __name__ == "__main__":
    main()


====================================================================================================
FILE: Keldysh\Keldsyh_II_various.ipynb
====================================================================================================

--- Notebook code cell 1 ---
"""
Reconciled Keldysh + avalanche ionization model for ZnSe and ZnS.

The script evaluates
--------------------
1. Full Keldysh photoionization rate, W_PI.
2. Avalanche/impact ionization using a Drude absorption cross section,

       W_av(I, n_e) = [sigma(I, n_e) I / E_g] n_e,

   with

       sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2),

       tau_C = 16 pi eps0^2 sqrt[m_r (0.1 E_g)^3]
               / [sqrt(2) e^4 n_e].

3. Time-dependent carrier-density growth,

       dn_e/dt = W_PI(t) + W_av(I(t), n_e(t)).

Model assumptions
-----------------
* Recombination and trapping are neglected.
* Carrier depletion and saturation are neglected.
* Propagation, self-focusing, and laser-induced changes in optical constants
  are neglected.
* The same linear refractive index is used in the Keldysh and Drude terms.
* The temporal pulse is Gaussian and centered at t = 0.
* The integration window is from -3 tau to +3 tau, where tau is the
  intensity FWHM duration.

Units
-----
* Internal calculations: SI units.
* Input fluence: J/cm^2.
* Input irradiance for scaling plots: W/cm^2.
* Wavelength: micrometers.
* Pulse duration: femtoseconds.
* Summary densities: cm^-3.
* Final rate plot: cm^-3 fs^-1.

Default workflow
----------------
The default execution produces only:
1. The first graph set: Keldysh photoionization-rate curves.
2. The density-growth summary table.
"""


from __future__ import annotations

import argparse
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple, Union

import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import dawsn, ellipe, ellipk

try:
    import pandas as pd
except ImportError:
    pd = None

try:
    from IPython.display import display as ipython_display
except ImportError:
    ipython_display = None


# ============================================================
# Constants
# ============================================================

C0 = 3.0e8
EPS0 = 8.85e-12
E_CHARGE = 1.6e-19
HBAR = 1.054e-34
ME0 = 9.11e-31

CM3_PER_M3 = 1.0e-6
WCM2_PER_WM2 = 1.0e-4
WM2_PER_WCM2 = 1.0e4
RATE_CM3_FS_PER_M3_S = 1.0e-21

CaseDict = Dict[str, Any]
ArrayLike = Union[np.ndarray, float]


# ============================================================
# Material properties
# ============================================================

def material_flag1(
    mat_flag: int,
    wavelength_um: float,
) -> Tuple[float, float, float, float, float]:
    """
    Return wavelength-dependent material parameters for ZnSe or ZnS.

    Parameters
    ----------
    mat_flag:
        Material selector: 1 for ZnSe and 2 for ZnS.
    wavelength_um:
        Vacuum wavelength in micrometers.

    Returns
    -------
    n0:
        Linear refractive index.
    n2:
        Nonlinear refractive index in m^2/W.
    Eg_J:
        Bandgap energy in joules.
    mred:
        Reduced electron-hole effective mass in kilograms.
    trans:
        Approximate transmission factor, 1 - R.

    Raises
    ------
    ValueError
        If the material flag is not 1 or 2, or if the Sellmeier expression
        becomes nonphysical at the requested wavelength.
    """

    lam = float(wavelength_um)
    if lam <= 0.0:
        raise ValueError("wavelength_um must be positive.")

    if mat_flag == 1:
        bandgap_ev = 2.7
        mred = 0.17 * ME0
        n_squared = (
            1.0
            + 4.45813734 * lam**2 / (lam**2 - 0.200859853**2)
            + 0.467216334 * lam**2 / (lam**2 - 0.391371166**2)
            + 2.89566290 * lam**2 / (lam**2 - 47.1362108**2)
        )
        if lam < 2.0:
            n2 = 2.3e-18
            reflectance = 0.32949
        else:
            n2 = 6.5e-19
            reflectance = 0.31059

    elif mat_flag == 2:
        bandgap_ev = 3.60
        mred = 0.34 * ME0
        n_squared = (
            8.393
            + 0.14383 / (lam**2 - 0.2421**2)
            + 4430.99 / (lam**2 - 36.71**2)
        )
        if lam < 2.0:
            n2 = 6.8e-19
            reflectance = 0.38251
        else:
            n2 = 4.0e-19
            reflectance = 0.26693

    else:
        raise ValueError("mat_flag must be 1 for ZnSe or 2 for ZnS.")

    if not np.isfinite(n_squared) or n_squared <= 0.0:
        raise ValueError(
            f"Nonphysical Sellmeier result n^2={n_squared!r} at {lam} um."
        )

    n0 = np.sqrt(n_squared)
    Eg_J = bandgap_ev * E_CHARGE
    trans = 1.0 - reflectance

    return float(n0), float(n2), float(Eg_J), float(mred), float(trans)


# ============================================================
# Case definitions
# ============================================================

def get_cases() -> List[CaseDict]:
    """
    Return the default ZnSe/ZnS NIR and LWIR LIDT cases.

    Returns
    -------
    list of dict
        Four material/laser case dictionaries.
    """

    return [
        {
            "name": r"ZnSe, 0.8 $\mu$m",
            "short": "ZnSe_NIR",
            "material": "ZnSe",
            "region": "NIR",
            "mat_flag": 1,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "F0_jcm2": 0.112,
        },
        {
            "name": r"ZnS, 0.8 $\mu$m",
            "short": "ZnS_NIR",
            "material": "ZnS",
            "region": "NIR",
            "mat_flag": 2,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "F0_jcm2": 0.170,
        },
        {
            "name": r"ZnSe, 9.2 $\mu$m",
            "short": "ZnSe_LWIR",
            "material": "ZnSe",
            "region": "LWIR",
            "mat_flag": 1,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "F0_jcm2": 0.83,
        },
        {
            "name": r"ZnS, 9.2 $\mu$m",
            "short": "ZnS_LWIR",
            "material": "ZnS",
            "region": "LWIR",
            "mat_flag": 2,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "F0_jcm2": 1.19,
        },
    ]


# ============================================================
# Laser pulse conversion
# ============================================================

def peak_intensity_from_fluence_wm2(F0_jcm2: float, tau_fs: float) -> float:
    """
    Convert peak fluence to peak intensity for a Gaussian temporal pulse.

    For a Gaussian intensity envelope with FWHM duration tau,

        I0 = (2 F0 / tau) sqrt[ln(2)/pi].

    Parameters
    ----------
    F0_jcm2:
        Peak fluence in J/cm^2.
    tau_fs:
        Intensity FWHM duration in femtoseconds.

    Returns
    -------
    float
        Peak intensity in W/m^2.
    """

    F0_jm2 = float(F0_jcm2) * 1.0e4
    tau_s = float(tau_fs) * 1.0e-15

    if F0_jm2 < 0.0:
        raise ValueError("Fluence must be nonnegative.")
    if tau_s <= 0.0:
        raise ValueError("Pulse duration must be positive.")

    return float((2.0 * F0_jm2 / tau_s) * np.sqrt(np.log(2.0) / np.pi))


def gaussian_intensity_time(t_s: float, I0_wm2: float, tau_s: float) -> float:
    """
    Evaluate a Gaussian temporal intensity profile.

    The profile is

        I(t) = I0 exp[-4 ln(2) (t/tau)^2],

    where tau is the intensity FWHM duration.

    Parameters
    ----------
    t_s:
        Time in seconds.
    I0_wm2:
        Peak intensity in W/m^2.
    tau_s:
        Intensity FWHM duration in seconds.

    Returns
    -------
    float
        Instantaneous intensity in W/m^2.
    """

    if tau_s <= 0.0:
        raise ValueError("tau_s must be positive.")

    return float(I0_wm2 * np.exp(-4.0 * np.log(2.0) * (t_s / tau_s) ** 2))


# ============================================================
# Keldysh photoionization model
# ============================================================

def qfun_keldysh(
    gamma: np.ndarray,
    x: np.ndarray,
    Kg: np.ndarray,
    Eg: np.ndarray,
    K1: np.ndarray,
    E1: np.ndarray,
    tol: float = 1.0e-3,
    max_terms: int = 10000,
) -> np.ndarray:
    """
    Evaluate the Keldysh Q-function series.

    Parameters
    ----------
    gamma:
        Keldysh parameter array.
    x:
        Effective photon-order argument.
    Kg, Eg, K1, E1:
        Complete elliptic-integral terms appearing in the Keldysh expression.
    tol:
        Absolute change in the partial sum used as the convergence criterion.
    max_terms:
        Maximum number of series terms.

    Returns
    -------
    np.ndarray
        Keldysh Q-function values.
    """

    gamma = np.atleast_1d(np.asarray(gamma, dtype=float))
    x = np.atleast_1d(np.asarray(x, dtype=float))
    Kg = np.atleast_1d(np.asarray(Kg, dtype=float))
    Eg = np.atleast_1d(np.asarray(Eg, dtype=float))
    K1 = np.atleast_1d(np.asarray(K1, dtype=float))
    E1 = np.atleast_1d(np.asarray(E1, dtype=float))

    arrays = [gamma, x, Kg, Eg, K1, E1]
    if len({arr.size for arr in arrays}) != 1:
        raise ValueError("All qfun_keldysh input arrays must have the same size.")

    q_values = np.zeros_like(gamma)

    for i in range(gamma.size):
        values = [gamma[i], x[i], Kg[i], Eg[i], K1[i], E1[i]]
        if not all(np.isfinite(v) for v in values) or K1[i] <= 0.0 or E1[i] <= 0.0:
            continue

        q_prefactor = np.sqrt(np.pi / (2.0 * K1[i]))
        q_sum = 0.0

        for j in range(max_terms):
            old_sum = q_sum
            exponent = -np.pi * (Kg[i] - Eg[i]) * j / E1[i]
            arg_inside = (
                np.pi**2
                * (2.0 * np.floor(x[i] + 1.0) - 2.0 * x[i] + j)
                / (2.0 * K1[i] * E1[i])
            )
            arg_inside = max(float(arg_inside), 0.0)

            with np.errstate(over="ignore", invalid="ignore", under="ignore"):
                term = np.exp(exponent) * dawsn(np.sqrt(arg_inside))

            if not np.isfinite(term):
                term = 0.0

            q_sum += float(term)

            if abs(q_sum - old_sum) <= tol:
                break

        q_values[i] = q_prefactor * q_sum

    return np.nan_to_num(q_values, nan=0.0, posinf=0.0, neginf=0.0)


def keldysh_full_rate_m3_s(
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
    intensity_wm2: ArrayLike,
) -> ArrayLike:
    """
    Evaluate the full Keldysh photoionization rate.

    Parameters
    ----------
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.
    intensity_wm2:
        Scalar or array of laser intensities in W/m^2.

    Returns
    -------
    float or np.ndarray
        Photoionization rate in m^-3 s^-1.
    """

    intensity = np.asarray(intensity_wm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    rate = np.zeros_like(intensity)
    positive = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(positive):
        I = intensity[positive]

        with np.errstate(divide="ignore", invalid="ignore", over="ignore", under="ignore"):
            electric_field = np.sqrt((2.0 * I) / (C0 * n0 * EPS0))
            gamma = (omega / (E_CHARGE * electric_field)) * np.sqrt(mred * delta_J)
            gamma_sq = gamma**2

            gg = gamma_sq / (1.0 + gamma_sq)
            g1 = 1.0 / (1.0 + gamma_sq)

            Kg = ellipk(gg)
            Eg = ellipe(gg)
            K1 = ellipk(g1)
            E1 = ellipe(g1)

            delta_tilde = (
                2.0
                * delta_J
                * np.sqrt(1.0 + gamma_sq)
                * E1
                / (np.pi * gamma)
            )
            x_order = delta_tilde / (HBAR * omega)
            X = np.floor(x_order + 1.0)

            prefactor = (
                2.0
                * omega
                / (9.0 * np.pi)
                * (
                    (np.sqrt(1.0 + gamma_sq) * mred * omega)
                    / (gamma * HBAR)
                )
                ** 1.5
            )

            q_values = qfun_keldysh(gamma, x_order, Kg, Eg, K1, E1)
            exponential = np.exp(-np.pi * X * (Kg - Eg) / E1)
            rate_positive = prefactor * q_values * exponential

        rate[positive] = np.nan_to_num(
            rate_positive,
            nan=0.0,
            posinf=0.0,
            neginf=0.0,
        )

    if scalar_input:
        return float(rate[0])
    return rate


# ============================================================
# Avalanche / impact-ionization model
# ============================================================

def collision_time_s(ne_m3: float, mred: float, delta_J: float) -> float:
    """
    Evaluate the electron collision time used in the Drude model.

    Parameters
    ----------
    ne_m3:
        Conduction-band electron density in m^-3.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.

    Returns
    -------
    float
        Collision time in seconds. Returns infinity at zero density.
    """

    ne = max(float(ne_m3), 0.0)
    if ne <= 0.0:
        return np.inf

    numerator = 16.0 * np.pi * EPS0**2 * np.sqrt(mred * (0.1 * delta_J) ** 3)
    denominator = np.sqrt(2.0) * E_CHARGE**4 * ne
    tau_c = numerator / denominator

    if not np.isfinite(tau_c) or tau_c <= 0.0:
        return np.inf

    return float(tau_c)


def drude_cross_section_m2(
    omega: float,
    mred: float,
    n0: float,
    tau_c_s: float,
) -> float:
    """
    Evaluate the Drude single-photon absorption cross section safely.

    The direct expression is

        sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2).

    To avoid overflow for very large collision times, it is evaluated as

        sigma = [e^2/(c eps0 n0 m_r)] / omega
                * [(omega tau_C)/(1 + (omega tau_C)^2)].

    Parameters
    ----------
    omega:
        Angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    n0:
        Linear refractive index.
    tau_c_s:
        Collision time in seconds.

    Returns
    -------
    float
        Drude absorption cross section in m^2.
    """

    tau_c = float(tau_c_s)

    if (
        not np.isfinite(tau_c)
        or tau_c <= 0.0
        or not np.isfinite(omega)
        or omega <= 0.0
        or mred <= 0.0
        or n0 <= 0.0
    ):
        return 0.0

    prefactor = E_CHARGE**2 / (C0 * EPS0 * n0 * mred)
    x = omega * tau_c

    if not np.isfinite(x) or x <= 0.0:
        return 0.0

    if x > 1.0e100:
        drude_factor = 1.0 / x
    else:
        drude_factor = x / (1.0 + x * x)

    sigma = (prefactor / omega) * drude_factor

    if not np.isfinite(sigma) or sigma < 0.0:
        return 0.0

    return float(sigma)


def avalanche_generation_rate_m3_s(
    intensity_wm2: float,
    ne_m3: float,
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
) -> float:
    """
    Evaluate the avalanche/impact-ionization carrier-generation rate.

    The implemented relation is

        W_av = (sigma I / E_g) n_e.

    Parameters
    ----------
    intensity_wm2:
        Instantaneous laser intensity in W/m^2.
    ne_m3:
        Instantaneous electron density in m^-3.
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.

    Returns
    -------
    float
        Avalanche generation rate in m^-3 s^-1.
    """

    I = max(float(intensity_wm2), 0.0)
    ne = max(float(ne_m3), 0.0)

    if I <= 0.0 or ne <= 0.0 or delta_J <= 0.0:
        return 0.0

    tau_c = collision_time_s(ne, mred, delta_J)
    sigma = drude_cross_section_m2(
        omega=omega,
        mred=mred,
        n0=n0,
        tau_c_s=tau_c,
    )

    if sigma <= 0.0:
        return 0.0

    W_av = (sigma * I / delta_J) * ne

    if not np.isfinite(W_av) or W_av < 0.0:
        return 0.0

    return float(W_av)


# ============================================================
# General helpers
# ============================================================

def positive_for_log(y: np.ndarray, min_value: float = 1.0e-300) -> np.ndarray:
    """
    Replace nonfinite and nonpositive values with NaN for logarithmic plotting.
    """

    y_plot = np.asarray(y, dtype=float).copy()
    y_plot[~np.isfinite(y_plot)] = np.nan
    y_plot[y_plot <= min_value] = np.nan
    return y_plot


def case_lidt_peak_intensity_wcm2(case: CaseDict) -> float:
    """
    Return the Gaussian peak intensity at the measured LIDT in W/cm^2.
    """

    return (
        peak_intensity_from_fluence_wm2(
            F0_jcm2=case["F0_jcm2"],
            tau_fs=case["tau_fs"],
        )
        * WCM2_PER_WM2
    )


def interpolate_log_y(
    x: np.ndarray,
    y: np.ndarray,
    x0: float,
) -> Optional[float]:
    """
    Interpolate y(x0) in log-log space.

    Returns None when x0 lies outside the valid positive data range.
    """

    x_arr = np.asarray(x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    valid = np.isfinite(x_arr) & np.isfinite(y_arr) & (x_arr > 0.0) & (y_arr > 0.0)

    if np.count_nonzero(valid) < 2:
        return None

    x_valid = x_arr[valid]
    y_valid = y_arr[valid]
    order = np.argsort(x_valid)
    x_valid = x_valid[order]
    y_valid = y_valid[order]

    if x0 < x_valid[0] or x0 > x_valid[-1]:
        return None

    log_y0 = np.interp(
        np.log10(x0),
        np.log10(x_valid),
        np.log10(y_valid),
    )
    return float(10.0**log_y0)


def save_or_show(
    fig: plt.Figure,
    save_dir: Optional[Path],
    filename: str,
) -> None:
    """
    Apply tight layout and either save or display a Matplotlib figure.
    """

    fig.tight_layout()

    if save_dir is not None:
        save_dir.mkdir(parents=True, exist_ok=True)
        output_path = save_dir / filename
        fig.savefig(output_path, dpi=300, bbox_inches="tight")
        plt.close(fig)
        print(f"Saved {output_path}")
    else:
        plt.show()


# ============================================================
# Time-dependent dynamics
# ============================================================

def solve_dynamics_from_peak_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 1000,
) -> Dict[str, Any]:
    """
    Solve total carrier-density dynamics at a specified peak intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I0_wcm2:
        Peak laser intensity in W/cm^2.
    n_time_points:
        Number of points used for post-processing the dense ODE solution.

    Returns
    -------
    dict
        Time-dependent photoionization, avalanche, total rates, and density.
    """

    if I0_wcm2 < 0.0:
        raise ValueError("I0_wcm2 must be nonnegative.")
    if n_time_points < 2:
        raise ValueError("n_time_points must be at least 2.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = float(I0_wcm2) * WM2_PER_WCM2

    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )

        derivative = W_pi + W_av
        if not np.isfinite(derivative) or derivative < 0.0:
            derivative = 0.0

        return [float(derivative)]

    solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-5,
        atol=1.0e6,
        max_step=tau_s / 350.0,
        dense_output=True,
    )

    t_eval = np.linspace(t0, t1, n_time_points)

    if solution.sol is not None:
        ne = np.maximum(solution.sol(t_eval)[0], 0.0)
    else:
        ne = np.maximum(np.interp(t_eval, solution.t, solution.y[0]), 0.0)

    intensity = np.asarray([intensity_at_time(t) for t in t_eval], dtype=float)
    Wpi = np.asarray([photo_rate_at_time(t) for t in t_eval], dtype=float)
    Wav = np.asarray(
        [
            avalanche_generation_rate_m3_s(
                intensity_wm2=I_now,
                ne_m3=ne_now,
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )
            for I_now, ne_now in zip(intensity, ne)
        ],
        dtype=float,
    )
    Wtotal = Wpi + Wav

    return {
        "case": case,
        "t_s": t_eval,
        "intensity_wm2": intensity,
        "Wpi_m3_s": Wpi,
        "Wav_m3_s": Wav,
        "Wtotal_m3_s": Wtotal,
        "Wpi_cm3_fs": Wpi * RATE_CM3_FS_PER_M3_S,
        "Wav_cm3_fs": Wav * RATE_CM3_FS_PER_M3_S,
        "Wtotal_cm3_fs": Wtotal * RATE_CM3_FS_PER_M3_S,
        "ne_m3": ne,
        "ne_cm3": ne * CM3_PER_M3,
        "solver_success": bool(solution.success),
        "solver_message": str(solution.message),
    }


SCALING_CACHE: Dict[Tuple[str, int, float, float, int], Dict[str, np.ndarray]] = {}


def compute_case_scaling(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 600,
) -> Dict[str, np.ndarray]:
    """
    Compute the peak total ionization rate versus peak laser intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        One-dimensional array of peak intensities in W/cm^2.
    n_time_points:
        Number of post-processing time points per ODE solution.

    Returns
    -------
    dict
        Intensity array and peak total ionization-rate array.
    """

    intensity_values = np.asarray(I_values_wcm2, dtype=float)

    if intensity_values.ndim != 1 or intensity_values.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensity_values)) or np.any(intensity_values <= 0.0):
        raise ValueError("All intensity values must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensity_values.size),
        float(intensity_values[0]),
        float(intensity_values[-1]),
        int(n_time_points),
    )

    if cache_key in SCALING_CACHE:
        return SCALING_CACHE[cache_key]

    Wtotal_peak = np.zeros_like(intensity_values)
    print(f"\nComputing intensity scaling for {case['short']} ...")

    report_interval = max(1, intensity_values.size // 10)

    for index, I0_wcm2 in enumerate(intensity_values):
        if index % report_interval == 0 or index == intensity_values.size - 1:
            print(
                f"  {index + 1:3d}/{intensity_values.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2 reported: {result['solver_message']}"
            )

        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(
                result["Wtotal_cm3_fs"],
                nan=0.0,
                posinf=0.0,
                neginf=0.0,
            )
        )

    output = {
        "I_wcm2": intensity_values,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
    }
    SCALING_CACHE[cache_key] = output
    return output


def solve_density_case(case: CaseDict) -> Dict[str, Any]:
    """
    Solve photoionization-only and photoionization-plus-avalanche density growth.

    Parameters
    ----------
    case:
        Material/laser case dictionary.

    Returns
    -------
    dict
        Material parameters, peak intensity, final densities, and solver status.
    """

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = peak_intensity_from_fluence_wm2(
        F0_jcm2=float(case["F0_jcm2"]),
        tau_fs=float(case["tau_fs"]),
    )

    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_photo(t: float, _y: np.ndarray) -> List[float]:
        return [photo_rate_at_time(t)]

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )
        derivative = W_pi + W_av
        return [float(max(derivative, 0.0)) if np.isfinite(derivative) else 0.0]

    photo_solution = solve_ivp(
        rhs_photo,
        (t0, t1),
        y0=[0.0],
        method="RK45",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 200.0,
    )

    total_solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 500.0,
    )

    ne_photo_final_m3 = float(max(photo_solution.y[0, -1], 0.0))
    ne_total_final_m3 = float(max(total_solution.y[0, -1], 0.0))

    return {
        "case": case,
        "n0": n0,
        "n2": n2,
        "trans": trans,
        "Eg_eV": Eg_J / E_CHARGE,
        "mred_over_me": mred / ME0,
        "I0_wm2": I0_wm2,
        "I0_wcm2": I0_wm2 * WCM2_PER_WM2,
        "ne_photo_m3": ne_photo_final_m3,
        "ne_total_m3": ne_total_final_m3,
        "ne_photo_cm3": ne_photo_final_m3 * CM3_PER_M3,
        "ne_total_cm3": ne_total_final_m3 * CM3_PER_M3,
        "ne_avalanche_added_cm3": (
            max(ne_total_final_m3 - ne_photo_final_m3, 0.0) * CM3_PER_M3
        ),
        "sol_photo_success": bool(photo_solution.success),
        "sol_photo_message": str(photo_solution.message),
        "sol_total_success": bool(total_solution.success),
        "sol_total_message": str(total_solution.message),
    }


# ============================================================
# Summary table
# ============================================================

def build_summary_table(results: Sequence[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Convert density-solver results into rows for display.
    """

    rows: List[Dict[str, Any]] = []

    for result in results:
        case = result["case"]
        rows.append(
            {
                "Case": case["short"],
                "Material": case["material"],
                "Regime": case["region"],
                "lambda_um": case["wavelength_um"],
                "tau_fs": case["tau_fs"],
                "F0_Jcm2": case["F0_jcm2"],
                "I0_Wcm2": result["I0_wcm2"],
                "n_photo_cm3": result["ne_photo_cm3"],
                "n_avalanche_added_cm3": result["ne_avalanche_added_cm3"],
                "n_total_cm3": result["ne_total_cm3"],
                "n0": result["n0"],
                "Eg_eV": result["Eg_eV"],
                "mred_over_me": result["mred_over_me"],
                "solver": (
                    "OK"
                    if result["sol_photo_success"] and result["sol_total_success"]
                    else "CHECK"
                ),
            }
        )

    return rows


def display_summary_table(rows: Sequence[Dict[str, Any]]) -> None:
    """
    Display the density-growth summary table in Jupyter or plain text.
    """

    print("\n================ Density-growth summary table ================\n")

    if pd is None:
        for row in rows:
            print(row)
        return

    dataframe = pd.DataFrame(rows)
    display_frame = dataframe.copy()

    scientific_columns = [
        "I0_Wcm2",
        "n_photo_cm3",
        "n_avalanche_added_cm3",
        "n_total_cm3",
    ]
    compact_columns = [
        "lambda_um",
        "tau_fs",
        "F0_Jcm2",
        "n0",
        "Eg_eV",
        "mred_over_me",
    ]

    for column in scientific_columns:
        display_frame[column] = display_frame[column].map(lambda value: f"{value:.4e}")

    for column in compact_columns:
        display_frame[column] = display_frame[column].map(lambda value: f"{value:.4g}")

    if ipython_display is not None:
        ipython_display(display_frame)
    else:
        print(display_frame.to_string(index=False))


# ============================================================
# First graph set: Keldysh photoionization curves
# ============================================================

def plot_keldysh_rate_curves(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot Keldysh photoionization-rate curves for all default cases.

    The measured LIDT peak intensity is marked by a black cross.
    """

    I_values_wm2 = np.logspace(14, 19, 900)
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes_flat = axes.ravel()

    for ax, case in zip(axes_flat, cases):
        wavelength_um = float(case["wavelength_um"])
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        n0, _n2, Eg_J, mred, _trans = material_flag1(
            mat_flag=int(case["mat_flag"]),
            wavelength_um=wavelength_um,
        )

        Wpi = np.asarray(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=I_values_wm2,
            ),
            dtype=float,
        )

        keep = np.isfinite(Wpi) & (Wpi > 0.0)

        ax.loglog(
            I_values_wm2[keep],
            Wpi[keep],
            linewidth=2.4,
            label=r"$W_{\rm PI}$",
        )

        I_lidt_wm2 = case_lidt_peak_intensity_wcm2(case) * WM2_PER_WCM2

        if np.any(keep):
            W_lidt = interpolate_log_y(
                x=I_values_wm2[keep],
                y=Wpi[keep],
                x0=I_lidt_wm2,
            )
            if W_lidt is not None:
                ax.plot(
                    I_lidt_wm2,
                    W_lidt,
                    "kx",
                    markersize=9,
                    markeredgewidth=2,
                    label=r"$I_0$ at LIDT",
                )

        ax.set_title(case["name"])
        ax.set_xlabel(r"Laser intensity $I$ (W/m$^2$)")
        ax.set_ylabel(r"$W_{\rm PI}$ (m$^{-3}$ s$^{-1}$)")
        ax.grid(True, which="both", alpha=0.25)
        ax.legend(frameon=False)

    for ax in axes_flat[len(cases):]:
        ax.set_visible(False)

    fig.suptitle("Keldysh photoionization-rate curves", fontsize=15)
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="01_first_graph_set_keldysh_rate_curves.png",
    )


# ============================================================
# ZnS-reference Keldysh parameter axis
# ============================================================

def gamma_zns_reference_from_intensity_wcm2(
    I_wcm2: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Evaluate the Keldysh parameter using ZnS as the reference material.

    Parameters
    ----------
    I_wcm2:
        Scalar or array of intensities in W/cm^2.
    wavelength_um:
        Wavelength in micrometers.
    include_field_factor_two:
        If True, include the factor of two associated with
        I = (1/2) c n eps0 E^2 in the denominator.

    Returns
    -------
    float or np.ndarray
        Keldysh parameter values.
    """

    intensity = np.asarray(I_wcm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    gamma = np.full_like(intensity, np.inf)
    valid = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(valid):
        I_wm2 = intensity[valid] * WM2_PER_WCM2
        n_zns, _n2, Eg_zns_J, mred_zns, _trans = material_flag1(2, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            gamma_valid = (omega / E_CHARGE) * np.sqrt(
                (mred_zns * C0 * n_zns * EPS0 * Eg_zns_J)
                / (field_factor * I_wm2)
            )

        gamma[valid] = np.nan_to_num(
            gamma_valid,
            nan=np.inf,
            posinf=np.inf,
            neginf=np.inf,
        )

    if scalar_input:
        return float(gamma[0])
    return gamma


def intensity_wcm2_from_gamma_zns_reference(
    gamma: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Convert a ZnS-reference Keldysh parameter to intensity in W/cm^2.
    """

    gamma_values = np.asarray(gamma, dtype=float)
    scalar_input = gamma_values.ndim == 0
    gamma_values = np.atleast_1d(gamma_values)

    intensity = np.full_like(gamma_values, np.inf)
    valid = np.isfinite(gamma_values) & (gamma_values > 0.0)

    if np.any(valid):
        n_zns, _n2, Eg_zns_J, mred_zns, _trans = material_flag1(2, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            I_wm2 = (
                (omega / E_CHARGE) ** 2
                * (mred_zns * C0 * n_zns * EPS0 * Eg_zns_J)
                / (field_factor * gamma_values[valid] ** 2)
            )

        intensity[valid] = I_wm2 * WCM2_PER_WM2

    if scalar_input:
        return float(intensity[0])
    return intensity


def add_zns_gamma_top_axis(
    ax: plt.Axes,
    wavelength_um: float,
    gamma_ticks: Tuple[float, ...],
    include_field_factor_two: bool = True,
) -> None:
    """
    Add a ZnS-reference Keldysh-parameter axis above an intensity axis.
    """

    ax_top = ax.twiny()
    ax_top.set_xscale("log")
    ax_top.set_xlim(ax.get_xlim())

    tick_positions = np.asarray(
        intensity_wcm2_from_gamma_zns_reference(
            gamma=np.asarray(gamma_ticks, dtype=float),
            wavelength_um=wavelength_um,
            include_field_factor_two=include_field_factor_two,
        ),
        dtype=float,
    )

    x_min, x_max = ax.get_xlim()
    valid_ticks: List[float] = []
    valid_labels: List[str] = []

    for gamma_value, tick_position in zip(gamma_ticks, tick_positions):
        if np.isfinite(tick_position) and x_min <= tick_position <= x_max:
            valid_ticks.append(float(tick_position))
            valid_labels.append(f"{gamma_value:g}")

    ax_top.set_xticks(valid_ticks)
    ax_top.set_xticklabels(valid_labels)
    ax_top.set_xlabel(r"Keldysh parameter $\gamma$ (ZnS reference)")
    ax_top.tick_params(axis="x", which="both", direction="in")


# ============================================================
# Last graph set: total ionization comparison
# ============================================================

def plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 50,
    I_min_wcm2: float = 5.0e10,
    I_max_wcm2: float = 1.0e15,
    y_min: float = 1.0e0,
    y_max: float = 1.0e30,
    include_field_factor_two: bool = True,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot peak total ionization rate for ZnSe and ZnS in NIR and LWIR.

    Each panel includes a ZnS-reference Keldysh-parameter top axis and a
    dashed vertical line at gamma = 1.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Intensity limits must satisfy 0 < I_min < I_max.")

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )

    regime_order = ["NIR", "LWIR"]
    panel_labels = {"NIR": "(a) NIR", "LWIR": "(b) LWIR"}
    gamma_ticks_by_regime = {
        "NIR": (10.0, 3.0, 1.0, 0.3),
        "LWIR": (1.0, 0.3, 0.1),
    }
    material_order = {"ZnSe": 0, "ZnS": 1}

    fig, axes = plt.subplots(1, 2, figsize=(13.5, 5.2), sharey=True)

    print("\nCalculating NIR/LWIR total-ionization comparison ...\n")

    for ax, regime in zip(axes, regime_order):
        regime_cases = sorted(
            [case for case in cases if case["region"] == regime],
            key=lambda case: material_order.get(case["material"], 99),
        )

        if not regime_cases:
            raise ValueError(f"No cases were supplied for regime {regime!r}.")

        wavelength_um = float(regime_cases[0]["wavelength_um"])

        for case in regime_cases:
            print(f"  {regime}: {case['short']}")
            scaling = compute_case_scaling(
                case=case,
                I_values_wcm2=I_values_wcm2,
                n_time_points=600,
            )

            I = scaling["I_wcm2"]
            Wtotal = scaling["Wtotal_peak_cm3_fs"]

            ax.loglog(
                I,
                positive_for_log(Wtotal),
                linewidth=2.6,
                label=case["material"],
            )

            I_lidt = case_lidt_peak_intensity_wcm2(case)
            W_lidt = interpolate_log_y(I, Wtotal, I_lidt)

            if W_lidt is not None:
                ax.plot(
                    I_lidt,
                    W_lidt,
                    "kx",
                    markersize=8.5,
                    markeredgewidth=2.0,
                )

        I_gamma_1 = float(
            intensity_wcm2_from_gamma_zns_reference(
                gamma=1.0,
                wavelength_um=wavelength_um,
                include_field_factor_two=include_field_factor_two,
            )
        )

        if I_min_wcm2 <= I_gamma_1 <= I_max_wcm2:
            ax.axvline(
                I_gamma_1,
                color="k",
                linestyle="--",
                linewidth=1.7,
            )
            ax.text(
                I_gamma_1 * 1.12,
                y_max / 8.0,
                r"$\gamma=1$",
                fontsize=11,
                verticalalignment="center",
            )

        ax.text(
            0.03,
            0.90,
            panel_labels[regime],
            transform=ax.transAxes,
            fontsize=14,
            fontweight="bold",
        )
        ax.set_xlabel(r"Laser intensity $I$ (W/cm$^2$)")
        ax.set_xlim(I_min_wcm2, I_max_wcm2)
        ax.set_ylim(y_min, y_max)
        ax.grid(True, which="major", alpha=0.28)
        ax.grid(True, which="minor", alpha=0.14, linestyle=":")
        ax.legend(frameon=False, fontsize=14, loc="lower right")

        add_zns_gamma_top_axis(
            ax=ax,
            wavelength_um=wavelength_um,
            gamma_ticks=gamma_ticks_by_regime[regime],
            include_field_factor_two=include_field_factor_two,
        )

    axes[0].set_ylabel(
        r"Peak total ionization rate $W_{\rm total}$ (cm$^{-3}$ fs$^{-1}$)"
    )

    fig.suptitle(
        r"Total ionization including avalanche: "
        r"$W_{\rm total}=W_{\rm PI}+(\sigma I/E_g)n_e$",
        fontsize=14,
    )

    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="02_last_graph_set_total_ionization_gamma_axis.png",
    )



# ============================================================
# ZnSe/ZnS plots 
# ============================================================

COMPONENT_SCALING_CACHE: Dict[
    Tuple[str, int, float, float, int], Dict[str, np.ndarray]
] = {}


def normalize_curve(values: np.ndarray) -> np.ndarray:
    """Normalize a nonnegative curve to its maximum value."""

    array = np.asarray(values, dtype=float)
    array = np.nan_to_num(array, nan=0.0, posinf=0.0, neginf=0.0)
    maximum = float(np.max(array)) if array.size else 0.0
    if maximum <= 0.0:
        return np.zeros_like(array)
    return array / maximum


def compute_case_scaling_components(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 700,
) -> Dict[str, np.ndarray]:
    """
    Compute peak photoionization, avalanche, total rates, and density.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        Peak intensities in W/cm^2.
    n_time_points:
        Number of time samples used to post-process each ODE solution.

    Returns
    -------
    dict
        Arrays of peak W_PI, W_av, W_total, and maximum electron density.
    """

    intensities = np.asarray(I_values_wcm2, dtype=float)
    if intensities.ndim != 1 or intensities.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensities)) or np.any(intensities <= 0.0):
        raise ValueError("All intensities must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensities.size),
        float(intensities[0]),
        float(intensities[-1]),
        int(n_time_points),
    )
    if cache_key in COMPONENT_SCALING_CACHE:
        return COMPONENT_SCALING_CACHE[cache_key]

    Wpi_peak = np.zeros_like(intensities)
    Wav_peak = np.zeros_like(intensities)
    Wtotal_peak = np.zeros_like(intensities)
    ne_max = np.zeros_like(intensities)

    print(f"\nComputing rate-component scaling for {case['short']} ...")
    report_interval = max(1, intensities.size // 10)

    for index, I0_wcm2 in enumerate(intensities):
        if index % report_interval == 0 or index == intensities.size - 1:
            print(
                f"  {index + 1:3d}/{intensities.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2: {result['solver_message']}"
            )

        Wpi_peak[index] = np.nanmax(
            np.nan_to_num(result["Wpi_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wav_peak[index] = np.nanmax(
            np.nan_to_num(result["Wav_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(result["Wtotal_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        ne_max[index] = np.nanmax(
            np.nan_to_num(result["ne_cm3"], nan=0.0, posinf=0.0, neginf=0.0)
        )

    output = {
        "I_wcm2": intensities,
        "Wpi_peak_cm3_fs": Wpi_peak,
        "Wav_peak_cm3_fs": Wav_peak,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
        "ne_max_cm3": ne_max,
    }
    COMPONENT_SCALING_CACHE[cache_key] = output
    return output


def plot_case_figure_1_style(
    case: CaseDict,
    save_dir: Optional[Path] = None,
) -> None:
    """Plot Keldysh photoionization rate versus peak irradiance."""

    I_values_wcm2 = np.logspace(10, 15, 900)
    I_values_wm2 = I_values_wcm2 * WM2_PER_WCM2
    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        int(case["mat_flag"]), wavelength_um
    )

    Wpi_cm3_fs = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_values_wm2,
        ),
        dtype=float,
    ) * RATE_CM3_FS_PER_M3_S

    I_lidt = case_lidt_peak_intensity_wcm2(case)
    fig, ax = plt.subplots(figsize=(7.0, 5.0))
    ax.loglog(
        I_values_wcm2,
        positive_for_log(Wpi_cm3_fs),
        "k-",
        linewidth=2.2,
        label=r"$W_{\rm PI}$",
    )

    W_lidt = interpolate_log_y(I_values_wcm2, Wpi_cm3_fs, I_lidt)
    if W_lidt is not None:
        ax.plot(
            I_lidt,
            W_lidt,
            "kx",
            markersize=9,
            markeredgewidth=2.0,
            label=r"$I_0$ at measured LIDT",
        )

    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Photoionization rate $W_{\rm PI}$ (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"{case['material']}: $W_{{\rm PI}}$ vs irradiance, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig1_{case['short']}.png",
    )


def plot_case_figure_2_style(
    case: CaseDict,
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot rate components, electron density, and total rate versus irradiance.
    """

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    scaling = compute_case_scaling_components(
        case=case,
        I_values_wcm2=I_values_wcm2,
        n_time_points=600,
    )

    I = scaling["I_wcm2"]
    Wpi = scaling["Wpi_peak_cm3_fs"]
    Wav = scaling["Wav_peak_cm3_fs"]
    Wtotal = scaling["Wtotal_peak_cm3_fs"]
    ne = scaling["ne_max_cm3"]
    I_lidt = case_lidt_peak_intensity_wcm2(case)

    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))

    ax = axes[0]
    ax.loglog(I, positive_for_log(Wtotal), "b--", linewidth=2.5, label=r"$W_{\rm total}$")
    ax.loglog(I, positive_for_log(Wpi), "k:", linewidth=2.3, label=r"$W_{\rm PI}$")
    ax.loglog(
        I,
        positive_for_log(Wav),
        color="orange",
        linestyle="-.",
        linewidth=2.3,
        label=r"$W_{\rm av}$",
    )
    ax.axvline(I_lidt, color="0.4", linestyle="--", linewidth=1.3, label=r"$I_0$ at LIDT")
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"(a) {case['material']}, $\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    ax = axes[1]
    ax_rate = ax.twinx()
    line_density, = ax.loglog(I, positive_for_log(ne), "r-", linewidth=2.5, label=r"$n_e$")
    line_rate, = ax_rate.loglog(
        I,
        positive_for_log(Wtotal),
        "b--",
        linewidth=2.5,
        label=r"$W_{\rm total}$",
    )
    ax.axvline(I_lidt, color="0.4", linestyle="--", linewidth=1.3)
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    ax_rate.set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title("(b) Density and total ionization rate")
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(
        [line_density, line_rate],
        [line_density.get_label(), line_rate.get_label()],
        frameon=False,
        fontsize=9,
    )
    ax.set_xlim(1.0e10, 1.0e15)

    fig.suptitle(f"{case['short']}: irradiance scaling", fontsize=14)
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig2_{case['short']}.png",
    )


def plot_case_figure_3_style(
    case: CaseDict,
    intensity_factors: Tuple[float, float, float, float] = (0.25, 0.5, 1.0, 2.0),
    save_dir: Optional[Path] = None,
) -> None:
    """Plot normalized time-domain carrier and ionization dynamics."""

    I_lidt_wcm2 = case_lidt_peak_intensity_wcm2(case)
    fig, axes = plt.subplots(4, 2, figsize=(13.0, 14.0), sharey=True)

    for row, factor in enumerate(intensity_factors):
        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=factor * I_lidt_wcm2,
            n_time_points=1800,
        )

        if float(case["tau_fs"]) >= 1000.0:
            time_axis = result["t_s"] * 1.0e12
            time_label = "Time (ps)"
        else:
            time_axis = result["t_s"] * 1.0e15
            time_label = "Time (fs)"

        I_norm = normalize_curve(result["intensity_wm2"])
        ne_norm = normalize_curve(result["ne_cm3"])
        Wpi_norm = normalize_curve(result["Wpi_cm3_fs"])
        Wav_norm = normalize_curve(result["Wav_cm3_fs"])
        Wtotal_norm = normalize_curve(result["Wtotal_cm3_fs"])

        ax = axes[row, 0]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(time_axis, ne_norm, "r-", linewidth=2.0, label=r"$n_e$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm LIDT}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.set_ylabel("Normalized value")
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

        ax = axes[row, 1]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(
            time_axis,
            Wav_norm,
            color="goldenrod",
            linestyle="-.",
            linewidth=2.0,
            label=r"$W_{\rm av}$",
        )
        ax.plot(time_axis, Wpi_norm, "k:", linewidth=2.0, label=r"$W_{\rm PI}$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm LIDT}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

    axes[-1, 0].set_xlabel(time_label)
    axes[-1, 1].set_xlabel(time_label)
    fig.suptitle(
        rf"{case['material']} time-domain dynamics, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig3_{case['short']}.png",
    )


def plot_material_figure_4_style(
    material_name: str,
    material_cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Compare NIR and LWIR density/rate scaling for one material."""

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))
    linestyles = {"NIR": "-", "LWIR": "-."}

    for case in material_cases:
        scaling = compute_case_scaling_components(
            case=case,
            I_values_wcm2=I_values_wcm2,
            n_time_points=600,
        )
        I = scaling["I_wcm2"]
        ne = scaling["ne_max_cm3"]
        Wtotal = scaling["Wtotal_peak_cm3_fs"]
        label = rf"{case['wavelength_um']:g} $\mu$m, $\tau={case['tau_fs']:g}$ fs"
        style = linestyles.get(case["region"], "-")

        axes[0].loglog(I, positive_for_log(ne), linestyle=style, linewidth=2.3, label=label)
        axes[1].loglog(I, positive_for_log(Wtotal), linestyle=style, linewidth=2.3, label=label)

        I_lidt = case_lidt_peak_intensity_wcm2(case)
        axes[0].axvline(I_lidt, color="0.5", linestyle="--", linewidth=1.0)
        axes[1].axvline(I_lidt, color="0.5", linestyle="--", linewidth=1.0)

    axes[0].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[0].set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    axes[0].set_title(f"(a) {material_name}: electron density")
    axes[0].grid(True, which="both", alpha=0.3)
    axes[0].legend(frameon=False, fontsize=9)
    axes[0].set_xlim(1.0e10, 1.0e15)

    axes[1].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[1].set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    axes[1].set_title(f"(b) {material_name}: total ionization rate")
    axes[1].grid(True, which="both", alpha=0.3)
    axes[1].legend(frameon=False, fontsize=9)
    axes[1].set_xlim(1.0e10, 1.0e15)

    fig.suptitle(
        rf"{material_name}: NIR 100 fs versus LWIR 2 ps irradiance scaling",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig4_{material_name}.png",
    )


def plot_znse_zns_figures(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Generate all Figs. 1-4 for ZnSe and ZnS."""

    print("\n============================================================")
    print("Generating ZnSe/ZnS plots")
    print("Cases: 0.8 um, 100 fs and 9.2 um, 2 ps")
    print("============================================================\n")

    for case in cases:
        plot_case_figure_1_style(case, save_dir=save_dir)
        plot_case_figure_2_style(
            case,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )
        plot_case_figure_3_style(case, save_dir=save_dir)

    for material_name in ("ZnSe", "ZnS"):
        material_cases = [
            case for case in cases if case["material"] == material_name
        ]
        plot_material_figure_4_style(
            material_name=material_name,
            material_cases=material_cases,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )


# ============================================================
# Workflow and command-line interface
# ============================================================

def solve_and_display_summary(cases: Sequence[CaseDict]) -> None:
    """Solve the four LIDT cases and display the summary table."""

    results: List[Dict[str, Any]] = []
    for case in cases:
        print(f"Solving density table entry for {case['short']} ...")
        result = solve_density_case(case)
        results.append(result)

        if not result["sol_photo_success"]:
            print(
                f"  WARNING: photo-only solver for {case['short']}: "
                f"{result['sol_photo_message']}"
            )
        if not result["sol_total_success"]:
            print(
                f"  WARNING: total solver for {case['short']}: "
                f"{result['sol_total_message']}"
            )

    display_summary_table(build_summary_table(results))


def run_first_last_table_workflow(
    cases: Sequence[CaseDict],
    points: int,
    save_dir: Optional[Path],
) -> None:
    """Run the compact workflow: first graph set, table, and last graph set."""

    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    solve_and_display_summary(cases)
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=points,
        I_min_wcm2=5.0e10,
        I_max_wcm2=1.0e15,
        y_min=1.0e0,
        y_max=1.0e30,
        include_field_factor_two=True,
        save_dir=save_dir,
    )


def run_all_plots_workflow(
    cases: Sequence[CaseDict],
    points: int,
    save_dir: Optional[Path],
) -> None:
    """Run the compact workflow plus all plots."""

    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    solve_and_display_summary(cases)
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=points,
        I_min_wcm2=5.0e10,
        I_max_wcm2=1.0e15,
        y_min=1.0e0,
        y_max=1.0e30,
        include_field_factor_two=True,
        save_dir=save_dir,
    )
    plot_znse_zns_figures(
        cases=cases,
        n_intensity_points=points,
        save_dir=save_dir,
    )


def build_argument_parser() -> argparse.ArgumentParser:
    """Construct the command-line argument parser."""

    parser = argparse.ArgumentParser(
        description=(
            "Run the reconciled ZnSe/ZnS Keldysh + avalanche model and "
            "generate the requested graph sets."
        )
    )
    parser.add_argument(
        "--mode",
        choices=("all", "first-last", "dis"),
        default="all",
        help=(
            "all: all plots and table; first-last: compact workflow only; "
            "dis: only the plots."
        ),
    )
    parser.add_argument(
        "--points",
        type=int,
        default=50,
        help="Number of intensity points used in scaling plots.",
    )
    parser.add_argument(
        "--save",
        action="store_true",
        help="Save figures instead of displaying them.",
    )
    parser.add_argument(
        "--outdir",
        type=str,
        default="figures_all_plots",
        help="Directory used when --save is specified.",
    )
    return parser


def main(argv: Optional[List[str]] = None) -> None:
    """
    Parse command-line options and run the selected workflow.

    In Jupyter, use ``main([])`` for the default all-plots workflow or, for
    a faster test, ``main(["--mode", "first-last", "--points", "12"])``.
    """

    parser = build_argument_parser()
    args, _unknown = parser.parse_known_args(argv)

    if args.points < 2:
        parser.error("--points must be at least 2.")

    cases = get_cases()
    save_dir = Path(args.outdir) if args.save else None

    if args.mode == "first-last":
        run_first_last_table_workflow(cases, args.points, save_dir)
    elif args.mode == "dis":
        plot_znse_zns_figures(cases, args.points, save_dir)
    else:
        run_all_plots_workflow(cases, args.points, save_dir)


if __name__ == "__main__":
    main()

--- Notebook code cell 2 ---


====================================================================================================
FILE: Keldysh\Keldsyh_II_various.py
====================================================================================================

# Converted from Keldsyh_II_various.ipynb
# Source notebook: Keldsyh_II_various.ipynb

# %%
# Cell 0
"""
Reconciled Keldysh + avalanche ionization model for ZnSe and ZnS.

The script evaluates
--------------------
1. Full Keldysh photoionization rate, W_PI.
2. Avalanche/impact ionization using a Drude absorption cross section,

       W_av(I, n_e) = [sigma(I, n_e) I / E_g] n_e,

   with

       sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2),

       tau_C = 16 pi eps0^2 sqrt[m_r (0.1 E_g)^3]
               / [sqrt(2) e^4 n_e].

3. Time-dependent carrier-density growth,

       dn_e/dt = W_PI(t) + W_av(I(t), n_e(t)).

Model assumptions
-----------------
* Recombination and trapping are neglected.
* Carrier depletion and saturation are neglected.
* Propagation, self-focusing, and laser-induced changes in optical constants
  are neglected.
* The same linear refractive index is used in the Keldysh and Drude terms.
* The temporal pulse is Gaussian and centered at t = 0.
* The integration window is from -3 tau to +3 tau, where tau is the
  intensity FWHM duration.

Units
-----
* Internal calculations: SI units.
* Input fluence: J/cm^2.
* Input irradiance for scaling plots: W/cm^2.
* Wavelength: micrometers.
* Pulse duration: femtoseconds.
* Summary densities: cm^-3.
* Final rate plot: cm^-3 fs^-1.

Default workflow
----------------
The default execution produces:
1. The first graph set: Keldysh photoionization-rate curves.
2. The density-growth summary table.
3. The total-ionization 3D surface grid.
"""


from __future__ import annotations

import csv
import json
import os
import pickle
from pathlib import Path
from typing import Any, Dict, List, Optional, Sequence, Tuple, Union

# CODEX MODIFICATION START: shared colormap normalization for 3D colorbar
from matplotlib import cm, colors
# CODEX MODIFICATION END: shared colormap normalization for 3D colorbar
import matplotlib.pyplot as plt
import numpy as np
from scipy.integrate import solve_ivp
from scipy.special import dawsn, ellipe, ellipk

try:
    import pandas as pd
except ImportError:
    pd = None

try:
    from IPython.display import display as ipython_display
except ImportError:
    ipython_display = None


# ============================================================
# Constants
# ============================================================

C0 = 3.0e8
EPS0 = 8.85e-12
E_CHARGE = 1.6e-19
HBAR = 1.054e-34
ME0 = 9.11e-31

CM3_PER_M3 = 1.0e-6
WCM2_PER_WM2 = 1.0e-4
WM2_PER_WCM2 = 1.0e4
RATE_CM3_FS_PER_M3_S = 1.0e-21

CaseDict = Dict[str, Any]
ArrayLike = Union[np.ndarray, float]

# CODEX MODIFICATION START: optional deferred Matplotlib display
DEFER_FIGURE_SHOW = False
# CODEX MODIFICATION END: optional deferred Matplotlib display

# CODEX MODIFICATION START: automatic editable figure exports
# Every saved PNG is accompanied by a Matplotlib-editable .mplfig.pkl file.
SAVE_EDITABLE_FIGURES = True
# CODEX MODIFICATION END: automatic editable figure exports

# CODEX MODIFICATION START: optional open saved image preview
OPEN_SAVED_FIGURES = False
# CODEX MODIFICATION END: optional open saved image preview


# ============================================================
# Material properties
# ============================================================

def material_flag1(
    mat_flag: int,
    wavelength_um: float,
) -> Tuple[float, float, float, float, float]:
    """
    Return wavelength-dependent material parameters for ZnSe or ZnS.

    Parameters
    ----------
    mat_flag:
        Material selector: 1 for ZnSe and 2 for ZnS.
    wavelength_um:
        Vacuum wavelength in micrometers.

    Returns
    -------
    n0:
        Linear refractive index.
    n2:
        Nonlinear refractive index in m^2/W.
    Eg_J:
        Bandgap energy in joules.
    mred:
        Reduced electron-hole effective mass in kilograms.
    trans:
        Approximate transmission factor, 1 - R.

    Raises
    ------
    ValueError
        If the material flag is not 1 or 2, or if the Sellmeier expression
        becomes nonphysical at the requested wavelength.
    """

    lam = float(wavelength_um)
    if lam <= 0.0:
        raise ValueError("wavelength_um must be positive.")

    if mat_flag == 1:
        bandgap_ev = 2.7
        mred = 0.17 * ME0
        n_squared = (
            1.0
            + 4.45813734 * lam**2 / (lam**2 - 0.200859853**2)
            + 0.467216334 * lam**2 / (lam**2 - 0.391371166**2)
            + 2.89566290 * lam**2 / (lam**2 - 47.1362108**2)
        )
        if lam < 2.0:
            n2 = 2.3e-18
            reflectance = 0.32949
        else:
            n2 = 6.5e-19
            reflectance = 0.31059

    elif mat_flag == 2:
        bandgap_ev = 3.60
        mred = 0.34 * ME0
        n_squared = (
            8.393
            + 0.14383 / (lam**2 - 0.2421**2)
            + 4430.99 / (lam**2 - 36.71**2)
        )
        if lam < 2.0:
            n2 = 6.8e-19
            reflectance = 0.38251
        else:
            n2 = 4.0e-19
            reflectance = 0.26693

    else:
        raise ValueError("mat_flag must be 1 for ZnSe or 2 for ZnS.")

    if not np.isfinite(n_squared) or n_squared <= 0.0:
        raise ValueError(
            f"Nonphysical Sellmeier result n^2={n_squared!r} at {lam} um."
        )

    n0 = np.sqrt(n_squared)
    Eg_J = bandgap_ev * E_CHARGE
    trans = 1.0 - reflectance

    return float(n0), float(n2), float(Eg_J), float(mred), float(trans)


# ============================================================
# Case definitions
# ============================================================

def get_cases() -> List[CaseDict]:
    """
    Return the default ZnSe/ZnS NIR and LWIR LIDT cases.

    Returns
    -------
    list of dict
        Four material/laser case dictionaries.
    """

    return [
        {
            "name": r"ZnSe, 0.8 $\mu$m",
            "short": "ZnSe_NIR",
            "material": "ZnSe",
            "region": "NIR",
            "mat_flag": 1,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "F0_jcm2": 0.112,
        },
        {
            "name": r"ZnS, 0.8 $\mu$m",
            "short": "ZnS_NIR",
            "material": "ZnS",
            "region": "NIR",
            "mat_flag": 2,
            "wavelength_um": 0.8,
            "tau_fs": 100.0,
            "F0_jcm2": 0.170,
        },
        {
            "name": r"ZnSe, 9.2 $\mu$m",
            "short": "ZnSe_LWIR",
            "material": "ZnSe",
            "region": "LWIR",
            "mat_flag": 1,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "F0_jcm2": 0.83,
        },
        {
            "name": r"ZnS, 9.2 $\mu$m",
            "short": "ZnS_LWIR",
            "material": "ZnS",
            "region": "LWIR",
            "mat_flag": 2,
            "wavelength_um": 9.2,
            "tau_fs": 2000.0,
            "F0_jcm2": 1.19,
        },
    ]


# ============================================================
# Laser pulse conversion
# ============================================================

def peak_intensity_from_fluence_wm2(F0_jcm2: float, tau_fs: float) -> float:
    """
    Convert peak fluence to peak intensity for a Gaussian temporal pulse.

    For a Gaussian intensity envelope with FWHM duration tau,

        I0 = (2 F0 / tau) sqrt[ln(2)/pi].

    Parameters
    ----------
    F0_jcm2:
        Peak fluence in J/cm^2.
    tau_fs:
        Intensity FWHM duration in femtoseconds.

    Returns
    -------
    float
        Peak intensity in W/m^2.
    """

    F0_jm2 = float(F0_jcm2) * 1.0e4
    tau_s = float(tau_fs) * 1.0e-15

    if F0_jm2 < 0.0:
        raise ValueError("Fluence must be nonnegative.")
    if tau_s <= 0.0:
        raise ValueError("Pulse duration must be positive.")

    return float((2.0 * F0_jm2 / tau_s) * np.sqrt(np.log(2.0) / np.pi))


def gaussian_intensity_time(t_s: float, I0_wm2: float, tau_s: float) -> float:
    """
    Evaluate a Gaussian temporal intensity profile.

    The profile is

        I(t) = I0 exp[-4 ln(2) (t/tau)^2],

    where tau is the intensity FWHM duration.

    Parameters
    ----------
    t_s:
        Time in seconds.
    I0_wm2:
        Peak intensity in W/m^2.
    tau_s:
        Intensity FWHM duration in seconds.

    Returns
    -------
    float
        Instantaneous intensity in W/m^2.
    """

    if tau_s <= 0.0:
        raise ValueError("tau_s must be positive.")

    return float(I0_wm2 * np.exp(-4.0 * np.log(2.0) * (t_s / tau_s) ** 2))


# ============================================================
# Keldysh photoionization model
# ============================================================

def qfun_keldysh(
    gamma: np.ndarray,
    x: np.ndarray,
    Kg: np.ndarray,
    Eg: np.ndarray,
    K1: np.ndarray,
    E1: np.ndarray,
    tol: float = 1.0e-3,
    max_terms: int = 10000,
) -> np.ndarray:
    """
    Evaluate the Keldysh Q-function series.

    Parameters
    ----------
    gamma:
        Keldysh parameter array.
    x:
        Effective photon-order argument.
    Kg, Eg, K1, E1:
        Complete elliptic-integral terms appearing in the Keldysh expression.
    tol:
        Absolute change in the partial sum used as the convergence criterion.
    max_terms:
        Maximum number of series terms.

    Returns
    -------
    np.ndarray
        Keldysh Q-function values.
    """

    gamma = np.atleast_1d(np.asarray(gamma, dtype=float))
    x = np.atleast_1d(np.asarray(x, dtype=float))
    Kg = np.atleast_1d(np.asarray(Kg, dtype=float))
    Eg = np.atleast_1d(np.asarray(Eg, dtype=float))
    K1 = np.atleast_1d(np.asarray(K1, dtype=float))
    E1 = np.atleast_1d(np.asarray(E1, dtype=float))

    arrays = [gamma, x, Kg, Eg, K1, E1]
    if len({arr.size for arr in arrays}) != 1:
        raise ValueError("All qfun_keldysh input arrays must have the same size.")

    q_values = np.zeros_like(gamma)

    for i in range(gamma.size):
        values = [gamma[i], x[i], Kg[i], Eg[i], K1[i], E1[i]]
        if not all(np.isfinite(v) for v in values) or K1[i] <= 0.0 or E1[i] <= 0.0:
            continue

        q_prefactor = np.sqrt(np.pi / (2.0 * K1[i]))
        q_sum = 0.0

        for j in range(max_terms):
            old_sum = q_sum
            exponent = -np.pi * (Kg[i] - Eg[i]) * j / E1[i]
            arg_inside = (
                np.pi**2
                * (2.0 * np.floor(x[i] + 1.0) - 2.0 * x[i] + j)
                / (2.0 * K1[i] * E1[i])
            )
            arg_inside = max(float(arg_inside), 0.0)

            with np.errstate(over="ignore", invalid="ignore", under="ignore"):
                term = np.exp(exponent) * dawsn(np.sqrt(arg_inside))

            if not np.isfinite(term):
                term = 0.0

            q_sum += float(term)

            if abs(q_sum - old_sum) <= tol:
                break

        q_values[i] = q_prefactor * q_sum

    return np.nan_to_num(q_values, nan=0.0, posinf=0.0, neginf=0.0)


def keldysh_full_rate_m3_s(
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
    intensity_wm2: ArrayLike,
) -> ArrayLike:
    """
    Evaluate the full Keldysh photoionization rate.

    Parameters
    ----------
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.
    intensity_wm2:
        Scalar or array of laser intensities in W/m^2.

    Returns
    -------
    float or np.ndarray
        Photoionization rate in m^-3 s^-1.
    """

    intensity = np.asarray(intensity_wm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    rate = np.zeros_like(intensity)
    positive = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(positive):
        I = intensity[positive]

        with np.errstate(divide="ignore", invalid="ignore", over="ignore", under="ignore"):
            electric_field = np.sqrt((2.0 * I) / (C0 * n0 * EPS0))
            gamma = (omega / (E_CHARGE * electric_field)) * np.sqrt(mred * delta_J)
            gamma_sq = gamma**2

            gg = gamma_sq / (1.0 + gamma_sq)
            g1 = 1.0 / (1.0 + gamma_sq)

            Kg = ellipk(gg)
            Eg = ellipe(gg)
            K1 = ellipk(g1)
            E1 = ellipe(g1)

            delta_tilde = (
                2.0
                * delta_J
                * np.sqrt(1.0 + gamma_sq)
                * E1
                / (np.pi * gamma)
            )
            x_order = delta_tilde / (HBAR * omega)
            X = np.floor(x_order + 1.0)

            prefactor = (
                2.0
                * omega
                / (9.0 * np.pi)
                * (
                    (np.sqrt(1.0 + gamma_sq) * mred * omega)
                    / (gamma * HBAR)
                )
                ** 1.5
            )

            q_values = qfun_keldysh(gamma, x_order, Kg, Eg, K1, E1)
            exponential = np.exp(-np.pi * X * (Kg - Eg) / E1)
            rate_positive = prefactor * q_values * exponential

        rate[positive] = np.nan_to_num(
            rate_positive,
            nan=0.0,
            posinf=0.0,
            neginf=0.0,
        )

    if scalar_input:
        return float(rate[0])
    return rate


# ============================================================
# Avalanche / impact-ionization model
# ============================================================

def collision_time_s(ne_m3: float, mred: float, delta_J: float) -> float:
    """
    Evaluate the electron collision time used in the Drude model.

    Parameters
    ----------
    ne_m3:
        Conduction-band electron density in m^-3.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.

    Returns
    -------
    float
        Collision time in seconds. Returns infinity at zero density.
    """

    ne = max(float(ne_m3), 0.0)
    if ne <= 0.0:
        return np.inf

    numerator = 16.0 * np.pi * EPS0**2 * np.sqrt(mred * (0.1 * delta_J) ** 3)
    denominator = np.sqrt(2.0) * E_CHARGE**4 * ne
    tau_c = numerator / denominator

    if not np.isfinite(tau_c) or tau_c <= 0.0:
        return np.inf

    return float(tau_c)


def drude_cross_section_m2(
    omega: float,
    mred: float,
    n0: float,
    tau_c_s: float,
) -> float:
    """
    Evaluate the Drude single-photon absorption cross section safely.

    The direct expression is

        sigma = e^2/(c eps0 n0 m_r) * tau_C/(1 + omega^2 tau_C^2).

    To avoid overflow for very large collision times, it is evaluated as

        sigma = [e^2/(c eps0 n0 m_r)] / omega
                * [(omega tau_C)/(1 + (omega tau_C)^2)].

    Parameters
    ----------
    omega:
        Angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    n0:
        Linear refractive index.
    tau_c_s:
        Collision time in seconds.

    Returns
    -------
    float
        Drude absorption cross section in m^2.
    """

    tau_c = float(tau_c_s)

    if (
        not np.isfinite(tau_c)
        or tau_c <= 0.0
        or not np.isfinite(omega)
        or omega <= 0.0
        or mred <= 0.0
        or n0 <= 0.0
    ):
        return 0.0

    prefactor = E_CHARGE**2 / (C0 * EPS0 * n0 * mred)
    x = omega * tau_c

    if not np.isfinite(x) or x <= 0.0:
        return 0.0

    if x > 1.0e100:
        drude_factor = 1.0 / x
    else:
        drude_factor = x / (1.0 + x * x)

    sigma = (prefactor / omega) * drude_factor

    if not np.isfinite(sigma) or sigma < 0.0:
        return 0.0

    return float(sigma)


def avalanche_generation_rate_m3_s(
    intensity_wm2: float,
    ne_m3: float,
    omega: float,
    mred: float,
    delta_J: float,
    n0: float,
) -> float:
    """
    Evaluate the avalanche/impact-ionization carrier-generation rate.

    The implemented relation is

        W_av = (sigma I / E_g) n_e.

    Parameters
    ----------
    intensity_wm2:
        Instantaneous laser intensity in W/m^2.
    ne_m3:
        Instantaneous electron density in m^-3.
    omega:
        Laser angular frequency in rad/s.
    mred:
        Reduced electron-hole effective mass in kg.
    delta_J:
        Bandgap energy in J.
    n0:
        Linear refractive index.

    Returns
    -------
    float
        Avalanche generation rate in m^-3 s^-1.
    """

    I = max(float(intensity_wm2), 0.0)
    ne = max(float(ne_m3), 0.0)

    if I <= 0.0 or ne <= 0.0 or delta_J <= 0.0:
        return 0.0

    tau_c = collision_time_s(ne, mred, delta_J)
    sigma = drude_cross_section_m2(
        omega=omega,
        mred=mred,
        n0=n0,
        tau_c_s=tau_c,
    )

    if sigma <= 0.0:
        return 0.0

    W_av = (sigma * I / delta_J) * ne

    if not np.isfinite(W_av) or W_av < 0.0:
        return 0.0

    return float(W_av)


# ============================================================
# General helpers
# ============================================================

def positive_for_log(y: np.ndarray, min_value: float = 1.0e-300) -> np.ndarray:
    """
    Replace nonfinite and nonpositive values with NaN for logarithmic plotting.
    """

    y_plot = np.asarray(y, dtype=float).copy()
    y_plot[~np.isfinite(y_plot)] = np.nan
    y_plot[y_plot <= min_value] = np.nan
    return y_plot


def case_lidt_peak_intensity_wcm2(case: CaseDict) -> float:
    """
    Return the Gaussian peak intensity at the measured LIDT in W/cm^2.
    """

    return (
        peak_intensity_from_fluence_wm2(
            F0_jcm2=case["F0_jcm2"],
            tau_fs=case["tau_fs"],
        )
        * WCM2_PER_WM2
    )


def interpolate_log_y(
    x: np.ndarray,
    y: np.ndarray,
    x0: float,
) -> Optional[float]:
    """
    Interpolate y(x0) in log-log space.

    Returns None when x0 lies outside the valid positive data range.
    """

    x_arr = np.asarray(x, dtype=float)
    y_arr = np.asarray(y, dtype=float)
    valid = np.isfinite(x_arr) & np.isfinite(y_arr) & (x_arr > 0.0) & (y_arr > 0.0)

    if np.count_nonzero(valid) < 2:
        return None

    x_valid = x_arr[valid]
    y_valid = y_arr[valid]
    order = np.argsort(x_valid)
    x_valid = x_valid[order]
    y_valid = y_valid[order]

    if x0 < x_valid[0] or x0 > x_valid[-1]:
        return None

    log_y0 = np.interp(
        np.log10(x0),
        np.log10(x_valid),
        np.log10(y_valid),
    )
    return float(10.0**log_y0)


def save_or_show(
    fig: plt.Figure,
    save_dir: Optional[Path],
    filename: str,
    apply_tight_layout: bool = True,
) -> None:
    """
    Apply tight layout and either save or display a Matplotlib figure.
    """

    # CODEX MODIFICATION START: allow manually arranged 3D figures
    if apply_tight_layout:
        fig.tight_layout()
    # CODEX MODIFICATION END: allow manually arranged 3D figures

    if save_dir is not None:
        save_dir.mkdir(parents=True, exist_ok=True)
        output_path = save_dir / filename
        fig.savefig(output_path, dpi=300, bbox_inches="tight")
        print(f"Saved {output_path}")
        # CODEX MODIFICATION START: optional open saved image preview
        if OPEN_SAVED_FIGURES and hasattr(os, "startfile"):
            os.startfile(output_path)
        # CODEX MODIFICATION END: optional open saved image preview
        # Temporarily disabled: editable Matplotlib .mplfig.pkl export.
        # Uncomment this block to restore Python-figure saving.
        # if SAVE_EDITABLE_FIGURES:
        #     editable_path = output_path.with_suffix(".mplfig.pkl")
        #     with editable_path.open("wb") as editable_file:
        #         pickle.dump(fig, editable_file)
        #     print(f"Saved editable Matplotlib figure {editable_path}")
        # CODEX MODIFICATION START: allow saved figures to display at end
        if DEFER_FIGURE_SHOW:
            print(f"Prepared saved figure for display: {filename}")
        else:
            plt.close(fig)
        # CODEX MODIFICATION END: allow saved figures to display at end
    else:
        # CODEX MODIFICATION START: optional deferred Matplotlib display
        if DEFER_FIGURE_SHOW:
            print(f"Prepared figure for display: {filename}")
        else:
            plt.show()
        # CODEX MODIFICATION END: optional deferred Matplotlib display


# ============================================================
# Time-dependent dynamics
# ============================================================

def solve_dynamics_from_peak_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 1000,
) -> Dict[str, Any]:
    """
    Solve total carrier-density dynamics at a specified peak intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I0_wcm2:
        Peak laser intensity in W/cm^2.
    n_time_points:
        Number of points used for post-processing the dense ODE solution.

    Returns
    -------
    dict
        Time-dependent photoionization, avalanche, total rates, and density.
    """

    if I0_wcm2 < 0.0:
        raise ValueError("I0_wcm2 must be nonnegative.")
    if n_time_points < 2:
        raise ValueError("n_time_points must be at least 2.")

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = float(I0_wcm2) * WM2_PER_WCM2

    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )

        derivative = W_pi + W_av
        if not np.isfinite(derivative) or derivative < 0.0:
            derivative = 0.0

        return [float(derivative)]

    solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-5,
        atol=1.0e6,
        max_step=tau_s / 350.0,
        dense_output=True,
    )

    t_eval = np.linspace(t0, t1, n_time_points)

    if solution.sol is not None:
        ne = np.maximum(solution.sol(t_eval)[0], 0.0)
    else:
        ne = np.maximum(np.interp(t_eval, solution.t, solution.y[0]), 0.0)

    intensity = np.asarray([intensity_at_time(t) for t in t_eval], dtype=float)
    Wpi = np.asarray([photo_rate_at_time(t) for t in t_eval], dtype=float)
    Wav = np.asarray(
        [
            avalanche_generation_rate_m3_s(
                intensity_wm2=I_now,
                ne_m3=ne_now,
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )
            for I_now, ne_now in zip(intensity, ne)
        ],
        dtype=float,
    )
    Wtotal = Wpi + Wav

    return {
        "case": case,
        "t_s": t_eval,
        "intensity_wm2": intensity,
        "Wpi_m3_s": Wpi,
        "Wav_m3_s": Wav,
        "Wtotal_m3_s": Wtotal,
        "Wpi_cm3_fs": Wpi * RATE_CM3_FS_PER_M3_S,
        "Wav_cm3_fs": Wav * RATE_CM3_FS_PER_M3_S,
        "Wtotal_cm3_fs": Wtotal * RATE_CM3_FS_PER_M3_S,
        "ne_m3": ne,
        "ne_cm3": ne * CM3_PER_M3,
        "solver_success": bool(solution.success),
        "solver_message": str(solution.message),
    }


SCALING_CACHE: Dict[Tuple[str, int, float, float, int], Dict[str, np.ndarray]] = {}


def compute_case_scaling(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 600,
) -> Dict[str, np.ndarray]:
    """
    Compute the peak total ionization rate versus peak laser intensity.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        One-dimensional array of peak intensities in W/cm^2.
    n_time_points:
        Number of post-processing time points per ODE solution.

    Returns
    -------
    dict
        Intensity array and peak total ionization-rate array.
    """

    intensity_values = np.asarray(I_values_wcm2, dtype=float)

    if intensity_values.ndim != 1 or intensity_values.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensity_values)) or np.any(intensity_values <= 0.0):
        raise ValueError("All intensity values must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensity_values.size),
        float(intensity_values[0]),
        float(intensity_values[-1]),
        int(n_time_points),
    )

    if cache_key in SCALING_CACHE:
        return SCALING_CACHE[cache_key]

    Wtotal_peak = np.zeros_like(intensity_values)
    print(f"\nComputing intensity scaling for {case['short']} ...")

    report_interval = max(1, intensity_values.size // 10)

    for index, I0_wcm2 in enumerate(intensity_values):
        if index % report_interval == 0 or index == intensity_values.size - 1:
            print(
                f"  {index + 1:3d}/{intensity_values.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2 reported: {result['solver_message']}"
            )

        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(
                result["Wtotal_cm3_fs"],
                nan=0.0,
                posinf=0.0,
                neginf=0.0,
            )
        )

    output = {
        "I_wcm2": intensity_values,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
    }
    SCALING_CACHE[cache_key] = output
    return output


def direct_peak_total_rate_at_intensity(
    case: CaseDict,
    I0_wcm2: float,
    n_time_points: int = 600,
) -> float:
    """Solve at one specified intensity instead of interpolating a scan."""

    scaling = compute_case_scaling(
        case=case,
        I_values_wcm2=np.asarray([float(I0_wcm2)]),
        n_time_points=n_time_points,
    )
    return float(scaling["Wtotal_peak_cm3_fs"][0])


def solve_density_case(case: CaseDict) -> Dict[str, Any]:
    """
    Solve photoionization-only and photoionization-plus-avalanche density growth.

    Parameters
    ----------
    case:
        Material/laser case dictionary.

    Returns
    -------
    dict
        Material parameters, peak intensity, final densities, and solver status.
    """

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    tau_s = float(case["tau_fs"]) * 1.0e-15
    I0_wm2 = peak_intensity_from_fluence_wm2(
        F0_jcm2=float(case["F0_jcm2"]),
        tau_fs=float(case["tau_fs"]),
    )

    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    t0 = -3.0 * tau_s
    t1 = +3.0 * tau_s

    def intensity_at_time(t: float) -> float:
        return gaussian_intensity_time(t, I0_wm2, tau_s)

    def photo_rate_at_time(t: float) -> float:
        return float(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=intensity_at_time(t),
            )
        )

    def rhs_photo(t: float, _y: np.ndarray) -> List[float]:
        return [photo_rate_at_time(t)]

    def rhs_total(t: float, y: np.ndarray) -> List[float]:
        ne = max(float(y[0]), 0.0)
        I_now = intensity_at_time(t)
        W_pi = photo_rate_at_time(t)
        W_av = avalanche_generation_rate_m3_s(
            intensity_wm2=I_now,
            ne_m3=ne,
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
        )
        derivative = W_pi + W_av
        return [float(max(derivative, 0.0)) if np.isfinite(derivative) else 0.0]

    photo_solution = solve_ivp(
        rhs_photo,
        (t0, t1),
        y0=[0.0],
        method="RK45",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 200.0,
    )

    total_solution = solve_ivp(
        rhs_total,
        (t0, t1),
        y0=[0.0],
        method="BDF",
        rtol=1.0e-6,
        atol=1.0e6,
        max_step=tau_s / 500.0,
    )

    ne_photo_final_m3 = float(max(photo_solution.y[0, -1], 0.0))
    ne_total_final_m3 = float(max(total_solution.y[0, -1], 0.0))

    return {
        "case": case,
        "n0": n0,
        "n2": n2,
        "trans": trans,
        "Eg_eV": Eg_J / E_CHARGE,
        "mred_over_me": mred / ME0,
        "I0_wm2": I0_wm2,
        "I0_wcm2": I0_wm2 * WCM2_PER_WM2,
        "ne_photo_m3": ne_photo_final_m3,
        "ne_total_m3": ne_total_final_m3,
        "ne_photo_cm3": ne_photo_final_m3 * CM3_PER_M3,
        "ne_total_cm3": ne_total_final_m3 * CM3_PER_M3,
        "ne_avalanche_added_cm3": (
            max(ne_total_final_m3 - ne_photo_final_m3, 0.0) * CM3_PER_M3
        ),
        "sol_photo_success": bool(photo_solution.success),
        "sol_photo_message": str(photo_solution.message),
        "sol_total_success": bool(total_solution.success),
        "sol_total_message": str(total_solution.message),
    }


# ============================================================
# Summary table
# ============================================================

def build_summary_table(results: Sequence[Dict[str, Any]]) -> List[Dict[str, Any]]:
    """
    Convert density-solver results into rows for display.
    """

    rows: List[Dict[str, Any]] = []

    for result in results:
        case = result["case"]
        rows.append(
            {
                "Case": case["short"],
                "Material": case["material"],
                "Regime": case["region"],
                "lambda_um": case["wavelength_um"],
                "tau_fs": case["tau_fs"],
                "F0_Jcm2": case["F0_jcm2"],
                "I0_Wcm2": result["I0_wcm2"],
                "n_photo_cm3": result["ne_photo_cm3"],
                "n_avalanche_added_cm3": result["ne_avalanche_added_cm3"],
                "n_total_cm3": result["ne_total_cm3"],
                "n0": result["n0"],
                "Eg_eV": result["Eg_eV"],
                "mred_over_me": result["mred_over_me"],
                "solver": (
                    "OK"
                    if result["sol_photo_success"] and result["sol_total_success"]
                    else "CHECK"
                ),
            }
        )

    return rows


def display_summary_table(rows: Sequence[Dict[str, Any]]) -> None:
    """
    Display the density-growth summary table in Jupyter or plain text.
    """

    print("\n================ Density-growth summary table ================\n")

    if pd is None:
        for row in rows:
            print(row)
        return

    dataframe = pd.DataFrame(rows)
    display_frame = dataframe.copy()

    scientific_columns = [
        "I0_Wcm2",
        "n_photo_cm3",
        "n_avalanche_added_cm3",
        "n_total_cm3",
    ]
    compact_columns = [
        "lambda_um",
        "tau_fs",
        "F0_Jcm2",
        "n0",
        "Eg_eV",
        "mred_over_me",
    ]

    for column in scientific_columns:
        display_frame[column] = display_frame[column].map(lambda value: f"{value:.4e}")

    for column in compact_columns:
        display_frame[column] = display_frame[column].map(lambda value: f"{value:.4g}")

    if ipython_display is not None:
        ipython_display(display_frame)
    else:
        print(display_frame.to_string(index=False))


# ============================================================
# First graph set: Keldysh photoionization curves
# ============================================================

def plot_keldysh_rate_curves(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot Keldysh photoionization-rate curves for all default cases.

    The measured LIDT peak intensity is marked by a black cross.
    """

    I_values_wm2 = np.logspace(14, 19, 900)
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    axes_flat = axes.ravel()

    for ax, case in zip(axes_flat, cases):
        wavelength_um = float(case["wavelength_um"])
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        n0, _n2, Eg_J, mred, _trans = material_flag1(
            mat_flag=int(case["mat_flag"]),
            wavelength_um=wavelength_um,
        )

        Wpi = np.asarray(
            keldysh_full_rate_m3_s(
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
                intensity_wm2=I_values_wm2,
            ),
            dtype=float,
        )

        keep = np.isfinite(Wpi) & (Wpi > 0.0)

        ax.loglog(
            I_values_wm2[keep],
            Wpi[keep],
            linewidth=2.4,
            label=r"$W_{\rm PI}$",
        )

        I_lidt_wm2 = case_lidt_peak_intensity_wcm2(case) * WM2_PER_WCM2

        if np.any(keep):
            W_lidt = interpolate_log_y(
                x=I_values_wm2[keep],
                y=Wpi[keep],
                x0=I_lidt_wm2,
            )
            if W_lidt is not None:
                ax.plot(
                    I_lidt_wm2,
                    W_lidt,
                    "kx",
                    markersize=9,
                    markeredgewidth=2,
                    label=r"$I_0$ at LIDT",
                )

        ax.set_title(case["name"])
        ax.set_xlabel(r"Laser intensity $I$ (W/m$^2$)")
        ax.set_ylabel(r"$W_{\rm PI}$ (m$^{-3}$ s$^{-1}$)")
        ax.grid(True, which="both", alpha=0.25)
        ax.legend(frameon=False)

    for ax in axes_flat[len(cases):]:
        ax.set_visible(False)

    fig.suptitle("Keldysh photoionization-rate curves", fontsize=15)
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="01_first_graph_set_keldysh_rate_curves.png",
    )


# ============================================================
# ZnS-reference Keldysh parameter axis
# ============================================================

def gamma_zns_reference_from_intensity_wcm2(
    I_wcm2: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Evaluate the Keldysh parameter using ZnS as the reference material.

    Parameters
    ----------
    I_wcm2:
        Scalar or array of intensities in W/cm^2.
    wavelength_um:
        Wavelength in micrometers.
    include_field_factor_two:
        If True, include the factor of two associated with
        I = (1/2) c n eps0 E^2 in the denominator.

    Returns
    -------
    float or np.ndarray
        Keldysh parameter values.
    """

    intensity = np.asarray(I_wcm2, dtype=float)
    scalar_input = intensity.ndim == 0
    intensity = np.atleast_1d(intensity)

    gamma = np.full_like(intensity, np.inf)
    valid = np.isfinite(intensity) & (intensity > 0.0)

    if np.any(valid):
        I_wm2 = intensity[valid] * WM2_PER_WCM2
        n_zns, _n2, Eg_zns_J, mred_zns, _trans = material_flag1(2, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            gamma_valid = (omega / E_CHARGE) * np.sqrt(
                (mred_zns * C0 * n_zns * EPS0 * Eg_zns_J)
                / (field_factor * I_wm2)
            )

        gamma[valid] = np.nan_to_num(
            gamma_valid,
            nan=np.inf,
            posinf=np.inf,
            neginf=np.inf,
        )

    if scalar_input:
        return float(gamma[0])
    return gamma


def intensity_wcm2_from_gamma_zns_reference(
    gamma: ArrayLike,
    wavelength_um: float,
    include_field_factor_two: bool = True,
) -> ArrayLike:
    """
    Convert a ZnS-reference Keldysh parameter to intensity in W/cm^2.
    """

    gamma_values = np.asarray(gamma, dtype=float)
    scalar_input = gamma_values.ndim == 0
    gamma_values = np.atleast_1d(gamma_values)

    intensity = np.full_like(gamma_values, np.inf)
    valid = np.isfinite(gamma_values) & (gamma_values > 0.0)

    if np.any(valid):
        n_zns, _n2, Eg_zns_J, mred_zns, _trans = material_flag1(2, wavelength_um)
        omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
        field_factor = 2.0 if include_field_factor_two else 1.0

        with np.errstate(divide="ignore", invalid="ignore", over="ignore"):
            I_wm2 = (
                (omega / E_CHARGE) ** 2
                * (mred_zns * C0 * n_zns * EPS0 * Eg_zns_J)
                / (field_factor * gamma_values[valid] ** 2)
            )

        intensity[valid] = I_wm2 * WCM2_PER_WM2

    if scalar_input:
        return float(intensity[0])
    return intensity


def add_zns_gamma_top_axis(
    ax: plt.Axes,
    wavelength_um: float,
    gamma_ticks: Tuple[float, ...],
    include_field_factor_two: bool = True,
) -> None:
    """
    Add a ZnS-reference Keldysh-parameter axis above an intensity axis.
    """

    ax_top = ax.twiny()
    ax_top.set_xscale("log")
    ax_top.set_xlim(ax.get_xlim())

    tick_positions = np.asarray(
        intensity_wcm2_from_gamma_zns_reference(
            gamma=np.asarray(gamma_ticks, dtype=float),
            wavelength_um=wavelength_um,
            include_field_factor_two=include_field_factor_two,
        ),
        dtype=float,
    )

    x_min, x_max = ax.get_xlim()
    valid_ticks: List[float] = []
    valid_labels: List[str] = []

    for gamma_value, tick_position in zip(gamma_ticks, tick_positions):
        if np.isfinite(tick_position) and x_min <= tick_position <= x_max:
            valid_ticks.append(float(tick_position))
            valid_labels.append(f"{gamma_value:g}")

    ax_top.set_xticks(valid_ticks)
    ax_top.set_xticklabels(valid_labels)
    ax_top.set_xlabel(r"Keldysh parameter $\gamma$ (ZnS reference)")
    ax_top.tick_params(axis="x", which="both", direction="in")


# ============================================================
# Last graph set: total ionization comparison
# ============================================================

def plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 50,
    I_min_wcm2: float = 5.0e10,
    I_max_wcm2: float = 1.0e15,
    y_min: float = 1.0e0,
    y_max: float = 1.0e30,
    include_field_factor_two: bool = True,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot peak total ionization rate for ZnSe and ZnS in NIR and LWIR.

    Each panel includes a ZnS-reference Keldysh-parameter top axis and a
    dashed vertical line at gamma = 1.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Intensity limits must satisfy 0 < I_min < I_max.")

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )

    regime_order = ["NIR", "LWIR"]
    panel_labels = {"NIR": "(a) NIR", "LWIR": "(b) LWIR"}
    gamma_ticks_by_regime = {
        "NIR": (10.0, 3.0, 1.0, 0.3),
        "LWIR": (1.0, 0.3, 0.1),
    }
    material_order = {"ZnSe": 0, "ZnS": 1}

    fig, axes = plt.subplots(1, 2, figsize=(13.5, 5.2), sharey=True)

    print("\nCalculating NIR/LWIR total-ionization comparison ...\n")

    for ax, regime in zip(axes, regime_order):
        regime_cases = sorted(
            [case for case in cases if case["region"] == regime],
            key=lambda case: material_order.get(case["material"], 99),
        )

        if not regime_cases:
            raise ValueError(f"No cases were supplied for regime {regime!r}.")

        wavelength_um = float(regime_cases[0]["wavelength_um"])

        for case in regime_cases:
            print(f"  {regime}: {case['short']}")
            scaling = compute_case_scaling(
                case=case,
                I_values_wcm2=I_values_wcm2,
                n_time_points=600,
            )

            I = scaling["I_wcm2"]
            Wtotal = scaling["Wtotal_peak_cm3_fs"]

            ax.loglog(
                I,
                positive_for_log(Wtotal),
                linewidth=2.6,
                label=case["material"],
            )

            I_lidt = case_lidt_peak_intensity_wcm2(case)
            W_lidt = direct_peak_total_rate_at_intensity(case, I_lidt)
            ax.plot(
                I_lidt,
                W_lidt,
                "kx",
                markersize=8.5,
                markeredgewidth=2.0,
            )

        I_gamma_1 = float(
            intensity_wcm2_from_gamma_zns_reference(
                gamma=1.0,
                wavelength_um=wavelength_um,
                include_field_factor_two=include_field_factor_two,
            )
        )

        if I_min_wcm2 <= I_gamma_1 <= I_max_wcm2:
            ax.axvline(
                I_gamma_1,
                color="k",
                linestyle="--",
                linewidth=1.7,
            )
            ax.text(
                I_gamma_1 * 1.12,
                y_max / 8.0,
                r"$\gamma=1$",
                fontsize=11,
                verticalalignment="center",
            )

        ax.text(
            0.03,
            0.90,
            panel_labels[regime],
            transform=ax.transAxes,
            fontsize=14,
            fontweight="bold",
        )
        ax.set_xlabel(r"Laser intensity $I$ (W/cm$^2$)")
        ax.set_xlim(I_min_wcm2, I_max_wcm2)
        ax.set_ylim(y_min, y_max)
        ax.grid(True, which="major", alpha=0.28)
        ax.grid(True, which="minor", alpha=0.14, linestyle=":")
        ax.legend(frameon=False, fontsize=14, loc="lower right")

        add_zns_gamma_top_axis(
            ax=ax,
            wavelength_um=wavelength_um,
            gamma_ticks=gamma_ticks_by_regime[regime],
            include_field_factor_two=include_field_factor_two,
        )

    axes[0].set_ylabel(
        r"Peak total ionization rate $W_{\rm total}$ (cm$^{-3}$ fs$^{-1}$)"
    )

    fig.suptitle(
        r"Total ionization including avalanche: "
        r"$W_{\rm total}=W_{\rm PI}+(\sigma I/E_g)n_e$",
        fontsize=14,
    )

    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="02_last_graph_set_total_ionization_gamma_axis.png",
    )



# ============================================================
# ZnSe/ZnS plots 
# ============================================================

COMPONENT_SCALING_CACHE: Dict[
    Tuple[str, int, float, float, int], Dict[str, np.ndarray]
] = {}

SURFACE_DATA_CACHE: Dict[
    Tuple[str, int, int, float, float, float, float], Dict[str, np.ndarray]
] = {}


def normalize_curve(values: np.ndarray) -> np.ndarray:
    """Normalize a nonnegative curve to its maximum value."""

    array = np.asarray(values, dtype=float)
    array = np.nan_to_num(array, nan=0.0, posinf=0.0, neginf=0.0)
    maximum = float(np.max(array)) if array.size else 0.0
    if maximum <= 0.0:
        return np.zeros_like(array)
    return array / maximum


def compute_case_scaling_components(
    case: CaseDict,
    I_values_wcm2: np.ndarray,
    n_time_points: int = 700,
) -> Dict[str, np.ndarray]:
    """
    Compute peak photoionization, avalanche, total rates, and density.

    Parameters
    ----------
    case:
        Material/laser case dictionary.
    I_values_wcm2:
        Peak intensities in W/cm^2.
    n_time_points:
        Number of time samples used to post-process each ODE solution.

    Returns
    -------
    dict
        Arrays of peak W_PI, W_av, W_total, and maximum electron density.
    """

    intensities = np.asarray(I_values_wcm2, dtype=float)
    if intensities.ndim != 1 or intensities.size == 0:
        raise ValueError("I_values_wcm2 must be a nonempty one-dimensional array.")
    if np.any(~np.isfinite(intensities)) or np.any(intensities <= 0.0):
        raise ValueError("All intensities must be finite and positive.")

    cache_key = (
        str(case["short"]),
        int(intensities.size),
        float(intensities[0]),
        float(intensities[-1]),
        int(n_time_points),
    )
    if cache_key in COMPONENT_SCALING_CACHE:
        return COMPONENT_SCALING_CACHE[cache_key]

    Wpi_peak = np.zeros_like(intensities)
    Wav_peak = np.zeros_like(intensities)
    Wtotal_peak = np.zeros_like(intensities)
    ne_max = np.zeros_like(intensities)

    print(f"\nComputing rate-component scaling for {case['short']} ...")
    report_interval = max(1, intensities.size // 10)

    for index, I0_wcm2 in enumerate(intensities):
        if index % report_interval == 0 or index == intensities.size - 1:
            print(
                f"  {index + 1:3d}/{intensities.size}: "
                f"I0 = {I0_wcm2:.3e} W/cm^2"
            )

        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=float(I0_wcm2),
            n_time_points=n_time_points,
        )

        if not result["solver_success"]:
            print(
                f"  WARNING: solver for {case['short']} at "
                f"{I0_wcm2:.3e} W/cm^2: {result['solver_message']}"
            )

        Wpi_peak[index] = np.nanmax(
            np.nan_to_num(result["Wpi_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wav_peak[index] = np.nanmax(
            np.nan_to_num(result["Wav_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        Wtotal_peak[index] = np.nanmax(
            np.nan_to_num(result["Wtotal_cm3_fs"], nan=0.0, posinf=0.0, neginf=0.0)
        )
        ne_max[index] = np.nanmax(
            np.nan_to_num(result["ne_cm3"], nan=0.0, posinf=0.0, neginf=0.0)
        )

    output = {
        "I_wcm2": intensities,
        "Wpi_peak_cm3_fs": Wpi_peak,
        "Wav_peak_cm3_fs": Wav_peak,
        "Wtotal_peak_cm3_fs": Wtotal_peak,
        "ne_max_cm3": ne_max,
    }
    COMPONENT_SCALING_CACHE[cache_key] = output
    return output


def _case_with_derived_labels(case: CaseDict) -> Dict[str, Any]:
    """Return case labels plus derived material/LIDT values for saved data."""

    wavelength_um = float(case["wavelength_um"])
    n0, n2, Eg_J, mred, trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )
    I_lidt_wcm2 = case_lidt_peak_intensity_wcm2(case)
    return {
        "short": str(case["short"]),
        "name": str(case["name"]),
        "material": str(case["material"]),
        "region": str(case["region"]),
        "mat_flag": int(case["mat_flag"]),
        "wavelength_um": wavelength_um,
        "tau_fs": float(case["tau_fs"]),
        "F0_jcm2": float(case["F0_jcm2"]),
        "I_lidt_wcm2": float(I_lidt_wcm2),
        "gamma_lidt_zns_reference": float(
            gamma_zns_reference_from_intensity_wcm2(I_lidt_wcm2, wavelength_um)
        ),
        "n0": float(n0),
        "n2_m2_W": float(n2),
        "Eg_eV": float(Eg_J / E_CHARGE),
        "mred_over_me": float(mred / ME0),
        "transmission_factor": float(trans),
    }


def compute_total_ionization_surface_data(
    case: CaseDict,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> Dict[str, np.ndarray]:
    """
    Compute 3D total-ionization surface arrays without plotting.

    This stores the same numerical quantities used by the 3D surface plot:
    I0 grid, electron-density grid, W_PI, W_av, W_total, and log10 axes.
    """

    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    cache_key = (
        str(case["short"]),
        int(n_intensity_points),
        int(n_density_points),
        float(I_min_wcm2),
        float(I_max_wcm2),
        float(ne_min_cm3),
        float(ne_max_cm3),
    )
    if cache_key in SURFACE_DATA_CACHE:
        return SURFACE_DATA_CACHE[cache_key]

    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        mat_flag=int(case["mat_flag"]),
        wavelength_um=wavelength_um,
    )

    I_values_wcm2 = np.logspace(
        np.log10(I_min_wcm2),
        np.log10(I_max_wcm2),
        n_intensity_points,
    )
    ne_values_cm3 = np.logspace(
        np.log10(ne_min_cm3),
        np.log10(ne_max_cm3),
        n_density_points,
    )
    I_grid_wcm2, ne_grid_cm3 = np.meshgrid(I_values_wcm2, ne_values_cm3)
    I_grid_wm2 = I_grid_wcm2 * WM2_PER_WCM2
    ne_grid_m3 = ne_grid_cm3 / CM3_PER_M3

    Wpi_grid_m3_s = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_grid_wm2,
        ),
        dtype=float,
    )

    Wav_grid_m3_s = np.zeros_like(I_grid_wm2)
    for row_index in range(I_grid_wm2.shape[0]):
        for column_index in range(I_grid_wm2.shape[1]):
            Wav_grid_m3_s[row_index, column_index] = avalanche_generation_rate_m3_s(
                intensity_wm2=I_grid_wm2[row_index, column_index],
                ne_m3=ne_grid_m3[row_index, column_index],
                omega=omega,
                mred=mred,
                delta_J=Eg_J,
                n0=n0,
            )

    Wtotal_grid_cm3_fs = (Wpi_grid_m3_s + Wav_grid_m3_s) * RATE_CM3_FS_PER_M3_S
    Wtotal_grid_cm3_fs = np.maximum(
        np.nan_to_num(Wtotal_grid_cm3_fs, nan=0.0, posinf=0.0, neginf=0.0),
        1.0e-300,
    )

    output = {
        "I_values_wcm2": I_values_wcm2,
        "ne_values_cm3": ne_values_cm3,
        "I_grid_wcm2": I_grid_wcm2,
        "ne_grid_cm3": ne_grid_cm3,
        "log10_I_grid_wcm2": np.log10(I_grid_wcm2),
        "log10_ne_grid_cm3": np.log10(ne_grid_cm3),
        "Wpi_grid_cm3_fs": Wpi_grid_m3_s * RATE_CM3_FS_PER_M3_S,
        "Wav_grid_cm3_fs": Wav_grid_m3_s * RATE_CM3_FS_PER_M3_S,
        "Wtotal_grid_cm3_fs": Wtotal_grid_cm3_fs,
        "log10_Wtotal_grid_cm3_fs": np.log10(Wtotal_grid_cm3_fs),
    }
    SURFACE_DATA_CACHE[cache_key] = output
    return output


def save_pi_ii_14_plot_variables(
    cases: Sequence[CaseDict],
    output_dir: Path,
    component_n_intensity_points: int = 50,
    total_n_intensity_points: int = 50,
    surface_n_intensity_points: int = 50,
    surface_n_density_points: int = 80,
) -> None:
    """
    Save labeled variables used by the 14 PI/II plot panels.

    Saved files
    -----------
    pi_ii_14_variables.npz
        Machine-readable numpy arrays with explicit names.
    pi_ii_14_manifest.json
        Human-readable variable map, units, cases, and figure-panel usage.
    pi_ii_14_component_scaling_long.csv
        Long-table version of per-case W_PI/W_av/W_total/n_e scaling.
    pi_ii_14_total_comparison_long.csv
        Long-table version of the NIR/LWIR total-rate comparison.

    The data are also sufficient to start new 3D plots because W_PI, W_av,
    W_total, I0 grid, and n_e grid are saved for each case.
    """

    output_dir.mkdir(parents=True, exist_ok=True)

    component_I_values_wcm2 = np.logspace(10, 15, component_n_intensity_points)
    total_I_values_wcm2 = np.logspace(
        np.log10(5.0e10),
        np.log10(1.0e15),
        total_n_intensity_points,
    )

    arrays: Dict[str, np.ndarray] = {
        "component_scaling__I_wcm2": component_I_values_wcm2,
        "total_comparison__I_wcm2": total_I_values_wcm2,
    }
    component_rows: List[Dict[str, Any]] = []
    total_rows: List[Dict[str, Any]] = []
    surface_rows: List[Dict[str, Any]] = []
    component_manifest: Dict[str, Any] = {}
    total_manifest: Dict[str, Any] = {}
    surface_manifest: Dict[str, Any] = {}

    print("\nSaving labeled variables for the 14 PI/II plot panels ...")

    for case in cases:
        case_label = _case_with_derived_labels(case)
        short = case_label["short"]
        wavelength_um = float(case["wavelength_um"])
        Wtotal_direct_at_lidt_cm3_fs = direct_peak_total_rate_at_intensity(
            case,
            case_lidt_peak_intensity_wcm2(case),
            n_time_points=600,
        )

        component = compute_case_scaling_components(
            case=case,
            I_values_wcm2=component_I_values_wcm2,
            n_time_points=600,
        )
        component_manifest[short] = {
            "used_by": [
                f"gruzdev_fig2_{short}.png: panels (a) and (b)",
                f"gruzdev_fig4_{case['material']}.png: material comparison panel(s)",
            ],
            "arrays": {},
        }
        for name, values in component.items():
            array_name = f"component__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            component_manifest[short]["arrays"][name] = array_name

        gamma_component = np.asarray(
            gamma_zns_reference_from_intensity_wcm2(
                component["I_wcm2"],
                wavelength_um,
            ),
            dtype=float,
        )
        arrays[f"component__{short}__gamma_zns_reference"] = gamma_component
        component_manifest[short]["arrays"][
            "gamma_zns_reference"
        ] = f"component__{short}__gamma_zns_reference"

        for index, I_value in enumerate(component["I_wcm2"]):
            row = {
                **case_label,
                "dataset": "component_scaling",
                "point_index": index,
                "I_wcm2": float(I_value),
                "gamma_zns_reference": float(gamma_component[index]),
                "Wpi_peak_cm3_fs": float(component["Wpi_peak_cm3_fs"][index]),
                "Wav_peak_cm3_fs": float(component["Wav_peak_cm3_fs"][index]),
                "Wtotal_peak_cm3_fs": float(component["Wtotal_peak_cm3_fs"][index]),
                "ne_max_cm3": float(component["ne_max_cm3"][index]),
            }
            component_rows.append(row)

        total = compute_case_scaling(
            case=case,
            I_values_wcm2=total_I_values_wcm2,
            n_time_points=600,
        )
        total_manifest[short] = {
            "used_by": [
                "02_last_graph_set_total_ionization_gamma_axis.png",
            ],
            "arrays": {},
        }
        for name, values in total.items():
            array_name = f"total_comparison__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            total_manifest[short]["arrays"][name] = array_name

        gamma_total = np.asarray(
            gamma_zns_reference_from_intensity_wcm2(
                total["I_wcm2"],
                wavelength_um,
            ),
            dtype=float,
        )
        arrays[f"total_comparison__{short}__gamma_zns_reference"] = gamma_total
        total_manifest[short]["arrays"][
            "gamma_zns_reference"
        ] = f"total_comparison__{short}__gamma_zns_reference"

        for index, I_value in enumerate(total["I_wcm2"]):
            row = {
                **case_label,
                "dataset": "total_comparison",
                "point_index": index,
                "I_wcm2": float(I_value),
                "gamma_zns_reference": float(gamma_total[index]),
                "Wtotal_peak_cm3_fs": float(total["Wtotal_peak_cm3_fs"][index]),
                "Wtotal_direct_at_lidt_cm3_fs": Wtotal_direct_at_lidt_cm3_fs,
            }
            total_rows.append(row)

        surface = compute_total_ionization_surface_data(
            case=case,
            n_intensity_points=surface_n_intensity_points,
            n_density_points=surface_n_density_points,
        )
        surface_manifest[short] = {
            "used_by": [
                "05_total_ionization_3d_2x2_all_cases.png",
                "future custom 3D/surface/contour plots",
            ],
            "arrays": {},
        }
        for name, values in surface.items():
            array_name = f"surface3d__{short}__{name}"
            arrays[array_name] = np.asarray(values, dtype=float)
            surface_manifest[short]["arrays"][name] = array_name

        for density_index in range(surface["I_grid_wcm2"].shape[0]):
            for intensity_index in range(surface["I_grid_wcm2"].shape[1]):
                surface_rows.append(
                    {
                        **case_label,
                        "dataset": "surface3d",
                        "density_index": density_index,
                        "intensity_index": intensity_index,
                        "I_wcm2": float(
                            surface["I_grid_wcm2"][density_index, intensity_index]
                        ),
                        "ne_cm3": float(
                            surface["ne_grid_cm3"][density_index, intensity_index]
                        ),
                        "log10_I_grid_wcm2": float(
                            surface["log10_I_grid_wcm2"][density_index, intensity_index]
                        ),
                        "log10_ne_grid_cm3": float(
                            surface["log10_ne_grid_cm3"][density_index, intensity_index]
                        ),
                        "Wpi_grid_cm3_fs": float(
                            surface["Wpi_grid_cm3_fs"][density_index, intensity_index]
                        ),
                        "Wav_grid_cm3_fs": float(
                            surface["Wav_grid_cm3_fs"][density_index, intensity_index]
                        ),
                        "Wtotal_grid_cm3_fs": float(
                            surface["Wtotal_grid_cm3_fs"][density_index, intensity_index]
                        ),
                        "log10_Wtotal_grid_cm3_fs": float(
                            surface["log10_Wtotal_grid_cm3_fs"][density_index, intensity_index]
                        ),
                    }
                )

    manifest = {
        "description": (
            "Labeled variables used by the 14 PI/II plot panels in "
            "Keldsyh_II_various.py, plus matching 3D surface variables."
        ),
        "source_script": "Keldsyh_II_various.py",
        "units": {
            "I_wcm2": "W/cm^2",
            "ne_cm3": "cm^-3",
            "Wpi_cm3_fs": "cm^-3 fs^-1",
            "Wav_cm3_fs": "cm^-3 fs^-1",
            "Wtotal_cm3_fs": "cm^-3 fs^-1",
            "wavelength_um": "um",
            "tau_fs": "fs",
            "F0_jcm2": "J/cm^2",
            "gamma_zns_reference": "dimensionless",
        },
        "cases": [_case_with_derived_labels(case) for case in cases],
        "settings": {
            "component_n_intensity_points": component_n_intensity_points,
            "component_I_min_wcm2": 1.0e10,
            "component_I_max_wcm2": 1.0e15,
            "total_n_intensity_points": total_n_intensity_points,
            "total_I_min_wcm2": 5.0e10,
            "total_I_max_wcm2": 1.0e15,
            "surface_n_intensity_points": surface_n_intensity_points,
            "surface_n_density_points": surface_n_density_points,
            "surface_I_min_wcm2": 1.0e10,
            "surface_I_max_wcm2": 1.0e15,
            "surface_ne_min_cm3": 1.0e10,
            "surface_ne_max_cm3": 1.0e22,
            "n_time_points_for_scaling": 600,
        },
        "files": {
            "numpy_arrays": "pi_ii_14_variables.npz",
            "manifest": "pi_ii_14_manifest.json",
            "component_scaling_csv": "pi_ii_14_component_scaling_long.csv",
            "total_comparison_csv": "pi_ii_14_total_comparison_long.csv",
            "surface3d_csv": "pi_ii_14_surface3d_long.csv",
        },
        "figure_panels_14": [
            {
                "figure": "02_last_graph_set_total_ionization_gamma_axis.png",
                "panel": "(a) NIR",
                "dataset": "total_comparison",
                "cases": ["ZnSe_NIR", "ZnS_NIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs", "gamma_zns_reference"],
            },
            {
                "figure": "02_last_graph_set_total_ionization_gamma_axis.png",
                "panel": "(b) LWIR",
                "dataset": "total_comparison",
                "cases": ["ZnSe_LWIR", "ZnS_LWIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs", "gamma_zns_reference"],
            },
            *[
                {
                    "figure": f"gruzdev_fig2_{case['short']}.png",
                    "panel": "(a) rate components",
                    "dataset": "component_scaling",
                    "cases": [case["short"]],
                    "variables": [
                        "I_wcm2",
                        "Wpi_peak_cm3_fs",
                        "Wav_peak_cm3_fs",
                        "Wtotal_peak_cm3_fs",
                    ],
                }
                for case in cases
            ],
            *[
                {
                    "figure": f"gruzdev_fig2_{case['short']}.png",
                    "panel": "(b) density and total rate",
                    "dataset": "component_scaling",
                    "cases": [case["short"]],
                    "variables": ["I_wcm2", "ne_max_cm3", "Wtotal_peak_cm3_fs"],
                }
                for case in cases
            ],
            {
                "figure": "gruzdev_fig4_ZnSe.png",
                "panel": "(a) electron density",
                "dataset": "component_scaling",
                "cases": ["ZnSe_NIR", "ZnSe_LWIR"],
                "variables": ["I_wcm2", "ne_max_cm3"],
            },
            {
                "figure": "gruzdev_fig4_ZnSe.png",
                "panel": "(b) total ionization rate",
                "dataset": "component_scaling",
                "cases": ["ZnSe_NIR", "ZnSe_LWIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs"],
            },
            {
                "figure": "gruzdev_fig4_ZnS.png",
                "panel": "(a) electron density",
                "dataset": "component_scaling",
                "cases": ["ZnS_NIR", "ZnS_LWIR"],
                "variables": ["I_wcm2", "ne_max_cm3"],
            },
            {
                "figure": "gruzdev_fig4_ZnS.png",
                "panel": "(b) total ionization rate",
                "dataset": "component_scaling",
                "cases": ["ZnS_NIR", "ZnS_LWIR"],
                "variables": ["I_wcm2", "Wtotal_peak_cm3_fs"],
            },
        ],
        "component_scaling": component_manifest,
        "total_comparison": total_manifest,
        "surface3d": surface_manifest,
    }

    np.savez_compressed(output_dir / "pi_ii_14_variables.npz", **arrays)
    with (output_dir / "pi_ii_14_manifest.json").open("w", encoding="utf-8") as handle:
        json.dump(manifest, handle, indent=2)

    write_csv(output_dir / "pi_ii_14_component_scaling_long.csv", component_rows)
    write_csv(output_dir / "pi_ii_14_total_comparison_long.csv", total_rows)
    write_csv(output_dir / "pi_ii_14_surface3d_long.csv", surface_rows)

    print(f"Saved PI/II variables to {output_dir}")


def write_csv(path: Path, rows: Sequence[Dict[str, Any]]) -> None:
    """Write a list of dictionaries as CSV."""

    if not rows:
        return
    fieldnames = list(rows[0].keys())
    with path.open("w", newline="", encoding="utf-8") as handle:
        writer = csv.DictWriter(handle, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(rows)


def plot_case_figure_1_style(
    case: CaseDict,
    save_dir: Optional[Path] = None,
) -> None:
    """Plot Keldysh photoionization rate versus peak irradiance."""

    I_values_wcm2 = np.logspace(10, 15, 900)
    I_values_wm2 = I_values_wcm2 * WM2_PER_WCM2
    wavelength_um = float(case["wavelength_um"])
    omega = 2.0 * np.pi * C0 / (wavelength_um * 1.0e-6)
    n0, _n2, Eg_J, mred, _trans = material_flag1(
        int(case["mat_flag"]), wavelength_um
    )

    Wpi_cm3_fs = np.asarray(
        keldysh_full_rate_m3_s(
            omega=omega,
            mred=mred,
            delta_J=Eg_J,
            n0=n0,
            intensity_wm2=I_values_wm2,
        ),
        dtype=float,
    ) * RATE_CM3_FS_PER_M3_S

    I_lidt = case_lidt_peak_intensity_wcm2(case)
    fig, ax = plt.subplots(figsize=(7.0, 5.0))
    ax.loglog(
        I_values_wcm2,
        positive_for_log(Wpi_cm3_fs),
        "k-",
        linewidth=2.2,
        label=r"$W_{\rm PI}$",
    )

    W_lidt = interpolate_log_y(I_values_wcm2, Wpi_cm3_fs, I_lidt)
    if W_lidt is not None:
        ax.plot(
            I_lidt,
            W_lidt,
            "kx",
            markersize=9,
            markeredgewidth=2.0,
            label=r"$I_0$ at measured LIDT",
        )

    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Photoionization rate $W_{\rm PI}$ (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"{case['material']}: $W_{{\rm PI}}$ vs irradiance, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig1_{case['short']}.png",
    )


def plot_case_figure_2_style(
    case: CaseDict,
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """
    Plot rate components, electron density, and total rate versus irradiance.
    """

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    scaling = compute_case_scaling_components(
        case=case,
        I_values_wcm2=I_values_wcm2,
        n_time_points=600,
    )

    I = scaling["I_wcm2"]
    Wpi = scaling["Wpi_peak_cm3_fs"]
    Wav = scaling["Wav_peak_cm3_fs"]
    Wtotal = scaling["Wtotal_peak_cm3_fs"]
    ne = scaling["ne_max_cm3"]
    I_lidt = case_lidt_peak_intensity_wcm2(case)

    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))

    ax = axes[0]
    ax.loglog(I, positive_for_log(Wtotal), "b--", linewidth=2.5, label=r"$W_{\rm total}$")
    ax.loglog(I, positive_for_log(Wpi), "k:", linewidth=2.3, label=r"$W_{\rm PI}$")
    ax.loglog(
        I,
        positive_for_log(Wav),
        color="orange",
        linestyle="-.",
        linewidth=2.3,
        label=r"$W_{\rm av}$",
    )
    ax.axvline(I_lidt, color="0.4", linestyle="--", linewidth=1.3, label=r"$I_0$ at LIDT")
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title(
        rf"(a) {case['material']}, $\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs"
    )
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(frameon=False, fontsize=9)
    ax.set_xlim(1.0e10, 1.0e15)

    ax = axes[1]
    ax_rate = ax.twinx()
    line_density, = ax.loglog(I, positive_for_log(ne), "r-", linewidth=2.5, label=r"$n_e$")
    line_rate, = ax_rate.loglog(
        I,
        positive_for_log(Wtotal),
        "b--",
        linewidth=2.5,
        label=r"$W_{\rm total}$",
    )
    ax.axvline(I_lidt, color="0.4", linestyle="--", linewidth=1.3)
    ax.set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    ax.set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    ax_rate.set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    ax.set_title("(b) Density and total ionization rate")
    ax.grid(True, which="both", alpha=0.3)
    ax.legend(
        [line_density, line_rate],
        [line_density.get_label(), line_rate.get_label()],
        frameon=False,
        fontsize=9,
    )
    ax.set_xlim(1.0e10, 1.0e15)

    fig.suptitle(f"{case['short']}: irradiance scaling", fontsize=14)
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig2_{case['short']}.png",
    )


def plot_case_figure_3_style(
    case: CaseDict,
    intensity_factors: Tuple[float, float, float, float] = (0.25, 0.5, 1.0, 2.0),
    save_dir: Optional[Path] = None,
) -> None:
    """Plot normalized time-domain carrier and ionization dynamics."""

    I_lidt_wcm2 = case_lidt_peak_intensity_wcm2(case)
    fig, axes = plt.subplots(4, 2, figsize=(13.0, 14.0), sharey=True)

    for row, factor in enumerate(intensity_factors):
        result = solve_dynamics_from_peak_intensity(
            case=case,
            I0_wcm2=factor * I_lidt_wcm2,
            n_time_points=1800,
        )

        if float(case["tau_fs"]) >= 1000.0:
            time_axis = result["t_s"] * 1.0e12
            time_label = "Time (ps)"
        else:
            time_axis = result["t_s"] * 1.0e15
            time_label = "Time (fs)"

        I_norm = normalize_curve(result["intensity_wm2"])
        ne_norm = normalize_curve(result["ne_cm3"])
        Wpi_norm = normalize_curve(result["Wpi_cm3_fs"])
        Wav_norm = normalize_curve(result["Wav_cm3_fs"])
        Wtotal_norm = normalize_curve(result["Wtotal_cm3_fs"])

        ax = axes[row, 0]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(time_axis, ne_norm, "r-", linewidth=2.0, label=r"$n_e$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm LIDT}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.set_ylabel("Normalized value")
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

        ax = axes[row, 1]
        ax.plot(time_axis, Wtotal_norm, "b--", linewidth=2.0, label=r"$W_{\rm total}$")
        ax.plot(
            time_axis,
            Wav_norm,
            color="goldenrod",
            linestyle="-.",
            linewidth=2.0,
            label=r"$W_{\rm av}$",
        )
        ax.plot(time_axis, Wpi_norm, "k:", linewidth=2.0, label=r"$W_{\rm PI}$")
        ax.plot(time_axis, I_norm, "r:", linewidth=2.0, label=r"$I(t)$")
        ax.text(
            0.58,
            0.78,
            rf"$I_0={factor:g}I_{{\rm LIDT}}$",
            transform=ax.transAxes,
            fontsize=10,
            fontweight="bold",
        )
        ax.grid(True, alpha=0.25)
        ax.set_ylim(-0.03, 1.05)
        if row == 0:
            ax.legend(frameon=False, fontsize=8, loc="upper left")

    axes[-1, 0].set_xlabel(time_label)
    axes[-1, 1].set_xlabel(time_label)
    fig.suptitle(
        rf"{case['material']} time-domain dynamics, "
        rf"$\lambda={case['wavelength_um']}$ $\mu$m, "
        rf"$\tau={case['tau_fs']:g}$ fs",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig3_{case['short']}.png",
    )


def plot_material_figure_4_style(
    material_name: str,
    material_cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Compare NIR and LWIR density/rate scaling for one material."""

    I_values_wcm2 = np.logspace(10, 15, n_intensity_points)
    fig, axes = plt.subplots(1, 2, figsize=(13.0, 5.2))
    linestyles = {"NIR": "-", "LWIR": "-."}

    for case in material_cases:
        scaling = compute_case_scaling_components(
            case=case,
            I_values_wcm2=I_values_wcm2,
            n_time_points=600,
        )
        I = scaling["I_wcm2"]
        ne = scaling["ne_max_cm3"]
        Wtotal = scaling["Wtotal_peak_cm3_fs"]
        label = rf"{case['wavelength_um']:g} $\mu$m, $\tau={case['tau_fs']:g}$ fs"
        style = linestyles.get(case["region"], "-")

        axes[0].loglog(I, positive_for_log(ne), linestyle=style, linewidth=2.3, label=label)
        axes[1].loglog(I, positive_for_log(Wtotal), linestyle=style, linewidth=2.3, label=label)

        I_lidt = case_lidt_peak_intensity_wcm2(case)
        axes[0].axvline(I_lidt, color="0.5", linestyle="--", linewidth=1.0)
        axes[1].axvline(I_lidt, color="0.5", linestyle="--", linewidth=1.0)

    axes[0].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[0].set_ylabel(r"Electron density $n_e$ (cm$^{-3}$)")
    axes[0].set_title(f"(a) {material_name}: electron density")
    axes[0].grid(True, which="both", alpha=0.3)
    axes[0].legend(frameon=False, fontsize=9)
    axes[0].set_xlim(1.0e10, 1.0e15)

    axes[1].set_xlabel(r"Peak laser irradiance $I_0$ (W/cm$^2$)")
    axes[1].set_ylabel(r"Total ionization rate (cm$^{-3}$ fs$^{-1}$)")
    axes[1].set_title(f"(b) {material_name}: total ionization rate")
    axes[1].grid(True, which="both", alpha=0.3)
    axes[1].legend(frameon=False, fontsize=9)
    axes[1].set_xlim(1.0e10, 1.0e15)

    fig.suptitle(
        rf"{material_name}: NIR 100 fs versus LWIR 2 ps irradiance scaling",
        fontsize=14,
    )
    save_or_show(
        fig,
        save_dir,
        f"gruzdev_fig4_{material_name}.png",
    )


def plot_znse_zns_figures(
    cases: Sequence[CaseDict],
    n_intensity_points: int = 70,
    save_dir: Optional[Path] = None,
) -> None:
    """Generate all Figs. 1-4 for ZnSe and ZnS."""

    print("\n============================================================")
    print("Generating ZnSe/ZnS plots")
    print("Cases: 0.8 um, 100 fs and 9.2 um, 2 ps")
    print("============================================================\n")

    for case in cases:
        plot_case_figure_1_style(case, save_dir=save_dir)
        plot_case_figure_2_style(
            case,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )
        plot_case_figure_3_style(case, save_dir=save_dir)

    for material_name in ("ZnSe", "ZnS"):
        material_cases = [
            case for case in cases if case["material"] == material_name
        ]
        plot_material_figure_4_style(
            material_name=material_name,
            material_cases=material_cases,
            n_intensity_points=n_intensity_points,
            save_dir=save_dir,
        )


# ============================================================
# CODEX MODIFICATION START: 3D total-ionization surface plot
# ============================================================

def plot_total_ionization_3d_surface(
    case: CaseDict,
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """
    Plot total ionization rate versus peak laser intensity and electron density.

    Axes are log10(I0), log10(ne), and log10(W_total), where W_total includes
    Keldysh photoionization plus avalanche/impact ionization.
    """

    surface_data = compute_total_ionization_surface_data(
        case=case,
        n_intensity_points=n_intensity_points,
        n_density_points=n_density_points,
        I_min_wcm2=I_min_wcm2,
        I_max_wcm2=I_max_wcm2,
        ne_min_cm3=ne_min_cm3,
        ne_max_cm3=ne_max_cm3,
    )

    X = surface_data["log10_I_grid_wcm2"]
    Y = surface_data["log10_ne_grid_cm3"]
    Z = surface_data["log10_Wtotal_grid_cm3_fs"]

    fig = plt.figure(figsize=(9, 7))
    ax = fig.add_subplot(111, projection="3d")
    surface = ax.plot_surface(
        X,
        Y,
        Z,
        cmap="jet",
        linewidth=0,
        antialiased=True,
        alpha=0.95,
    )

    ax.set_xlabel(r"$\log_{10}(I_0)$  [W/cm$^2$]")
    ax.set_ylabel(r"$\log_{10}(n_e)$  [cm$^{-3}$]")
    ax.set_zlabel(r"$\log_{10}(W_{\rm total})$  [cm$^{-3}$ fs$^{-1}$]")
    ax.set_title(f"Total ionization surface: {case['short']}")

    fig.colorbar(
        surface,
        ax=ax,
        shrink=0.65,
        pad=0.12,
        label=r"$\log_{10}(W_{\rm total})$",
    )

    ax.view_init(elev=28, azim=135)
    fig.tight_layout()
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename=f"05_total_ionization_3d_{case['short']}.png",
    )


def plot_total_ionization_3d_surface_grid(
    cases: Sequence[CaseDict],
    save_dir: Optional[Path] = None,
    n_intensity_points: int = 80,
    n_density_points: int = 80,
    I_min_wcm2: float = 1.0e10,
    I_max_wcm2: float = 1.0e15,
    ne_min_cm3: float = 1.0e10,
    ne_max_cm3: float = 1.0e22,
) -> None:
    """Plot all four total-ionization 3D surfaces in one 2x2 figure."""

    if len(cases) != 4:
        raise ValueError("The 2x2 3D grid requires exactly four cases.")
    if n_intensity_points < 2:
        raise ValueError("n_intensity_points must be at least 2.")
    if n_density_points < 2:
        raise ValueError("n_density_points must be at least 2.")
    if I_min_wcm2 <= 0.0 or I_max_wcm2 <= I_min_wcm2:
        raise ValueError("Require 0 < I_min_wcm2 < I_max_wcm2.")
    if ne_min_cm3 <= 0.0 or ne_max_cm3 <= ne_min_cm3:
        raise ValueError("Require 0 < ne_min_cm3 < ne_max_cm3.")

    surface_data_list: List[Dict[str, np.ndarray]] = []
    z_grids: List[np.ndarray] = []
    for case in cases:
        surface_data = compute_total_ionization_surface_data(
            case=case,
            n_intensity_points=n_intensity_points,
            n_density_points=n_density_points,
            I_min_wcm2=I_min_wcm2,
            I_max_wcm2=I_max_wcm2,
            ne_min_cm3=ne_min_cm3,
            ne_max_cm3=ne_max_cm3,
        )
        surface_data_list.append(surface_data)
        Z = surface_data["log10_Wtotal_grid_cm3_fs"]
        z_grids.append(Z)

    z_min = min(float(np.nanmin(Z)) for Z in z_grids)
    z_max = max(float(np.nanmax(Z)) for Z in z_grids)
    norm = colors.Normalize(vmin=z_min, vmax=z_max)
    cmap = plt.get_cmap("jet")

    fig = plt.figure(figsize=(15, 11))
    fig.subplots_adjust(
        left=0.04,
        right=0.88,
        bottom=0.06,
        top=0.92,
        wspace=0.10,
        hspace=0.16,
    )

    for index, (case, surface_data, Z) in enumerate(
        zip(cases, surface_data_list, z_grids)
    ):
        X = surface_data["log10_I_grid_wcm2"]
        Y = surface_data["log10_ne_grid_cm3"]
        ax = fig.add_subplot(2, 2, index + 1, projection="3d")
        ax.plot_surface(
            X,
            Y,
            Z,
            facecolors=cmap(norm(Z)),
            linewidth=0,
            antialiased=True,
            shade=False,
            alpha=0.95,
        )
        ax.set_xlabel(r"$\log_{10}(I_0)$")
        ax.set_ylabel(r"$\log_{10}(n_e)$")
        ax.set_zlabel(r"$\log_{10}(W_{\rm total})$")
        ax.set_title(case["short"])
        ax.view_init(elev=28, azim=135)

    colorbar_axis = fig.add_axes([0.91, 0.18, 0.018, 0.64])
    colorbar_mappable = cm.ScalarMappable(norm=norm, cmap=cmap)
    colorbar_mappable.set_array([])
    fig.colorbar(
        colorbar_mappable,
        cax=colorbar_axis,
        label=r"$\log_{10}(W_{\rm total})$ [cm$^{-3}$ fs$^{-1}$]",
    )

    fig.suptitle(
        "Total ionization surfaces: ZnSe/ZnS NIR and LWIR",
        fontsize=15,
    )
    save_or_show(
        fig=fig,
        save_dir=save_dir,
        filename="05_total_ionization_3d_2x2_all_cases.png",
        apply_tight_layout=False,
    )

# ============================================================
# CODEX MODIFICATION END: 3D total-ionization surface plot
# ============================================================


# ============================================================
# Workflow
# ============================================================

def solve_and_display_summary(cases: Sequence[CaseDict]) -> None:
    """Solve the four LIDT cases and display the summary table."""

    results: List[Dict[str, Any]] = []
    for case in cases:
        print(f"Solving density table entry for {case['short']} ...")
        result = solve_density_case(case)
        results.append(result)

        if not result["sol_photo_success"]:
            print(
                f"  WARNING: photo-only solver for {case['short']}: "
                f"{result['sol_photo_message']}"
            )
        if not result["sol_total_success"]:
            print(
                f"  WARNING: total solver for {case['short']}: "
                f"{result['sol_total_message']}"
            )

    display_summary_table(build_summary_table(results))


def main() -> None:
    """Run the fixed default workflow."""

    cases = get_cases()
    # Keep this multi-material workflow separate from the BaF2 workflow.
    save_dir = (
        Path(__file__).resolve().parent
        / "figures_Keldysh_II"
        / "figures_Keldsyh_II_various"
    )
    variable_dir = save_dir / "saved_variables"

    plot_keldysh_rate_curves(cases=cases, save_dir=save_dir)
    solve_and_display_summary(cases)
    save_pi_ii_14_plot_variables(
        cases=cases,
        output_dir=variable_dir,
        component_n_intensity_points=50,
        total_n_intensity_points=50,
        surface_n_intensity_points=50,
        surface_n_density_points=80,
    )
    plot_total_ionization_nir_lwir_comparison_with_gamma_axis(
        cases=cases,
        n_intensity_points=50,
        I_min_wcm2=5.0e10,
        I_max_wcm2=1.0e15,
        y_min=1.0e0,
        y_max=1.0e30,
        include_field_factor_two=True,
        save_dir=save_dir,
    )
    plot_znse_zns_figures(
        cases=cases,
        n_intensity_points=50,
        save_dir=save_dir,
    )
    plot_total_ionization_3d_surface_grid(
        cases=cases,
        save_dir=save_dir,
        n_intensity_points=50,
        n_density_points=80,
    )


if __name__ == "__main__":
    main()


====================================================================================================
FILE: Keldysh_mred_sensitivity.m
====================================================================================================

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
outputDir = fullfile(scriptDir, 'figures_Keldysh_II');
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

====================================================================================================
FILE: Keldysh\Dismas-matlab.zip::Electron_density_growth1.m
====================================================================================================

% Script to calculate the electron density growth as a function of laser and material inputs. 

%% Clear Variable Space
clear all
% clc

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
Ne = cell(1,1); % [electrons/cm�3]
Ne2 = Ne;
% Variable to track final density values for each cell when I is an array.
FinalDensity = zeros(1,length(I));

% Calculate electron density for all intensity values
for i = 1:length(I)

It = @(t) I(i).*exp(-4*log(2)*(t-offset).^2./tau^2); % On-axis (r=0) intensity [W/m�2]
%It = @(t) I(i).*exp(-4*log(2)*(t-offset).^2./tau^2)*10^-4; % On?axis (r=0) intensity [W/cm�2]

% This function calculates the full and photoexcitation rate with time [fs] and Ne as the only inputs. 
%Because it is an anonymous function, any function calls here have access to all variables in the workspace.
% Inputs:
% t: time [fs]
% Ne: Free electron density [electrons/cm�3]
% Outputs:
%  Photoexcitation Rate and Full Rate [electrons/fs/cm�3]

% Full rate equation 
fullRate = @(t,Ne) (It(t) * Ne).*10^-19 + ...
    keldysh_full1(omega,me,delta,n(i),It(t)).*10^(-15)./100^3;
%  fullRate = @(t,Ne) (alpha * It(t) * Ne).*10^-19 + ...
%      keldysh_full(omega,me,delta,n(i),It(t)).*10^(-15)./100^3- ...
%      Ne./T_recombination;

% Photoionization rate equation [electrons/fs/cm�3]
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
ylabel(AX(1),'Electron Density (1/cm�3)','FontSize',14)
set(AX(2),'ycolor','b', 'LineWidth', 3)
ylabel(AX(2),'Pulse Intensity (W/cm�2)', 'FontSize',14)
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


====================================================================================================
FILE: Keldysh\Dismas-matlab.zip::keldysh_full1.m
====================================================================================================

function W = keldysh_full1(w,me,delta,n,I)
% Function to calculate the full Keldysh rate (eq 37 from Keldysh paper(1965))
%
% Inputs:
% w: radial frequency of light (omega) [rad/s]
% me: effective electron mass [kg]
% delta: bandgap of material [J]
% n: refractive index [unitless]
% I: Laser Irradiance [W/m�2]
% Outputs:
%W: Keldysh photoionization rate [electrons/s/m�3]

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

W = Wf1 .* Wf2 .* Wf3; % [electrons/s/m�3]

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
    % Check to see if  'dawson.m' exists ...
%in the path. This function is a faster ...
if exist('dawson.m','file') == 2
    Q2(i) = Q2(i) + exp-pi() .* (Kg(i)-Eg(i)) .* ...
        j ./ E1(i).* dawson(sqrt(pi()^2.*(2*floor...
        (x(i)+1)-2.*x(i) + j) ./(2*K1(i) .* E1(i))));
else
Q2(i) = Q2(i) + exp(-pi() .* (Kg(i)-Eg(i)) .* ...
    j ./ E1(i)) .* mfun('dawson',sqrt(pi()^2....
    *(2*floor(x(i)+1)-2.*x(i) + j) ./(2*K1(i) ....
    * E1(i))));
 end
 err = abs(Q2(i)-OldQ2);
j = j + 1;
OldQ2 = Q2(i);
end
end
Q = Q1.*Q2;
end
end

====================================================================================================
FILE: Keldysh\Dismas-matlab.zip::keldysh_MPI1.m
====================================================================================================

function [W] = keldysh_MPI1(w,me,delta,n,I)
% Function to calculate the Keldysh tunneling rate (eq 41 from Keldysh paper(1965))
%
% Inputs:
% w: radial frequency of light (omega) [rad/s]
% me: effective electron mass [kg]
% delta: bandgap of material [J]
% n: refractive index [unitless]===from matFlag
% I: Laser Irradiance [W/m�2]
% Outputs:
% W: Keldysh MPI Rate [electrons/s/m�3]


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

% Check to see if 'dawson.m' exists in the path. ...
%This function is a faster implementation of the dawson integral...
%than the 'mfun' implementation.
if exist('dawson.m','file') == 2
Wmpi2 = dawson(((2.*X-(2.*delta_tau)./(hbar*w)).^(1/2)));
else
Wmpi2 = mfun('dawson',((2.*X-(2.*delta_tau)./(hbar*w)).^(1/2)));
end
Wmpi3 = exp(2.*X.*(1-(e^2.*F.^2)./(4*me*w^2*delta)));
Wmpi4 = ((e^2.*F.^2)./(16*me*w^2*delta)).^X;

W = Wmpi1 .* Wmpi2 .* Wmpi3 .* Wmpi4; % [electrons/s/m�3]
end

====================================================================================================
FILE: Keldysh\Dismas-matlab.zip::keldysh_rate2.m
====================================================================================================

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
%lambda = 1.7; % Wavelength in micrometers (�m)
lambda = 9.2; % Wavelength in micrometers (�m)
%lambda = 0.8; % Wavelength in micrometers (�m)
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

====================================================================================================
FILE: Keldysh\Dismas-matlab.zip::keldysh_tunneling1.m
====================================================================================================

function [W] = keldysh_tunneling1(w,me,delta,n,I)
% Function to calculate the Keldysh tunneling rate (eq 40 from ...
%Keldysh paper(1965))
 %
 % Inputs:
 % w: radial frequency of light (omega) [rad/s]
 % me: effective electron mass [kg]
 % delta: bandgap of material [J]
 % n: refractive index [unitless]
 % I: Laser Irradiance [W/m�2]
 % Outputs:
 % W: Keldysh Tunneling Rate [electrons/s/m�3]
 

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

W = Wtun1 .* Wtun2 .*Wtun3; % [electrons/s/m�3]....combined terms for whole equation

end

====================================================================================================
FILE: Keldysh\Dismas-matlab.zip::material_flag1.m
====================================================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
%Returns material refractive index to the main script, ...
%The Sellmeier Equation, refractive ...
%index values, and reflectivity values can be found at http://...
%refractiveindex.info/.
function [n0, n2, delta, me, Trans] = material_flag1(matFlag,...
    lambda, me0, e)% inputs: (matFlag, lambda, m_e,e)
% Use a switch/case structure to select between different materials
% Values for matFlag:

 % 1: ZnSe

 % 2: ZnS

 switch matFlag
 
%ZnSe
     case 1
      
         delta_eV = 2.71;
         delta = delta_eV * e;%in J
         me = 0.17 * me0;
         n0 = sqrt(1 + 4.45813734*lambda^2/(lambda^2-0.200859853^2) + ...
             0.467216334*lambda^2/(lambda^2-0.391371166^2) + ...
             2.89566290*lambda^2/(lambda^2-47.1362108^2));
         n2 = 6.5e-19; %@9.2 um
         %n2 = 2.3e-18; %@1030 nm, use it for 800 nm 
         %Ref = 0.32949; % 800nm
         Ref = 0.31059; % 9200nm
         Trans = 1-Ref;
         
  
 % ZnS
     case 2
        
         delta_eV = 3.6;
         delta= delta_eV * e;
         %me = 0.16 * me0;
         me = 0.34 * me0;
         n0 = sqrt(8.393 + 0.14383/(lambda^2-0.2421^2) + ...
             4430.99/(lambda^2-36.71^2)); % use http://refractiveindex.info.../;
         n2 = 4.0e-19; %@9.2 um
         %n2 = 6.8e-19; %@1030 nm, use it for 800 nm 
   
         Ref = 0.26693; % 9200nm
         %Ref = 0.38251; % 800nm
         Trans = 1-Ref;
 
     otherwise
         disp('Warning: Invalid material parameters');
         return
 end
end
