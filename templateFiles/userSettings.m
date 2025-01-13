function [personalSettings, batchSettings] = userSettings()

%% authentication data
personalSettings.username = 'InsertYourUsername';
personalSettings.password = 'InsertYourPassword';
personalSettings.hostname = 'login.cluster.uni-hannover.de';
personalSettings.port = 22;

%% personal settings (basic, necessary)
% Relative/Path/To/Your/Results/Directory/Inside/Your/Upload/Directory
personalSettings.relResultsFolder = 'results';
% path to local dir to upload (type: '[...]\exampleUploadDir' for demo).
% absolute\path\to\your\local\upload\directory
personalSettings.locUploadFolder = 'transfer/UploadDir';
% path to download dir (type: '[...]\exampleDownloadDir' for demo).
% absolute\path\to\your\local\download\directory
personalSettings.locDownloadFolder = 'transfer/DownloadDir';

%% Batch file and PBS settings
% Scheduler running on the cluster. Choose 'PBS' or 'SLURM'.
% Uni Hannover Cluster migrated from PBS to SLURM in 2022.
% The syntax for some commands is slightly different.
batchSettings.scheduler = 'SLURM';
% number of nodes to use [1, 9], (only one node will be used as long as
% 'distributed computing server' is not supported by your Cluster system)
batchSettings.nodes = 1;
% number of cores per node to use [1, 24]
batchSettings.ppn = 1;
% max wallclock time in hours [0.05 200], choose as expected job duration.
batchSettings.time = 0.25;
% memory to use in GB [1, ...] (up to 1000GB for some systems)
batchSettings.mem = 2;
% name of the job
batchSettings.name = 'myFirstJob';
% mail address all job notifications are send to 
batchSettings.mailName = 'yourMailadress@yourDomain.com';
% Cases in which mail is sent:
% PBS syntax: job cancel ('a'), job begin ('b'), job end ('e'). Default: 'abe'
% batchSettings.mailType = 'abe'; % uncomment for PBS
% SLURM syntax: BEGIN,END,FAIL
batchSettings.mailType = 'BEGIN,END,FAIL'; % uncomment for SLURM
% job queue (PBS) or partition (SLURM) to use.
% PBS: Choose from 'all' (default) and the ones specified in the wiki
% batchSettings.queue = 'all'; % uncomment for PBS
% SLURM: Leave partition empty to allow all (default)
batchSettings.queue = ''; % uncomment for SLURM
% Matlab version to use (inform first, which modules are available)
batchSettings.matVersion = 'MATLAB/2020a';
% name of your main matlab script, located in first layer of your upload folder.
batchSettings.matFileName = 'example.m';
% Name of the batch file (has to be defined for internal reasons)
batchSettings.batFileName = 'batchJob.sh';

% For advanced settings, see functions/jobSettings.m
