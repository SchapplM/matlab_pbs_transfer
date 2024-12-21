% This function downloads and unzips external ssh2 functions

% Moritz Schappler, moritz.schappler@imes.uni-hannover.de, 2020-09
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function setUpBasics()

tbpath = fileparts(which('cluster_transfer_toolbox_path_init.m'));
if exist(fullfile(tbpath,'functions','matlab-ssh/README.md'), 'file')
  return % files already existing
end
fprintf('ssh2 library does not exist locally. Download from github.\n');
websave(fullfile(tempdir(), 'matlab-ssh.zip'), ...
  'https://github.com/SchapplM/matlab-ssh-via-system/archive/master.zip');
tmpdir_zip = tempname();
unzip(fullfile(tempdir(), 'matlab-ssh.zip'), tmpdir_zip);
movefile(fullfile(tmpdir_zip, 'matlab-ssh-via-system-master'), ...
  fullfile(tbpath,'functions', 'matlab-ssh'));
ssh2path = fullfile(tbpath,'functions','matlab-ssh');
addpath(ssh2path);

