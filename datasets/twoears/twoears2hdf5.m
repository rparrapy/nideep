function [] = twoears2hdf5(fpath, dir_dst)
% remove rows with zero entries in ground truth
load(fpath, 'x', 'y', 'featureNames', 'classnames');

dir_src = fileparts(fpath);
[~, phase] = fileparts(dir_src); % test or train from directory name
assert( strcmp(phase, 'test') | strcmp(phase, 'train'), 'Unable to determine phase (test vs. train).' );

[nozero, ~] = find( all( y~=0, 2 ) );
x2 = x( nozero, : );
y2 = y( nozero, : );
% exclude column for general class
y2( y2==-1 ) = 0;
general_col = find( strcmp( classnames, 'general' ) );
y2(:, general_col) = [];

% random shuffle
o = randperm( length( y2 ) );
x2 = x2( o, : );
y2 = y2( o, : );

[x_feat, feature_type_names, y, y_1hot] = twoears2Blob(x2, featureNames, y2);

for ii = 1 : numel(feature_type_names)
    % save formatted features to file
    fname = sprintf('feat_%s_%s.h5', feature_type_names{ii}, phase);
    hdf5write( fullfile(dir_dst, fname), strcat('/', feature_type_names{ii}), x_feat{ii});
    
    % write hdf5 list files for features
    file_id = fopen( fullfile(dir_dst, sprintf('feat_%s_%s.txt', feature_type_names{ii}, phase) ),'w');
    fprintf(file_id, fullfile(dir_dst, sprintf('feat_%s_%s.h5\n', feature_type_names{ii}, phase) ) );
    fclose(file_id);
end

% save ground truth to file(s)
hdf5write( fullfile(dir_dst, sprintf('labels_%s.h5', phase) ), '/label', y );
hdf5write( fullfile(dir_dst, sprintf('labels_1hot_%s.h5', phase) ), '/label', y_1hot );

% write hdf5 list files (.txt)
file_id = fopen( fullfile(dir_dst, sprintf('labels_%s.txt', phase) ),'w');
fprintf(file_id, fullfile(dir_dst, sprintf('labels_%s.h5\n', phase) ) );
fclose(file_id);
file_id = fopen( fullfile(dir_dst, sprintf('labels_1hot_%s.txt', phase) ),'w');
fprintf(file_id, fullfile(dir_dst, sprintf('labels_1hot_%s.h5', phase) ) );
fclose(file_id);