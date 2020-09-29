% This function creates the batch-file for the demanded cluster job.
% Therefor a template textfile is opened and the relevant dummy
% variables are exchanged by the required values set in jobSettings.m.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function ps = createJobFile(bs, ps)

%% copy content of template batch file
copyfile('templateFiles/batchJob_template.txt', 'templateFiles/batchJob.sh');
fileID = fopen('templateFiles/batchJob.sh', 'r');
s = textscan(fileID, '%s', 'Delimiter', '\n');
s = s{1, 1};
str = '';
for i = 1: length(s)
    str = [str, s{i, 1}, newline]; %#ok<AGROW>
end
fclose(fileID);

%% exchange PBS variables
ps.dateString = datestr(datetime('now'), 'yyyymmdd_HHMMSS');
ps.extUploadFolderConcrete = [ps.extUploadFolder, '/upload', ps.dateString];
[hours, minutes] = getHoursAndMinutes(bs.time);
str = strrep(str, '?NODES?', num2str(bs.nodes));
str = strrep(str, '?PPN?', num2str(bs.ppn));
str = strrep(str, '?HOURS?', hours);
str = strrep(str, '?MINUTES?', minutes);
str = strrep(str, '?MEMORY?', num2str(bs.mem));
str = strrep(str, '?NAME?', bs.name);
str = strrep(str, '?MAILADDRESS?', bs.mailName);
str = strrep(str, '?MAILTYPE?', bs.mailType);
str = strrep(str, '?QUEUE?', bs.queue);

%% exchange other variables
str = strrep(str, '?MATVERSION?', bs.matVersion);
str = strrep(str, '?WORKDIR?', ps.extUploadFolderConcrete);
str = strrep(str, '?MATFILE?', bs.matFileName);

%% save batch file
fileID = fopen('templateFiles/batchJob.sh', 'w');
fprintf(fileID, '%s', str);
fclose(fileID);

%% copy batch file to upload dir
copyfile('templateFiles/batchJob.sh', ps.locUploadFolder);
