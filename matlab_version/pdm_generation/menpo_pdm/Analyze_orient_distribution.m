clear
load('menpo_68_pts.mat');
addpath('../PDM_helpers');

xs = all_pts(1:end/2,:);
ys = all_pts(end/2+1:end,:);
num_imgs = size(xs, 1);

rots = zeros(3, num_imgs);
errs = zeros(1,num_imgs);

% pdmLoc = ['../../models/pdm/pdm_68_aligned_wild.mat'];
pdmLoc = ['pdm_68_aligned_menpo_v3.mat'];

load(pdmLoc);

pdm = struct;
pdm.M = double(M);
pdm.E = double(E);
pdm.V = double(V);
errs_poss = [];
for i=1:num_imgs
    
    labels_curr = cat(2, xs(i,:)', ys(i,:)');
    labels_curr(labels_curr==-1) = 0;

    [ a, R, T, ~, l_params, err, shapeOrtho] = fit_PDM_ortho_proj_to_2D(pdm.M, pdm.E, pdm.V, labels_curr);
    errs(i) = err/a;
    rots(:,i) = Rot2Euler(R);
    
    if(errs(i) < 0 || errs(i) > 4)
       fprintf('i - %d, err - %.3f\n', i, errs(i));
       errs_poss = cat(1, errs_poss, i);
    end       
end

% Current error is 2.1728 on the training data
% After cleanup and smaller steps it is 1.5388
% After training on it we have 1.1999
% V2 - 1.1392
% V3 - 1.1406