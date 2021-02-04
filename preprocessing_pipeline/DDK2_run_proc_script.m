%% Run AFNI Processing script created by afni_proc
function output = DDK2_run_proc_script(orig_dir)

cd(orig_dir)

proc_script = dir('proc.*');
unix(['tcsh -xef ' proc_script(1).name ' 2>&1 | tee output.' proc_script(1).name]); % |& syntax doesn't work on OSX, so replaced with 2>&1 |