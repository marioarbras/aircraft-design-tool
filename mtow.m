% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function [mission, aircraft] = mtow(mission, aircraft, constants)
mass_to = fsolve(@(x)mtow_error(x, mission, aircraft, constants), 0, optimoptions('fsolve', 'Display','none'));
[~, mission, aircraft] = mtow_error(mass_to, mission, aircraft, constants);

function i = find_energy_source_index(aircraft, energy_source)
for i = 1 : length(aircraft.energy_sources)
    if strcmp(aircraft.energy_sources{i}.name, energy_source)
        break;
    end
end

function i = find_propulsion_type_index(aircraft, propulsion_type)
for i = 1 : length(aircraft.propulsion_types)
    if strcmp(aircraft.propulsion_types{i}.name, propulsion_type)
        break;
    end
end

function test = is_fuel(energy_source)
test = strcmp(energy_source.type, 'fuel');

function test = is_electric(energy_source)
test = strcmp(energy_source.type, 'electric');

function test = is_jet(propulsion)
test = strcmp(propulsion.type, 'jet');

function test = is_prop(propulsion)
test = strcmp(propulsion.type, 'prop');

function ld = get_ld(performance, segment, propulsion_type)
if strcmp(segment.type, 'cruise')
    if is_jet(propulsion_type)
        ld = 0.886 * performance.ld_max;
    elseif is_prop(propulsion_type)
        ld = performance.ld_max;
    end
elseif strcmp(segment.type, 'hold')
    if is_jet(propulsion_type)
        ld = performance.ld_max;
    elseif is_prop(propulsion_type)
        ld = 0.886 * performance.ld_max;
    end
end

function [err, mission, aircraft] = mtow_error(mass_to, mission, aircraft, constants)

% Initialize mission and aircraft parameters
mission.time = 0;
mission.range = 0;

mf_batt = 0;
mf_fuel = 0;
mass_ac = mass_to;

for i = 1 : length(aircraft.energy_sources)
    aircraft.energy_sources{i}.mass = 0;
end

