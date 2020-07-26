% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function [lift, drag] = llt(wing)

for i = 1 : collocation_points
    b(i) = -v * sin()
    for j = 1 : vortex_loop
        a(i, j) = vortex_ring(wing.points(i), wing.loops(j));
    end
end

function induced_vel = vortex_line(p, p1, p2)
r1 = p - p1;
r2 = p - p2;
r0 = r1 - r2;
r12 = cross(r1, r2);
induced_vel = r12 / norm(r12)^2 * dot(r0, r1 / norm(r1) - r2 / norm(r2));

function induced_vel = vortex_ring(p, p1, p2, p3, p4, gamma)
induced_vel = (vortex_line(p, p1, p2) + vortex_line(p, p2, p3) + vortex_line(p, p3, p4) + vortex_line(p, p4, p1)) * gamma / 4 / pi();