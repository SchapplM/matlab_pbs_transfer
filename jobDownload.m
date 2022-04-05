% Download your data
% Just enter your JobID which was given to you after running jobStart.m.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

%% clean & set up workspace
clc();
clearvars();
close all;
tbpath = fileparts(which('cluster_transfer_toolbox_path_init.m'));
addpath(fullfile(tbpath, 'functions')); % add subfunctions
addpath(fullfile(tbpath, 'functions', 'matlab-ssh2-master','ssh2'));
%% general settings
[personalSettings, batchSettings] = userSettings(); % load user settings
personalSettings = jobAuthentication(personalSettings); % load personal authentication data
personalSettings = jobSettings(personalSettings, batchSettings); % load personal settings
setUpBasics(); % unzip external functions, etc.

%% download data
% get bool whether job has been completed yet
[jobDone, personalSettings, batchSettings] = checkIfJobIsDone(personalSettings, batchSettings);
if(jobDone)
    downloadUserData(personalSettings, batchSettings);
else
    disp('Job is not ready yet or has been aborted.');
end

%% clean up workspace
tbpath = fileparts(which('cluster_transfer_toolbox_path_init.m'));
rmpath(fullfile(tbpath, 'functions'));
rmpath(fullfile(tbpath, 'functions', 'matlab-ssh2-master','ssh2'));
clearvars();
close all;
