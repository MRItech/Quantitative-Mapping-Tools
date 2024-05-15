
% Non-linear R2* mapping accelerated with GPU
% Univ. of Alberta, 2024
% Author: N Naji, nashwana@ualberta.ca

% Provides similar accuracy to non linear fitting, except in voxels with
% multiple points within noise floor. Those voxels are typically on the
% edge of the volume.

% optional settings:
% opt.init = 'zero','LL','arlo' Initial estimate, def: 'zero', best: 'arlo'
% opt.refine_nl =1;             Re-estimate less reliable voxels using standard slow
%                               non-linear fitting. 
% opt.field_correct = 1;       Apply linear field correction with/without 
%                               first smoothing the field map (set opt.gauss_smoth)
% opt.act_vox = [1 1 2]         to set the actual voxel size before prior
% to interpolation

% opt.truncate_threshold =      Exclude less reliable points from voxel fit,
% set truncate threshold manually, or automatically using 'auto'     
