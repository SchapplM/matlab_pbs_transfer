% Authentification settings

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

%% Overwrite if authentication variables not set
function personalSettings = jobAuthentication(personalSettings)
if(strcmp(personalSettings.username, 'InsertYourUsername'))
    personalSettings.username = input('Type your Username: ', 's');
    personalSettings.password = input('Type your password: ', 's');
end