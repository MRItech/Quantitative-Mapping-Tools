%% Example for T2 mapping from dual or multi-echo spin-echo using a Lookup Table   
% Univ. of Alberta, 2024
% Author: N Naji, nashwana@ualberta.ca
clear

is_dual_echo = false;

%% load lookup table,


tbl = load ('folder\lookuptable.mat');

B1_range = tbl.param.B1_range; % range of B1 values simulated
T2_range = tbl.param.T2_range; % range of T2 values simulated

% Form the magnitude singal from Mx and My
lookupTable_ = squeeze(abs( tbl.Sx_ + 1j*tbl.Sy_ )); 

% re-arrange dimensions such as [T2, B1, echoes]
lookupTable_ = permute(lookupTable_,[2 1 3]);

%% load image volume

% assuming nifti file
input_path = 'inputFolder\MESE';

n = 20; % number of echoes
for i = 1:n
    file_name = [input_path,'_e',num2str(i),'.nii.gz'];
    info_ = niftiinfo(file_name);
    magnitude(:,:,:,i) = info_.MultiplicativeScaling*single(niftiread(file_name)) + info_.AdditiveOffset;
end

% select echoes to be fitted
echonum = 1:20; % or size(magnitude,4);  i.e., if using all echoes
% if dual echo, set echonum to be the used echoes. e.g. echonum = [1 , 5]
if ~is_dual_echo
    imgVolume = magnitude(:,:,:,echonum);   % echoes to be fitted
else
    imgVolume = magnitude;
end

% load B1
B1map = []; % if not available

B1map = single(niftiread('inputFolder\B1_registered_to_MESE.nii.gz'));

% make sure to normalize B1map such that prescribed flip angle correspond to 1

%% select relevant echoes from the table and normalize by 1st echo

lookupTable =  (lookupTable_(:,:,echonum(2:end)) ./ lookupTable_(:,:,echonum(1)));

% normalize imgVolume by 1st echo
if is_dual_echo
    imgVolume = (imgVolume(:,:,:,2) ./ imgVolume(:,:,:,1));
else
    imgVolume = (imgVolume(:,:,:,echonum(2:end)) ./ imgVolume(:,:,:,echonum(1)));
end

 %% run fitting

 t= tic;
 [T2map,B1map ]= T2map_from_lookupTable_par( lookupTable, imgVolume, T2_range, B1map, B1_range );
 
 toc(t)

 T2map (isnan(T2map)) = 0; % remove nan
 T2map(isinf(T2map))=0; % remove inf

%%  save the map
results_path = ['Results\'];
if ~exist(results_path,'dir')
    mkdir(results_path)
end

info_.Datatype = 'single';
info_.MultiplicativeScaling = 1;
info_.AdditiveOffset = 0;

ext ='';
if isempty(B1map)
    ext = '_withoutB1';
end

niftiwrite(single(T2map),[results_path,'T2map',ext],info_,"Compressed",true)
