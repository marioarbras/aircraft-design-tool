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
