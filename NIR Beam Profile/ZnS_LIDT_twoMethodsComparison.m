clc; clear; close all;

% baseFolder = "C:\Users\Faculty\OneDrive - The City University of New York\Tasks\BNL2026\LIDT2026\NIR Beam Profile\08_03_26";
baseFolder = 'D:\OneDrive - The City University of New York\Tasks\BNL2026\LIDT2026\NIR Beam Profile\08_03_26';

folderPath = fullfile(baseFolder, "beamprofile");
bgPath = fullfile(baseFolder, "Background_Image__2026-08-03__10-42-05.png");
bg = double(imread(bgPath));


imageFiles = dir(fullfile(folderPath, "*.png"));

for i = 1:length(imageFiles)
    imagePath = fullfile(imageFiles(i).folder, imageFiles(i).name);


% img = im2double(imread(imagePath));
img = double(imread(imagePath));
if ndims(img) == 3
    img = rgb2gray(img);
end

S = img-bg;
S(S<0) = 0;

pixel_size_um = 5.86;
S_max = max(S(:));
S_total = sum(S(:));
E_pulse = 80; %uJ

S_selected = S(S > 0.05*S_max); % Eliminating the lower 5%, to account for dark noise.
S_total = sum(S_selected);

F = (E_pulse * S_max) / (S_total * pixel_size_um^2);  % uJ/um^2
F_J_cm2 = 100 * F; % J/cm^2


fprintf("%s\n", imageFiles(i).name);
fprintf("S_max = %.6g\n", S_max);
fprintf("S_total = %.6g\n", S_total);
fprintf("F = %.6g J/cm^2\n\n", F_J_cm2);


%%
r_a = 149.45; %um
r_b = 216.8; %um

F_ave = (2 * E_pulse) / (pi * r_a^2);  % uJ/um^2
F_ave_J_cm2 = 100 * F_ave % J/cm^2


end

r_a = 162.1; %um
r_b = 152.4; %um
E_pulse = 20; %uJ

F_ave = (2 * E_pulse) / (pi * r_a^2);  % uJ/um^2
F_ave_J_cm2 = 100 * F_ave % J/cm^2