% Iterate over mission segments
for i = 1 : length(mission.segments)
    [mission.segments{i}.temperature, mission.segments{i}.speed_sound, mission.segments{i}.pressure, mission.segments{i}.density] = atmosisa(mission.segments{i}.altitude);

    if strcmp(mission.segments{i}.type, 'taxi') % Taxi segment
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        if is_fuel(aircraft.energy_sources{ei})
            mf_fuel = 1 - 0.9725;
        elseif is_electric(aircraft.energy_sources{ei})
            mf_batt = 0;
        end
    elseif strcmp(mission.segments{i}.type, 'hover') % Hover segment
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        if is_fuel(aircraft.energy_sources{ei})
            errordlg('Not available'); % NOT AVAILABLE
            break;
        elseif is_electric(aircraft.energy_sources{ei})
            pl = aircraft.propulsion_types{pti}.fm * sqrt(2 * mission.segments{i}.density / aircraft.performance.disc_loading);
            mf_batt = mission.segments{i}.time * constants.g / aircraft.energy_sources{ei}.specific_energy / aircraft.propulsion_types{pti}.efficiency / aircraft.energy_sources{ei}.efficiency / pl;
        end
    elseif strcmp(mission.segments{i}.type, 'climb') % Climb segment
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        if is_fuel(aircraft.energy_sources{ei})
            mach = mission.segments{i}.velocity / mission.segments{i}.speed_sound(1);
            if mach < 1
                mf_fuel = 1 - (1 - 0.04 * mach);
            else
                mf_fuel = 1 - (0.96 - 0.03 * (mach - 1));
            end
        elseif is_electric(aircraft.energy_sources{ei})
            errordlg('Not available'); % NOT AVAILABLE
            break;
        end
    elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
        altitude_range = mission.segments{i}.altitude(2) - mission.segments{i}.altitude(1);
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        if is_fuel(aircraft.energy_sources{ei})
            errordlg('Not available'); % NOT AVAILABLE
            break;
        elseif is_electric(aircraft.energy_sources{ei})
            pl = 1 / (mission.segments{i}.velocity - aircraft.propulsion_types{pti}.k_i / 2 * mission.segments{i}.velocity + aircraft.propulsion_types{pti}.k_i / 2 * sqrt(mission.segments{i}.velocity^2 + 2 * aircraft.performance.disc_loading / mission.segments{i}.density(1)) + mission.segments{i}.density(1) * aircraft.propulsion_types{pti}.tip_velocity^3 / aircraft.performance.disc_loading * aircraft.propulsion_types{pti}.ss * aircraft.propulsion_types{pti}.cd / 8); % Power loading
            mf_batt = altitude_range * constants.g / aircraft.energy_sources{ei}.specific_energy / aircraft.propulsion_types{pti}.efficiency / aircraft.energy_sources{ei}.efficiency / pl / mission.segments{i}.velocity; % Mass fraction for this segment
        end
    elseif strcmp(mission.segments{i}.type, 'acceleration') % Acceleration segment
        mach = mission.segments{i}.velocity / mission.segments{i}.a;
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        if is_fuel(aircraft.energy_sources{ei})
            if i > 1 && mach == mission.segment{i - 1}.velocity / mission.segments{i - 1}.a
                mf_fuel = 0;
            elseif mach < 1
                mf_fuel = 1 - (1 - 0.04 * mach);
            else
                mf_fuel = 1 - (0.96 - 0.03 * (mach - 1));
            end
        elseif is_electric(aircraft.energy_sources{ei})
            errordlg('Not available'); % NOT AVAILABLE
            break;
        end
    elseif strcmp(mission.segments{i}.type, 'cruise') % Cruise segment
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        ld = get_ld(aircraft.performance, mission.segments{i}, aircraft.propulsion_types{pti});
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        
        if is_fuel(aircraft.energy_sources{ei})
            mf_fuel = 1 - exp(-mission.segments{i}.range * aircraft.propulsion_types{pti}.specific_fuel_consumption / mission.segments{i}.velocity / ld);
        elseif is_electric(aircraft.energy_sources{ei})
            mf_batt = mission.segments{i}.range * constants.g / aircraft.energy_sources{ei}.specific_energy / aircraft.propulsion_types{pti}.efficiency / aircraft.energy_sources{ei}.efficiency / ld;
        end
    elseif strcmp(mission.segments{i}.type, 'hold') % Hold segment
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        ld = get_ld(aircraft.performance, mission.segments{i}, aircraft.propulsion_types{pti});
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        if is_fuel(aircraft.energy_sources{ei})
            mf_fuel = 1 - exp(-mission.segments{i}.time * aircraft.propulsion_types{pti}.specific_fuel_consumption / ld);
        elseif is_electric(aircraft.energy_sources{ei})
            mf_batt = mission.segments{i}.time * mission.segments{i}.velocity * constants.g / aircraft.energy_sources{ei}.specific_energy / aircraft.propulsion_types{pti}.efficiency / aircraft.energy_sources{ei}.efficiency / ld;
        end
    elseif strcmp(mission.segments{i}.type, 'combat') % Combat segment
    %     ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
    %     if is_fuel(aircraft.energy_sources{ei})
    %         % mf_fuel = 1 - % TODO
    %     elseif is_electric(aircraft.energy_sources{ei})
    %         errordlg('Not available'); % NOT AVAILABLE
    %         break;
    %     end
    elseif strcmp(mission.segments{i}.type, 'descent') % Descent segment
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        if is_fuel(aircraft.energy_sources{ei})
            mf_fuel = 0;
        elseif is_electric(aircraft.energy_sources{ei})
            mf_batt = 0;
        end
    elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
        altitude_range = abs(mission.segments{i}.altitude(2) - mission.segments{i}.altitude(1));
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        if is_fuel(aircraft.energy_sources{ei})
            errordlg('Not available'); % NOT AVAILABLE
            break;
        elseif is_electric(aircraft.energy_sources{ei})
            v_i = sqrt(aircraft.performance.disc_loading / 2 / mission.segments{i}.density(2)); % Induced velocity in hover
            if mission.segments{i}.velocity / v_i <= -2 % If this condition is met, the vertical climb equation is used for descent, else, an empirical equation is employed
                pl = 1 / (mission.segments{i}.velocity - aircraft.propulsion_types{pti}.k_i / 2 * (mission.segments{i}.velocity + sqrt(mission.segments{i}.velocity^2 - 2 * aircraft.performance.disc_loading / mission.segments{i}.density(2))) + mission.segments{i}.density(2) * aircraft.propulsion_types{pti}.tip_velocity^3 / aircraft.performance.disc_loading * aircraft.propulsion_types{pti}.ss * aircraft.propulsion_types{pti}.cd / 8);
            else
                v_d = v_i * (aircraft.propulsion_types{pti}.k_i - 1.125 * mission.segments{i}.velocity / v_i - 1.372 * (mission.segments{i}.velocity / v_i)^2 - 1.718 * (mission.segments{i}.velocity / v_i)^3 - 0.655 * (mission.segments{i}.velocity / v_i)^4); % Induced velocity in descent according to an empirical relation (see lecture slides)
                pl = 1 / (mission.segments{i}.velocity + aircraft.propulsion_types{pti}.k_i * v_d + mission.segments{i}.density(2) * aircraft.propulsion_types{pti}.tip_velocity^3 / aircraft.performance.disc_loading * aircraft.propulsion_types{pti}.ss * aircraft.propulsion_types{pti}.cd / 8);
            end

            if pl > 0
                mf_batt = altitude_range * constants.g / aircraft.energy_sources{ei}.specific_energy / aircraft.propulsion_types{pti}.efficiency / aircraft.energy_sources{ei}.efficiency / pl / abs(mission.segments{i}.velocity);
            else
                mf_batt = 0;
            end
        end
    elseif strcmp(mission.segments{i}.type, 'landing') % Landing segment
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        if is_fuel(aircraft.energy_sources{ei})
            mf_fuel = 1 - 0.9725;
        elseif is_electric(aircraft.energy_sources{ei})
            mf_batt = 0;
        end
    elseif strcmp(mission.segments{i}.type, 'drop') % Drop segment
        mass_ac = mass_ac - mission.segments{i}.mass_drop;
    elseif strcmp(mission.segments{i}.type, 'load') % Load segment
        mass_ac = mass_ac + mission.segments{i}.mass_reload;
    end
    
    % Accumulate mission parameters
    if isfield(mission.segments{i}, "energy_source")
        ei = find_energy_source_index(aircraft, mission.segments{i}.energy_source);
        if is_fuel(aircraft.energy_sources{ei})
            aircraft.energy_sources{ei}.mass = aircraft.energy_sources{ei}.mass + mf_fuel * mass_ac;
            mass_ac = mass_ac - aircraft.energy_sources{ei}.mass; % Aircraft mass at end of segment
        elseif is_electric(aircraft.energy_sources{ei})
            aircraft.energy_sources{ei}.mass = aircraft.energy_sources{ei}.mass + mf_batt * mass_to;
        end
    end
    mission.time = mission.time + mission.segments{i}.time;
    mission.range = mission.range + mission.segments{i}.range;
end

% Accumulate energy mass
energy_mass = 0;
for i = 1 : length(aircraft.energy_sources)
    energy_mass = energy_mass + aircraft.energy_sources{i}.mass;
    if isfield(aircraft.energy_sources{i}, 'reserve')
        energy_mass = energy_mass + aircraft.energy_sources{i}.mass * aircraft.energy_sources{i}.reserve;
    end
end

% Accumulate propulsion mass
propulsion_mass = 0;
for i = 1 : length(aircraft.propulsion_types)
    propulsion_mass = propulsion_mass + aircraft.propulsion_types{i}.mass;
end

aircraft.mass = mass_to;

err = aircraft.mass - energy_mass - propulsion_mass - aircraft.payload.mass - aircraft.structure.mass - aircraft.subsystems.mass;
