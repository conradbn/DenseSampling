function [conditions,exemplars] = DDK2_onset_file_creation(subj,year,orig_dir,onsets_dir,raw_data_files)
%% Create the onset files for use in AFNI
cd(orig_dir)
%% First check that the number of PsychoPy files matches the number of imaging files
r = raw_data_files;
if numel(r.psypy_fname) ~= numel(r.func_fname)
    error('The selected number of fMRI run files does not match the selected number of PsychoPy files - Cannot proceed!');
end

%% First check that timestamps match between specified image files <-> PsychoPy files
for ii = 1:numel(r.func_fname)
    % Acquisition time for functional run
    img_t = [r.func_fname{ii}(1:end-4) '.json'];
    img_t = jsondecode(fileread(img_t));
    img_t = img_t.AcquisitionTime;
    % Start of PsychoPy experiment 
    t = readtable(r.psypy_fname{ii},'PreserveVariableNames',true);
    exp_t = t.date{1}(end-3:end);
    % Convert to date time
    img_t = datetime(img_t,'InputFormat','HH:mm:ss.SSSSSS');
    exp_t = datetime(exp_t,'InputFormat','HHmm');
    % Check that functional data was acquired after experiment file began
    if exp_t > img_t && exp_t - img_t > minutes(5)
        error(['Specified imaging run #' num2str(ii) ' was started before associated PsychoPy experiment - Cannot proceed']);
    elseif exp_t > img_t
        disp(['* WARNING * Check laptop time = real time! '...
              'Specified imaging run #' num2str(ii) ' was started before associated PsychoPy experiment, but within 5 minutes of each other']); 
          pause(4);
        disp(['* PsychoPy run #' num2str(ii) ' experiment file initiated at ' datestr(exp_t,'HH:MM')]);
        disp(['* fMRI run #' num2str(ii) ' acquisition initiated at         ' datestr(img_t,'HH:MM:SS')]);
    else
        disp(['* PsychoPy run #' num2str(ii) ' experiment file initiated at ' datestr(exp_t,'HH:MM')]); 
        disp(['* fMRI run #' num2str(ii) ' acquisition initiated at         ' datestr(img_t,'HH:MM:SS')]); 
    end
end
disp('**** Timestamp checking complete! ****');

%% Create onset files for each condition
conditions = {'Digit' 'Dots' 'Letter' 'Novel' 'Error' 'Omission'};       
% Loop through conditions and create onset files
for ii = 1:numel(conditions)
    c = conditions{ii};
    for jj = 1:numel(r.psypy_fname)
        t = readtable(r.psypy_fname{jj},'PreserveVariableNames',true);
        if strcmp(c,'Error')
            rm = ~strcmp(t.commerror,'1');
            t(rm,:) = [];
            onsets = t.("trialCat.Onset")';
        elseif strcmp(c,'Omission')
            rm = ~strcmp(t.omerror,'1');
            t(rm,:) = [];
            onsets = t.("trialCat.Onset")';
        else
            % Remove other conditions
            rm = ~strcmp(t.Category,c);
            t(rm,:) = [];
            % Remove errors/ommissions
            rm = ~strcmp(t.commerror,'NA') | ~strcmp(t.omerror,'NA');
            t(rm,:) = [];
            % Get onsets
            onsets = t.("trialCat.Onset")';
        end
        % Placeholder if no trials during this run
        if numel(onsets) == 0
            onsets = -1;
        end
        % Write to file, include new line indicator
        file = [onsets_dir '/onsets_' subj '_' year '_' c '.txt'];
        fid = fopen(file, 'a');
        fprintf(fid, [regexprep(num2str(onsets),'\s+',' ') '\n']);
        fclose(fid);
    end        
end
disp('**** Condition onset files created! ****');

%% Create onset files for each exemplar
exemplars = {'Digit_2' 'Digit_3' 'Digit_4' 'Digit_5' 'Digit_6' 'Digit_7'...
             'Dots_2' 'Dots_3' 'Dots_4' 'Dots_5' 'Dots_6' 'Dots_7'...
             'A' 'B' 'G' 'S' 'T' 'Z'...
             'BACS1B' 'BACS1C' 'BACS1G' 'BACS1H' 'BACS1L' 'BACS1U'};
% Loop through exemplay and create onset files
for ii = 1:numel(exemplars)
    c = exemplars{ii};
    for jj = 1:numel(r.psypy_fname)
        t = readtable(r.psypy_fname{jj},'PreserveVariableNames',true);
        % Remove other conditions
        rm = ~strcmp(t.Exemplar,c);
        t(rm,:) = [];
        % Remove errors/ommissions
        rm = ~strcmp(t.commerror,'NA') | ~strcmp(t.omerror,'NA');
        t(rm,:) = [];
        % Get onsets
        onsets = t.("trialCat.Onset")';
        % Placeholder if no trials during this run
        if numel(onsets) == 0
            onsets = -1;
        end
        % Write to file, include new line indicator
        file = [onsets_dir '/onsets_' subj '_' year '_' c '.txt'];
        fid = fopen(file, 'a');
        fprintf(fid, [regexprep(num2str(onsets),'\s+',' ') '\n']);
        fclose(fid);
    end        
end
disp('**** Exemplar onset files created! ****');

   

    


