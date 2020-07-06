% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function plot_mission(mission)

figure;
legend;
hold on;
a = gca;
a.XLabel.String = 'Range';
a.YLabel.String = "Altitude";

% Iterate over mission segments
x = 0;
for i = 1 : length(mission.segments)
    if strcmp(mission.segments{i}.type, 'taxi') % Taxi segment
        plot([x, x + 500], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Taxi (', num2str(i-1), '-', num2str(i), ')']);
        text([x, x + 500], [mission.segments{i}.altitude, mission.segments{i}.altitude], {num2str(i-1), num2str(i)});
        x = x + 500;
    elseif strcmp(mission.segments{i}.type, 'hover') % Hover segment
        plot([x, x + 500], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Hover (', num2str(i-1), '-', num2str(i), ')']);
        text(x + 500, mission.segments{i}.altitude, num2str(i));
        x = x + 500;
    elseif strcmp(mission.segments{i}.type, 'transition') % Transition segment
        plot([x, x + 500], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Transition (', num2str(i-1), '-', num2str(i), ')']);
        text(x + 500, mission.segments{i}.altitude, num2str(i));
        x = x + 500;
    elseif strcmp(mission.segments{i}.type, 'climb') % Climb segment
        plot([x, x + mission.segments{i}.range], [mission.segments{i}.altitude(1), mission.segments{i}.altitude(2)], 'DisplayName', ['Climb (', num2str(i-1), '-', num2str(i), ')']);
        text(x + mission.segments{i}.range, mission.segments{i}.altitude(2), num2str(i));
        x = x + mission.segments{i}.range;
    elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
        plot([x, x + mission.segments{i}.range], [mission.segments{i}.altitude(1), mission.segments{i}.altitude(2)], 'DisplayName', ['Vertical Climb (', num2str(i-1), '-', num2str(i), ')']);
        text(x + mission.segments{i}.range, mission.segments{i}.altitude(2), num2str(i));
        x = x + mission.segments{i}.range;
    elseif strcmp(mission.segments{i}.type, 'acceleration') % Acceleration segment
    elseif strcmp(mission.segments{i}.type, 'cruise') % Cruise segment
        plot([x, x + mission.segments{i}.range], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Cruise (', num2str(i-1), '-', num2str(i), ')']);
        text(x + mission.segments{i}.range, mission.segments{i}.altitude, num2str(i));
        x = x + mission.segments{i}.range;
    elseif strcmp(mission.segments{i}.type, 'hold') % Hold segment
        plot([x, x + mission.segments{i}.range], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Hold (', num2str(i-1), '-', num2str(i), ')']);
        text(x + mission.segments{i}.range, mission.segments{i}.altitude, num2str(i));
        x = x + mission.segments{i}.range;
    elseif strcmp(mission.segments{i}.type, 'descent') % Descent segment
        plot([x, x + mission.segments{i}.range], [mission.segments{i}.altitude(1), mission.segments{i}.altitude(2)], 'DisplayName', ['Descent (', num2str(i-1), '-', num2str(i), ')']);
        text(x + mission.segments{i}.range, mission.segments{i}.altitude(2), num2str(i));
        x = x + mission.segments{i}.range;
    elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
        plot([x, x + mission.segments{i}.range], [mission.segments{i}.altitude(1), mission.segments{i}.altitude(2)], 'DisplayName', ['Vertical Descent (', num2str(i-1), '-', num2str(i), ')']);
        text(x + mission.segments{i}.range, mission.segments{i}.altitude(2), num2str(i));
        x = x + mission.segments{i}.range;
    elseif strcmp(mission.segments{i}.type, 'drop') % Drop segment
        plot([x, x + 500], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Drop (', num2str(i-1), '-', num2str(i), ')']);
        text([x + 250, x + 500], [mission.segments{i}.altitude - 10, mission.segments{i}.altitude], {'\downarrow', num2str(i)});
        x = x + 500;
    elseif strcmp(mission.segments{i}.type, 'load') % Load segment
        plot([x, x + 500], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Load (', num2str(i-1), '-', num2str(i), ')']);
        text([x + 250, x + 500], [mission.segments{i}.altitude - 10, mission.segments{i}.altitude], {'\uparrow', num2str(i)});
        x = x + 500;
    elseif strcmp(mission.segments{i}.type, 'landing') % Landing segment
        plot([x, x + 500], [mission.segments{i}.altitude, mission.segments{i}.altitude], 'DisplayName', ['Landing (', num2str(i-1), '-', num2str(i), ')']);
        text(x + 500, mission.segments{i}.altitude, num2str(i));
        x = x + 500;
    end
end
