% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function aircraft = lift_slope(aircraft, mission)

% Iterate over aircraft lifting surfaces
for i = 1 : length(mission.segments)
    for j = 1 : length(aircraft.components)
        aircraft.components{j}.cl_aa = zeros(length(mission.segments), 1);
        if is_wing(aircraft.components{j})
            m = mean(mission.segments{i}.velocity) / mean(mission.segments{i}.speed_sound);
            bb = sqrt(1 - m^2);
            aircraft.components{j}.cl_aa = aircraft.components{j}.airfoil.cl_aa * aircraft.components{j}.aspect_ratio /...
                (2 + sqrt(4 + aircraft.components{j}.aspect_ratio^2 * bb^2 * (1 + tand(aircraft.components{j}.sweep_tc_max)^2 / bb^2)));
        end
    end
end

function f = form_factor(xc_max, tc_max, sweep_tc_max, m)
f = (1 + 0.6 / xc_max * tc_max + 100 * tc_max^4) * 1.34 * m^0.18 * cosd(sweep_tc_max)^0.28;

function test = is_fuselage(component)
test = strcmp(component.type, 'fuselage');

function test = is_wing(component)
test = strcmp(component.type, 'wing');
