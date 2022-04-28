% This function connects to the host and downloads the results of the
% performed job. Therefor the demanded directory is compressed as zip file on
% the server side, downloaded and again unzipped on the local side. 

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function downloadUserData(ps, bs)

tbpath = fileparts(which('cluster_transfer_toolbox_path_init.m'));
%% ssh2 cofig
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);

%% put log files in download dir
ps.extUploadFolderConcrete = [ps.extUploadFolder, '/upload', ps.dateString];
ssh2_command(ssh2_conn, ['mkdir -p ', ps.extDownloadFolder]);
% Prepare downloading the batch script for reproduction of the process
ssh2_command(ssh2_conn, ['cp -f ', ps.extUploadFolderConcrete, '/', bs.matFileName, ' ', ps.extDownloadFolder]);
ssh2_command(ssh2_conn, ['cp -f ', ps.extUploadFolderConcrete, '/batchJob.sh ' ps.extDownloadFolder]);

% Download log and error output of the job
ssh2_command(ssh2_conn, ['cp -f ', ps.extUploadFolderConcrete, '/', num2str(ps.jobID), '.log ' ps.extDownloadFolder]);
ssh2_command(ssh2_conn, ['cp -f ', bs.name, '.e', num2str(ps.jobID), ' ', ps.extDownloadFolder]);
ssh2_command(ssh2_conn, ['cp -f ', bs.name, '.o', num2str(ps.jobID), ' ', ps.extDownloadFolder]);

%% ssh2 download zip-file via sftp
[ssh2_conn, cmdZip] = ssh2_command(ssh2_conn, ['zip -r download.zip ', ps.extDownloadFolder]);
ssh2_close(ssh2_conn);
ssh2_conn = scp_simple_get(ps.hostname, ps.username, ps.password, 'download.zip');

%% remove zip file from server
ssh2_command(ssh2_conn, 'rm -rf download.zip');

%% remove upload data and results from the server
if(ps.deleteDataAfterDownload)
    ssh2_command(ssh2_conn, ['rm -rf ', ps.extUploadFolder, '/upload', ps.dateString]);
    ssh2_command(ssh2_conn, ['rm -f ', bs.name, '.e', num2str(ps.jobID)]);
    ssh2_command(ssh2_conn, ['rm -f ', bs.name, '.o', num2str(ps.jobID)]);
end

%% unzip folder
if ~exist('downloadDummy', 'file'); mkdir('downloadDummy'); end         % create dummy dir for unzipping
unzip('download.zip', 'downloadDummy');                                 % unzip downloaded file to dummy dir
delete('download.zip');                                                 % remove downloaded local zip file after unzipping
if ~exist(ps.locDownloadFolder, 'file'), mkdir(ps.locDownloadFolder); end
movefile(['downloadDummy', ps.extDownloadFolder], ...
    fullfile(tbpath, ps.locDownloadFolder, [datestr(datetime('now'), ...
    'yyyymmdd_HHMMSS'), '_jobID', num2str(ps.jobID)]));
rmdir('downloadDummy', 's');                                            % remove dummy folder
