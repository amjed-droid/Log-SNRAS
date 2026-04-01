%% Script to extract empirical statistics for Table 2
clc
clear

% Note: The 'TESS' directory contains both Kepler and TESS data. 
% It is simply a local folder name and does not exclude Kepler light curves.
dataDir = 'C:\Users\intel\Downloads\kepler\TESS'; 
fileList = dir(fullfile(dataDir, '*.fits')); 
nFiles = length(fileList);

all_labels = zeros(nFiles, 1);
all_psis = zeros(nFiles, 1);
all_penalties = zeros(nFiles, 1);

tic_count = 0; % Dedicated counter to calculate the percentage of host star TIC 261136679

fprintf('Scanning data to extract table statistics...\n');

for i = 1:nFiles
    filePath = fullfile(dataDir, fileList(i).name);
    try
        data = fitsread(filePath, 'binarytable', 1);
        if size(data, 2) >= 7
            f = data{7}; 
        else
            f = data{1}; 
        end
        
        f = fillmissing(f, 'linear');
        f(isnan(f)) = mean(f, 'omitnan');
        
        s_trad = (max(f) - min(f)) / (std(f, 'omitnan') + eps);
        m = f < (mean(f, 'omitnan') - 1.5 * std(f, 'omitnan')); 
        
        % Extract dispersion contrast (psi) and penalty score using the Log-SNRAS function
        [~, all_penalties(i), all_psis(i)] = calculate_log_snras(f, s_trad, m);
        
        name = lower(fileList(i).name);
        if contains(name, 'planet') || contains(name, 'confirmed') || ...
           contains(name, '261136679') || contains(name, '1625')
       
            all_labels(i) = 1; % Confirmed Planet
            if contains(name, '261136679')
                tic_count = tic_count + 1; % Increment specific host star counter
            end
        else
            all_labels(i) = 0; % Heteroscedastic Artifact (Noise)
        end
    catch
        continue;
    end
end

% --- Statistical Calculations for Table 2 ---
idx_planets = (all_labels == 1);
idx_artifacts = (all_labels == 0);

num_planets = sum(idx_planets);
num_artifacts = sum(idx_artifacts);
tic_percentage = round((tic_count / num_planets) * 100);

% Calculate the Median values
med_psi_planets = median(all_psis(idx_planets));
med_pen_planets = median(all_penalties(idx_planets));

med_psi_artifacts = median(all_psis(idx_artifacts));
med_pen_artifacts = median(all_penalties(idx_artifacts));

% --- Print results ready to be copied into LaTeX ---
fprintf('Confirmed Planets: N = %d | Median Psi = %.3f | Median Penalty = %.3f\n', ...
        num_planets, med_psi_planets, med_pen_planets);
fprintf('Heteroscedastic Artifacts: N = %d | Median Psi = %.3f | Median Penalty = %.3f\n', ...
        num_artifacts, med_psi_artifacts, med_pen_artifacts);
fprintf('Note: %d%% of the Confirmed segments originate from TIC 261136679.\n', tic_percentage);
fprintf('=========================================================\n');
