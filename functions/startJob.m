% Submit the job to the job manager by submitting the batch file.
% 
% Input:
% ssh2_conn
%   Object for the SSH connection
% ps
%   personal settings
% startsettings_in [optional], struct. 
%   field/value pairs for dependencies of the job:
%     fields: .afterok, .afternotok, .... see `man qsub` on the cluster.
%     values: array with job IDs. May be empty (as a default structure)
%   Other fields (specific for this Matlab function):
%   .waittime_max: maximum waiting time in case of no success for job start
%   .retry_interval: interval for retry of job start in seconds

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function jobID = startJob(ssh2_conn, ps, bs, startsettings_in)
% Check validity of input (to protect against deprecated settings files)
if ~isfield(bs, 'scheduler')
  error('Field "scheduler" not defined for batch settings');
elseif ~strcmp(bs.scheduler, 'PBS') && ~strcmp(bs.scheduler, 'SLURM')
  error('Case %s not defined for batch setting "scheduler"', bs.scheduler);
end
if nargin < 3
  startsettings_in = struct();
end

%% Generate dependencies, split input settings struct
% See `man qsub` (PBS) or `man sbatch` (SLURM) on the cluster
dependstr = '';
startsettings_dep = struct(); % for dependencies of the job
startsettings_gen = struct('waittime_max', 3600*3, 'retry_interval', 60); % for general settings
for f = fields(startsettings_in)'
  if any(strcmp(f{1}, {'waittime_max', 'retry_interval'}))
    startsettings_gen.(f{1}) = startsettings_in.(f{1});
    continue;
  end
  startsettings_dep.(f{1}) = startsettings_in.(f{1});
end
% Example:
% -W depend=afterok:7546567 (PBS)
% --dependency=afternotok:207990 (SLURM)
if nargin >= 3 && ~isempty(fields((startsettings_in)))
  if strcmp(bs.scheduler, 'PBS')
    dependstr = '-W depend=';
  else % SLURM
    dependstr = '--dependency=';
  end
  dependstr_empty = dependstr;
  for f = fields(startsettings_in)'
    if any(strcmp(f{1}, {'waittime_max', 'retry_interval'})), continue; end
    val = startsettings_in.(f{1}); % Values of fields like afterok, afternotok
    I_ok = ~isnan(val);
    if ~all(I_ok)
      warning('Values for field %s are non-integer. Ignore these', f{1});
    end
    val = val(I_ok);
    if isempty(val), continue; end % skip empty fields
    % Add comma for additional dependencies
    if dependstr(end)~='=', dependstr=[dependstr,',']; end %#ok<AGROW>
    % assemble arguments
    dependstr = [dependstr, f{1}]; %#ok<AGROW>
    % set values
    for i = 1:length(val)
      dependstr = [dependstr, sprintf(':%d', val(i))]; %#ok<AGROW>
    end
  end
  if strcmp(dependstr_empty, dependstr)
    dependstr = ''; % no dependencies. Remove argument
  end
end
%% start batch job
t0 = tic();
while true
  if strcmp(bs.scheduler, 'PBS')
    cmdline_qsub = 'qsub ';
  else % SLURM
    cmdline_qsub = 'sbatch ';
  end
  cmdline_qsub = [cmdline_qsub, dependstr, ' ', ps.extUploadFolder, ...
    '/upload', ps.dateString, '/', bs.batFileName]; %#ok<AGROW> 
  pause(0.050 + rand()*0.100);
  try
    [ssh2_conn, cmdResponse] = ssh2_command(ssh2_conn, cmdline_qsub);
    if ssh2_conn.command_status
      disp(ssh2_conn.command_result);
      error('Start command for job failed');
    end
  catch err
    warning('startJob:SSH_error', 'Error running the job via ssh: %s', err.message);
    cmdResponse = {''};
  end
  % read jobID from command response
  jobID = 0;
  for i = 1:length(cmdResponse)
    if strcmp(bs.scheduler, 'PBS')
      % Expected form of output: "8264679.batch.css.lan"
      tokens = regexp(cmdResponse{i,1}, '(\d+)\..*?', 'tokens');
    else % SLURM
      tokens = regexp(cmdResponse{i,1}, 'Submitted batch job (\d+)', 'tokens');
    end
    if ~isempty(tokens)
      jobID = str2double(tokens{1});
      break;
    end
  end
  if jobID == 0
    warning('Unexpected output. Job ID not found:');
    disp(cmdResponse);
    disp('ERROR: Job did not start well (no job ID)');
    disp(['Command to start the job (on the server): "', cmdline_qsub, '"']);
    if toc(t0) > startsettings_gen.waittime_max
      break;
    end
    fprintf('Retry job upload in %1.1fs for the next %1.1f min.\n', ...
      startsettings_gen.retry_interval, (startsettings_gen.waittime_max-toc(t0))/60);
    pause(startsettings_gen.retry_interval);
  else % Job has started successfully
    break
  end
end