function [meanError, all_rot_preds, all_rot_gts, meanErrors, all_errors, rels_all, seq_ids] = calcBiwiError(resDir, gtDir)

seqNames = {'01','02','03','04','05','06','07','08','09', ...
    '10', '11','12','13','14','15','16','17','18','19', ...
    '20', '21','22','23','24'};

rotMeanErr = zeros(numel(seqNames),3);
rotRMS = zeros(numel(seqNames),3);
rot = cell(1,numel(seqNames));
rotg = cell(1,numel(seqNames));
rels_all = [];

seq_ids = {};

for i=1:numel(seqNames)
        
    posesGround =  load ([gtDir '/' seqNames{i} '/groundTruthPose.txt']);
   
    [frame t, rels, sc tx ty tz rx ry rz] = textread([resDir '/' seqNames{i} '.csv'], '%f, %f, %f, %f, %f, %f, %f, %f, %f, %f', 'headerlines', 1);
   
    % the reliabilities of head pose
    rels_all = cat(1, rels_all, rels);    
    
    rotg{i} = posesGround(:,[5 6 7]);
    rot{i} = [rx ry rz];  

    % Correct the first frame so it corresponds to (0,0,0), as slightly
    % different pose might be assumed frontal and this corrects for
    % that
    
    % Work out the correction matrix for ground truth
    rot_corr_gt = Euler2Rot(rotg{i}(1,:));
    for r_e = 1:size(rotg{i},1)
        rot_curr_gt = Euler2Rot(rotg{i}(r_e,:));
        rot_new_gt = rot_corr_gt' * rot_curr_gt;
        rotg{i}(r_e,:) = Rot2Euler(rot_new_gt);
    end
    
    % Work out the correction matrix for estimates
    rot_corr_est = Euler2Rot(rot{i}(1,:));
    for r_e = 1:size(rot{i},1)
        rot_curr_est = Euler2Rot(rot{i}(r_e,:));
        rot_new_est = rot_corr_est' * rot_curr_est;
        rot{i}(r_e,:) = Rot2Euler(rot_new_est);
    end
    
    rotg{i} = rotg{i} * 180 / pi;
    rot{i} = rot{i} * 180 / pi;  

    
    rotMeanErr(i,:) = mean(abs((rot{i}(:,:)-rotg{i}(:,:))));
    rotRMS(i,:) = sqrt(mean(((rot{i}(:,:)-rotg{i}(:,:))).^2)); 
    
    seq_ids = cat(1, seq_ids, repmat(seqNames(i), size(rot{i},1), 1));
    
end
%%
meanErrors = rotMeanErr;
allRot = cell2mat(rot');
allRotg = cell2mat(rotg');
meanError = mean(abs((allRot(:,:)-allRotg(:,:))));

all_errors = abs(allRot-allRotg);

rmsError = sqrt(mean(((allRot(:,:)-allRotg(:,:))).^2)); 
errorVariance = std(abs((allRot(:,:)-allRotg(:,:))));

all_rot_preds = allRot;
all_rot_gts = allRotg;