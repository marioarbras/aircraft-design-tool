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

function data = load_project(filename)

data = jsondecode(fileread(filename));

% File schema
if isfield(data, 'x_schema')
    data = rmfield(data, 'x_schema');
end

% Concept
if isfield(data, 'concept')
    if ~iscell(data.concept.designs)
        data.concept.designs = num2cell(data.concept.designs);
    end
end

% Mission
if isfield(data, 'mission')
    if ~iscell(data.mission.segments)
        data.mission.segments = num2cell(data.mission.segments);
    end
end

% Vehicle
if isfield(data, 'vehicle')
    if ~iscell(data.vehicle.components)
        data.vehicle.components = num2cell(data.vehicle.components);
    end

    for i = 1 : length(data.vehicle.components)
        if isfield(data.vehicle.components{i}, 'segments')
            if ~iscell(data.vehicle.components{i}.segments)
                data.vehicle.components{i}.segments = num2cell(data.vehicle.components{i}.segments);
            end
        end
    end

    if isfield(data.vehicle, 'segments')
        if ~iscell(data.vehicle.segments)
            data.vehicle.segments = num2cell(data.vehicle.segments);
        end
    end
end

% Energy
if isfield(data, 'energy')
    if ~iscell(data.energy.networks)
        data.energy.networks = num2cell(data.energy.networks);
        for i = 1 : length(data.energy.networks)
            if ~iscell(data.energy.networks{i}.layout)
                data.energy.networks{i}.layout = num2cell(data.energy.networks{i}.layout);
            end
        end
    end
end
