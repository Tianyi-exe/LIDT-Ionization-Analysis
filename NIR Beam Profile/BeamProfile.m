clc; clear; close all;

% === Beam profile analysis for BaF2 07_10_26 ===
% baseFolder = "C:\Users\Faculty\OneDrive - The City University of New York\Tasks\BNL2026\LIDT2026\NIR Beam Profile\07_23_26";
baseFolder = 'D:\OneDrive - The City University of New York\Tasks\BNL2026\LIDT2026\NIR Beam Profile\07_23_26';

folderPath = fullfile(baseFolder, "beamprofile");
bgPath = fullfile(baseFolder, "Bg_Image__2026-07-23__12-14-56.png");

pixel_size_um = 5.86;
thresholdFraction = exp(-2); % 1/e^2 of the maximum signal
roiHalfSize_px = 100;
% CODEX MODIFICATION START: search the full image for the beam center
beamSearchColumnFraction = 1.0;
% CODEX MODIFICATION END: search the full image for the beam center
profileDisplayFraction = 0.25;

if ~isfolder(folderPath)
    error("Beam profile folder not found: %s", folderPath);
end

if isfile(bgPath)
    bgRaw = imread(bgPath);
    bgData = imageToDoubleGray(bgRaw);
else
    warning("Background image not found. Using local ROI background estimate instead: %s", bgPath);
    bgData = [];
end

imageFiles = [
    dir(fullfile(folderPath, "*.png"));
    dir(fullfile(folderPath, "*.tif"));
    dir(fullfile(folderPath, "*.tiff"))
];

if isempty(imageFiles)
    error("No image files found in: %s", folderPath);
end

[~, sortIdx] = sort(lower(string({imageFiles.name})));
imageFiles = imageFiles(sortIdx);

N = numel(imageFiles);
cols = ceil(sqrt(N));
rows = ceil(N / cols);

beamFig = figure( ...
    'Name', 'BaF2 Beam Profiles', ...
    'Color', 'w', ...
    'Position', [200, 100, 1400, 800]);

beam3dFig = figure( ...
    'Name', 'BaF2 Beam Profiles 3D', ...
    'Color', 'w', ...
    'Position', [250, 120, 1400, 800]);

