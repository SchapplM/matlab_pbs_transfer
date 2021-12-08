% This function loads the content of folder '2_upload' to the
% destination given by 'uploadFolder' on the cluster.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function uploadUserData(ps)

%% ssh2 config
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);         % configure ssh2 connection
ssh2_conn = ssh2_command(ssh2_conn, ['mkdir -p /tmp/', ps.username]);

%% zip dir to upload
dummyFilenameZip = ['upload', num2str(randi([1000, 9999], 1))];
listing = getContentOfFolder(ps.locUploadFolder);
cd(ps.locUploadFolder);
zip(dummyFilenameZip, listing);

%% upload zip file and delete local zip file
ssh2_conn = sftp_put(ssh2_conn, ...                                     % upload zip file
     [dummyFilenameZip, '.zip'], ...
     ['/tmp/', ps.username]);
delete([dummyFilenameZip, '.zip']);                                     % delete local zip file
cd(ps.locPath);                                                         % change dir back to local home dir

%% unzip uploaded zip-file on server
ssh2_conn = ssh2_command(ssh2_conn, ['mkdir -p ' ps.extUploadFolderConcrete]);
ssh2_conn = ssh2_command(ssh2_conn, ...                                 % unzip uploadesd zip file to new dir
    ['unzip ', '/tmp/', ps.username,'/', dummyFilenameZip, '.zip -d ', ps.extUploadFolderConcrete]);
ssh2_conn = ssh2_command(ssh2_conn, ...                                 % delete zip file
    ['rm -rf ', '/tmp/', ps.username,'/', dummyFilenameZip, '.zip']);

%% close ssh2 connection
ssh2_conn = ssh2_close(ssh2_conn);
