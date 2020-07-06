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
    if ~iscell(data.aircraft.propulsion_types)
        data.aircraft.propulsion_types = num2cell(data.aircraft.propulsion_types);
    end
    
    if ~iscell(data.aircraft.energy_sources)
        data.aircraft.energy_sources = num2cell(data.aircraft.energy_sources);
    end

    if ~iscell(data.aircraft.components)
        data.aircraft.components = num2cell(data.aircraft.components);
    end
end
