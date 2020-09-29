% This function downloads and unzips external ssh2 functions

% Moritz Schappler, moritz.schappler@imes.uni-hannover.de, 2020-09
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function setUpBasics()
  
if exist('functions/matlab-ssh2-master/README.md', 'file')
  return % files already existing
end
fprintf('ssh2 library does not exist locally. Download from github.\n');
websave(fullfile(tempdir(), 'matlab-ssh2.zip'), ...
  'https://github.com/davidfreedman/matlab-ssh2/archive/master.zip');
tmpdir_zip = tempname();
unzip(fullfile(tempdir(), 'matlab-ssh2.zip'), tmpdir_zip);
movefile(fullfile(tmpdir_zip,'*'), 'functions');
ssh2path = fullfile('functions','matlab-ssh2-master','ssh2');
% To encounter strange problems in loading the jar file, move it
% up. TODO: Better solution preserving the original directories
movefile(fullfile(ssh2path,'ganymed-ssh2-build250','ganymed-ssh2-build250.jar'), ssh2path);
addpath(ssh2path);

