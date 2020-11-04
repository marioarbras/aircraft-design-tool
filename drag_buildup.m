% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function aircraft = drag_buildup(aircraft, mission)

% Iterate over aircraft components
for i = 1 : length(aircraft.components)
    if is_fuselage(aircraft.components{i})
        aircraft.components{i}.area_wet = fuselage_area_wet(aircraft.components{i}.length, aircraft.components{i}.diameter);
    elseif is_wing(aircraft.components{i})
        aircraft.components{i}.area_ref = aircraft.components{i}.span * aircraft.components{i}.mean_chord;
        aircraft.components{i}.area_wet = wing_area_wet(aircraft.components{i}.airfoil.tc_max, aircraft.components{i}.area_ref);
    end
end

cd_0 = zeros(length(mission.segments), 1);
for i = 1 : length(aircraft.components)
    aircraft.components{i}.cd_0 = zeros(length(mission.segments), 1);
    for j = 1 : length(mission.segments)
        if is_fuselage(aircraft.components{i})
            aircraft.components{i}.cd_0(j) = friction_coeff(aircraft.components{i}.length, mean(mission.segments{j}.velocity), mean(mission.segments{j}.speed_sound), mean(mission.segments{j}.density), air_viscosity(mean(mission.segments{j}.temperature))) *...
                fuselage_form_factor(aircraft.components{i}.length, aircraft.components{i}.diameter) *...
                aircraft.components{i}.interf_factor *...
                aircraft.components{i}.area_wet / aircraft.performance.wing_area_ref;
        elseif is_wing(aircraft.components{i})
            m = mean(mission.segments{j}.velocity) / mean(mission.segments{j}.speed_sound);
            bb = sqrt(1 - m^2);
            aircraft.components{i}.cl_aa(j) = aircraft.components{i}.airfoil.cl_aa * aircraft.components{i}.aspect_ratio /...
                (2 + sqrt(4 + aircraft.components{i}.aspect_ratio^2 * bb^2 * (1 + tand(aircraft.components{i}.sweep_tc_max)^2 / bb^2)));

            aircraft.components{i}.cd_0(j) = friction_coeff(aircraft.components{i}.mean_chord, mean(mission.segments{j}.velocity), mean(mission.segments{j}.speed_sound), mean(mission.segments{j}.density), air_viscosity(mean(mission.segments{j}.temperature))) *...
                wing_form_factor(aircraft.components{i}.airfoil.xc_max, aircraft.components{i}.airfoil.tc_max, aircraft.components{i}.sweep_tc_max, m) *...
                aircraft.components{i}.interf_factor *...
                aircraft.components{i}.area_wet / aircraft.performance.wing_area_ref;
        end
    end
    cd_0 = cd_0 + aircraft.components{i}.cd_0;
end
aircraft.performance.cd_0 = max(cd_0);

function f = fuselage_form_factor(l, d)
ld = l / d;
f = 1 + 60 / ld^3 + ld / 400;

function f = wing_form_factor(xc_max, tc_max, sweep_tc_max, m)
f = (1 + 0.6 / xc_max * tc_max + 100 * tc_max^4) * 1.34 * m^0.18 * cosd(sweep_tc_max)^0.28;

function a = fuselage_area_wet(l, d)
a = pi() * d * l + pi() * d^2;

function a = wing_area_wet(tc_max, wing_area_ref)
if (tc_max > 0.05)
    a = (1.977 + 0.52 * tc_max) * wing_area_ref;
else
    a = 2.003 * wing_area_ref;
end

function test = is_fuselage(component)
test = strcmp(component.type, 'fuselage');

function test = is_wing(component)
test = strcmp(component.type, 'wing');
