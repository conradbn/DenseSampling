function [raw_data_files] = DS_get_filenames(subj,year,process_dir)
%% Select image filenames for DDK2 fMRI process
% Go to subjects raw (NIFTI) data directory
raw_dir = strrep(process_dir,'Processed_Data','Subject_Data');
raw_dir = dir([raw_dir '/' subj '/' year '/mri/Price_*']);
if numel(raw_dir) ~= 0
    cd([raw_dir.folder '/' raw_dir.name '/NIFTI'])
else
    disp('WARNING - Subject folder is not set up as expected!')
    cd(strrep(process_dir,'Processed_Data','Subject_Data'))
end
    
% T1-w Anatomical MPRAGE
menu('Select a single MPRAGE file (i.e. the best if multiple were collected)','OK');
[file,path] = uigetfile('*MPRAGE*.nii','MultiSelect', 'off');
if ~iscell(file)
    file = {file};
end
if isequal(file,0)
   disp('User selected Cancel');
else
   disp(['User selected the following MPRAGE file: ', fullfile(path,file{1})]);
end
raw_data_files.anat_fname = file;
raw_data_files.anat_path = path;

% Reverse phase encode fMRI ("APA")
menu('Select fMRI APA files to be processed','OK');
[file,path] = uigetfile('*APA*.nii','MultiSelect', 'on');
if ~iscell(file)
    file = {file};
end
if isequal(file,0)
   disp('User selected Cancel');
else
   for ii = 1:numel(file)
       disp(['User selected the following APA file: ', fullfile(path,file{ii})]);
   end
end
raw_data_files.apa_fname = file;
raw_data_files.apa_path = path;

%% fMRI
menu('Select fMRI files (i.e. runs) to be processed','OK');
[file,path] = uigetfile('*fMRI_IaN*.nii','MultiSelect', 'on');
if ~iscell(file)
    file = {file};
end
if isequal(file,0)
   disp('User selected Cancel');
else
   for ii = 1:numel(file)
       disp(['User selected the following fMRI file: ', fullfile(path,file{ii})]);
   end
end
raw_data_files.func_fname = file;
raw_data_files.func_path = path;

% Check for partial runs, and convert using dicm2nii.
% The nii data as converted from gstudy is incorrect for partial runs (i.e.
% all acquired volumes are stacked in 3D matrix, instead of 4D series)
for ii = 1:numel(raw_data_files.func_fname)
    fname = raw_data_files.func_fname{ii};
    info = niftiinfo(fname);
    if size(info.PixelDimensions,2) ~= 4
        % Get string to reduce possible data to this run
        run = regexp(fname,'fMRI_\d','match','once');
        % id = regexp(fname,'\d\d\d\d\d\d.\d\d','match','once'); This
        % doesn't work when scanID has _2 appended!
        id = regexp(fname,'\d\d\d\d\d\d','match','once');
        id = strrep(id,'.','_');
        menu(['WARNING: The following is a partial run! ' fname newline...
              'Please go to the XMLPARREC folder and select the associated .PAR file' newline...
              '(this run requires an alternative NIfTI conversion)'],'OK');
        [file,path] = uigetfile(['*' id '*' run '*.PAR'],'MultiSelect', 'off');
        if isequal(file,0)
            disp('User selected Cancel');
        else
            disp(['User selected the following fMRI (PAR) file: ', fullfile(path,file)]);
        end
        % Convert file using dicm2nii
        dicm2nii([path file],raw_data_files.func_path,'.nii');
        new_nii = load('dcmHeaders.mat');
        new_nii = fieldnames(new_nii.h);
        % Rename new file
        unix(['mv ' new_nii{1} '.nii ' fname(1:end-4) '_dicm2nii.nii']);
        unix(['cp ' fname(1:end-4) '.json ' fname(1:end-4) '_dicm2nii.json']);
        % Remove extra files from conversion
        unix(['rm -f dcmHeaders.mat ' new_nii{1} '.json']);
        % Replace filename with newly converted filename
        raw_data_files.func_fname{ii} = [fname(1:end-4) '_dicm2nii.nii'];
    end

end

%% PsychoPy file
if numel(raw_dir) ~= 0
    try
        cd([raw_dir.folder '/psychopy/IsItANumber_scan/data_summary']);
    catch
        cd([raw_dir.folder '/psychopy/IsItaNumber_scan/data_summary']);
    end
else
    cd(strrep(process_dir,'Processed_Data','Subject_Data'));
end
menu('Select PsychoPy files to be processed','OK');
[file,path] = uigetfile('*IsItANumber_*\d*.csv','MultiSelect', 'on');
if ~iscell(file)
    file = {file};
end
if isequal(file,0)
   disp('User selected Cancel');
else
   for ii = 1:numel(file)
       disp(['User selected the following PsychoPy file: ', fullfile(path,file{ii})]);
   end
end
raw_data_files.psypy_fname = file;
raw_data_files.psypy_path = path;

%% Get order of Psychopy files from user
raw_data_files.psypy_order = str2double(inputdlg(raw_data_files.psypy_fname,'Run# as acquired'));
if ~all(ismember(1:numel(raw_data_files.psypy_fname),raw_data_files.psypy_order))
    error('The "Run# as acquired" values were specified incorrectly (they did not match the total number of PsychoPy files)');
end
