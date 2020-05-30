% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

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

% Aircraft
if isfield(data, 'aircraft')
    if ~iscell(data.aircraft.fuselages)
        data.aircraft.fuselages = num2cell(data.aircraft.fuselages);
    end

    if ~iscell(data.aircraft.lifting_surfaces)
        data.aircraft.lifting_surfaces = num2cell(data.aircraft.lifting_surfaces);
    end
end
