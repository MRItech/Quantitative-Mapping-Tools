%% R2* processing pipeline
% Univ. of Alberta, 2024
% Author: N Naji, nashwana@ualberta.ca
% if used, please cite: Naji N, Snyder J, Seres P, Beaulieu C, Wilman A. 
% Repeatability of susceptibility separation methods in brain at 3 T. In Proceedings of the 32nd Annual Meeting of ISMRM, Singapore, Singapore 2024 (p. 2620).

% commented settings are optional

% opt.use_GPU_if_available = 1;      % Accelerate processing using available GPU
opt.useGPU = 1;

opt.save_path = ['/R2s/'];
%% R2* options
opt.R2sMapping.Recon = 1;              % activate calculating R2* map 
opt.R2sMapping.Update = 1;             % re-produce R2* map if already exists
opt.R2sMapping.use_mask = 1;           % calculate R2* within brain mask only

opt.R2sMapping.field_correct = 1;     % correct for B0 inhomogenities using phase info
opt.R2sMapping.gauss_smoth =1;         % smooth B0 map before correction
opt.R2sMapping.act_vox = [0.625 ,0.625 ,2];     % set the actual voxel size if scanner interpolation was used

opt.R2sMapping.truncate_threshold =0;  % exclude time points of low SNR, set a threshold value or 'auto' or 0 to disable

opt.R2sMapping.refine_nl = 0;          % recalculate regions of less reliability  using slow nonlinear fit

opt.R2sMapping.verbose = 1;                   % 0: silent, 1: basic, 2: detailed


%% load magnitude, phase, TEs_sec, voxel_size_mm, SliceThickness_mm
% Raw.mag = magnitude;
% Raw.ph = phase;
% Raw.vox = voxel_size_mm;
% Raw.TE = TEs_sec;
% Raw.SliceThickness = SliceThickness_mm;

%% quick mask, if not available
mx_proj = max(Raw.mag,[],4);
max_val = max(mx_proj,[],"all");

threshold = 0.02; % precentage

mask = mx_proj >threshold*max_val;
%% ====== R2* Mapping =====
if opt.R2sMapping.field_correct, r2s_txt = '_corrected'; else r2s_txt = ''; end
r2a_fn = [opt.save_path, 'R2s_map',r2s_txt,'.nii.gz'];

if opt.R2sMapping.Recon
     if (opt.R2sMapping.Update || ~exist(r2a_fn,'file'))
        
    
        disp(['R2* mapping ...'])
        opt.R2sMapping.useGPU = opt.useGPU;
        if opt.R2sMapping.use_mask, R2smask = mask; else,  R2smask =[]; end
        [Results.R2s, ~, ~] = f_R2s_mapping(Raw, opt.R2sMapping,R2smask);

        % save Results.R2s
     end

end