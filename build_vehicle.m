% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function vehicle = build_vehicle(mission, vehicle)
% Add missing area_ref and area_wet to fuselage and wing components
for i = 1 : length(vehicle.components)
    if is_type(vehicle.components{i}, 'fuselage')
        vehicle.components{i}.area_wet = fuselage_area_wet(vehicle.components{i}.length, vehicle.components{i}.diameter);
    elseif is_type(vehicle.components{i}, 'wing')
        vehicle.components{i}.span = vehicle.components{i}.aspect_ratio * vehicle.components{i}.mean_chord;
        vehicle.components{i}.area_ref = vehicle.components{i}.span * vehicle.components{i}.mean_chord;
        vehicle.components{i}.area_wet = wing_area_wet(vehicle.components{i}.airfoil.tc_max, vehicle.components{i}.area_ref);
    end
end

function a = fuselage_area_wet(l, d)
a = pi() * d * l + pi() * d^2;

function a = wing_area_wet(tc_max, wing_area_ref)
if (tc_max > 0.05)
    a = (1.977 + 0.52 * tc_max) * wing_area_ref;
else
    a = 2.003 * wing_area_ref;
end
