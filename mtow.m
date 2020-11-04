% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function [mission, vehicle] = mtow(mission, vehicle, energy)

mass_to = fsolve(@(x)mtow_error(x, mission, vehicle, energy), sum_masses(vehicle), optimoptions('fsolve', 'Display','none'));
[~, mission, vehicle] = mtow_error(mass_to, mission, vehicle, energy);

function mass = sum_masses(vehicle)
mass = 0;
for i = 1 : length(vehicle.components)
    m = vehicle.components{i}.mass;

    if isfield(vehicle.components{i}, 'reserve')
        m = m * vehicle.components{i}.reserve;
    end

    if isfield(vehicle.components{i}, 'number')
        m = m * vehicle.components{i}.number;
    end
    
    mass = mass + m;
end

function [elem, id] = find_by_name(data, name)
elem = struct();
id = 0;
for i = 1 : length(data)
    if strcmp(data{i}.name, name)
        elem = data{i};
        id = i;
        return;
    end
end

function [elem, id] = find_by_type(data, type)
elem = struct();
id = [];
type_tags = split(type, '.');
for i = 1 : length(data)
    match = true;

    elem_tags = split(data{i}.type, '.');
    for j = 1 : length(type_tags)
        if ~strcmp(elem_tags{j}, type_tags{j})
            match = false;
            break;
        end
    end
    
    if (match == true)
        elem = data{i};
        id = i;
        return;
    end
end

% function [elems, ids] = find_by_type(data, type)
% elems = {};
% ids = [];
% type_tags = split(type, '.');
% for i = 1 : length(data)
%     match = true;

%     elem_tags = split(data{i}.type, '.');
%     for j = 1 : length(type_tags)
%         if ~strcmp(elem_tags{j}, type_tags{j})
%             match = false;
%             break;
%         end
%     end
    
%     if (match == true)
%         elems = [elems data{i}];
%         ids = [ids i];
%     end
% end

function [elems, ids] = find_network_components(vehicle, network)
elems = {};
ids = [];
for i = 1 : length(network.layout)
    for j = 1 : length(vehicle.components)
        if strcmp(network.layout{i}.name, vehicle.components{j}.name)
            e = vehicle.components{j};
            fields = fieldnames(network.layout{i});
            for k = 1 : length(fields)
                e.(fields{k}) = network.layout{i}.(fields{k});
            end
            elems = [elems e];
            ids = [ids j];
            break;
        end
    end
end

function mf_fuel = breguet(range, velocity, sfc, ld)
mf_fuel = 1 - exp(-range * sfc / velocity / ld);

function a = area(rotor)
a = pi() * rotor.radius^2;
if isfield(rotor, 'number')
    a = a * rotor.number;
end

function dl = disc_loading(area, weight)
dl = weight / area;

function e = network_efficiency(network)
e = 1.0;
for i = 1 : length(network)
    e = e * network{i}.efficiency;
end

function test = is_type(data, type)
test = strcmp(data.type, type);

function ld = estimate_ld_max(vehicle)
c = find_by_type(vehicle.components, 'wing.main');
ld = c.aspect_ratio + 10;

function ld = get_ld(vehicle, segment, engine)
ld_max = estimate_ld_max(vehicle);
if strcmp(segment.type, 'cruise')
    if is_type(engine, 'engine.jet')
        ld = 0.886 * ld_max;
    elseif is_type(engine, 'engine.prop')
        ld = ld_max;
    end
elseif strcmp(segment.type, 'hold')
    if is_type(engine, 'engine.jet')
        ld = ld_max;
    elseif is_type(engine, 'engine.prop')
        ld = 0.886 * ld_max;
    end
end

