function plot_mission(mission)

x = 0;

figure;
legend;
hold on;

% Iterate over mission segments
for i = 1 : length(mission.segments)
    if strcmp(mission.segments(i).type, 'taxi') % Taxi segment

    elseif strcmp(mission.segments(i).type, 'hover') % Hover segment

    elseif strcmp(mission.segments(i).type, 'climb') % Climb segment
        plot([x, x + mission.segments(i).range], [mission.segments(i).altitude(1), mission.segments(i).altitude(2)], 'DisplayName', 'Climb');
        x = x + mission.segments(i).range;
    elseif strcmp(mission.segments(i).type, 'vertical_climb') % Vertical climb segment
        plot([x, x + mission.segments(i).range], [mission.segments(i).altitude(1), mission.segments(i).altitude(2)], 'DisplayName', 'Vertical descent');
        x = x + mission.segments(i).range;
    elseif strcmp(mission.segments(i).type, 'acceleration') % Acceleration segment

    elseif strcmp(mission.segments(i).type, 'cruise') % Cruise segment
        plot([x, x + mission.segments(i).range], [mission.segments(i).altitude, mission.segments(i).altitude], 'DisplayName', 'Cruise');
        x = x + mission.segments(i).range;
    elseif strcmp(mission.segments(i).type, 'hold') % Hold segment
        plot([x, x + mission.segments(i).range], [mission.segments(i).altitude, mission.segments(i).altitude], 'DisplayName', 'Hold');
        x = x + mission.segments(i).range;
    elseif strcmp(mission.segments(i).type, 'descent') % Descent segment
        plot([x, x + mission.segments(i).range], [mission.segments(i).altitude(1), mission.segments(i).altitude(2)], 'DisplayName', 'Descent');
        x = x + mission.segments(i).range;
    elseif strcmp(mission.segments(i).type, 'vertical_descent') % Vertical descent segment
        plot([x, x + mission.segments(i).range], [mission.segments(i).altitude(1), mission.segments(i).altitude(2)], 'DisplayName', 'Vertical descent');
        x = x + mission.segments(i).range;
    elseif strcmp(mission.segments(i).type, 'landing') % Landing segment

    end
end
