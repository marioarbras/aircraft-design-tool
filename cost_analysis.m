% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function vehicle = cost_analysis(mission, vehicle)

cpi = 255.768 / 162.6; % CPI between May 2020 and May 1998

%% Development, test and evaluation costs

vehicle.development_cost = 0 * cpi; % <-------------- COMPLETE

%% Acquisition and production

vehicle.acquisitions_cost = 0 * cpi; % <------------- COMPLETE

%% Operations and maintenance
na = 4; % <------------------------------------------ CONFIRM VALUES
rho_k = 0.81; % kg/dm^3
fh = 365 * 8;
cr = 1;
cs = 102870; % $US
ms = 32.40; % $US
mmh_fh = 5;
f = [2 2.1 2.2 2.1 2.3 2.5 2.6 3.0 2.9 2.8]; % 2030-2040

fuel_tank = find_by_type(vehicle.components, 'energy.fuel');

% Fuel
wf = fuel_tank.mass; % kg
tm = mission.time / 3600; % h
cf = (wf / tm) * fh * (f / (3.79 * rho_k)) * na;

% Oil and lubricant
col = 0.05 * cf;

% Crew
cc = cs * cr * na;

% Maintenance personnel
cmp = ms * fh * na * mmh_fh;

vehicle.operations_cost = sum(cf + col + cc + cmp) * cpi;

%% Total costs
p = 0.15; % Profit % <-------------------------------- CONFIRM VALUES
qp = 500; % Number of manufactured units

vehicle.total_cost = vehicle.development_cost + vehicle.acquisitions_cost;

vehicle.unit_cost = vehicle.acquisitions_cost / qp;
vehicle.unit_price = vehicle.unit_cost * (1 + p);

