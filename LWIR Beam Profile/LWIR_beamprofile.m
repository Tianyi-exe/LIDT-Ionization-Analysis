clc; clear; close all;
set(groot, 'DefaultAxesFontSize', 16, 'DefaultTextFontSize', 16, ...
    'DefaultLegendFontSize', 16, 'DefaultColorbarFontSize', 16);

scriptFolder = fileparts(mfilename('fullpath'));
if scriptFolder == ""
    scriptFolder = pwd;
end

dataFiles = dir(fullfile(scriptFolder, "*.bgData"));
if isempty(dataFiles)
    error("No .bgData files found in: %s", scriptFolder);
end

[~, sortIdx] = sort(lower(string({dataFiles.name})));
dataFiles = dataFiles(sortIdx);

outputFolder = fullfile(fileparts(scriptFolder), "BeamProfile figures");
if ~isfolder(outputFolder)
    mkdir(outputFolder);
end

thresholdFraction = exp(-2); % 1/e^2 of the maximum signal
profileDisplayFraction = 0.25;
pixelSizeX_um = 80;
pixelSizeY_um = 80;
arrayWidth_px = 320;
arrayHeight_px = 320;

N = numel(dataFiles);
cols = ceil(sqrt(N));
rows = ceil(N / cols);

beamFig = figure( ...
    'Name', 'LWIR Beam Profiles', ...
    'Color', 'w', ...
    'Position', [150, 100, 1500, 850]);

beam3dFig = figure( ...
    'Name', 'LWIR Beam Profiles 3D', ...
    'Color', 'w', ...
    'Position', [200, 120, 1500, 850]);

for i = 1:N
    filePath = fullfile(dataFiles(i).folder, dataFiles(i).name);
    [imgData, x_mm, y_mm, plotTitle] = readLwirBgData( ...
        filePath, pixelSizeX_um, pixelSizeY_um, arrayWidth_px, arrayHeight_px);
    imgData = imgData - min(imgData(:), [], "all");

    maxVal = max(imgData(:));
    if maxVal <= 0
        warning("No positive signal found. Skipping: %s", dataFiles(i).name);
        continue;
    end

    threshold = maxVal * thresholdFraction;
    [~, peakIdx] = max(imgData(:));
    [measureRowIdx, measureColIdx] = ind2sub(size(imgData), peakIdx);

    xrange = [x_mm(1), x_mm(end)];
    yrange = [y_mm(1), y_mm(end)];

    figure(beamFig);
    subplot(rows, cols, i);
    imagesc(x_mm, y_mm, imgData);
    axis image;
    colormap(gca, jet);
    set(gca, 'YDir', 'normal');
    hold on;

    contour(x_mm, y_mm, imgData, [threshold threshold], ...
            'y', 'LineWidth', 2.5);

    ax = gca;
    hYProfile = plot(ax, nan, nan, 'r', 'LineWidth', 1.4);
    hXProfile = plot(ax, nan, nan, 'r', 'LineWidth', 1.4);
    hYLow = yline(ax, y_mm(measureRowIdx), '--y', 'LineWidth', 1);
    hYHigh = yline(ax, y_mm(measureRowIdx), '--y', 'LineWidth', 1);
    hXLow = xline(ax, x_mm(measureColIdx), '--y', 'LineWidth', 1);
    hXHigh = xline(ax, x_mm(measureColIdx), '--y', 'LineWidth', 1);
    hMeasureX = plot(ax, [x_mm(measureColIdx), x_mm(measureColIdx)], yrange, ...
                     '--', 'Color', [0, 1, 1], 'LineWidth', 1.2, ...
                     'HitTest', 'on', 'PickableParts', 'all');
    hMeasureY = plot(ax, xrange, [y_mm(measureRowIdx), y_mm(measureRowIdx)], ...
                     '--', 'Color', [0, 1, 1], 'LineWidth', 1.2, ...
                     'HitTest', 'on', 'PickableParts', 'all');
    hDiameterText = text(ax, xrange(1) + 0.05*diff(xrange), ...
                         yrange(2) - 0.10*diff(yrange), ...
                         '', ...
                         'Color', 'w', ...
                         'FontSize', 16, ...
                         'FontWeight', 'bold', ...
                         'Interpreter', 'tex');

    cursorData = struct( ...
        'imgDouble', imgData, ...
        'x_mm', x_mm, ...
        'y_mm', y_mm, ...
        'xrange', xrange, ...
        'yrange', yrange, ...
        'profileDisplayFraction', profileDisplayFraction, ...
        'measureRowIdx', measureRowIdx, ...
        'measureColIdx', measureColIdx, ...
        'hYProfile', hYProfile, ...
        'hXProfile', hXProfile, ...
        'hYLow', hYLow, ...
        'hYHigh', hYHigh, ...
        'hXLow', hXLow, ...
        'hXHigh', hXHigh, ...
        'hMeasureX', hMeasureX, ...
        'hMeasureY', hMeasureY, ...
        'hDiameterText', hDiameterText, ...
        'dragDirection', '');
    setappdata(ax, 'MeasureCursorData', cursorData);
    updateMeasureProfiles(ax);
    set(hMeasureX, 'ButtonDownFcn', @(~, ~) startMeasureCursorDrag(beamFig, ax, 'x'));
    set(hMeasureY, 'ButtonDownFcn', @(~, ~) startMeasureCursorDrag(beamFig, ax, 'y'));

    title(plotTitle, 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 16);
    xlabel('X (mm)');
    ylabel('Y (mm)');
    xlim(xrange);
    ylim(yrange);
    colorbar;

    figure(beam3dFig);
    subplot(rows, cols, i);
    surf(x_mm, y_mm, imgData, 'EdgeColor', 'none');
    shading interp;
    colormap(gca, jet);
    hold on;
    contour3(x_mm, y_mm, imgData, [threshold threshold], ...
             'y', 'LineWidth', 2.5);
    view(45, 35);
    axis tight;
    grid on;
    title(plotTitle, 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 16);
    xlabel('X (mm)');
    ylabel('Y (mm)');
    zlabel('Signal (a.u.)');
    colorbar;
