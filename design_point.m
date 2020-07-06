% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function aircraft = design_point(mission, aircraft, constants)

wl = 0:5:1000;
dl = 0:5:10000;
pl = 0:0.0005:0.3;
[plf_grid, wl_grid] = meshgrid(pl, wl);
[plv_grid, dl_grid] = meshgrid(pl, dl);
cf = ones(length(wl), length(pl));
cv = ones(length(dl), length(pl));

% Configure plot
colors = {'#0072BD','#D95319','#EDB120','#7E2F8E','#77AC30','#4DBEEE','#A2142F'};
fig = figure('DeleteFcn', 'doc datacursormode');
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

k = 1 / pi / aircraft.performance.aspect_ratio / constants.e;

% Iterate over horizontal flight mission segments
for i = 1 : length(mission.segments)
%     if strcmp(mission.segments{i}.type, 'hover') % Hover segment
%         pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
%         cv = cv .* hover_region(plv_grid, dl_grid, mission.segments{i}.density, aircraft.propulsion_types{pti}.fm);
%         h = hover(dl, mission.segments{i}.density, aircraft.propulsion_types{pti}.fm);
%         cv = cv .* transition_region(plv_grid, wl_grid, dl_grid, mission.segments{i}.density, k, aircraft.performance.cd_0, aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
%         tr = transition(wl, dl, mission.segments{i}.density, k, aircraft.performance.cd_0, aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
%         yyaxis right;
%         plot(h, dl, 'DisplayName', 'Hover', strcat("Hover constraint, segment ", int2str(i), ' (hover)'));
%         plot(tr, dl, 'DisplayName', strcat("Transition constraint, \theta = ", num2str(mission.segments{i}.transition_angle), ", segment ", int2str(i), ' (hover)'));
    if strcmp(mission.segments{i}.type, 'climb') % Climb segment
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        cf = cf .* climb_region(plf_grid, wl_grid, mission.segments{i}.density(1), mission.segments{i}.velocity, aircraft.performance.cd_0, k, mission.segments{i}.angle, aircraft.propulsion_types{pti});
        cl = climb(wl, mission.segments{i}.density(1), mission.segments{i}.velocity, aircraft.performance.cd_0, k, mission.segments{i}.angle, aircraft.propulsion_types{pti});
        yyaxis left;
        plot(cl, wl, 'DisplayName', strcat("Climb constraint, segment ", int2str(i), ' (climb)'));
%     elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
%         pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
%         cv = cv .* vertical_climb_region(plv_grid, dl_grid, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         vcl = vertical_climb(dl, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         yyaxis right;
%         plot(vcl, dl, 'DisplayName', 'Vertical Climb', 'DisplayName', strcat("Vertical climb constraint, segment ", int2str(i), ' (vertical climb)'));
    elseif strcmp(mission.segments{i}.type, 'cruise') % Cruise segment
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        cf = cf .* range_region(wl_grid, mission.segments{i}.density, mission.segments{i}.velocity, aircraft.performance.cd_0, k, aircraft.propulsion_types{pti});
        r = range(mission.segments{i}.density, mission.segments{i}.velocity, aircraft.performance.cd_0, k, aircraft.propulsion_types{pti});
        cf = cf .* cruise_speed_region(plf_grid, wl_grid, mission.segments{i}.density, mission.segments{i}.velocity, aircraft.performance.cd_0, k, aircraft.propulsion_types{pti});
        cr = cruise_speed(wl, mission.segments{i}.density, mission.segments{i}.velocity, aircraft.performance.cd_0, k, aircraft.propulsion_types{pti});
        yyaxis left;
        plot([pl(1) pl(end)], [r r], 'DisplayName', strcat("Range constraint, segment ", int2str(i), ' (cruise)'));
        plot(cr, wl, 'DisplayName', strcat("Cruise speed constraint, segment ", int2str(i), ' (cruise)'));
    elseif strcmp(mission.segments{i}.type, 'hold') % Hold segment
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        cf = cf .* endurance_region(wl_grid, mission.segments{i}.density, mission.segments{i}.velocity, aircraft.performance.cd_0, k, aircraft.propulsion_types{pti});
        e = endurance(mission.segments{i}.density, mission.segments{i}.velocity, aircraft.performance.cd_0, k, aircraft.propulsion_types{pti});
        yyaxis left;
        plot([pl(1) pl(end)], [e e], 'DisplayName', strcat("Endurance constraint, segment ", int2str(i), ' (hold)'));
    elseif strcmp(mission.segments{i}.type, 'descent') % Descent segment
%     elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
%         cv = cv .* vertical_descent_region(plv_grid, dl_grid, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         vd = vertical_descent(dl, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         yyaxis right;
%         plot(vd, dl, ''DisplayName', strcat("Vertical descent constraint, segment ", int2str(i), ' (vertical descent)'));
    end
end

cf(~cf) = NaN;
yyaxis left;
sf = surf(pl, wl, cf, 'FaceAlpha', 0.2, 'FaceColor', '#0072BD', 'EdgeColor', 'none', 'DisplayName', 'Forward Flight Design Space');

% Pick forward flight wing and power loading
yyaxis left;
[x, y] = ginput(1);
scatter(x, y, 'filled', 'MarkerEdgeColor', '#0072BD', 'MarkerFaceColor', '#0072BD', 'DisplayName', 'Forward Flight Design Point');

aircraft.performance.power_loading_fwd = x;
aircraft.performance.wing_loading = y;
aircraft.performance.wing_area_ref = aircraft.mass * constants.g / aircraft.performance.wing_loading;
aircraft.performance.wing_span_ref = sqrt(aircraft.performance.aspect_ratio * aircraft.performance.wing_area_ref);
aircraft.performance.wing_chord_ref = aircraft.performance.wing_area_ref / aircraft.performance.wing_span_ref;
aircraft.performance.power_fwd = aircraft.mass * constants.g / aircraft.performance.power_loading_fwd;

% Iterate over vertical flight mission segments
for i = 1 : length(mission.segments)
    if strcmp(mission.segments{i}.type, 'hover') % Hover segment
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        cv = cv .* hover_region(plv_grid, dl_grid, mission.segments{i}.density, aircraft.propulsion_types{pti}.fm);
        h = hover(dl, mission.segments{i}.density, aircraft.propulsion_types{pti}.fm);
        yyaxis right;
        plot(h, dl, 'DisplayName', strcat("Hover constraint, segment ", int2str(i), ' (hover)'));
    elseif strcmp(mission.segments{i}.type, 'transition') % Transition segment
        cv = cv .* transition_region(plv_grid, aircraft.performance.wing_loading, dl_grid, mission.segments{i}.density, k, aircraft.performance.cd_0, aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
        tr = transition(aircraft.performance.wing_loading, dl, mission.segments{i}.density, k, aircraft.performance.cd_0, aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i+1}.velocity, mission.segments{i}.transition_angle);
        yyaxis right;
        plot(tr, dl, 'DisplayName', strcat("Transition constraint, \theta = ", num2str(mission.segments{i}.transition_angle), ", segment ", int2str(i), ' (hover)'));
    elseif strcmp(mission.segments{i}.type, 'vertical_climb') % Vertical climb segment
        pti = find_propulsion_type_index(aircraft, mission.segments{i}.propulsion_type);
        cv = cv .* vertical_climb_region(plv_grid, dl_grid, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
        vcl = vertical_climb(dl, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
        yyaxis right;
        plot(vcl, dl, 'DisplayName', strcat("Vertical climb constraint, segment ", int2str(i), ' (vertical climb)'));
    elseif strcmp(mission.segments{i}.type, 'vertical_descent') % Vertical descent segment
%         cv = cv .* vertical_descent_region(plv_grid, dl_grid, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         vd = vertical_descent(dl, mission.segments{i}.density(1), aircraft.propulsion_types{pti}.tip_velocity, aircraft.propulsion_types{pti}.ss, aircraft.propulsion_types{pti}.cd, aircraft.propulsion_types{pti}.k_i, mission.segments{i}.velocity);
%         yyaxis right;
%         plot(vd, dl, 'DisplayName', strcat("Vertical descent constraint, segment ", int2str(i), ' (vertical descent)'));
    end
end

cv(~cv) = NaN;
yyaxis right;
sv = surf(pl, dl, cv, 'FaceAlpha', 0.2, 'FaceColor', '#D95319', 'EdgeColor', 'none', 'DisplayName', 'Vertical Flight Design Space');

% Pick vertical flight disk and power loading
yyaxis right;
[x, y] = ginput(1);
scatter(x, y, 'filled', 'MarkerEdgeColor', '#D95319', 'MarkerFaceColor', '#D95319', 'DisplayName', 'Vertical Flight Design Point');

aircraft.performance.power_loading_vert = x;
aircraft.performance.disc_loading = y;
aircraft.performance.disc_area_ref = aircraft.mass * constants.g / aircraft.performance.disc_loading;
aircraft.performance.power_vert = aircraft.mass * constants.g / aircraft.performance.power_loading_vert;

%% Performance functions
function test = is_jet(propulsion)
test = strcmp(propulsion.type, 'jet');

function test = is_prop(propulsion)
test = strcmp(propulsion.type, 'prop');

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
function pl = hover(dl, rho, fm)
pl = fm .* sqrt(2 .* rho ./ dl);

function pl = vertical_climb(dl, rho, v_tip, ss, cd, k_i, v_y)
pl = 1 ./ (v_y - k_i .* v_y ./ 2 + k_i .* sqrt(v_y.^2 + 2 .* dl ./ rho) ./ 2 + rho .* v_tip.^3 .* ss .* cd ./ dl ./ 8);

function pl = vertical_descent(dl, rho, v_tip, ss, cd, k_i, v_y, v_i)
if v_y / v_i <= -2 % If this condition is met, the vertical climb equation is used for descent, else, an empirical equation is employed
    pl = 1 ./ (v_y - k_i ./ 2 * (v_y + sqrt(v_y.^2 - 2 .* dl ./ rho)) + rho .* v_tip.^3 .* ss .* cd ./ dl ./ 8);
else
    v_d = v_i * (k_i - 1.125 * v_y / v_i - 1.372 * (v_y / v_i)^2 - 1.718 * (v_y / v_i)^3 - 0.655 * (v_y / v_i)^4); % Induced velocity in descent according to an empirical relation (see lecture slides)
    pl = 1 ./ (v_y + k_i .* v_d + rho .* v_tip.^3 ./ dl .* ss .* cd ./ 8);
end

function pl = transition(wl, dl, rho, k, cd_0, v_tip, ss, cd, k_i, v, tt_tilt)
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
function wl = range(rho, v, cd_0, k, propulsion)
if is_jet(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(cd_0 / 3 / k);
elseif is_prop(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(cd_0 / k);
end

function wl = endurance(rho, v, cd_0, k, propulsion)
if is_jet(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(cd_0 / k);
elseif is_prop(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(3 * cd_0 / k);
end

function wl = stall_speed(rho, v_s, c_lmax)
wl = 0.5 * rho * v_s^2 * c_lmax;

function ptl = cruise_speed(wl, rho, v, cd_0, k, propulsion)
if is_jet(propulsion)
    ptl = 1 ./ (rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);
elseif is_prop(propulsion)
    ptl = propulsion.efficiency ./ (rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);
end

function pl = climb(wl, rho, v, cd_0, k, gg, propulsion)
if is_jet(propulsion)
    pl = 1 ./ (sind(gg) + rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);
elseif is_prop(propulsion)
    pl = propulsion.efficiency ./ (v .* sind(gg) + rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);
end

function pl = climb_angle(wl, rho, cd_0, k, gg, propulsion)
if is_jet(propulsion)
    pl = climb(wl, rho, v_best_climb_angle_jet(wl, rho, k, cd_0), cd_0, k, gg, propulsion); % TODO: Replace with segment speed
elseif is_prop(propulsion)
    pl = climb(wl, rho, v_best_climb_angle_prop(wl, rho, k, cd_0), cd_0, k, gg, propulsion); % TODO: Replace with segment speed
end

% function pl = climb_rate(wl, rho, cd_0, k, gg, propulsion)
% if is_jet(propulsion)
%     % pl = fsolve(@(x)climb_rate_jet_error(x, wl, rho, cd_0, k, gg, propulsion), 0.01, optimoptions('fsolve', 'Display','iter'));
% elseif is_prop(propulsion)
%     pl = climb(wl, rho, v_best_climb_rate_prop(wl, rho, k, cd_0), cd_0, k, gg, propulsion);
% end

% function err = climb_rate_jet_error(tl, wl, rho, cd_0, k, gg, propulsion)
% err = climb(wl, rho, v_best_climb_rate_jet(tl, wl, rho, k, cd_0), cd_0, k, gg, propulsion) - tl;

% Forward flight constraint regions
function c = range_region(wl, rho, v, cd_0, k, propulsion)
if is_jet(propulsion)
    c = wl < 0.5 * rho * v^2 * sqrt(cd_0 / 3 / k);
elseif is_prop(propulsion)
    c = wl < 0.5 * rho * v^2 * sqrt(cd_0 / k);
end

function c = endurance_region(wl, rho, v, cd_0, k, propulsion)
if is_jet(propulsion)
    c = wl < 0.5 * rho * v^2 * sqrt(cd_0 / k);
elseif is_prop(propulsion)
    c = wl < 0.5 * rho * v^2 * sqrt(3 * cd_0 / k);
end

function c = stall_speed_region(rho, v_s, c_lmax)
c = wl < 0.5 * rho * v_s^2 * c_lmax;

function c = cruise_speed_region(pl, wl, rho, v, cd_0, k, propulsion)
if is_jet(propulsion)
    c = pl < 1 ./ (rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);
elseif is_prop(propulsion)
    c = pl < propulsion.efficiency ./ (rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);
end

function c = climb_region(pl, wl, rho, v, cd_0, k, gg, propulsion)
if is_jet(propulsion)
    c = pl < 1 ./ (sind(gg) + rho .* v.^2 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);
elseif is_prop(propulsion)
    c = pl < propulsion.efficiency ./ (v .* sind(gg) + rho .* v.^3 .* cd_0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);
end

function c = climb_angle_region(pl, wl, rho, cd_0, k, gg, propulsion)
if is_jet(propulsion)
    c = climb_region(pl, wl, rho, v_best_climb_angle_jet(wl, rho, k, cd_0), cd_0, k, gg, propulsion);
elseif is_prop(propulsion)
    c = climb_region(pl, wl, rho, v_best_climb_angle_prop(wl, rho, k, cd_0), cd_0, k, gg, propulsion);
end

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
