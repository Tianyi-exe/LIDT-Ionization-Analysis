%PLOT_ALL_MATERIALS_FROM_CSV_REVIEW Compare every fluence-qualified material from CSV.
%   Combines the two existing review workflows and saves PNG plus editable
%   MATLAB .fig files in the Keldysh/figures_Keldysh_II results folder.
%   NIR plots include ZnSe, ZnS, BaF2, NaCl, GaAs, IRG207, Ge, and KRS-5.
%   Ti:Sapphire is intentionally disabled pending a material-specific model.
%   LWIR plots include the four available material cases.
%   CdTe is excluded because its input fluence is not available.
%
%   Figure 1: total W_total comparison (all available NIR and LWIR cases)
%   Figure 2: NIR W_PI, W_av, W_total for each available material
%   Figure 3: side-by-side NIR and LWIR n_e/W_total comparisons
%   Figure 4: NIR/LWIR comparison per material
%   Figure 5: unified 3D W_total surfaces for all available material cases
%   Figure 1 calculates gamma from each material's own n0, Eg, and mred
%   values, then shows a distinct gamma = 1 dashed line for every material.
clc; clear; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

scriptDir = fileparts(mfilename('fullpath'));
keldyshRoot = fileparts(scriptDir);
dataDir = fullfile(keldyshRoot, 'figures_Keldysh_II');
outputDir = fullfile(keldyshRoot, 'figures_Keldysh_II_full');
if ~isfolder(outputDir), mkdir(outputDir); end

variousDir = fullfile(dataDir, 'figures_Keldsyh_II_various');
baf2Dir = fullfile(dataDir, 'figures_Keldsyh_II_BaF2');
naclDir = fullfile(dataDir, 'figures_Keldsyh_II_NaCl');
gaasDir = fullfile(dataDir, 'figures_Keldsyh_II_GaAs');
irg207Dir = fullfile(dataDir, 'figures_Keldsyh_II_IRG207');
geDir = fullfile(dataDir, 'figures_Keldsyh_II_Ge');
krs5Dir = fullfile(dataDir, 'figures_Keldsyh_II_KRS5');
% Ti:Sapphire is a Ti3+:Al2O3 host/dopant system.  Do not add its
% host-only diagnostic CSV to the cross-material comparison yet.
% tiSapphireDir = fullfile(dataDir, 'figures_Keldsyh_II_TiSapphire');

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
gaasComponent = readCsv(fullfile(gaasDir, 'saved_variables', ...
    'gaas_component_scaling_long.csv'));
gaasTotal = readCsv(fullfile(gaasDir, 'saved_variables', ...
    'gaas_total_comparison_long.csv'));
irg207Component = readCsv(fullfile(irg207Dir, 'saved_variables', ...
    'irg207_component_scaling_long.csv'));
irg207Total = readCsv(fullfile(irg207Dir, 'saved_variables', ...
    'irg207_total_comparison_long.csv'));
geComponent = readCsv(fullfile(geDir, 'saved_variables', ...
    'ge_component_scaling_long.csv'));
geTotal = readCsv(fullfile(geDir, 'saved_variables', ...
    'ge_total_comparison_long.csv'));
krs5Component = readCsv(fullfile(krs5Dir, 'saved_variables', ...
    'krs5_component_scaling_long.csv'));
krs5Total = readCsv(fullfile(krs5Dir, 'saved_variables', ...
    'krs5_total_comparison_long.csv'));
% tiSapphireComponent = readCsv(fullfile(tiSapphireDir, 'saved_variables', ...
%     'ti_sapphire_component_scaling_long.csv'));
% tiSapphireTotal = readCsv(fullfile(tiSapphireDir, 'saved_variables', ...
%     'ti_sapphire_total_comparison_long.csv'));
varSurface = readSurfaceCsv(fullfile(variousDir, 'saved_variables', ...
    'pi_ii_14_surface3d_long.csv'));
bafSurface = readSurfaceCsv(fullfile(baf2Dir, 'saved_variables', ...
    'baf2_surface3d_long.csv'));
