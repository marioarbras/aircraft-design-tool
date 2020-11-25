% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function a = rotor_area(rotor)
a = pi() * rotor.radius^2;
if isfield(rotor, 'number')
    a = a * rotor.number;
end