end

saveas(beamFig, fullfile(outputFolder, "LWIR_beamprofile.png"));
savefig(beamFig, fullfile(outputFolder, "LWIR_beamprofile.fig"));
saveas(beam3dFig, fullfile(outputFolder, "LWIR_beamprofile_3D.png"));
savefig(beam3dFig, fullfile(outputFolder, "LWIR_beamprofile_3D.fig"));

function startMeasureCursorDrag(figHandle, ax, direction)
    cursorData = getappdata(ax, 'MeasureCursorData');
    cursorData.dragDirection = direction;
    setappdata(ax, 'MeasureCursorData', cursorData);
    set(figHandle, 'WindowButtonMotionFcn', @(~, ~) dragMeasureCursor(ax));
    set(figHandle, 'WindowButtonUpFcn', @(~, ~) stopMeasureCursorDrag(figHandle, ax));
end

function dragMeasureCursor(ax)
    if ~isvalid(ax)
        return;
    end

    cursorData = getappdata(ax, 'MeasureCursorData');
    currentPoint = get(ax, 'CurrentPoint');

    switch cursorData.dragDirection
        case 'x'
            cursorX = min(max(currentPoint(1, 1), cursorData.xrange(1)), cursorData.xrange(2));
            [~, cursorData.measureColIdx] = min(abs(cursorData.x_mm - cursorX));
            cursorX = cursorData.x_mm(cursorData.measureColIdx);
            set(cursorData.hMeasureX, 'XData', [cursorX, cursorX], 'YData', cursorData.yrange);

        case 'y'
            cursorY = min(max(currentPoint(1, 2), cursorData.yrange(1)), cursorData.yrange(2));
            [~, cursorData.measureRowIdx] = min(abs(cursorData.y_mm - cursorY));
            cursorY = cursorData.y_mm(cursorData.measureRowIdx);
            set(cursorData.hMeasureY, 'XData', cursorData.xrange, 'YData', [cursorY, cursorY]);
    end

    setappdata(ax, 'MeasureCursorData', cursorData);
    updateMeasureProfiles(ax);
end

function stopMeasureCursorDrag(figHandle, ax)
    if isvalid(figHandle)
        set(figHandle, 'WindowButtonMotionFcn', '');
        set(figHandle, 'WindowButtonUpFcn', '');
    end

    if isvalid(ax)
        cursorData = getappdata(ax, 'MeasureCursorData');
        cursorData.dragDirection = '';
        setappdata(ax, 'MeasureCursorData', cursorData);
    end
end

