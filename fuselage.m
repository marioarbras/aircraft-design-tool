function aircraft = fuselage(aircraft, segment)

% Iterate over aircraft lifting surfaces
for i = 1 : length(aircraft.fuselages)
    aircraft.fuselages(i).c_d0 = friction_coeff(aircraft.fuselages(i).l, segment.v, segment.speed_sound, segment.density, air_viscosity(segment.temperature)) *...
        form_factor(aircraft.fuselages(i).l / aircraft.fuselages(i).d) *...
        aircraft.fuselages(i).interf_fator *...
        aircraft.fuselages(i).s_wet / aircraft.fuselages(i).s_ref;
end

function f = form_factor(ld)
f = 1 + 60 / ld^3 + ld / 400;
