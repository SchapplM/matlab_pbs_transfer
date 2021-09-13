% Submit the job to the job manager by submitting the batch file.
% 
% Input:
% ps
%   personal settings
% startsettings [optional], struct. field/value pairs for dependencies of
%   the job. Fields, see `man qsub` on the cluster. Examples
%   fields: afterok, afternotok, ...
%   values: array with job IDs

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function jobID = startJob(ps, startsettings)

%% ssh2 cofig
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password); % configure ssh2 connection
ssh2_conn = ssh2_command(ssh2_conn, 'ls -la *ninjas*');

%% Generate dependencies
% See `man qsub` on the cluster
dependstr = '';
%  -W depend=afterok:7546567
if nargin >= 2 && ~isempty(startsettings)
  dependstr = '-W depend=';
  for f = fields(startsettings)
    % Add comma for additional dependencies
    if dependstr(end)~='=', dependstr=[dependstr,',']; end %#ok<AGROW>
    % assemble arguments
    val = startsettings.(f{1});
    dependstr = [dependstr, f{1}]; %#ok<AGROW>
    % set values
    for i = 1:length(val)
      dependstr = [dependstr, sprintf(':%d', val(i))]; %#ok<AGROW>
    end
  end
end
%% start batch job
cmdline_qsub = ['qsub ', dependstr, ' ', ps.extUploadFolder, ...
  '/upload', ps.dateString, '/batchJob.sh'];
[ssh2_conn, cmdResponse] = ssh2_command(ssh2_conn, cmdline_qsub);
if length(cmdResponse{1,1}) > 10
  jobID = str2double(cmdResponse{1,1}(1:7)); % read jobID from command response
else % if no jobID is returned
  jobID = 0;
  disp('ERROR: Job did not start well (no job ID)');
  disp(['Command to start the job (on the server): "', cmdline_qsub, '"']);
end

%% close ssh2
ssh2_close(ssh2_conn);
