% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function aircraft = lifting_surface(aircraft, segment)

m = segment.v / segment.speed_sound;

% Iterate over aircraft lifting surfaces
for i = 1 : length(aircraft.lifting_surfaces)
    bb = sqrt(1 - m^2);
    aircraft.lifting_surfaces(i).cl_aa = aircraft.lifting_surfaces(i).airfoil.cl_aa * aircraft.lifting_surfaces(i).ar /...
        (2 + sqrt(4 + aircraft.lifting_surfaces(i).ar^2 * bb^2 * (1 + tand(aircraft.lifting_surfaces(i).sweep_tc_max)^2 / bb^2)));

    aircraft.lifting_surfaces(i).c_d0 = friction_coeff(aircraft.lifting_surfaces(i).c, segment.v, segment.speed_sound, segment.density, air_viscosity(segment.temperature)) *...
        form_factor(aircraft.lifting_surfaces(i).airfoil.xc_max, aircraft.lifting_surfaces(i).airfoil.tc_max, aircraft.lifting_surfaces(i).sweep_tc_max, m) *...
        aircraft.lifting_surfaces(i).interf_fator *...
        aircraft.lifting_surfaces(i).s_wet / aircraft.lifting_surfaces(i).s_ref;
end

function f = form_factor(xc_max, tc_max, sweep_tc_max, m)
f = (1 + 0.6 / xc_max * tc_max + 100 * tc_max^4) * 1.34 * m^0.18 * cosd(sweep_tc_max)^0.28;
