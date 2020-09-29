function [personalSettings, batchSettings] = userSettings()

%% authentication data
personalSettings.username = 'InsertYourUsername';
personalSettings.password = 'InsertYourPassword';
personalSettings.hostname = 'login.cluster.uni-hannover.de';

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
% mail address all job notifications are send to send mail in case of:
% job cancel ('a'), job begin ('b'), job end ('e'). Default: 'abe'
batchSettings.mailName = 'yourMailadress@yourDomain.com';
batchSettings.mailType = 'abe';
% job queue to use. Choose from 'all' (default), 'helena' (big jobs) and
% 'test' (small test jobs)
batchSettings.queue = 'all';
% Matlab version to use (inform first, which modules are available)
batchSettings.matVersion = 'MATLAB/2020a';
% name of your main matlab script, located in first layer of your upload folder.
batchSettings.matFileName = 'example.m';

% For advanced settings, see functions/jobSettings.m