naclSurface = readSurfaceCsv(fullfile(naclDir, 'saved_variables', ...
    'nacl_surface3d_long.csv'));
gaasSurface = readSurfaceCsv(fullfile(gaasDir, 'saved_variables', ...
    'gaas_surface3d_long.csv'));
irg207Surface = readSurfaceCsv(fullfile(irg207Dir, 'saved_variables', ...
    'irg207_surface3d_long.csv'));
geSurface = readSurfaceCsv(fullfile(geDir, 'saved_variables', ...
    'ge_surface3d_long.csv'));
krs5Surface = readSurfaceCsv(fullfile(krs5Dir, 'saved_variables', ...
    'krs5_surface3d_long.csv'));
% tiSapphireSurface = readSurfaceCsv(fullfile(tiSapphireDir, 'saved_variables', ...
%     'ti_sapphire_surface3d_long.csv'));

% The existing ZnSe/ZnS CSV has a ZnS-reference gamma column.  Recalculate
% gamma from each row's own material properties for an apples-to-apples plot.
varTotal = addMaterialGamma(varTotal);
bafTotal = addMaterialGamma(bafTotal);
naclTotal = addMaterialGamma(naclTotal);
gaasTotal = addMaterialGamma(gaasTotal);
irg207Total = addMaterialGamma(irg207Total);
geTotal = addMaterialGamma(geTotal);
krs5Total = addMaterialGamma(krs5Total);
% tiSapphireTotal = addMaterialGamma(tiSapphireTotal);

