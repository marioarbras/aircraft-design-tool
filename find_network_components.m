% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function [elems, ids] = find_network_components(vehicle, network)
elems = {};
ids = [];
for i = 1 : length(network.layout)
    for j = 1 : length(vehicle.components)
        if strcmp(network.layout{i}.name, vehicle.components{j}.name)
            e = vehicle.components{j};
            fields = fieldnames(network.layout{i});
            for k = 1 : length(fields)
                e.(fields{k}) = network.layout{i}.(fields{k});
            end
            elems = [elems e];
            ids = [ids j];
            break;
        end
    end
end
