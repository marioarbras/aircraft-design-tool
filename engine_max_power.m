% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function p = engine_max_power(engine)
p = engine.max_power;
if isfield(engine, 'number')
    p = p * engine.number;
end