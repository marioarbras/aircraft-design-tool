% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function aircraft = fuselage(aircraft, segment)

% Iterate over aircraft lifting surfaces
for i = 1 : length(aircraft.fuselages)
    aircraft.fuselages{i}.c_d0 = friction_coeff(aircraft.fuselages{i}.length, segment.velocity, segment.speed_sound, segment.density, air_viscosity(segment.temperature)) *...
        form_factor(aircraft.fuselages{i}.length / aircraft.fuselages{i}.diameter) *...
        aircraft.fuselages{i}.interf_factor *...
        aircraft.fuselages{i}.area_wet / aircraft.fuselages{i}.area_ref;
end

function f = form_factor(ld)
f = 1 + 60 / ld^3 + ld / 400;
