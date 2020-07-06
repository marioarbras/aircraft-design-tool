% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function aircraft = drag_buildup(aircraft, mission)

% Iterate over aircraft components
aircraft.performance.cd_0 = zeros(length(mission.segments), 1);
for i = 1 : length(mission.segments)
    for j = 1 : length(aircraft.components)
        aircraft.components{j}.cd_0 = zeros(length(mission.segments), 1);
        if is_fuselage(aircraft.components{j})
            aircraft.components{j}.cd_0(i) = friction_coeff(aircraft.components{j}.length, mission.segments{i}.velocity, mission.segments{i}.speed_sound, mission.segments{i}.density, air_viscosity(mission.segments{i}.temperature)) *...
                fuselage_form_factor(aircraft.components{j}.length / aircraft.components{j}.diameter) *...
                aircraft.components{j}.interf_factor *...
                aircraft.components{j}.area_wet / aircraft.components{j}.area_ref;
        elseif is_wing(aircraft.components{j})
            m = mean(mission.segments{i}.velocity) / mean(mission.segments{i}.speed_sound);
            bb = sqrt(1 - m^2);
            aircraft.components{j}.cl_aa = aircraft.components{j}.airfoil.cl_aa * aircraft.components{j}.aspect_ratio /...
                (2 + sqrt(4 + aircraft.components{j}.aspect_ratio^2 * bb^2 * (1 + tand(aircraft.components{j}.sweep_tc_max)^2 / bb^2)));

            aircraft.components{j}.cd_0 = friction_coeff(aircraft.components{j}.mean_chord, mission.segments{i}.velocity, mission.segments{i}.speed_sound, mission.segments{i}.density, air_viscosity(mission.segments{i}.temperature)) *...
                wing_form_factor(aircraft.components{j}.airfoil.xc_max, aircraft.components{j}.airfoil.tc_max, aircraft.components{j}.sweep_tc_max, m) *...
                aircraft.components{j}.interf_factor *...
                aircraft.components{j}.area_wet / aircraft.components{j}.area_ref;
        end

        aircraft.performance.cd_0 = aircraft.performance.cd_0 + aircraft.components{j}.cd_0 .* aircraft.components{j}.area_ref;
    end
end
aircraft.performance.cd_0 = aircraft.performance.cd_0 ./ aircraft.performance.area_ref;

function f = fuselage_form_factor(ld)
f = 1 + 60 / ld^3 + ld / 400;

function f = wing_form_factor(xc_max, tc_max, sweep_tc_max, m)
f = (1 + 0.6 / xc_max * tc_max + 100 * tc_max^4) * 1.34 * m^0.18 * cosd(sweep_tc_max)^0.28;

function test = is_fuselage(component)
test = strcmp(component.type, 'fuselage');

function test = is_wing(component)
test = strcmp(component.type, 'wing');
