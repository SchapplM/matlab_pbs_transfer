% Settings
% 
% Author:       Philipp Kortmann
% Date:         2018/04/17

function personalSettings = jobSettings(personalSettings, batchSettings)
%% personal settings (advanced, do not change if not familiar with the cluster settings)
personalSettings.extPath = ['/bigwork/', personalSettings.username];           % external path to your default directory. Use /home/username or /bigwork/username.
personalSettings.extUploadFolder = [personalSettings.extPath, '/JOBS'];% external (server) dir, where local files are uploaded to
personalSettings.locPath = fileparts(which('cluster_transfer_toolbox_path_init.m'));                                      % path to local top level working dir
personalSettings.deleteDataAfterDownload = 1;                               % bool whether upload and result data from a certain job should be deleted from server after downloading its results
personalSettings.extDownloadFolder = [personalSettings.extPath, ...
    '/JOBS/$UPLOADDIR$/', personalSettings.relResultsFolder];          % external (server) dir, from which to download results, %UPLOADDIR% will be adjusted later by the program.

%% Override, if standard variables were not changed (DO NOT CHANGE!)
if(strcmp(batchSettings.mailName, 'yourMailadress@yourDomaine.com'))
    batchSettings.mailName = input('Type your mail address: ', 's');
end
if(strcmp(personalSettings.locUploadFolder, 'absolute\path\to\your\local\upload\directory'))
    personalSettings.locUploadFolder = 'exampleUploadDir';
    unzip('templateFiles/exampleDirectories.zip');
end
if(strcmp(personalSettings.locDownloadFolder, 'absolute\path\to\your\local\download\directory'))
    personalSettings.locDownloadFolder = 'exampleDownloadDir';
end
if(strcmp(personalSettings.relResultsFolder, 'Relative/Path/To/Your/Results/Directory/Inside/Your/Upload/Directory'))
    personalSettings.relResultsFolder = 'results';
end
if(strcmp(personalSettings.extDownloadFolder, [personalSettings.extPath, '/myUploads/$UPLOADDIR$/Relative/Path/To/Your/Results/Directory/Inside/Your/Upload/Directory']))
    personalSettings.extDownloadFolder = [personalSettings.extPath, '/myUploads/$UPLOADDIR$/', personalSettings.relResultsFolder];
end

