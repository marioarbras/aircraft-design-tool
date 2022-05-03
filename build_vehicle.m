% Aircraft design tool
%
% Copyright (C) 2022 Mario Bras
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

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
