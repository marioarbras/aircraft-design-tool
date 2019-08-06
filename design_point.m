% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function [propulsion, performance] = design_point(mission, propulsion, performance, constants)

wl = 0:10:10000;
ptl = 0:0.001:0.1;
dl = 0:10:10000;

f(1) = figure;
legend;
hold on;
a(1) = gca;

f(2) = figure;
legend;
hold on;
a(2) = gca;

a(1).XLim = [0 wl(end)];
a(1).YLim = [0 ptl(end)];
a(1).XLabel.String = 'W/S';
a(1).YLabel.String = 'W/P';
a(1).Title.String = 'Forward Flight Design Point';

a(2).XLim = [0 dl(end)];
a(2).YLim = [0 ptl(end)];
a(2).XLabel.String = 'W/A';
a(2).YLabel.String = 'W/P';
a(2).Title.String = 'Vertical Flight Design Point';

k = 1 / pi / performance.ar / constants.e;

%% Forward flight constraints
% EDIT NUMBER/TYPE OF CONSTRAINTS TO PLOT
r = range(mission.segments(3).density, mission.segments(3).v, performance.c_d0, k, mission.segments(3).propulsion);
e = endurance(mission.segments(6).density, mission.segments(6).v, performance.c_d0, k, mission.segments(6).propulsion);
cr = cruise_speed(wl, mission.segments(3).density, mission.segments(3).v, performance.c_d0, k, propulsion.ee_prop, mission.segments(3).propulsion);
cl1 = climb_angle(wl, mission.segments(8).density(1), performance.c_d0, k, mission.segments(8).angle, propulsion.ee_prop, mission.segments(8).propulsion);
cl2 = climb_angle(wl, mission.segments(8).density(2), performance.c_d0, k, mission.segments(8).angle, propulsion.ee_prop, mission.segments(8).propulsion);

figure(f(1));
plot(a(1), [r r], [ptl(1) ptl(end)], 'DisplayName', 'Range');
plot(a(1), [e e], [ptl(1) ptl(end)], 'DisplayName', 'Endurance');
plot(a(1), wl, cr, 'DisplayName', 'Cruise Speed');
plot(a(1), wl, cl1, 'DisplayName', strcat('Climb Angle @ \rho = ', num2str(mission.segments(8).density(1))));
plot(a(1), wl, cl2, 'DisplayName', strcat('Climb Angle @ \rho = ', num2str(mission.segments(8).density(2))));

% Pick forward flight wing and power loading
[performance.wl, performance.pl_fwd] = ginput(1);
performance.s_ref = mission.weight_to / performance.wl;
performance.b_ref = sqrt(performance.ar * performance.s_ref);
performance.c_ref = performance.s_ref / performance.b_ref;
performance.p_fwd = mission.weight_to / performance.pl_fwd;

%% Vertical flight constraints
% EDIT NUMBER/TYPE OF CONSTRAINTS TO PLOT
h = hover(dl, mission.segments(3).density, propulsion.fm);
vcl = vertical_climb(dl, mission.segments(2).density(1), propulsion.v_tip, propulsion.ss, propulsion.c_d, propulsion.k_i, mission.segments(2).v);
tr = transition(performance.wl, dl, mission.segments(3).density, k, performance.c_d0, propulsion.v_tip, propulsion.ss, propulsion.c_d, propulsion.k_i, mission.segments(3).v, propulsion.tt_tilt);

figure(f(2));
plot(a(2), [dl(1) dl(end)], [performance.pl_fwd performance.pl_fwd], 'k--', 'DisplayName', 'Forward Flight W/P');
plot(a(2), dl, h, 'DisplayName', 'Hover');
plot(a(2), dl, vcl, 'DisplayName', 'Vertical Climb');
plot(a(2), dl, tr, 'DisplayName', strcat('Transition @ \theta = ', num2str(propulsion.tt_tilt)));

% Pick vertical flight disk and power loading
[performance.dl, performance.pl_vert] = ginput(1);
propulsion.a = mission.weight_to / performance.dl;
propulsion.p_vert = mission.weight_to / performance.pl_vert;

%% Performance functions
function test = is_jet(propulsion)
test = strcmp(propulsion.type, 'jet');

function test = is_prop(propulsion)
test = strcmp(propulsion.type, 'prop');

function v = v_min_thrust(wl, rho, k, c_d0)
v = sqrt(2 * wl / rho * sqrt(k / c_d0));

function v = v_min_power(wl, rho, k, c_d0)
v = sqrt(2 * wl / rho * sqrt(k / 3 / c_d0));

function v = v_best_climb_rate_jet(tl, wl, rho, k, c_d0)
v = sqrt(wl / 3 / rho / c_d0 * (1 / tl + sqrt(1 / tl^2 + 12 * c_d0 * k)));

function v = v_best_climb_rate_prop(wl, rho, k, c_d0)
v = v_min_power(wl, rho, k, c_d0);

function v = v_best_climb_angle_jet(wl, rho, k, c_d0)
v = v_min_thrust(wl, rho, k, c_d0);

function v = v_best_climb_angle_prop(wl, rho, k, c_d0)
v = 0.875 * v_best_climb_rate_prop(wl, rho, k, c_d0); % Raymer pp. 466

