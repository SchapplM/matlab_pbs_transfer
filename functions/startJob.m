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

function jobID = startJob(ps, bs, startsettings)
% Check validity of input (to protect against deprecated settings files)
if ~isfield(bs, 'scheduler')
  error('Field "scheduler" not defined for batch settings');
elseif ~strcmp(bs.scheduler, 'PBS') && ~strcmp(bs.scheduler, 'SLURM')
  error('Case %s not defined for batch setting "scheduler"', bs.scheduler);
end

%% ssh2 config
ssh2_conn = ssh2_config(ps.hostname, ps.username, ps.password); % configure ssh2 connection

%% Generate dependencies
% See `man qsub` (PBS) or `man sbatch` (SLURM) on the cluster
dependstr = '';
%  -W depend=afterok:7546567
if nargin >= 3 && ~isempty(startsettings)
  if strcmp(bs.scheduler, 'PBS')
    dependstr = '-W depend=';
  else % SLURM
    dependstr = '--dependency=';
  end
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
if strcmp(bs.scheduler, 'PBS')
  cmdline_qsub = 'qsub ';
else % SLURM
  cmdline_qsub = 'sbatch ';
end

cmdline_qsub = [cmdline_qsub, dependstr, ' ', ps.extUploadFolder, ...
  '/upload', ps.dateString, '/batchJob.sh'];
[ssh2_conn, cmdResponse] = ssh2_command(ssh2_conn, cmdline_qsub);

% read jobID from command response
jobID = 0;
if strcmp(bs.scheduler, 'PBS')
  % Expected form of output: "8264679.batch.css.lan"
  tokens = regexp(cmdResponse{1,1}, '(\d+)\..*?', 'tokens');
else % SLURM
  tokens = regexp(cmdResponse{1,1}, 'Submitted batch job (\d+)', 'tokens');
end
if ~isempty(tokens)
  jobID = str2double(tokens{1});
else
  warning('Unexpected output. Job ID not found: %s', cmdResponse{1,1});
  disp('ERROR: Job did not start well (no job ID)');
  disp(['Command to start the job (on the server): "', cmdline_qsub, '"']);
end

%% close ssh2
ssh2_close(ssh2_conn);
