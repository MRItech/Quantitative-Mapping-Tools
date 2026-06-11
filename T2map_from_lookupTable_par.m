% Fast T2 mapping from dual or multi-echo spin-echo using a lookup Table
% Univ. of Alberta, 2024
% Author: N Naji, nashwana@ualberta.ca
% based on
% Snyder J, et al. Inline dual-echo T2 quantification in brain using a fast mapping reconstruction technique.
% NMR in Biomedicine. 2023;36(1):e4811. doi:10.1002/nbm.4811

% lookupTable: [T2, B1, echoes]
% imgVolume: echoes in the last dimension. all echoes should be normalized by the first echo
% T2_range: % range of T2 values simulated
% B1map, optional when number of echoes > 3 (set B1map=[] if not available)
% b1Range: % range of B1 values simulated

function [T2map,B1map ]= T2map_from_lookupTable_par( lookupTable, imgVolume, T2_range, B1map, b1Range )

            % is B1 provided
            if isempty(B1map)
                disp(' Fitting without B1')
                givenB1 =0;
            else
                 disp(' Fitting with B1 knowledge')
                 givenB1 =1;
            end

            N = size(imgVolume);

            T2map = zeros(N(1:3));
            % exclude out of bound voxels
            mask = ones(N(1:3));
             if givenB1
                    B1map(B1map==0)=nan;
                    mask(B1map< min(b1Range)) =0;
                    mask(B1map>max(b1Range)) =0;
                    mask(isnan(B1map)) =0;
                    mask(isinf(B1map)) =0;

             end

            mask(isnan(imgVolume(:,:,:,1))) =0;
            mask(isinf(imgVolume(:,:,:,1))) =0;
            
            % find remaining
            idx = find(mask);
            [jj,kk,ll] = ind2sub(N(1:3),idx);
            lnth = length(jj);

            % arrange image and table 
            imgVolume = permute(imgVolume, [4, 1, 2, 3]);
            lookupTable = permute(lookupTable, [3, 1, 2]); % T2 already in first dim
            N_table = size(lookupTable);
            
            if ~givenB1
                lookupTable = reshape(lookupTable, N_table(1), []);
            end

            p = gcp('nocreate');
            if isempty(p)
                p =parpool('Threads');
            end
            % loop
              parfor lk = 1:lnth
                    j = jj(lk); k = kk(lk); l = ll(lk);
                    
                    
                   if givenB1
                        % find B1 indx
                        b1ind = find(abs(b1Range - B1map(j,k,l))==min(abs(b1Range - B1map(j,k,l))));
                        b1ind = b1ind(1);
                        dv = sum(abs(imgVolume(:,j,k,l) - lookupTable(:,:,b1ind)).^2);
                   else
                         dv = sum(abs(imgVolume(:,j,k,l) - lookupTable).^2);
                   end
    
                    dv(isnan(dv)) = inf;
                    t2ind_ = find(dv==min(dv));
    
                    if givenB1
                        T2map_(lk) = T2_range(t2ind_(1));
                    else
                        
                        [t2ind, b1ind] = ind2sub(N_table(2:3),t2ind_);
                        T2map_(lk) = T2_range(t2ind(1));
                        B1map_(lk) = b1Range(b1ind(1));
                    end
              end
             
        T2map(idx) =T2map_;
        if ~givenB1
            B1map(idx) = B1map_;
        end

end