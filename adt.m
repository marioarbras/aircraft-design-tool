% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function data = adt(filename, varargin)
%% Load project file
data = load_project(filename);

%% Concept
data.concept = ahp(data.concept);
print_concepts(data.concept)

%% Constants and intermediate calculations
constants.g = 9.81; % m/s^2
constants.e = 0.85; % Oswald efficiency number.

% Build mission profile
data.mission = build_mission(data.mission);

%% Plot mission profile
plot_mission(data.mission);

% Take-off mass estimation
[data.mission, data.aircraft] = mtow(data.mission, data.aircraft, constants);

%% Design point calculation
data.aircraft = design_point(data.mission, data.aircraft, constants);

% Recalculate take-off mass based on updated values from design point
% [data.mission, data.aircraft] = mtow(data.mission, data.aircraft, constants);
% data.aircraft = design_point(data.mission, data.aircraft, constants);

%% Lift curve slope
data.aircraft = lift_slope(data.aircraft, data.mission);

%% Drag buildup
data.aircraft = drag_buildup(data.aircraft, data.mission);

%% Save new project file
if ~isempty(varargin)
    save_project(data, varargin{1})
end
