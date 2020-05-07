% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function data = load_project(filename)

data = jsondecode(fileread(filename));

if ~iscell(data.mission.segments)
    data.mission.segments = num2cell(data.mission.segments);
end

if ~iscell(data.aircraft.fuselages)
    data.aircraft.fuselages = num2cell(data.aircraft.fuselages);
end

if ~iscell(data.aircraft.lifting_surfaces)
    data.aircraft.lifting_surfaces = num2cell(data.aircraft.lifting_surfaces);
end
