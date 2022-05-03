% Aircraft design tool
%
% Copyright (C) 2022 Mario Bras
%
% This program is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 3 as
% published by the Free Software Foundation.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program.  If not, see <https://www.gnu.org/licenses/>.

function concept = ahp(concept)

concept.categories = clear_category_weights(concept.categories);
concept.designs = clear_design_weights(concept.designs);
concept.categories.weight = 1;

[concept.categories, concept.designs] = priority_vectors(concept.categories, concept.designs);

function category = clear_category_weights(category)
category.weight = 0;
if isfield(category, 'categories')
    if ~iscell(category.categories)
        category.categories = num2cell(category.categories);
    end
    for i = 1 : length(category.categories)
        category.categories{i} = clear_category_weights(category.categories{i});
    end
end

function designs = clear_design_weights(designs)
for i = 1 : length(designs)
    designs{i}.weight = 0;
end

function [category, designs] = priority_vectors(category, designs)
[v,d] = eig(category.pairs, 'vector');
[~,j] = max(d(imag(d) == 0));
v(:,j) = abs(v(:,j) / norm(v(:,j),1));
 
if isfield(category, 'categories')
    for i = 1 : length(category.categories)
        category.categories{i}.weight = v(i,j) * category.weight;
        [category.categories{i}, designs] = priority_vectors(category.categories{i}, designs);
    end
else
    for i = 1 : length(designs)
        designs{i}.weight = designs{i}.weight + v(i,j) * category.weight;
    end
end
