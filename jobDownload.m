% Download your data
% Just enter your JobID which was given to you after running jobStart.m.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function jobDownload(jobid)
if nargin == 0
  jobid = 0;
end
assert(isa(jobid, 'double') && size(jobid,1)==1, ...
  'jobid has to be 1xN double array of Job IDs');
% set up workspace
tbpath = fileparts(which('cluster_transfer_toolbox_path_init.m'));
addpath(fullfile(tbpath, 'functions')); % add subfunctions
addpath(fullfile(tbpath, 'functions', 'matlab-ssh2-master','ssh2'));
for jid = jobid(:)' % loop for downloading multiple jobs
  %% general settings
  [personalSettings, batchSettings] = userSettings(); % load user settings
  personalSettings = jobAuthentication(personalSettings); % load personal authentication data
  personalSettings = jobSettings(personalSettings, batchSettings); % load personal settings
  setUpBasics(); % unzip external functions, etc.
  %% download data
  personalSettings.jobID = jid;
  % get bool whether job has been completed yet
  [jobDone, personalSettings, batchSettings] = checkIfJobIsDone(personalSettings, batchSettings);
  if(jobDone)
      downloadUserData(personalSettings, batchSettings);
  else
      disp('Job is not ready yet or has been aborted.');
  end
end
%% clean up workspace
rmpath(fullfile(tbpath, 'functions'));
rmpath(fullfile(tbpath, 'functions', 'matlab-ssh2-master','ssh2'));
