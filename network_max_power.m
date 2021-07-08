% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function max_p = network_max_power(network)
max_p = 0;
for i = 1 : length(network)
    if (is_type(network{i}, 'engine'))
        p = engine_max_power(network{i});
        if p > max_p
            max_p = p;
        end
    end
end

function p = engine_max_power(engine)
p = engine.max_power;
if isfield(engine, 'number')
    p = p * engine.number;
end