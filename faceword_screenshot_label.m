clear all

boldname = 'self';
path_output = '~/Desktop/Label_Screenshots';

FS = fs_setup;
subjBoldPath = fullfile(FS.subjects, '..', 'Data_fMRI');
subjBoldDir = dir(fullfile(subjBoldPath, ['*' boldname]));
nSubj = numel(subjBoldDir);

%% visualize every label separately
labelNames = { % ...
    'roi.lh.f13.o-vs-scr.label'...
    'roi.rh.f13.o-vs-scr.label'...
    'roi.lh.f13.f-vs-o.ffa1.label'...
    'roi.lh.f20.f-vs-o.ffa1.label'...
    'roi.lh.f13.f-vs-o.ffa2.label'...
    'roi.lh.f13.w-vs-o.label'...
    'roi.lh.f13.f-vs-o.label'...
    'roi.lh.f20.f-vs-o.label'...
    'roi.lh.f40.f-vs-o.label'...
    'roi.rh.f13.f-vs-o.ffa1.label' ...
    'roi.rh.f13.f-vs-o.ffa2.label'...
    'roi.rh.f20.f-vs-o.ffa2.label'...
    'roi.rh.f40.f-vs-o.ffa2.label'...
    'roi.rh.f13.f-vs-o.label'...
    'roi.rh.f20.f-vs-o.label'...
    'roi.rh.f40.f-vs-o.label'
    };
nLabels = numel(labelNames);

f_single = waitbar(0, 'Generating screenshots for every label...');

for iLabel = 1:nLabels
    
    thisLabel = labelNames{iLabel};
    hemi = fs_hemi(thisLabel);
    
    conStrPosition = strfind(thisLabel, '.');
    theContrast = thisLabel(conStrPosition(3)+1:conStrPosition(4)-1);
    
    for iSubj = 1:nSubj
        
        thisSubj = subjBoldDir(iSubj).name;
        subjCode = fw_subjcode(thisSubj);
        
        analysis = sprintf('loc_%s.%s', boldname, hemi);
        file_overlay = fullfile(subjBoldPath, thisSubj, 'bold', analysis, theContrast, 'sig.nii.gz');
        
        if ~exist(file_overlay, 'file')
            continue
        end
            
        fs_screenshot_label(subjCode, thisLabel, path_output, file_overlay);
       
        % waitbar
        wait_per = ((iLabel-1) * nSubj + iSubj) / (nLabels * nSubj);
        waitbar(wait_per, f_single);
        
    end
    
end

close(f_single);


%% visualize multiple labels at the same time
% fn_multilabels = {'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.label';
%     'roi.lh.f13.w-vs-o.label', 'roi.lh.f20.f-vs-o.label';
%     'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa1.label';
%     'roi.lh.f13.w-vs-o.label', 'roi.lh.f13.f-vs-o.ffa2.label'};
% 
% nMultilabels = size(fn_multilabels, 1);
% 
% f_multi = waitbar(0, 'Generating screenshots for multitple labels...');
% 
% overlap = table;
% for iLabel = 1:nMultilabels
%     
%     theseLabel = fn_multilabels(iLabel, :);
%     [hemi, nHemi] = fs_hemi_multi(theseLabel);
%     
%     % move to next loop if the labels are not for the same hemisphere
%     if nHemi ~= 1
%         continue;
%     end
%     
%     for iSubj = 1:nSubj
%         
%         thisSubj = subjBoldDir(iSubj).name;
%         subjCode = fw_subjcode(thisSubj);
%         
%         % Generate the screenshots
%         isok = fs_screenshot_label(subjCode, theseLabel, path_output);
%         
%         if isok
%             % get info about the two labels (their overlaps)
%             overlap_table = fw_labeloverlap(theseLabel, subjCode);
%             overlap = [overlap; overlap_table]; %#ok<AGROW>
%         end
%         
%         % waitbar
%         wait_per = ((iLabel-1) * nSubj + iSubj) / (nMultilabels * nSubj);
%         waitbar(wait_per, f_multi);
%         
%     end
% end
% 
% close(f_multi);
% fn_overlap = fullfile(path_output, 'overlap.csv');
% writetable(overlap, fn_overlap);
% 


