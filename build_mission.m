% Aircraft design tool
%
% Copyright (C) 2022 Mario Bras
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

function mission = build_mission(mission)
% Initialize mission parameters
mission.time = 0;
mission.range = 0;

% Iterate over mission segments
for i = 1 : length(mission.segments)
    [mission.segments{i}.temperature, mission.segments{i}.speed_sound, mission.segments{i}.pressure, mission.segments{i}.density] = atmosisa(mission.segments{i}.altitude);

    if ~isfield(mission.segments{i}, 'velocity')
        mission.segments{i}.velocity = 0;
    end

    if strcmp(mission.segments{i}.type, 'taxi') % Taxi segment
        mission.segments{i}.range = 0;
    elseif strcmp(mission.segments{i}.type, 'hover') % Hover segment
        mission.segments{i}.range = 0;
    elseif strcmp(mission.segments{i}.type, 'transition') % Transition segment
        mission.segments{i}.range = mean(mission.segments{i}.velocity) * mission.segments{i}.time;
    elseif strcmp(mission.segments{i}.type, 'climb') % Climb segment
        mission.segments{i}.time = (mission.segments{i}.altitude(2) - mission.segments{i}.altitude(1)) / mission.segments{i}.velocity / sind(mission.segments{i}.angle);
        mission.segments{i}.range = mission.segments{i}.velocity * mission.segments{i}.time * cosd(mission.segments{i}.angle);
    elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
        mission.segments{i}.time = (mission.segments{i}.altitude(2) - mission.segments{i}.altitude(1)) / mission.segments{i}.velocity;
        mission.segments{i}.range = 0;
    elseif strcmp(mission.segments{i}.type, 'acceleration') % Acceleration segment
        mission.segments{i}.range = mission.segments{i}.velocity * mission.segments{i}.time;
    elseif strcmp(mission.segments{i}.type, 'cruise') % Cruise segment
        mission.segments{i}.time = mission.segments{i}.range / mission.segments{i}.velocity;
    elseif strcmp(mission.segments{i}.type, 'hold') % Hold segment
        mission.segments{i}.range = mission.segments{i}.velocity * mission.segments{i}.time;
    % elseif strcmp(mission.segments{i}.type, 'combat') % Combat segment
        % TODO
    elseif strcmp(mission.segments{i}.type, 'descent') % Descent segment
        mission.segments{i}.time = abs(mission.segments{i}.altitude(2) - mission.segments{i}.altitude(1)) / abs(mission.segments{i}.velocity) / abs(sind(mission.segments{i}.angle));
        mission.segments{i}.range = abs(mission.segments{i}.velocity) * mission.segments{i}.time * abs(cosd(mission.segments{i}.angle));
    elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
        mission.segments{i}.time = abs(mission.segments{i}.altitude(2) - mission.segments{i}.altitude(1)) / abs(mission.segments{i}.velocity);
        mission.segments{i}.range = 0;
    elseif strcmp(mission.segments{i}.type, 'landing') % Landing segment
        mission.segments{i}.range = 0;
    elseif strcmp(mission.segments{i}.type, 'load_step') % Load step segment
        mission.segments{i}.range = 0;
    end

    mission.time = mission.time + mission.segments{i}.time;
    mission.range = mission.range + mission.segments{i}.range;
end
