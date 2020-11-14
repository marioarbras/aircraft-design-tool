% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function [elem, id] = find_by_type(data, type)
elem = struct();
id = [];
type_tags = split(type, '.');
for i = 1 : length(data)
    match = true;

    elem_tags = split(data{i}.type, '.');
    for j = 1 : length(type_tags)
        if ~strcmp(elem_tags{j}, type_tags{j})
            match = false;
            break;
        end
    end
    
    if (match == true)
        elem = data{i};
        id = i;
        return;
    end
end

% function [elems, ids] = find_by_type(data, type)
% elems = {};
% ids = [];
% type_tags = split(type, '.');
% for i = 1 : length(data)
%     match = true;

%     elem_tags = split(data{i}.type, '.');
%     for j = 1 : length(type_tags)
%         if ~strcmp(elem_tags{j}, type_tags{j})
%             match = false;
%             break;
%         end
%     end
    
%     if (match == true)
%         elems = [elems data{i}];
%         ids = [ids i];
%     end
% end
