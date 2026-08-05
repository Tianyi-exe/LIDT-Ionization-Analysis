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