function c_l = cl_min_thrust(k, c_d0)
c_l = sqrt(c_d0 / k);

function c_l = cl_min_power(k, c_d0)
c_l = sqrt(3 * c_d0 / k);

function c_d = cd_min_thrust(c_d0)
c_d = 2 * c_d0;

function c_d = cd_min_power(c_d0)
c_d = 4 * c_d0;

%% Vertical flight constraint functions
function pl = hover(dl, rho, fm)
pl = fm .* sqrt(2 .* rho ./ dl);

function pl = vertical_climb(dl, rho, v_tip, ss, c_d, k_i, v_y)
pl = 1 ./ (v_y - k_i .* v_y ./ 2 + k_i .* sqrt(v_y.^2 + 2 .* dl ./ rho) ./ 2 + rho .* v_tip.^3 .* ss .* c_d ./ dl ./ 8);

function pl = vertical_descent(dl, rho, v_tip, ss, c_d, k_i, v_y, v_i)
if v_y / v_i <= -2 % If this condition is met, the vertical climb equation is used for descent, else, an empirical equation is employed
    pl = 1 ./ (v_y - k_i ./ 2 * (v_y + sqrt(v_y.^2 - 2 .* dl ./ rho)) + rho .* v_tip.^3 .* ss .* c_d ./ dl ./ 8);
else
    v_d = v_i * (k_i - 1.125 * v_y / v_i - 1.372 * (v_y / v_i)^2 - 1.718 * (v_y / v_i)^3 - 0.655 * (v_y / v_i)^4); % Induced velocity in descent according to an empirical relation (see lecture slides)
    pl = 1 ./ (v_y + k_i .* v_d + rho .* v_tip.^3 ./ dl .* ss .* c_d ./ 8);
end

function pl = transition(wl, dl, rho, k, c_d0, v_tip, ss, c_d, k_i, v, tt_tilt)
aa = 0; % Assuming zero angle of attack of the blades
mm = v * cosd(aa) / v_tip;
pl = 1 ./ (k_i ./ sind(tt_tilt) .* sqrt(-v.^2 ./ 2 + sqrt((v.^2 ./ 2).^2 + (dl ./ 2 ./ rho ./ sind(tt_tilt)).^2)) + rho .* v_tip.^3 ./ dl .* (ss .* c_d ./ 8 .* (1 + 4.6 .* mm.^2)) + 0.5 .* rho .* v^3 .* c_d0 ./ wl + 2 .* wl .* k ./ rho ./ v);

%% Forward flight constraint functions
function wl = range(rho, v, c_d0, k, propulsion)
if is_jet(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(c_d0 / 3 / k);
elseif is_prop(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(c_d0 / k);
end

function wl = endurance(rho, v, c_d0, k, propulsion)
if is_jet(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(c_d0 / k);
elseif is_prop(propulsion)
    wl = 0.5 * rho * v^2 * sqrt(3 * c_d0 / k);
end

function wl = stall_speed(rho, v_s, c_lmax)
wl = 0.5 * rho * v_s^2 * c_lmax;

function ptl = cruise_speed(wl, rho, v, c_d0, k, ee_prop, propulsion)
if is_jet(propulsion)
    ptl = 1 ./ (rho .* v.^2 .* c_d0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);
elseif is_prop(propulsion)
    ptl = ee_prop ./ (rho .* v.^3 .* c_d0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);
end

function ptl = climb(wl, rho, v, c_d0, k, gg, ee_prop, propulsion)
if is_jet(propulsion)
    ptl = 1 ./ (sind(gg) + rho .* v.^2 .* c_d0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v.^2);
elseif is_prop(propulsion)
    ptl = ee_prop ./ (v .* sind(gg) + rho .* v.^3 .* c_d0 ./ 2 ./ wl + 2 .* k .* wl ./ rho ./ v);
end

function ptl = climb_angle(wl, rho, c_d0, k, gg, ee_prop, propulsion)
if is_jet(propulsion)
    ptl = climb(wl, rho, v_best_climb_angle_jet(wl, rho, k, c_d0), c_d0, k, gg, ee_prop, propulsion);
elseif is_prop(propulsion)
    ptl = climb(wl, rho, v_best_climb_angle_prop(wl, rho, k, c_d0), c_d0, k, gg, ee_prop, propulsion);
end

% function ptl = climb_rate(wl, rho, c_d0, k, gg, ee_prop, propulsion)
% if is_jet(propulsion)
%     % ptl = fsolve(@(x)climb_rate_jet_error(x, wl, rho, c_d0, k, gg, ee_prop, propulsion), 0.01, optimoptions('fsolve', 'Display','iter'));
% elseif is_prop(propulsion)
%     ptl = climb(wl, rho, v_best_climb_rate_prop(wl, rho, k, c_d0), c_d0, k, gg, ee_prop, propulsion);
% end

% function err = climb_rate_jet_error(tl, wl, rho, c_d0, k, gg, ee_prop, propulsion)
% err = climb(wl, rho, v_best_climb_rate_jet(tl, wl, rho, k, c_d0), c_d0, k, gg, ee_prop, propulsion) - tl;
