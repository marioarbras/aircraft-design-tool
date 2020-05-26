% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function concept = ahp(concept)

if ~isfield(concept.categories, 'weight')
    concept.categories.weight = 1;
end
[concept.categories, concept.designs] = priority_vectors(concept.categories, concept.designs);

function [category, designs] = priority_vectors(category, designs)
[v,d] = eig(category.pairs, 'vector');
[~,j] = max(d(imag(d) == 0));
v(:,j) = abs(v(:,j) / norm(v(:,j),1))';
 
if isfield(category, 'categories')
    if ~iscell(category.categories)
        category.categories = num2cell(category.categories);
    end
    for i = 1 : length(category.categories)
        category.categories{i}.weight = v(i,j) * category.weight;
        [category.categories{i}, designs] = priority_vectors(category.categories{i}, designs);
    end
else
    for i = 1 : length(designs)
        if ~isfield(designs{i}, 'weight')
            designs{i}.weight = 0;
        end
        designs{i}.weight = designs{i}.weight + v(i,j) * category.weight;
    end
end
