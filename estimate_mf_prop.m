% Aircraft design tool
%
% Mario Bras (mbras@uvic.ca) and Ricardo Marques (ricardoemarques@uvic.ca) 2019
%
% This file is subject to the license terms in the LICENSE file included in this distribution

function mf_prop = estimate_mf_prop(f_install, pw_to, pw_ice, pw_gen, pw_em, pw_prop, config)
% f_install: Factor that accounts for all auxiliary systems for propulsion (> 1)
% pw_to: Shaft power to MTOW ratio
% pw_ice: Maximum shaft power to ICE weight ratio
% pw_gen: Maximum shaft power to generator weight ratio
% pw_em: Maximum shaft power to electric motor weight ratio
% pw_prop: Maximum shaft power to propeller weight ratio

if strcmp(config, 'series')
    mf_prop = f_install * pw_to / (pw_ice + pw_gen + pw_em + pw_prop);
elseif strcmp(config, 'parallel')
    mf_prop = f_install * pw_to / (pw_ice + pw_em + pw_prop);
end
