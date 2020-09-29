% Submit the job to the job manager by submitting the batch file.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function jobID = startJob(ps)

%% ssh2 cofig
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password);         % configure ssh2 connection
ssh2_conn = ssh2_command(ssh2_conn, 'ls -la *ninjas*');

%% start batch job
cmdline_qsub = ['qsub ', ps.extUploadFolder, '/upload', ps.dateString, '/batchJob.sh'];
[ssh2_conn, cmdResponse] = ssh2_command(ssh2_conn, cmdline_qsub);
if(length(cmdResponse{1,1}) > 10)
    jobID = str2num(cmdResponse{1,1}(1:7));                             % read jobID from command response
else                                                                    % if no jobID is returned
    jobID = 0;
    disp('ERROR: Job did not start well (no job ID)');
    disp(['Command to start the job (on the server): "', cmdline_qsub, '"']);
end

%% close ssh2
ssh2_conn = ssh2_close(ssh2_conn);
