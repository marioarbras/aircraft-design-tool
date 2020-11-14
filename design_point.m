% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function vehicle = design_point(mission, vehicle, energy)
global constants;

wl = 0:5:1000;
dl = 0:5:10000;
pl = 0:0.0005:0.3;
[plf_grid, wl_grid] = meshgrid(pl, wl);
[plv_grid, dl_grid] = meshgrid(pl, dl);
cf = ones(length(wl), length(pl));
cv = ones(length(dl), length(pl));

% Configure plot
colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
fig = figure();
yyaxis right;
legend;
hold on;
a = gca;
a.Title.String = 'Design Point';
a.XLim = [0 pl(end)];
a.XLabel.String = 'W/P';
a.YLim = [0 dl(end)];
a.YLabel.String = 'W/A';
a.LineStyleOrder = '-';
colororder(colors)
yyaxis left;
a.YLim = [0 wl(end)];
a.YLabel.String = 'W/S';
a.LineStyleOrder = '-';
colororder(colors)

k = k_parameter(vehicle);

% Iterate over horizontal flight mission segments
yyaxis left;
for i = 1 : length(mission.segments)
%     if strcmp(mission.segments{i}.type, 'hover') % Hover segment
%         pti = find_propulsion_type_index(vehicle, mission.segments{i}.propulsion_type);
%         cv = cv .* hover_region(plv_grid, dl_grid, mission.segments{i}.density, vehicle.propulsion_types{pti}.fm);
%         h = hover(dl, mission.segments{i}.density, vehicle.propulsion_types{pti}.fm);
%         cv = cv .* transition_region(plv_grid, wl_grid, dl_grid, mission.segments{i}.density, k, vehicle.performance.cd_0, vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
%         tr = transition(wl, dl, mission.segments{i}.density, k, vehicle.performance.cd_0, vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
%         yyaxis right;
%         plot(h, dl, 'DisplayName', 'Hover', strcat("Hover constraint, segment ", int2str(i), ' (hover)'));
%         plot(tr, dl, 'DisplayName', strcat("Transition constraint, \theta = ", num2str(mission.segments{i}.transition_angle), ", segment ", int2str(i), ' (hover)'));
    if strcmp(mission.segments{i}.type, 'climb') % Climb segment
        [constraint, region] = climb(plf_grid, wl_grid, k, mission.segments{i}, vehicle, energy)
        plot(constraint, wl, 'DisplayName', strcat(mission.segments{i}.name, ":", mission.segments{i}.type, " constraint"));
%     elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
%         pti = find_propulsion_type_index(vehicle, mission.segments{i}.propulsion_type);
%         cv = cv .* vertical_climb_region(plv_grid, dl_grid, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         vcl = vertical_climb(dl, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         yyaxis right;
%         plot(vcl, dl, 'DisplayName', 'Vertical Climb', 'DisplayName', strcat("Vertical climb constraint, segment ", int2str(i), ' (vertical climb)'));
    elseif strcmp(mission.segments{i}.type, 'cruise') % Cruise segment
        [range_constraint, cruise_speed_constraint, region] = cruise(plf_grid, wl_grid, k, mission.segments{i}, vehicle, energy)
        plot([pl(1) pl(end)], [range_constraint range_constraint], 'DisplayName', strcat("Range constraint, segment ", int2str(i), ' (cruise)'));
        plot(cruise_speed_constraint, wl, 'DisplayName', strcat("Cruise speed constraint, segment ", int2str(i), ' (cruise)'));
    elseif strcmp(mission.segments{i}.type, 'hold') % Hold segment
        [constraint, region] = hold(plf_grid, wl_grid, k, segment, vehicle, energy)
        plot([pl(1) pl(end)], [constraint constraint], 'DisplayName', strcat("Endurance constraint, segment ", int2str(i), ' (hold)'));
    elseif strcmp(mission.segments{i}.type, 'descent') % Descent segment
%     elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
%         cv = cv .* vertical_descent_region(plv_grid, dl_grid, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         vd = vertical_descent(dl, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         yyaxis right;
%         plot(vd, dl, ''DisplayName', strcat("Vertical descent constraint, segment ", int2str(i), ' (vertical descent)'));
    end

    cf = cf .* region;
end

% Plot forward flight feasible design region
cf(~cf) = NaN;
yyaxis left;
sf = surf(pl, wl, cf, 'FaceAlpha', 0.2, 'FaceColor', '#0072BD', 'EdgeColor', 'none', 'DisplayName', 'Forward Flight Design Space');

% Pick forward flight wing and power loading
yyaxis left;
[x, y] = ginput(1);
scatter(x, y, 'filled', 'MarkerEdgeColor', '#0072BD', 'MarkerFaceColor', '#0072BD', 'DisplayName', 'Forward Flight Design Point');

vehicle.performance.power_loading_fwd = x;
vehicle.performance.wing_loading = y;

vehicle.performance.power_fwd = vehicle.mass * constants.g / vehicle.performance.power_loading_fwd;

% Calculate wing area
wing_area = vehicle.mass * constants.g / vehicle.performance.wing_loading;
[c, c_id] = find_by_type(vehicle.components, 'wing.main');
vehicle.components{c_id}.span =  = sqrt(c.aspect_ratio * wing_area);
vehicle.components{c_id}.mean_chord =  = c.span / c.aspect_ratio;

% Iterate over vertical flight mission segments
for i = 1 : length(mission.segments)
    if strcmp(mission.segments{i}.type, 'hover') % Hover segment
        pti = find_propulsion_type_index(vehicle, mission.segments{i}.propulsion_type);
        cv = cv .* hover_region(plv_grid, dl_grid, mission.segments{i}.density, vehicle.propulsion_types{pti}.fm);
        h = hover(dl, mission.segments{i}.density, vehicle.propulsion_types{pti}.fm);
        yyaxis right;
        plot(h, dl, 'DisplayName', strcat("Hover constraint, segment ", int2str(i), ' (hover)'));
    elseif strcmp(mission.segments{i}.type, 'transition') % Transition segment
        cv = cv .* transition_region(plv_grid, vehicle.performance.wing_loading, dl_grid, mission.segments{i}.density, k, vehicle.performance.cd_0, vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
        tr = transition(vehicle.performance.wing_loading, dl, mission.segments{i}.density, k, vehicle.performance.cd_0, vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
        yyaxis right;
        plot(tr, dl, 'DisplayName', strcat("Transition constraint, \theta = ", num2str(mission.segments{i}.transition_angle), ", segment ", int2str(i), ' (hover)'));
    elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
        pti = find_propulsion_type_index(vehicle, mission.segments{i}.propulsion_type);
        cv = cv .* vertical_climb_region(plv_grid, dl_grid, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
        vcl = vertical_climb(dl, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
        yyaxis right;
        plot(vcl, dl, 'DisplayName', strcat("Vertical climb constraint, segment ", int2str(i), ' (vertical climb)'));
    elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
%         cv = cv .* vertical_descent_region(plv_grid, dl_grid, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         vd = vertical_descent(dl, mission.segments{i}.density(1), vehicle.propulsion_types{pti}.tip_velocity, vehicle.propulsion_types{pti}.ss, vehicle.propulsion_types{pti}.cd, vehicle.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         yyaxis right;
%         plot(vd, dl, 'DisplayName', strcat("Vertical descent constraint, segment ", int2str(i), ' (vertical descent)'));
    end
end

% Plot vertical flight feasible design region
cv(~cv) = NaN;
yyaxis right;
sv = surf(pl, dl, cv, 'FaceAlpha', 0.2, 'FaceColor', '#D95319', 'EdgeColor', 'none', 'DisplayName', 'Vertical Flight Design Space');

% Pick vertical flight disk and power loading
yyaxis right;
[x, y] = ginput(1);
scatter(x, y, 'filled', 'MarkerEdgeColor', '#D95319', 'MarkerFaceColor', '#D95319', 'DisplayName', 'Vertical Flight Design Point');

vehicle.performance.power_loading_vert = x;
vehicle.performance.disc_loading = y;
vehicle.performance.disc_area_ref = vehicle.mass * constants.g / vehicle.performance.disc_loading;
vehicle.performance.power_vert = vehicle.mass * constants.g / vehicle.performance.power_loading_vert;

function [constraint, region] = climb(plf_grid, wl_grid, k, segment, vehicle, energy)
[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
engine = find_by_type(network, 'engine');
[segment_props, ~] = find_by_name(vehicle.segments, segment.name);

if is_type(engine, 'engine.jet')
    constraint = climb_constraint_jet(wl, segment.density(1), segment.velocity, segment_props.base_drag_coefficient, k, segment.angle);
    region = climb_region_jet(plf_grid, wl_grid, segment.density(1), segment.velocity, vehicle.performance.cd_0, k, segment.angle);
elseif is_type(engine, 'engine.prop')
    prop = find_by_type(network, 'driver.propeller');
    constraint = climb_constraint_prop(wl, segment.density(1), segment.velocity, segment_props.base_drag_coefficient, k, segment.angle, prop);
    region = climb_region_prop(plf_grid, wl_grid, segment.density(1), segment.velocity, vehicle.performance.cd_0, k, segment.angle, prop);
end

function [range_constraint, cruise_speed_constraint, region] = cruise(plf_grid, wl_grid, k, segment, vehicle, energy)
[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
engine = find_by_type(network, 'engine');

if is_type(engine, 'engine.jet')
    range_constraint = range_constraint_jet(segment.density, segment.velocity, !!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!!!, k);
    range_region = range_region_jet(wl_grid, segment.density, segment.velocity, !!!!!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!!!, k);

    cruise_speed_constraint = cruise_speed_jet(wl, segment.density, segment.velocity, !!!!!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!, k);
    cruise_speed_region = cruise_speed_region_jet(plf_grid, wl_grid, segment.density, segment.velocity, !!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!, k);
elseif is_type(engine, 'engine.prop')
    range_constraint = range_constraint_prop(segment.density, segment.velocity, !!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!!!, k);
    range_region = range_region_prop(wl_grid, segment.density, segment.velocity, !!!!!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!!!, k);

    prop = find_by_type(network, 'propeller');
    cruise_speed_constraint = cruise_speed_prop(wl, segment.density, segment.velocity, !!!!!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!, k, prop);
    cruise_speed_region = cruise_speed_region_prop(plf_grid, wl_grid, segment.density, segment.velocity, !!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!, k, prop);
end

region = range_region .* cruise_speed_region;

function [constraint, region] = hold(plf_grid, wl_grid, k, segment, vehicle, energy)
[network, network_ids] = find_network_components(vehicle, find_by_name(energy.networks, segment.energy_network));
engine = find_by_type(network, 'engine');

if is_type(engine, 'engine.jet')
    constraint = endurance_constraint_jet(segment.density, segment.velocity, !!!vehicle.performance.cd_0!!!, k);
    region = endurance_region_jet(wl_grid, segment.density, segment.velocity, !!!!!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!, k);
elseif is_type(engine, 'engine.prop')
    constraint = endurance_constraint_prop(segment.density, segment.velocity, !!!vehicle.performance.cd_0!!!, k);
    region = endurance_region_prop(wl_grid, segment.density, segment.velocity, !!!!!!!!!!!!!vehicle.performance.cd_0!!!!!!!!!!!!, k);
end

function k = k_parameter(vehicle)
c = find_by_type(vehicle.components, 'wing.main');
k = 1 / pi / c.aspect_ratio / c.oswald_efficiency;

%% Performance functions
function v = v_min_thrust(wl, rho, k, cd_0)
v = sqrt(2 * wl / rho * sqrt(k / cd_0));

function v = v_min_power(wl, rho, k, cd_0)
v = sqrt(2 * wl / rho * sqrt(k / 3 / cd_0));

function v = v_best_climb_rate_jet(tl, wl, rho, k, cd_0)
v = sqrt(wl / 3 / rho / cd_0 * (1 / tl + sqrt(1 / tl^2 + 12 * cd_0 * k)));

function v = v_best_climb_rate_prop(wl, rho, k, cd_0)
v = v_min_power(wl, rho, k, cd_0);

function v = v_best_climb_angle_jet(wl, rho, k, cd_0)
v = v_min_thrust(wl, rho, k, cd_0);

function v = v_best_climb_angle_prop(wl, rho, k, cd_0)
v = 0.875 * v_best_climb_rate_prop(wl, rho, k, cd_0); % Raymer pp. 466

function c_l = cl_min_thrust(k, cd_0)
c_l = sqrt(cd_0 / k);

function c_l = cl_min_power(k, cd_0)
c_l = sqrt(3 * cd_0 / k);

function cd = cd_min_thrust(cd_0)
cd = 2 * cd_0;

function cd = cd_min_power(cd_0)
cd = 4 * cd_0;

%% Vertical flight constraint functions
function pl = hover_constraint(dl, rho, fm)
pl = fm .* sqrt(2 .* rho ./ dl);

function pl = vertical_climb_constraint(dl, rho, v_tip, ss, cd, k_i, v_y)
pl = 1 ./ (v_y - k_i .* v_y ./ 2 + k_i .* sqrt(v_y.^2 + 2 .* dl ./ rho) ./ 2 + rho .* v_tip.^3 .* ss .* cd ./ dl ./ 8);

function pl = vertical_descent_constraint(dl, rho, v_tip, ss, cd, k_i, v_y, v_i)
if v_y / v_i <= -2 % If this condition is met, the vertical climb equation is used for descent, else, an empirical equation is employed
    pl = 1 ./ (v_y - k_i ./ 2 * (v_y + sqrt(v_y.^2 - 2 .* dl ./ rho)) + rho .* v_tip.^3 .* ss .* cd ./ dl ./ 8);
else
    v_d = v_i * (k_i - 1.125 * v_y / v_i - 1.372 * (v_y / v_i)^2 - 1.718 * (v_y / v_i)^3 - 0.655 * (v_y / v_i)^4); % Induced velocity in descent according to an empirical relation (see lecture slides)
    pl = 1 ./ (v_y + k_i .* v_d + rho .* v_tip.^3 ./ dl .* ss .* cd ./ 8);
end

function pl = transition_constraint(wl, dl, rho, k, cd_0, v_tip, ss, cd, k_i, v, tt_tilt)
aa = 0; % Assuming zero angle of attack of the blades
mm = v * cosd(aa) / v_tip;
pl = 1 ./ (k_i ./ sind(tt_tilt) .* sqrt(-v.^2 ./ 2 + sqrt((v.^2 ./ 2).^2 + (dl ./ 2 ./ rho ./ sind(tt_tilt)).^2)) + rho .* v_tip.^3 ./ dl .* (ss .* cd ./ 8 .* (1 + 4.6 .* mm.^2)) + 0.5 .* rho .* v^3 .* cd_0 ./ wl + 2 .* wl .* k ./ rho ./ v);

%% Vertical flight constraint regions
function c = hover_region(pl, dl, rho, fm)
c = pl < fm .* sqrt(2 .* rho ./ dl);

function c = vertical_climb_region(pl, dl, rho, v_tip, ss, cd, k_i, v_y)
c = pl < 1 ./ (v_y - k_i .* v_y ./ 2 + k_i .* sqrt(v_y.^2 + 2 .* dl ./ rho) ./ 2 + rho .* v_tip.^3 .* ss .* cd ./ dl ./ 8);

function c = vertical_descent_region(pl, dl, rho, v_tip, ss, cd, k_i, v_y, v_i)
if v_y / v_i <= -2 % If this condition is met, the vertical climb equation is used for descent, else, an empirical equation is employed
    c = pl < 1 ./ (v_y - k_i ./ 2 * (v_y + sqrt(v_y.^2 - 2 .* dl ./ rho)) + rho .* v_tip.^3 .* ss .* cd ./ dl ./ 8);
else
    v_d = v_i * (k_i - 1.125 * v_y / v_i - 1.372 * (v_y / v_i)^2 - 1.718 * (v_y / v_i)^3 - 0.655 * (v_y / v_i)^4); % Induced velocity in descent according to an empirical relation (see lecture slides)
    c = pl < 1 ./ (v_y + k_i .* v_d + rho .* v_tip.^3 ./ dl .* ss .* cd ./ 8);
end

function c = transition_region(pl, wl, dl, rho, k, cd_0, v_tip, ss, cd, k_i, v, tt_tilt)
aa = 0; % Assuming zero angle of attack of the blades
mm = v * cosd(aa) / v_tip;
c = pl < 1 ./ (k_i ./ sind(tt_tilt) .* sqrt(-v.^2 ./ 2 + sqrt((v.^2 ./ 2).^2 + (dl ./ 2 ./ rho ./ sind(tt_tilt)).^2)) + rho .* v_tip.^3 ./ dl .* (ss .* cd ./ 8 .* (1 + 4.6 .* mm.^2)) + 0.5 .* rho .* v^3 .* cd_0 ./ wl + 2 .* wl .* k ./ rho ./ v);

% Forward flight constraint functions
function wl = range_constraint_jet(rho, v, cd_0, k)
wl = 0.5 * rho * v^2 * sqrt(cd_0 / 3 / k);

function wl = range_constraint_prop(rho, v, cd_0, k)
wl = 0.5 * rho * v^2 * sqrt(cd_0 / k);

function wl = endurance_constraint_jet(rho, v, cd_0, k)
wl = 0.5 * rho * v^2 * sqrt(cd_0 / k);

function wl = endurance_constraint_prop(rho, v, cd_0, k)
wl = 0.5 * rho * v^2 * sqrt(3 * cd_0 / k);

function wl = stall_speed_constraint(rho, v_s, c_lmax)
wl = 0.5 * rho * v_s^2 * c_lmax;

function ptl = cruise_speed_constraint_jet(wl, rho, v, cd_0, k)
ptl = 1 ./ (rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);

function ptl = cruise_speed_constraint_prop(wl, rho, v, cd_0, k, prop)
ptl = prop.efficiency ./ (rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);

function pl = climb_constraint_jet(wl, rho, v, cd_0, k, gg)
pl = 1 ./ (sind(gg) + rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);

function pl = climb_constraint_prop(wl, rho, v, cd_0, k, gg, prop)
pl = prop.efficiency ./ (v .* sind(gg) + rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);

function pl = climb_angle_constraint_jet(wl, rho, cd_0, k, gg)
pl = climb_constraint_jet(wl, rho, v_best_climb_angle_jet(wl, rho, k, cd_0), cd_0, k, gg); % TODO: Replace with segment speed

function pl = climb_angle_constraint_prop(wl, rho, cd_0, k, gg, prop)
pl = climb_constraint_prop(wl, rho, v_best_climb_angle_prop(wl, rho, k, cd_0), cd_0, k, gg, prop); % TODO: Replace with segment speed

% function pl = climb_rate(wl, rho, cd_0, k, gg, propulsion)
% if is_jet(propulsion)
%     % pl = fsolve(@(x)climb_rate_jet_error(x, wl, rho, cd_0, k, gg, propulsion), 0.01, optimoptions('fsolve', 'Display','iter'));
% elseif is_prop(propulsion)
%     pl = climb(wl, rho, v_best_climb_rate_prop(wl, rho, k, cd_0), cd_0, k, gg, propulsion);
% end

% function err = climb_rate_jet_error(tl, wl, rho, cd_0, k, gg, propulsion)
% err = climb(wl, rho, v_best_climb_rate_jet(tl, wl, rho, k, cd_0), cd_0, k, gg, propulsion) - tl;

% Forward flight constraint regions
function c = range_region_jet(wl, rho, v, cd_0, k)
c = wl < 0.5 * rho * v^2 * sqrt(cd_0 / 3 / k);

function c = range_region_prop(wl, rho, v, cd_0, k)
c = wl < 0.5 * rho * v^2 * sqrt(cd_0 / k);

function c = endurance_region_jet(wl, rho, v, cd_0, k)
c = wl < 0.5 * rho * v^2 * sqrt(cd_0 / k);

function c = endurance_region_prop(wl, rho, v, cd_0, k)
c = wl < 0.5 * rho * v^2 * sqrt(3 * cd_0 / k);

function c = stall_speed_region(rho, v_s, c_lmax)
c = wl < 0.5 * rho * v_s^2 * c_lmax;

function c = cruise_speed_region_jet(pl, wl, rho, v, cd_0, k)
c = pl < 1 ./ (rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);

function c = cruise_speed_region_prop(pl, wl, rho, v, cd_0, k, prop)
c = pl < prop.efficiency ./ (rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);

function c = climb_region_jet(pl, wl, rho, v, cd_0, k, gg)
c = pl < 1 ./ (sind(gg) + rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);

function c = climb_region_prop(pl, wl, rho, v, cd_0, k, gg, prop)
c = pl < prop.efficiency ./ (v .* sind(gg) + rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);

function c = climb_angle_region_jet(pl, wl, rho, cd_0, k, gg)
c = climb_region_jet(pl, wl, rho, v_best_climb_angle_jet(wl, rho, k, cd_0), cd_0, k, gg);

function c = climb_angle_region_prop(pl, wl, rho, cd_0, k, gg, prop)
c = climb_region_prop(pl, wl, rho, v_best_climb_angle_prop(wl, rho, k, cd_0), cd_0, k, gg, prop);