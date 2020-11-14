% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function data = adt(filename, varargin)
%% Constants
global constants;
constants.g = 9.81; % m/s^2
constants.e = 0.85; % Oswald efficiency number.

%% Load project file
data = load_project(filename);

%% Concept
data.concept = ahp(data.concept);
print_concepts(data.concept)

% Add missing mission segment and vehicle component parameters
data.mission = build_mission(data.mission);
data.vehicle = build_vehicle(data.mission, data.vehicle);

%% Plot mission profile
plot_mission(data.mission);

%% Aerodynamics calculation
data.vehicle = aerodynamics(data.mission, data.vehicle);

% Take-off mass estimation
[data.mission, data.vehicle] = mtow(data.mission, data.vehicle, data.energy);

%% Design point calculation
data.vehicle = design_point(data.mission, data.vehicle, data.energy);

% Recalculate take-off mass based on updated values from design point
% [data.mission, data.vehicle] = mtow(data.mission, data.vehicle, data.energy);
% data.vehicle = design_point(data.mission, data.vehicle, data.energy);

%% Save new project file
if ~isempty(varargin)
    save_project(data, varargin{1})
end