for i = 1:N
    imagePath = fullfile(imageFiles(i).folder, imageFiles(i).name);
    imgRaw = imread(imagePath);
    imgData = imageToDoubleGray(imgRaw);

    detectionData = subtractBackgroundIfSameSize(imgData, bgData);
    if max(detectionData(:)) <= 0
        detectionData = subtractLocalBackground(imgData);
    end
    if max(detectionData(:)) <= 0
        detectionData = imgData - min(imgData(:), [], "all");
    end
    [roiRows, roiCols] = findBeamRoi(detectionData, roiHalfSize_px, beamSearchColumnFraction);

    imgCrop = imgData(roiRows, roiCols);
    if ~isempty(bgData) && isequal(size(imgData), size(bgData))
        bgCrop = bgData(roiRows, roiCols);
        imgDouble = imgCrop - bgCrop;
    else
        imgDouble = subtractLocalBackground(imgCrop);
    end
    imgDouble(imgDouble < 0) = 0;

    maxVal = max(imgDouble(:));
    if maxVal <= 0
        warning("No positive signal after background subtraction. Skipping: %s", imageFiles(i).name);
        continue;
    end

    threshold = maxVal * thresholdFraction;
    beamMask = imgDouble >= threshold;
    cc = bwconncomp(beamMask);
    stats = regionprops(cc, 'Area', 'Centroid');

    if isempty(stats)
        warning("No region detected. Skipping: %s", imageFiles(i).name);
        continue;
    end

    [~, idx] = max([stats.Area]);
    componentMask = false(size(imgDouble));
    componentMask(cc.PixelIdxList{idx}) = true;

    [~, peakIdx] = max(imgDouble(:));
    [measureRowIdx, measureColIdx] = ind2sub(size(imgDouble), peakIdx);

    [rows_img, cols_img] = size(imgDouble);
    x_um = (0:cols_img-1) * pixel_size_um;
    y_um = (0:rows_img-1) * pixel_size_um;
    xrange = [x_um(1), x_um(end)];
    yrange = [y_um(1), y_um(end)];

    figure(beamFig);
    subplot(rows, cols, i);
    imagesc(x_um, y_um, imgDouble);
    axis image;
    colormap(gca, jet);
    set(gca, 'YDir', 'normal');
    hold on;

    contour(x_um, y_um, imgDouble, [threshold threshold], ...
            'y', 'LineWidth', 2.5);

    ax = gca;
    hYProfile = plot(ax, nan, nan, 'r', 'LineWidth', 1.4);
    hXProfile = plot(ax, nan, nan, 'r', 'LineWidth', 1.4);
    hYLow = yline(ax, y_um(measureRowIdx), '--y', 'LineWidth', 1);
    hYHigh = yline(ax, y_um(measureRowIdx), '--y', 'LineWidth', 1);
    hXLow = xline(ax, x_um(measureColIdx), '--y', 'LineWidth', 1);
    hXHigh = xline(ax, x_um(measureColIdx), '--y', 'LineWidth', 1);
    hMeasureX = plot(ax, [x_um(measureColIdx), x_um(measureColIdx)], yrange, ...
                     '--', 'Color', [0, 1, 1], 'LineWidth', 1.2, ...
                     'HitTest', 'on', 'PickableParts', 'all');
    hMeasureY = plot(ax, xrange, [y_um(measureRowIdx), y_um(measureRowIdx)], ...
                     '--', 'Color', [0, 1, 1], 'LineWidth', 1.2, ...
                     'HitTest', 'on', 'PickableParts', 'all');
    hDiameterText = text(ax, xrange(1) + 0.05*diff(xrange), ...
                         yrange(2) - 0.10*diff(yrange), ...
                         '', ...
                         'Color', 'w', ...
                         'FontSize', 9, ...
                         'FontWeight', 'bold', ...
                         'Interpreter', 'tex');

    cursorData = struct( ...
        'imgDouble', imgDouble, ...
        'x_um', x_um, ...
        'y_um', y_um, ...
        'xrange', xrange, ...
        'yrange', yrange, ...
        'pixel_size_um', pixel_size_um, ...
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

    title(imageFiles(i).name, 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 10);
    xlabel('X (\mum)', 'Interpreter', 'tex');
    ylabel('Y (\mum)', 'Interpreter', 'tex');
    xlim(xrange);
    ylim(yrange);
    colorbar;

    figure(beam3dFig);
    subplot(rows, cols, i);
    surf(x_um, y_um, imgDouble, 'EdgeColor', 'none');
    shading interp;
    colormap(gca, jet);
    hold on;
    contour3(x_um, y_um, imgDouble, [threshold threshold], ...
             'y', 'LineWidth', 2.5);
    view(45, 35);
    axis tight;
    grid on;
    title(imageFiles(i).name, 'Interpreter', 'none', 'FontWeight', 'bold', 'FontSize', 10);
    xlabel('X (\mum)', 'Interpreter', 'tex');
    ylabel('Y (\mum)', 'Interpreter', 'tex');
    zlabel('Signal (a.u.)');
    colorbar;
end

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
            [~, cursorData.measureColIdx] = min(abs(cursorData.x_um - cursorX));
            cursorX = cursorData.x_um(cursorData.measureColIdx);
            set(cursorData.hMeasureX, 'XData', [cursorX, cursorX], 'YData', cursorData.yrange);

        case 'y'
            cursorY = min(max(currentPoint(1, 2), cursorData.yrange(1)), cursorData.yrange(2));
            [~, cursorData.measureRowIdx] = min(abs(cursorData.y_um - cursorY));
            cursorY = cursorData.y_um(cursorData.measureRowIdx);
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

    xZoomIdx = find(cursorData.x_um >= cursorData.xrange(1) & cursorData.x_um <= cursorData.xrange(2));
    yZoomIdx = find(cursorData.y_um >= cursorData.yrange(1) & cursorData.y_um <= cursorData.yrange(2));

    if ~isempty(xZoomIdx)
        xProfile_crop = xProfile(xZoomIdx);
        xProfile_plot = xProfile_crop - min(xProfile_crop);
        if max(xProfile_plot) > 0
            xProfile_scaled = xProfile_plot / max(xProfile_plot) * diff(cursorData.yrange) * cursorData.profileDisplayFraction;
        else
            xProfile_scaled = zeros(size(xProfile_plot));
        end
        set(cursorData.hXProfile, ...
            'XData', cursorData.x_um(xZoomIdx), ...
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
            'YData', cursorData.y_um(yZoomIdx));
    end

    [xCross, xDiameter_um] = findProfileDiameter(xProfile, cursorData.pixel_size_um);
    [yCross, yDiameter_um] = findProfileDiameter(yProfile, cursorData.pixel_size_um);

    set(cursorData.hXLow, 'Value', cursorData.x_um(xCross(1)));
    set(cursorData.hXHigh, 'Value', cursorData.x_um(xCross(end)));
    set(cursorData.hYLow, 'Value', cursorData.y_um(yCross(1)));
    set(cursorData.hYHigh, 'Value', cursorData.y_um(yCross(end)));

    if isnan(xDiameter_um)
        xDiameterText = 'X Diam: N/A';
    else
        xDiameterText = sprintf('X Diam: %.1f \\mum', xDiameter_um);
    end

    if isnan(yDiameter_um)
        yDiameterText = 'Y Diam: N/A';
    else
        yDiameterText = sprintf('Y Diam: %.1f \\mum', yDiameter_um);
    end

    diameterText = sprintf('%s\n%s', xDiameterText, yDiameterText);
    set(cursorData.hDiameterText, 'String', diameterText);
end

function [crossIdx, diameter_um] = findProfileDiameter(profile, pixel_size_um)
    profilePeak = max(profile);
    if profilePeak <= 0
        crossIdx = [1, numel(profile)];
        diameter_um = NaN;
        return;
    end

    profileThresh = profilePeak * exp(-2);
    crossIdx = find(profile >= profileThresh);
    if isempty(crossIdx)
        crossIdx = [1, numel(profile)];
        diameter_um = NaN;
        return;
    end

    diameter_um = (crossIdx(end) - crossIdx(1)) * pixel_size_um;
end

function imgData = imageToDoubleGray(imgRaw)
    imgData = im2double(imgRaw);
    if ndims(imgData) == 3
        imgData = rgb2gray(imgData);
    end
end

function corrected = subtractBackgroundIfSameSize(imgData, bgData)
    if ~isempty(bgData) && isequal(size(imgData), size(bgData))
        corrected = imgData - bgData;
        corrected(corrected < 0) = 0;
    else
        corrected = subtractLocalBackground(imgData);
    end
end

function imgSub = subtractLocalBackground(imgData)
    borderWidth = max(5, round(0.02 * min(size(imgData))));
    borderMask = false(size(imgData));
    borderMask(1:borderWidth, :) = true;
    borderMask(end-borderWidth+1:end, :) = true;
    borderMask(:, 1:borderWidth) = true;
    borderMask(:, end-borderWidth+1:end) = true;
    bgLevel = median(imgData(borderMask), "all");
    imgSub = imgData - bgLevel;
    imgSub(imgSub < 0) = 0;
end

function [roiRows, roiCols] = findBeamRoi(imgData, halfSize, searchColumnFraction)
    [numRows, numCols] = size(imgData);

    smoothData = imgaussfilt(imgData, 6);
    % CODEX MODIFICATION START: use full-frame search when requested
    if searchColumnFraction >= 1
        searchData = smoothData;
    else
        searchCols = 1:max(1, round(numCols * searchColumnFraction));
        searchData = zeros(size(smoothData));
        searchData(:, searchCols) = smoothData(:, searchCols);
    end
    % CODEX MODIFICATION END: use full-frame search when requested

    maxVal = max(searchData(:));
    if maxVal <= 0
        searchData = smoothData;
        maxVal = max(searchData(:));
    end
    if maxVal <= 0
        searchData = imgData - min(imgData(:), [], "all");
        maxVal = max(searchData(:));
    end
    if maxVal <= 0
        rowCenter = round(numRows / 2);
        colCenter = round(numCols / 2);
    else
        [~, maxIdx] = max(searchData(:));
        [rowCenter, colCenter] = ind2sub(size(searchData), maxIdx);
    end

    rowStart = max(1, floor(rowCenter - halfSize));
    rowEnd = min(numRows, ceil(rowCenter + halfSize));
    colStart = max(1, floor(colCenter - halfSize));
    colEnd = min(numCols, ceil(colCenter + halfSize));

    roiRows = rowStart:rowEnd;
    roiCols = colStart:colEnd;
end