function vehicle = taxi(segment, vehicle, energy)
[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');

if is_type(source, 'energy.fuel')
    mf_fuel = 1 - 0.9725;
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_fuel * vehicle.mass;
    vehicle.mass = vehicle.mass - source.mass;
end

function vehicle = hover(segment, vehicle, energy)
global constants;

[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');

if is_type(source, 'energy.fuel')
    errordlg('Not available'); % NOT AVAILABLE
    return;
elseif is_type(source, 'energy.electric')
    rotor = find_by_type(network, 'driver.rotor');

    dl = disc_loading(area(rotor), vehicle.mass * constants.g);
    pl = rotor.efficiency * sqrt(2 * segment.density / dl);
    mf_batt = segment.time * constants.g / source.specific_energy / network_efficiency(network) / pl;
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_batt * vehicle.mass;
end

function vehicle = climb(segment, vehicle, energy)
[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');

if is_type(source, 'energy.fuel')
    mach = segment.velocity / segment.speed_sound(1);
    if mach < 1
        mf_fuel = 1 - (1 - 0.04 * mach);
    else
        mf_fuel = 1 - (0.96 - 0.03 * (mach - 1));
    end
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_fuel * vehicle.mass;
    vehicle.mass = vehicle.mass - source.mass;
elseif is_type(source, 'energy.electric')
    errordlg('Not available'); % NOT AVAILABLE
    return;
end

function vehicle = vertical_climb(segment, vehicle, energy)
global constants;

[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');

if is_type(source, 'energy.fuel')
    errordlg('Not available'); % NOT AVAILABLE
    return;
elseif is_type(source, 'energy.electric')
    rotor = find_by_type(network, 'driver.rotor');

    altitude_range = segment.altitude(2) - segment.altitude(1);
    dl = disc_loading(area(rotor), vehicle.mass * constants.g);
    pl = 1 / (segment.velocity - rotor.induced_power_factor / 2 * segment.velocity + rotor.induced_power_factor / 2 * sqrt(segment.velocity^2 + 2 * dl / segment.density(1)) + segment.density(1) * rotor.tip_velocity^3 / dl * rotor.rotor_solidity * rotor.base_drag_coefficient / 8); % Power loading
    mf_batt = altitude_range * constants.g / source.specific_energy / network_efficiency(network) / pl / segment.velocity; % Mass fraction for this segment
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_batt * vehicle.mass;
end


function vehicle = acceleration(segment, prev_segment, vehicle, energy)
[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');

mach = segment.velocity / segment.speed_sound;

if is_type(source, 'energy.fuel')
    if mach == prev_segment.velocity / prev_segment.speed_sound
        mf_fuel = 0;
    elseif mach < 1
        mf_fuel = 1 - (1 - 0.04 * mach);
    else
        mf_fuel = 1 - (0.96 - 0.03 * (mach - 1));
    end
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_fuel * vehicle.mass;
    vehicle.mass = vehicle.mass - source.mass;
elseif is_type(source, 'energy.electric')
    errordlg('Not available'); % NOT AVAILABLE
    return;
end

function vehicle = cruise(segment, vehicle, energy)
global constants;

[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');
engine = find_by_type(network, 'engine');

ld = get_ld(vehicle, segment, engine);

if is_type(source, 'energy.fuel')
    if is_type(engine, 'engine.jet')
        mf_fuel = breguet(segment.range, segment.velocity, engine.specific_fuel_consumption, ld);
    elseif is_type(engine, 'engine.prop')
        prop = find_by_type(network, 'driver.propeller');
        sfc = engine.brake_specific_fuel_consumption * segment.velocity / prop.efficiency;
        mf_fuel = breguet(segment.range, segment.velocity, sfc, ld);
    end
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_fuel * vehicle.mass;
    vehicle.mass = vehicle.mass - source.mass;
elseif is_type(source, 'energy.electric')
    mf_batt = segment.range * constants.g / source.specific_energy / network_efficiency(network) / ld;
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_batt * vehicle.mass;
end


function vehicle = hold(segment, vehicle, energy)
global constants;

[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');
engine = find_by_type(network, 'engine');

ld = get_ld(vehicle, segment, engine);

if is_type(source, 'energy.fuel')
    if is_type(engine, 'engine.jet')
        mf_fuel = breguet(segment.range, segment.velocity, engine.specific_fuel_consumption, ld);
    elseif is_type(engine, 'engine.prop')
        prop = find_by_type(network, 'driver.propeller');
        sfc = engine.brake_specific_fuel_consumption * segment.velocity / prop.efficiency;
        mf_fuel = breguet(segment.range, segment.velocity, sfc, ld);
    end
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_fuel * vehicle.mass;
    vehicle.mass = vehicle.mass - source.mass;
elseif is_type(source, 'energy.electric')
    mf_batt = segment.time * segment.velocity * constants.g / source.specific_energy / network_efficiency(network) / ld;
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_batt * vehicle.mass;
end

function vehicle = descent(segment, vehicle, energy)
% [network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
% [source, source_id] = find_by_type(network, 'energy');

% if is_type(source, 'energy.fuel')
%     % mf_fuel = 0;
% elseif is_type(source, 'energy.electric')
%     % mf_batt = 0;
% end


function vehicle = vertical_descent(segment, vehicle, energy)
global constants;

[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');
engine = find_by_type(network, 'engine');
rotor = find_by_type(network, 'driver.rotor');

altitude_range = abs(segment.altitude(2) - segment.altitude(1));

if is_type(source, 'energy.fuel')
    errordlg('Not available'); % NOT AVAILABLE
    return;
elseif is_type(source, 'energy.electric')
    dl = disc_loading(area(rotor), vehicle.mass * constants.g);
    v_i = sqrt(dl / 2 / segment.density(2)); % Induced velocity in hover
    if segment.velocity / v_i <= -2 % If this condition is met, the vertical climb equation is used for descent, else, an empirical equation is employed
        pl = 1 / (segment.velocity - rotor.induced_power_factor / 2 * (segment.velocity + sqrt(segment.velocity^2 - 2 * dl / segment.density(2))) + segment.density(2) * rotor.tip_velocity^3 / dl * rotor.rotor_solidity * rotor.base_drag_coefficient / 8);
    else
        v_d = v_i * (rotor.induced_power_factor - 1.125 * segment.velocity / v_i - 1.372 * (segment.velocity / v_i)^2 - 1.718 * (segment.velocity / v_i)^3 - 0.655 * (segment.velocity / v_i)^4); % Induced velocity in descent according to an empirical relation (see lecture slides)
        pl = 1 / (segment.velocity + rotor.induced_power_factor * v_d + segment.density(2) * rotor.tip_velocity^3 / dl * rotor.rotor_solidity * rotor.base_drag_coefficient / 8);
    end

    if pl > 0
        mf_batt = altitude_range * constants.g / source.specific_energy / network_efficiency(network) / pl / abs(segment.velocity);
    else
        mf_batt = 0;
    end
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_batt * vehicle.mass;
end

function vehicle = landing(segment, vehicle, energy)
[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
[source, source_id] = find_by_type(network, 'energy');

if is_type(source, 'energy.fuel')
    mf_fuel = 1 - 0.9725;
    vehicle.components{network_ids(source_id)}.mass = source.mass + mf_fuel * vehicle.mass;
    vehicle.mass = vehicle.mass - source.mass;
elseif is_type(source, 'energy.electric')
    % mf_batt = 0;
end

function vehicle = load_step(vehicle, segment)
vehicle.mass = vehicle.mass + segment.mass;

function [error, mission, vehicle] = mtow_error(x, mission, vehicle, energy)
global constants;

vehicle.mass = x;

% Iterate over mission segments
for i = 1 : length(mission.segments)
    [mission.segments{i}.temperature, mission.segments{i}.speed_sound, mission.segments{i}.pressure, mission.segments{i}.density] = atmosisa(mission.segments{i}.altitude);

    if strcmp(mission.segments{i}.type, 'taxi') % Taxi segment
        vehicle = taxi(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'hover') % Hover segment
        vehicle = hover(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'climb') % Climb segment
        vehicle = climb(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
        vehicle = vertical_climb(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'acceleration') % Acceleration segment
        vehicle = acceleration(mission.segments{i}, mission.segments{i - 1}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'cruise') % Cruise segment
        vehicle = cruise(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'hold') % Hold segment
        vehicle = hold(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'combat') % Combat segment
    %     ei = find_energy_source_index(vehicle, mission.segments{i}.source);
    %     if is_type(source, 'energy.fuel')
    %         % mf_fuel = 1 - % TODO
    %     elseif is_type(source, 'energy.electric')
    %         errordlg('Not available'); % NOT AVAILABLE
    %         break;
    %     end
    elseif strcmp(mission.segments{i}.type, 'descent') % Descent segment
        vehicle = descent(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
        vehicle = vertical_descent(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'landing') % Landing segment
        vehicle = landing(mission.segments{i}, vehicle, energy);
    elseif strcmp(mission.segments{i}.type, 'load_step') % Load step segment
        vehicle = load_step(vehicle, mission.segments{i});
    end
    
    % % Accumulate mission parameters
    % ei = find_energy_source_index(vehicle, mission.segments{i}.source);
    % if is_type(source, 'energy.fuel')
    %     vehicle.energy_sources{ei}.mass = vehicle.energy_sources{ei}.mass + mf_fuel * mass_ac;
    %     mass_ac = mass_ac - vehicle.energy_sources{ei}.mass; % Vehicle mass at end of segment
    % elseif is_type(source, 'energy.electric')
    %     vehicle.energy_sources{ei}.mass = vehicle.energy_sources{ei}.mass + mf_batt * mass_to;
    % end
    % mission.time = mission.time + mission.segments{i}.time;
    % mission.range = mission.range + mission.segments{i}.range;
end

% Accumulate component masses
mass = 0;
for i = 1 : length(vehicle.components)
    mass = mass + vehicle.components{i}.mass;
    if isfield(vehicle.components{i}, 'reserve')
        mass = mass + vehicle.components{i}.mass * vehicle.components{i}.reserve;
    end
end

error = vehicle.mass - mass;
