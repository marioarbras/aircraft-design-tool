% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function print_concepts(concept)
weights = zeros(1, length(concept.designs));
names = cell(1, length(concept.designs));

for i = 1 : length(concept.designs)
    weights(i) = concept.designs{i}.weight;
    names{i} = concept.designs{i}.name;
end

[weights,order] = sort(weights,'descend');

fprintf('<strong>Concepts</strong>\n');
fprintf("  - <strong>%s: %f</strong>\n", names{order(1)}, weights(1));
for i = 2 : length(concept.designs)
    fprintf("  - %s: %f\n", names{order(i)}, weights(i));
end
