% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function vehicle = aero_analysis(mission, vehicle)

% Add missing segments vector to vehicle components
for i = 1 : length(vehicle.components)
    if (is_type(vehicle.components{i}, 'fuselage') || is_type(vehicle.components{i}, 'wing'))
        vehicle.components{i}.segments = repmat({struct()}, length(mission.segments), 1);
        for j = 1 : length(vehicle.components{i}.segments)
            vehicle.components{i}.segments{j}.name = mission.segments{j}.name;
            vehicle.components{i}.segments{j}.base_drag_coefficient = 0;
            vehicle.components{i}.segments{j}.lift_slope_coefficient = 0;
        end
    end
end


% Add missing segments vector to vehicle
vehicle.segments = repmat({struct()}, length(mission.segments), 1);
for i = 1 : length(vehicle.segments)
    vehicle.segments{i}.name = mission.segments{i}.name;
    vehicle.segments{i}.base_drag_coefficient = 0;
    vehicle.segments{i}.lift_slope_coefficient = 0;
end

main_wing = find_by_type(vehicle.components, 'wing.main');
main_wing_area_ref = main_wing.span * main_wing.mean_chord;

for i = 1 : length(vehicle.components)
    if is_type(vehicle.components{i}, 'fuselage')
        for j = 1 : length(mission.segments)
            [~, comp_segment_id] = find_by_name(vehicle.components{i}.segments, mission.segments{j}.name);

            vehicle.components{i}.segments{comp_segment_id}.base_drag_coefficient = friction_coeff(vehicle.components{i}.length, mean(abs(mission.segments{j}.velocity)), mean(mission.segments{j}.speed_sound), mean(mission.segments{j}.density), air_viscosity(mean(mission.segments{j}.temperature))) *...
                fuselage_form_factor(vehicle.components{i}.length, vehicle.components{i}.diameter) *...
                vehicle.components{i}.interf_factor *...
                vehicle.components{i}.area_wet / main_wing_area_ref;

            [~, vehicle_segment_id] = find_by_name(vehicle.segments, mission.segments{j}.name);

            vehicle.segments{vehicle_segment_id}.base_drag_coefficient = vehicle.segments{vehicle_segment_id}.base_drag_coefficient + vehicle.components{i}.segments{comp_segment_id}.base_drag_coefficient;
        end
    elseif is_type(vehicle.components{i}, 'wing')
        for j = 1 : length(mission.segments)
            [~, comp_segment_id] = find_by_name(vehicle.components{i}.segments, mission.segments{j}.name);

            m = mean(abs(mission.segments{j}.velocity)) / mean(mission.segments{j}.speed_sound);
            bb = sqrt(1 - m^2);

            vehicle.components{i}.segments{comp_segment_id}.lift_slope_coefficient = vehicle.components{i}.airfoil.lift_slope_coefficient * vehicle.components{i}.aspect_ratio /...
                (2 + sqrt(4 + vehicle.components{i}.aspect_ratio^2 * bb^2 * (1 + tand(vehicle.components{i}.sweep_tc_max)^2 / bb^2)));

            vehicle.components{i}.segments{comp_segment_id}.base_drag_coefficient = friction_coeff(vehicle.components{i}.mean_chord, mean(abs(mission.segments{j}.velocity)), mean(mission.segments{j}.speed_sound), mean(mission.segments{j}.density), air_viscosity(mean(mission.segments{j}.temperature))) *...
                wing_form_factor(vehicle.components{i}.airfoil.xc_max, vehicle.components{i}.airfoil.tc_max, vehicle.components{i}.sweep_tc_max, m) *...
                vehicle.components{i}.interf_factor *...
                vehicle.components{i}.area_wet / main_wing_area_ref;

            [~, vehicle_segment_id] = find_by_name(vehicle.segments, mission.segments{j}.name);

            vehicle.segments{vehicle_segment_id}.base_drag_coefficient = vehicle.segments{vehicle_segment_id}.base_drag_coefficient + vehicle.components{i}.segments{comp_segment_id}.base_drag_coefficient;
            vehicle.segments{vehicle_segment_id}.lift_slope_coefficient = vehicle.segments{vehicle_segment_id}.lift_slope_coefficient + vehicle.components{i}.segments{comp_segment_id}.lift_slope_coefficient;
        end
    end
end

function f = fuselage_form_factor(l, d)
ld = l / d;
f = 1 + 60 / ld^3 + ld / 400;

function f = wing_form_factor(xc_max, tc_max, sweep_tc_max, m)
f = (1 + 0.6 / xc_max * tc_max + 100 * tc_max^4) * 1.34 * m^0.18 * cosd(sweep_tc_max)^0.28;
