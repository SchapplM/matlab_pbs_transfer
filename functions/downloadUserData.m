% This function connects to the host and downloads the results of the
% performed job. Therefor the demanded directory is compressed as zip file on
% the server side, downloaded and again unzipped on the local side. 

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function downloadUserData(ps, bs)

tbpath = fileparts(which('cluster_transfer_toolbox_path_init.m'));
%% ssh2 config
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);

%% put log files in download dir
ps.extUploadFolderConcrete = [ps.extUploadFolder, '/upload', ps.dateString];
[ssh2_conn]=ssh2_command(ssh2_conn, ['mkdir -p ', ps.extDownloadFolder]);
if ssh2_conn.command_status
  error('Error creating tmp dir:\n%s', char(ssh2_conn.command_result));
end
% Prepare downloading the batch script for reproduction of the process
[ssh2_conn,~]=ssh2_command(ssh2_conn, ['cp -f ', ps.extUploadFolderConcrete, '/', bs.matFileName, ' ', ps.extDownloadFolder]);
[ssh2_conn,~]=ssh2_command(ssh2_conn, ['cp -f ', ps.extUploadFolderConcrete, '/batchJob.sh ' ps.extDownloadFolder]);

% Download log and error output of the job
[ssh2_conn,~]=ssh2_command(ssh2_conn, ['cp -f ', ps.extUploadFolderConcrete, '/', num2str(ps.jobID), '.log* ' ps.extDownloadFolder]);
% copy error and output file (does not work currently due to new filenames)
% [ssh2_conn,~]=ssh2_command(ssh2_conn, ['cp -f ', bs.name, '.e', num2str(ps.jobID), ' ', ps.extDownloadFolder]);
% [ssh2_conn,~]=ssh2_command(ssh2_conn, ['cp -f ', bs.name, '.o', num2str(ps.jobID), ' ', ps.extDownloadFolder]);

%% download zip file
tmpdir_remote = ['/home/', ps.username, '/tmp'];
ssh2_conn = ssh2_command(ssh2_conn, ['mkdir -p ', tmpdir_remote]);
[ssh2_conn, ~] = ssh2_command(ssh2_conn, ['zip -r ' ...
  tmpdir_remote, '/download.zip ', ps.extDownloadFolder]);
if ssh2_conn.command_status
  error('Error creating zip file on server:\n%s', char(ssh2_conn.command_result));
end
ssh2_conn = scp_simple_get(ps.hostname, ps.username, ps.password, 'download.zip', ...
  tbpath, tmpdir_remote);

%% remove zip file from server
[ssh2_conn,~]=ssh2_command(ssh2_conn, ['rm ', tmpdir_remote, '/download.zip']);

%% remove upload data and results from the server
if ps.deleteDataAfterDownload 
  [~,~]=ssh2_command(ssh2_conn, ['rm -rf ', ps.extUploadFolder, '/upload', ps.dateString]);
  [~,~]=ssh2_command(ssh2_conn, ['rm -f ', bs.name, '.e', num2str(ps.jobID)]);
  [~,~]=ssh2_command(ssh2_conn, ['rm -f ', bs.name, '.o', num2str(ps.jobID)]);
end

%% unzip folder
if ~exist(fullfile(tbpath, 'downloadDummy'), 'file')
  mkdir(fullfile(tbpath, 'downloadDummy'));% create dummy dir for unzipping
end
unzip(fullfile(tbpath, 'download.zip'), fullfile(tbpath, 'downloadDummy')); % unzip downloaded file to dummy dir
delete(fullfile(tbpath, 'download.zip')); % remove downloaded local zip file after unzipping
targetdir = fullfile(tbpath, ps.locDownloadFolder, [datestr(datetime('now'), ...
    'yyyymmdd_HHMMSS'), '_jobID', num2str(ps.jobID)]);
if ~exist(fullfile(tbpath, ps.locDownloadFolder), 'file')
  mkdir(fullfile(tbpath, ps.locDownloadFolder));
end
movefile([fullfile(tbpath, 'downloadDummy'), ps.extDownloadFolder], targetdir);
fprintf('Downloaded data for job %d to %s\n', ps.jobID, targetdir);
rmdir(fullfile(tbpath, 'downloadDummy'), 's');
