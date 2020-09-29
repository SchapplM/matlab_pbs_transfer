% This function returns hours and minutes as string 
% (of two chars, e.g. '05', 58...) for a given time in hours.

% Philipp Kortmann, 2018/04/17
% (C) Institut für Mechatronische Systeme, Leibniz Universität Hannover

function [h, m] = getHoursAndMinutes(time)


%% set hours
h = floor(time);
if(h < 1)
    h = '00';
elseif(h < 10)
    h = ['0', num2str(h)];
elseif(h > 180)
    h = '180';
else
    h = num2str(h);
end

%% set minutes
m = (time - floor(time)) * 60;
if(m < 0)
    m = '00';
elseif(m < 10)
    m = ['0', num2str(floor(m))];
elseif(m > 59)
    m = '59';
else
    m = num2str(floor(m));
end

%% default settings
if(time < 0)
    m = '00';
    h = '01';
end