function updateMeasureProfiles(ax)
    cursorData = getappdata(ax, 'MeasureCursorData');

    xProfile = cursorData.imgDouble(cursorData.measureRowIdx, :);
    yProfile = cursorData.imgDouble(:, cursorData.measureColIdx);

    xZoomIdx = find(cursorData.x_mm >= cursorData.xrange(1) & cursorData.x_mm <= cursorData.xrange(2));
    yZoomIdx = find(cursorData.y_mm >= cursorData.yrange(1) & cursorData.y_mm <= cursorData.yrange(2));

    if ~isempty(xZoomIdx)
        xProfile_crop = xProfile(xZoomIdx);
        xProfile_plot = xProfile_crop - min(xProfile_crop);
        if max(xProfile_plot) > 0
            xProfile_scaled = xProfile_plot / max(xProfile_plot) * diff(cursorData.yrange) * cursorData.profileDisplayFraction;
        else
            xProfile_scaled = zeros(size(xProfile_plot));
        end
        set(cursorData.hXProfile, ...
            'XData', cursorData.x_mm(xZoomIdx), ...
            'YData', cursorData.yrange(1) + xProfile_scaled);
    end

    if ~isempty(yZoomIdx)
        yProfile_crop = yProfile(yZoomIdx);
        yProfile_plot = yProfile_crop - min(yProfile_crop);
        if max(yProfile_plot) > 0
            yProfile_scaled = yProfile_plot / max(yProfile_plot) * diff(cursorData.xrange) * cursorData.profileDisplayFraction;
        else
            yProfile_scaled = zeros(size(yProfile_plot));
        end
        set(cursorData.hYProfile, ...
            'XData', cursorData.xrange(1) + yProfile_scaled, ...
            'YData', cursorData.y_mm(yZoomIdx));
    end

    [xCross, xDiameter_mm] = findProfileDiameter(xProfile, cursorData.x_mm);
    [yCross, yDiameter_mm] = findProfileDiameter(yProfile, cursorData.y_mm);

    set(cursorData.hXLow, 'Value', cursorData.x_mm(xCross(1)));
    set(cursorData.hXHigh, 'Value', cursorData.x_mm(xCross(end)));
    set(cursorData.hYLow, 'Value', cursorData.y_mm(yCross(1)));
    set(cursorData.hYHigh, 'Value', cursorData.y_mm(yCross(end)));

    if isnan(xDiameter_mm)
        xDiameterText = 'X Diam: N/A';
    else
        xDiameterText = sprintf('X Diam: %.3f mm', xDiameter_mm);
    end

    if isnan(yDiameter_mm)
        yDiameterText = 'Y Diam: N/A';
    else
        yDiameterText = sprintf('Y Diam: %.3f mm', yDiameter_mm);
    end

    diameterText = sprintf('%s\n%s', xDiameterText, yDiameterText);
    set(cursorData.hDiameterText, 'String', diameterText);
end

function [crossIdx, diameter_mm] = findProfileDiameter(profile, axis_mm)
    profilePeak = max(profile);
    if profilePeak <= 0
        crossIdx = [1, numel(profile)];
        diameter_mm = NaN;
        return;
    end

    profileThresh = profilePeak * exp(-2);
    crossIdx = find(profile >= profileThresh);
    if isempty(crossIdx)
        crossIdx = [1, numel(profile)];
        diameter_mm = NaN;
        return;
    end

    diameter_mm = axis_mm(crossIdx(end)) - axis_mm(crossIdx(1));
end

function [imgData, x_mm, y_mm, plotTitle] = readLwirBgData( ...
    filePath, pixelSizeX_um, pixelSizeY_um, arrayWidth_px, arrayHeight_px)
    data = h5read(filePath, "/BG_DATA/1/DATA");
    width = arrayWidth_px;
    height = arrayHeight_px;

    if numel(data) ~= width * height
        fileWidth = double(h5read(filePath, "/BG_DATA/1/RAWFRAME/WIDTH"));
        fileHeight = double(h5read(filePath, "/BG_DATA/1/RAWFRAME/HEIGHT"));
        warning("Expected %d x %d data, but found %d values. Using file dimensions %d x %d.", ...
            width, height, numel(data), fileWidth, fileHeight);
        width = fileWidth;
        height = fileHeight;
    end

    imgData = reshape(double(data), [width, height])';

    x_mm = (0:width-1) * pixelSizeX_um / 1000;
    y_mm = (0:height-1) * pixelSizeY_um / 1000;

    [~, name, ext] = fileparts(filePath);
    plotTitle = string(name) + string(ext);
end
