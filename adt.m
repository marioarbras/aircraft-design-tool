% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function adt(open_filename, varargin)
    
close all;

data = load_project(open_filename);

% Constants
constants.g = 9.81; % m/s^2
constants.e = 0.85; % Oswald efficiency number.

% Intermediate calculations
data.aircraft.propulsion.total_efficiency = data.aircraft.propulsion.prop_efficiency * data.aircraft.propulsion.gear_efficiency * data.aircraft.propulsion.em_efficiency * data.aircraft.propulsion.esc_efficiency * data.aircraft.propulsion.dist_efficiency;
data.mission.mf_prop = estimate_mf_prop(1.2, 0.04, 1.5, 0.3, 0.1, 0.5, data.aircraft.propulsion.config);
data.mission.mf_subs = estimate_mf_subs(data.mission.mf_prop, data.mission.mf_struct);

%% Concept
data.concept = ahp(data.concept);

%% Take-off mass estimation
[data.mission, data.aircraft] = mtow(data.mission, data.aircraft, constants);

%% Plot mission profile
plot_mission(data.mission);

%% Design point calculation
data.aircraft = design_point(data.mission, data.aircraft, constants);

%% Engine selection
data.mission.mf_prop = data.aircraft.propulsion.mass / data.aircraft.mass_to;

%% Lifting surface design
data.aircraft = lifting_surface(data.aircraft, data.mission.segments{3});

%% Fuselage design
data.aircraft = fuselage(data.aircraft, data.mission.segments{3});

%% Drag buildup
data.aircraft = drag_buildup(data.aircraft);

if ~isempty(varargin)
    save_project(data, varargin{1})
end