cases = [ ...
    makeCase(varComponent, varTotal, "ZnSe_NIR", "I_lidt_wcm2", ...
        "gamma_material", "ZnSe", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(varComponent, varTotal, "ZnS_NIR",  "I_lidt_wcm2", ...
        "gamma_material", "ZnS", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(bafComponent, bafTotal, "BaF2_NIR", "I0_wcm2", ...
        "gamma_material", "BaF2", "Wtotal_direct_at_lidt_cm3_fs"); ...
    makeCase(naclComponent, naclTotal, "NaCl_NIR", "I0_wcm2", ...
        "gamma_material", "NaCl", "Wtotal_direct_at_reference_cm3_fs"); ...
    makeCase(gaasComponent, gaasTotal, "GaAs_NIR", "I0_wcm2", ...
        "gamma_material", "GaAs", "Wtotal_direct_at_reference_cm3_fs"); ...
    makeCase(irg207Component, irg207Total, "IRG207_NIR", "I0_wcm2", ...
        "gamma_material", "IRG207", "Wtotal_direct_at_reference_cm3_fs"); ...
    makeCase(geComponent, geTotal, "Ge_NIR", "I0_wcm2", ...
        "gamma_material", "Ge", "Wtotal_direct_at_reference_cm3_fs"); ...
    makeCase(krs5Component, krs5Total, "KRS5_NIR", "I0_wcm2", ...
        "gamma_material", "KRS-5", "Wtotal_direct_at_reference_cm3_fs"); ...
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
pairedMaterials = ["ZnSe", "ZnS", "BaF2", "NaCl"];

% A shared gamma axis would be misleading because gamma is material-specific.
% Instead, Figure 1 uses individually labeled gamma = 1 vertical lines.
fig = newFigure('01 Total ionization comparison', ...
    'Total ionization comparison; black x = model value at LIDT');
tiledlayout(fig, 1, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
plotTotalComparison(nexttile, nIR, '(a) NIR: all fluence-qualified materials');
plotTotalComparison(nexttile, lwir, '(b) LWIR: ZnSe, ZnS, BaF2, NaCl');
saveFigurePair(outputDir, 'combined_01_total_ionization_comparison');

fig = newFigure('02 NIR rate components', ...
    'NIR rate components for all fluence-qualified materials');
[nRows, nCols] = tileShape(numel(nIR), 3);
tiledlayout(fig, nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
for k = 1:numel(nIR)
    plotComponentPanel(nexttile, nIR(k));
end
saveFigurePair(outputDir, 'combined_02_NIR_rate_components');

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
saveFigurePair(outputDir, 'combined_03_NIR_LWIR_density_total_rate');

fig = newFigure('04 Material NIR/LWIR comparisons', ...
    'Material comparison at NIR and LWIR');
tiledlayout(fig, 2, 2, 'TileSpacing', 'compact', 'Padding', 'compact');
for material = pairedMaterials
    plotMaterialComparison(nexttile, cases(strcmp({cases.material}, char(material))));
end
saveFigurePair(outputDir, 'combined_04_material_NIR_LWIR_comparison');

surfaceCases = [ ...
    makeSurfaceCase(varSurface, cases, "ZnSe_NIR"); ...
    makeSurfaceCase(varSurface, cases, "ZnS_NIR"); ...
    makeSurfaceCase(bafSurface, cases, "BaF2_NIR"); ...
    makeSurfaceCase(naclSurface, cases, "NaCl_NIR"); ...
    makeSurfaceCase(gaasSurface, cases, "GaAs_NIR"); ...
    makeSurfaceCase(irg207Surface, cases, "IRG207_NIR"); ...
    makeSurfaceCase(geSurface, cases, "Ge_NIR"); ...
    makeSurfaceCase(krs5Surface, cases, "KRS5_NIR"); ...
    makeSurfaceCase(varSurface, cases, "ZnSe_LWIR");...
    makeSurfaceCase(varSurface, cases, "ZnS_LWIR");...
    makeSurfaceCase(bafSurface, cases, "BaF2_LWIR");...
    makeSurfaceCase(naclSurface, cases, "NaCl_LWIR")];


fig = newSurfaceFigure('05 Combined 3D total-ionization surfaces', ...
    'Total ionization surfaces: all available material and wavelength cases');
plotCombined3dSurfaces(fig, surfaceCases);
saveFigurePair(outputDir, 'combined_05_all_materials_3d_total_ionization');

fig = newHeatmapFigure('06 Combined total-ionization heatmaps', ...
    'Total ionization-rate heatmaps: dotted = \gamma = 1; dashed = LIDT');
plotCombinedHeatmaps(fig, surfaceCases);
saveFigurePair(outputDir, 'combined_06_all_materials_total_ionization_heatmaps');

drawnow;
fprintf(['Displayed unified CSV-review figures: NIR uses all fluence-qualified materials; ', ...
    'LWIR uses ZnSe, ZnS, BaF2, NaCl. CdTe is excluded because F0 is unavailable. ', ...
    'PNG and .fig files were saved in %s.\n'], outputDir);

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
    'material', char(displayMaterialName(c.material(1))), ...
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
    color = materialColor(reference);
    label = sprintf('\\gamma_{%s}=1', latexMaterialName(reference));
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

[nRows, nCols] = tileShape(numel(surfaceCases), 4);
layout = tiledlayout(fig, nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
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

[nRows, nCols] = tileShape(numel(surfaceCases), 4);
layout = tiledlayout(fig, nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');
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
    case "GaAs", color = [0.6350 0.0780 0.1840];
    case "IRG207", color = [0.9290 0.6940 0.1250];
    case "Ge", color = [0.3010 0.7450 0.9330];
    case "KRS-5", color = [0.2500 0.2500 0.2500];
    % case "Ti:Sapphire", color = [0.5000 0.0000 0.5000];
    otherwise,    color = [0 0 0];
end
end

function name = displayMaterialName(rawName)
rawName = string(rawName);
if contains(rawName, "IRG207")
    name = "IRG207";
elseif contains(rawName, "KRS")
    name = "KRS-5";
elseif contains(rawName, "Germanium") || rawName == "Ge"
    name = "Ge";
else
    name = rawName;
end
end

function label = latexMaterialName(material)
switch string(material)
    case "BaF2", label = 'BaF_2';
    % case "Ti:Sapphire", label = 'Ti:Sapphire';
    otherwise, label = char(material);
end
end

function [nRows, nCols] = tileShape(nPanels, maxColumns)
nCols = min(maxColumns, nPanels);
nRows = ceil(nPanels / nCols);
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
