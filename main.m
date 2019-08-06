% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

close all;

% Units
lb2kg = 0.45359237; % lb to kg

% Constants
constants.g = 9.81; % m/s^2
constants.e = 0.85; % Oswald efficiency number.

%% Known parameters and initial assumptions
% Propulsion
propulsion.ee_gear = 0.6; % Gearbox efficiency
propulsion.ee_em = 0.9; % Electric motor efficiency
propulsion.ee_esc = 0.8; % Electronic speed controller efficiency
propulsion.config = 'series'; % Propulsion configuration: 'series', 'parallel'

propulsion.ee_dist = 0.6; % Power distribution system efficiency
propulsion.ee_prop = 0.8; % Propeller efficiency
propulsion.k_i = 1.15; % Factor to account for losses in hover
propulsion.c_d = 0.02; % Average blade drag coefficient
propulsion.ss = 0.08; % Main rotor solidity ratio
propulsion.v_tip = 0.7 * 343; % Speed at the blade tip (m/s)
propulsion.fm = 0.6; % Figure of merit
propulsion.a = 10; % Rotor area (m^2)
propulsion.n = 4; % Number of rotors
propulsion.tt_tilt = 40; % Final rotor tilt angle during transition (deg)

propulsion.ee_total = propulsion.ee_prop * propulsion.ee_gear * propulsion.ee_em * propulsion.ee_esc * propulsion.ee_dist;

% Energy
energy.e_spec_batt = 360000; % Battery specific energy (J/kg)
energy.ee_batt = 0.9; % Battery efficiency
energy.f_usable_batt = 0.9; % Usable capacity, i.e. ratio between usable capacity and stored energy of the battery
energy.reserve_batt = 1.2; % Battery reserve factor
energy.reserve_fuel = 1.06; % Fuel reserve factor

% Performance
performance.c_d0 = 0.02; % Aircraft base drag
performance.ar = 5; % Aspect ratio
performance.ld_max = performance.ar + 10; % Maximum L/D ratio
performance.dl = 700; % Disk loading (N/m^2)

% Fixed weights/mass fractions
mission.mass_to = 4000; % Initial maximum take-off mass estimate (kg)
mission.mass_payload = 1500 * lb2kg; % Payload mass (kg)
mission.mf_prop = estimate_mf_prop(1.2, 0.04, 1.5, 0.3, 0.1, 0.5, propulsion.config);
mission.mf_struct = 0.24; % Structural mass fraction
mission.mf_subs = estimate_mf_subs(mission.mf_prop, mission.mf_struct);

%% Mission segments
% Mission types: 'taxi', 'hover', 'climb', 'vertical_climb', 'acceleration', 'cruise', 'hold', 'combat', 'descent', 'vertical_descent', 'landing', 'drop', 'load'
% Energy types: 'fuel', 'electric'
% Propulsion types: 'jet', 'prop'

% Taxi
mission.segments(1).type = 'taxi';
mission.segments(1).energy.type = 'electric';
mission.segments(1).time = 600; % Taxi time (s)
mission.segments(1).altitude = 0; % Taxi altitude (m)

% Vertical climb
mission.segments(2).type = 'vertical_climb';
mission.segments(2).energy.type = 'electric';
mission.segments(2).v = 20; % Rate of climb (m/s)
mission.segments(2).altitude = [0 1000]; % Altitude range (m)

% Electric cruise
mission.segments(3).type = 'cruise';
mission.segments(3).propulsion.type = 'prop';
mission.segments(3).energy.type = 'electric';
mission.segments(3).v = 100; % Cruise velocity (m/s)
mission.segments(3).range = 5000; % Cruise range (m)
mission.segments(3).altitude = 1000; % Cruise altitude (m)

% Descent
mission.segments(4).type = 'descent';
mission.segments(4).energy.type = 'electric';
mission.segments(4).v = -60; % Rate of descent (m/s)
mission.segments(4).altitude = [1000 100]; % Altitude range (m)
mission.segments(4).angle = -20; % Descent angle (deg)

% Drop
mission.segments(5).type = 'drop';
mission.segments(5).mass_drop = 1000;
mission.segments(5).time = 0; % Assuming instantaneous drop
mission.segments(5).altitude = 100; % Drop altitude (m)

% Hold
mission.segments(6).type = 'hold';
mission.segments(6).propulsion.type = 'prop';
mission.segments(6).energy.type = 'fuel';
mission.segments(6).energy.sfc = 4.25e-5 * 9.81; % Specific fuel Consumption
mission.segments(6).v = 40; % Loiter velocity (m/s)
mission.segments(6).time = 300; % Loiter time (s)
mission.segments(6).altitude = 100; % Loiter altitude (m)

% Reload
mission.segments(7).type = 'load';
mission.segments(7).mass_reload = 1000;
mission.segments(7).time = 0; % Assuming instantaneous reload
mission.segments(7).altitude = 100; % Drop altitude (m)

% Climb
mission.segments(8).type = 'climb';
mission.segments(8).propulsion.type = 'prop';
mission.segments(8).energy.type = 'fuel';
mission.segments(8).v = 50; % Rate of climb (m/s)
mission.segments(8).altitude = [100 1000]; % Altitude range (m)
mission.segments(8).angle = 20; % Climb angle (deg)

