% This function loads the content of folder '2_upload' to the
% destination given by 'uploadFolder' on the cluster.
% 
% Input:
% ssh2_conn
%   Object for the SSH connection
% ps
%   personal settings

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function uploadUserData(ssh2_conn, ps)

%% ssh2 config
pause(0.050 + rand()*0.100);
ssh2_conn = ssh2_command(ssh2_conn, ['mkdir -p /tmp/', ps.username]);

%% zip dir to upload
dummyFilenameZip = ['upload', num2str(randi([1000, 9999], 1))];
listing = getContentOfFolder(ps.locUploadFolder);
cd(ps.locUploadFolder);
zip(dummyFilenameZip, listing);

%% upload zip file and delete local zip file
pause(0.050 + rand()*0.100);
ssh2_conn = sftp_put(ssh2_conn, [dummyFilenameZip, '.zip'], ...
  ['/tmp/', ps.username]);
delete([dummyFilenameZip, '.zip']); % delete local zip file
cd(ps.locPath); % change dir back to local home dir

%% unzip uploaded zip-file on server
pause(0.050 + rand()*0.100);
ssh2_conn = ssh2_command(ssh2_conn, ['mkdir -p ' ps.extUploadFolderConcrete]);
pause(0.050 + rand()*0.100);
ssh2_conn = ssh2_command(ssh2_conn, ... % unzip uploaded zip file to new dir
    ['unzip ', '/tmp/', ps.username,'/', dummyFilenameZip, '.zip -d ', ps.extUploadFolderConcrete], 1);
pause(0.050 + rand()*0.100);
ssh2_conn = ssh2_command(ssh2_conn, ... % delete zip file
    ['rm -rf ', '/tmp/', ps.username,'/', dummyFilenameZip, '.zip']);

