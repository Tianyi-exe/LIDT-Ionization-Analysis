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
