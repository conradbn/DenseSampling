function [orig_dir,proc_dir,onsets_dir,raw_data_files] = DDK2_process_folder_setup(process_dir,subj,year,raw_data_files)
%% Create the DDK2 subject processing directory and copy raw data there
r = raw_data_files;

% Make new directories
orig_dir = [process_dir '/' subj '/' year '/orig'];
mkdir(orig_dir);

proc_dir = [process_dir '/' subj '/' year '/proc'];
mkdir(proc_dir);

onsets_dir = [proc_dir '/onsets'];
mkdir(onsets_dir)

%% Copy files
disp(['*** Copying data to ' orig_dir ' ***']);

%% Eprime tab-delimited file(s) 
for ii = 1:numel(r.psypy_fname)
    file = [r.psypy_path r.psypy_fname{ii}];
    unix(['rsync "' file '" ' orig_dir]);
    disp(['** PsychoPy file #' num2str(ii) ' done **']);
end

% Rename psychopy files to indicate the specified acquisition order 
for ii = 1:numel(r.psypy_fname)
    n1 = [orig_dir '/' r.psypy_fname{ii}];
    ind = r.psypy_order(ii);
    n2 = [orig_dir '/s' num2str(ind,'%02.f') '_' r.psypy_fname{ii}];
    unix(['mv ' n1 ' ' n2]);
end 
% Get new Psychopy filenames
r.psypy_fname_orig = r.psypy_fname;
p = dir([orig_dir '/s*.csv']);
r.psypy_fname = cellstr(char(p.name))';
raw_data_files = r;

%% Anatomical file (plus JSON file)
file = [r.anat_path r.anat_fname{1}];
% if size(file,1) > 1
%     disp(['**** WARNING, multiple ' anat_fname ' files exist, using the first one found']);
%     file = file(1,:);
% end
unix(['rsync "' file '" ' orig_dir]);
unix(['rsync "' file(1:end-4) '.json" ' orig_dir]);
disp('** Anat done **');

%% APA (reverse phase encoded EPI images) file (plus JSON file)
for ii = 1:numel(r.apa_fname)
    if ~isequal(r.apa_fname,'')
        file = [r.apa_path '/' r.apa_fname{ii}];
    %     if size(file,1) > 1
    %         disp(['**** WARNING, multiple ' apa_fname ' files exist, using the first one found']);
    %         file = file(1,:);
    %     end
        unix(['rsync "' file '" ' orig_dir]);
        unix(['rsync "' file(1:end-4) '.json" ' orig_dir]);
    else
        disp('**** WARNING - No APA specified (reverse phase encoded EPI volume) !!! ****');
    end
    disp(['** APA file #' num2str(ii) ' done **']);
end

%% Functional data file(s) (plus JSON files)
for ii = 1:numel(r.func_fname)
    file = [r.func_path r.func_fname{ii}];
    unix(['rsync "' file '" ' orig_dir]);
    unix(['rsync "' file(1:end-4) '.json" ' orig_dir]);
    disp(['** Functional #' num2str(ii) ' done **']);
end

disp('**** Folder setup and data copying complete! ****')

%% Gzip files to reduce space
files = subdir([orig_dir,'/*.nii']);
for ii = 1:numel(files)
    disp(['Compressing ' num2str(ii) ' of ' num2str(numel(files)) ' nifti files to save space...']);
    unix(['pigz -f ' files(ii).name]); % Force overwrite
end

cd(orig_dir)