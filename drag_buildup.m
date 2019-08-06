% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function performance = drag_buildup(performance, aircraft)

performance.c_d0 = 0;

% Iterate over aircraft lifting surfaces
for i = 1 : length(aircraft.lifting_surfaces)
    performance.c_d0 = performance.c_d0 + aircraft.lifting_surfaces(i).c_d0;
end

% Iterate over aircraft fuselages
for i = 1 : length(aircraft.fuselages)
    performance.c_d0 = performance.c_d0 + aircraft.fuselages(i).c_d0;
end
