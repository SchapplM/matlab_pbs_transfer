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

function ssh2_conn = uploadUserData(ssh2_conn, ps)

%% initialize tmp directory
% Use tmp folder within /home, because the /tmp directory could be
% different if the login server changes between the reconnects for each
% command
tmpdir_remote = ['/home/', ps.username, '/tmp'];
pause(0.050 + rand()*0.100);
ssh2_conn = ssh2_command(ssh2_conn, ['mkdir -p ', tmpdir_remote]);
if ssh2_conn.command_status
  error('Error creating tmp dir on server:\n%s', char(ssh2_conn.command_result));
end
%% zip dir to upload
dummyFilenameZip = ['upload', num2str(randi([1000, 9999], 1))];
listing = getContentOfFolder(ps.locUploadFolder);
cd(ps.locUploadFolder);
zip(dummyFilenameZip, listing);

%% upload zip file and delete local zip file
pause(0.050 + rand()*0.100);

ssh2_conn = scp_put(ssh2_conn, [dummyFilenameZip, '.zip'], tmpdir_remote);
delete([dummyFilenameZip, '.zip']); % delete local zip file
cd(ps.locPath); % change dir back to local home dir
if ssh2_conn.command_status
  error('Error copying zip file to server:\n%s', char(ssh2_conn.command_result));
end
%% unzip uploaded zip-file on server
pause(0.050 + rand()*0.100);
[ssh2_conn,~] = ssh2_command(ssh2_conn, ['mkdir -p ' ps.extUploadFolderConcrete]);
if ssh2_conn.command_status
  error('Error creating upload dir on server:\n%s', char(ssh2_conn.command_result));
end
pause(0.050 + rand()*0.100);
[ssh2_conn,~] = ssh2_command(ssh2_conn, ... % unzip uploaded zip file to new dir
    ['unzip -qq ', tmpdir_remote, '/', dummyFilenameZip, '.zip -d ', ps.extUploadFolderConcrete], 1);
if ssh2_conn.command_status
  error('Error extracting zip file on server:\n%s', char(ssh2_conn.command_result));
end
pause(0.050 + rand()*0.100);
[ssh2_conn,~] = ssh2_command(ssh2_conn, ... % delete zip file
    ['rm -rf ', tmpdir_remote, '/', dummyFilenameZip, '.zip']);
if ssh2_conn.command_status
  error('Error deleting zip file on server:\n%s', char(ssh2_conn.command_result));
end

