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