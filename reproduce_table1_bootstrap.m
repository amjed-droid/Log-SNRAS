% =========================================================================
% Script for Table 1: Bootstrap AUC and Confidence Intervals
% Written by: Ahmed S. Jabbar
% Note: Runs B=2000 iterations to get the 95% CI (as requested by Reviewer 1)
% =========================================================================
clear; clc; close all;

disp('Loading dataset...');
% Make sure 'Supplementary_Table_C4.csv' is in the same folder!
data = readtable('Supplementary_Table_C4.csv');

% Fix column names if there are spaces
data.Properties.VariableNames = strtrim(data.Properties.VariableNames);

% 1. Create Ground Truth Labels
% 1 = Confirmed Planet, 0 = Artifact
n_rows = height(data);
y_true = nan(n_rows, 1);

for i = 1:n_rows
    f_name = upper(data.Filename{i});
    
    % Check for planets
    if contains(f_name, '261136679') || contains(f_name, 'TOI_201') || ...
       contains(f_name, 'KEPLER_1625') || contains(f_name, 'TESS_S')
        y_true(i) = 1; 
        
    % Check for noise/artifacts
    elseif contains(f_name, '12644769') || contains(f_name, '5812701') || ...
           contains(f_name, 'V723_MON') || contains(f_name, 'TIC14444029')
        y_true(i) = 0; 
    end
end

% Remove rows where we couldn't define a label
valid_idx = ~isnan(y_true);
y_true_clean = y_true(valid_idx);
data_clean = data(valid_idx, :);

% 2. Setup Bootstrap Parameters
score_columns = {'T_SNR', 'R_SNR', 'L_SNRAS'}; 
metric_names = {'Traditional SNR', 'Robust SNR', 'Log-SNRAS (Ours)'};

B = 2000; % Number of iterations
disp(['Starting Stratified Bootstrap with B = ', num2str(B)]);
disp('--------------------------------------------------');

% Find indices for planets and artifacts for stratified sampling
pos_idx = find(y_true_clean == 1);
neg_idx = find(y_true_clean == 0);

% Set fixed seed for reproducibility (Crucial for the review!)
rng(42); 

% 3. Calculate AUC and 95% CI for each metric
for k = 1:length(score_columns)
    
    current_col = score_columns{k};
    scores = data_clean.(current_col);
    scores(isnan(scores)) = 0; % Replace any missing scores with 0
    
    % Multiply by -1 because lower penalty is better for Log-SNRAS
    scores_to_test = -scores; 
    
    auc_results = zeros(B, 1);
    
    % Run the bootstrap loop
    for b = 1:B
        % Sample with replacement (Stratified)
        sample_pos = datasample(pos_idx, length(pos_idx));
        sample_neg = datasample(neg_idx, length(neg_idx));
        boot_idx = [sample_pos; sample_neg];
        
        % Calculate AUC
        [~, ~, ~, auc_results(b)] = perfcurve(y_true_clean(boot_idx), scores_to_test(boot_idx), 1);
    end
    
    % Get Mean and Confidence Intervals
    final_mean_auc = mean(auc_results);
    ci_95 = prctile(auc_results, [2.5, 97.5]);
    
    % Print results for Table 1
    fprintf('%s:\n', metric_names{k});
    fprintf('Mean AUC = %.3f | 95%% CI = [%.3f, %.3f]\n\n', final_mean_auc, ci_95(1), ci_95(2));
end

disp('Done! Please copy these values to Table 1 in the manuscript.');
