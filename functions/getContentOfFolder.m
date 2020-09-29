% This function returns a list of all files and directories inside a
% certain directory. 

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function list = getContentOfFolder(dirPath)

s = dir(dirPath);
list = cell(1, length(s) - 2);
for i = length(s):-1:3
    list{i-2} = s(i).name;
end


