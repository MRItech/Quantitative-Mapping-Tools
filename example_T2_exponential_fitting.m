%% T2 mapping using Exponential fitting 
% Univ. of Alberta, 2024
% Author: N Naji, nashwana@ualberta.ca
clear

%% settings

opt.R2sMapping.useGPU = 1;
opt.R2sMapping.Recon = 1;              % activate calculating T2 map 
opt.R2sMapping.Update = 1;             % re-produce T2 map if already exists
opt.R2sMapping.use_mask = 0; 
opt.R2sMapping.field_correct = 0;
opt.R2sMapping.gauss_smoth =0;
opt.R2sMapping.truncate_threshold =0;
opt.R2sMapping.refine_nl = 0;
opt.R2sMapping.verbose = 1;

%% load magnitude, TEs_sec, voxel_size_mm, SliceThickness_mm

% assuming nifti file
input_path = 'inputFolder\MESE';

n = 20; % number of echoes
for i = 1:n
    file_name = [input_path,'_e',num2str(i),'.nii.gz'];
    info_ = niftiinfo(file_name);
    magnitude(:,:,:,i) = info_.MultiplicativeScaling*single(niftiread(file_name)) + info_.AdditiveOffset;
end

% read TEs from json files

% select echoes to be fitted
TE_sel = 1:size(magnitude,4);            % i.e., all echoes

Raw.mag = magnitude(:,:,:,TE_sel);   
Raw.ph = zeros(size(Raw.mag));           % phase info is not required, set zero array
Raw.vox = single(info_.PixelDimensions); % in mm, e.g. [ 1, 1, 1]
Raw.SliceThickness = Raw.vox(3);
Raw.TE = TEs(TE_sel);                    % in seconds

 %% run fitting
[R2, S0, residual] = f_R2s_mapping(Raw, opt.R2sMapping,[]);

 T2map = 1./R2;
 T2map (isnan(T2map)) = 0;
 T2map(isinf(T2map))=0;

%%  save the map
results_path = ['Results\'];
if ~exist(results_path,'dir')
    mkdir(results_path)
end

info_.Datatype = 'single';
info_.MultiplicativeScaling = 1;
info_.AdditiveOffset = 0;

niftiwrite(single(T2map),[results_path,'T2map_expFit'],info_,"Compressed",true)