% Jet cruise back
mission.segments(9).type = 'cruise';
mission.segments(9).propulsion.type = 'jet';
mission.segments(9).energy.type = 'fuel';
mission.segments(9).energy.sfc = 4.25e-6 * 9.81; % Specific fuel Consumption
mission.segments(9).v = 100; % Cruise velocity (m/s)
mission.segments(9).range = 5000; % Cruise range (m)
mission.segments(9).altitude = 1000; % Cruise altitude (m)

% Vertical descent
mission.segments(10).type = 'vertical_descent';
mission.segments(10).energy.type = 'electric';
mission.segments(10).v = -50; % Rate of descent (m/s)
mission.segments(10).altitude = [1000 0]; % Altitude range (m)

% Landing
mission.segments(11).type = 'landing';
mission.segments(11).energy.type = 'electric';
mission.segments(11).time = 600; % Landing time (s)
mission.segments(11).altitude = 0; % Landing altitude (m)

%% Take-off mass estimation
mission = mtow(mission, propulsion, energy, performance, constants);

%% Plot mission profile
plot_mission(mission);

%% Design point calculation
[propulsion, performance] = design_point(mission, propulsion, performance, constants);

%% Engine selection
propulsion.p_fwd = 500000; % Engine power (W)
propulsion.p_vert = 500000; % Engine power (W)
mission.mass_prop = 500; % Engine mass (kg)
mission.mf_prop = mission.mass_prop / mission.mass_to;

%% Aircraft components
aircraft.fuselages(1).interf_fator = 1;
aircraft.fuselages(1).d = 1;
aircraft.fuselages(1).l = 4;
aircraft.fuselages(1).s_ref = 1;
aircraft.fuselages(1).s_wet = 2;

aircraft.lifting_surfaces(1).type = 'wing';
aircraft.lifting_surfaces(1).interf_fator = 1;
aircraft.lifting_surfaces(1).ar = performance.ar;
aircraft.lifting_surfaces(1).b = performance.b_ref;
aircraft.lifting_surfaces(1).c = performance.c_ref;
aircraft.lifting_surfaces(1).airfoil.type = 'naca0012';
aircraft.lifting_surfaces(1).airfoil.tc_max = 0.15;
aircraft.lifting_surfaces(1).airfoil.xc_max = 0.3;
aircraft.lifting_surfaces(1).airfoil.cl_aa = 2 * pi;
aircraft.lifting_surfaces(1).airfoil.cl_max = 2;
aircraft.lifting_surfaces(1).sweep_le = 10;
aircraft.lifting_surfaces(1).sweep_c4 = 15;
aircraft.lifting_surfaces(1).sweep_tc_max = 20;
aircraft.lifting_surfaces(1).s_ref = performance.s_ref;
aircraft.lifting_surfaces(1).s_wet = 2 * aircraft.lifting_surfaces(1).s_ref;

aircraft.lifting_surfaces(2).type = 'h-tail';
aircraft.lifting_surfaces(2).interf_fator = 1;
aircraft.lifting_surfaces(2).ar = 5;
aircraft.lifting_surfaces(2).b = 2;
aircraft.lifting_surfaces(2).c = 1;
aircraft.lifting_surfaces(2).airfoil.type = 'naca0012';
aircraft.lifting_surfaces(2).airfoil.tc_max = 0.15;
aircraft.lifting_surfaces(2).airfoil.xc_max = 0.3;
aircraft.lifting_surfaces(2).airfoil.cl_aa = 2 * pi;
aircraft.lifting_surfaces(2).airfoil.cl_max = 2;
aircraft.lifting_surfaces(2).sweep_le = 10;
aircraft.lifting_surfaces(2).sweep_c4 = 15;
aircraft.lifting_surfaces(2).sweep_tc_max = 20;
aircraft.lifting_surfaces(2).s_ref = 5;
aircraft.lifting_surfaces(2).s_wet = 2 * aircraft.lifting_surfaces(2).s_ref;

aircraft.lifting_surfaces(3).type = 'v-tail';
aircraft.lifting_surfaces(3).interf_fator = 1;
aircraft.lifting_surfaces(3).ar = 5;
aircraft.lifting_surfaces(3).b = 2;
aircraft.lifting_surfaces(3).c = 1;
aircraft.lifting_surfaces(3).airfoil.type = 'naca0012';
aircraft.lifting_surfaces(3).airfoil.tc_max = 0.15;
aircraft.lifting_surfaces(3).airfoil.xc_max = 0.3;
aircraft.lifting_surfaces(3).airfoil.cl_aa = 2 * pi;
aircraft.lifting_surfaces(3).airfoil.cl_max = 2;
aircraft.lifting_surfaces(3).sweep_le = 10;
aircraft.lifting_surfaces(3).sweep_c4 = 15;
aircraft.lifting_surfaces(3).sweep_tc_max = 20;
aircraft.lifting_surfaces(3).s_ref = 5;
aircraft.lifting_surfaces(3).s_wet = 2 * aircraft.lifting_surfaces(3).s_ref;

%% Lifting surface design
aircraft = lifting_surface(aircraft, mission.segments(3));

%% Fuselage design
aircraft = fuselage(aircraft, mission.segments(3));

%% Drag buildup
performance = drag_buildup(performance, aircraft);
