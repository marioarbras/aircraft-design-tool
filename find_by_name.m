% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function [elem, id] = find_by_name(data, name)
elem = struct();
id = 0;
for i = 1 : length(data)
    if strcmp(data{i}.name, name)
        elem = data{i};
        id = i;
        return;
    end
end
