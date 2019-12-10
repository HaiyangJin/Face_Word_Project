function overlap_table = fw_labeloverlap(fn_labels, subjCode)


nLabel = numel(fn_labels);
if nLabel < 2
    error('The number of labels should be more than one.');
end

FS = fs_setup;
labelFolder = fullfile(FS.subjects, subjCode, 'label');

c = nchoosek(1:nLabel, 2); % combination matrix
nC = size(c, 1); % number of combinations

overlap_str = struct;
for iC = 1:nC
    
    theseLabel = fn_labels(c(iC, :));
    
    % load the two label files 
    mat_cell = cellfun(@(x) fs_readlabel(fullfile(labelFolder, x)), theseLabel, 'UniformOutput', false);
    
    % check if there is overlapping between the two labels
    mat_label1 = mat_cell{1};
    mat_label2 = mat_cell{2};
    isoverlap = ismember(mat_label1, mat_label2);
    overlapVer = mat_label1(isoverlap(:, 1));
    nOverVer = numel(overlapVer);
    
    
    overlap_str.SubjCode = {subjCode};
    overlap_str.Label = theseLabel;
    overlap_str.nOverlapVer = nOverVer;
    overlap_str.OverlapVer = {overlapVer'};
    
end

overlap_table = struct2table(overlap_str);

end