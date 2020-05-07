# Aircraft Design Tool

Aircraft design tool created for the MECH 475 course at the University of Victoria.

You can use this tool to help you complete the conceptual design of an aircraft. You can define an arbitrarily complex mission profile and assemble an aircraft with an arbitrary number of lifting and non-lifting surfaces.

## Powerplant Types

You can choose what type of powerplant to use in each mission segment. There are two types of powerplants you can choose from based on the stored energy type: *fue*l or *electric* powerplant.

Fuel-based powerplants can also be *jet*- or *propeller*-driven.

## Mission Profile

A mission profile is built by combining piecewise continuous segments together. Each segment requires a minimum number of parameters to be well defined. Extra parameters can be provided per segment, but will not affect the calculations necessary for that segment.

## Mission Segments

There is a set of allowed mission segments that can be combined together to form a mission profile.

**Taxi**

In a taxi segment the aircraft is on the runway waiting to take-off. The engines are on, so energy is being consumed (in the form of fuel or electric energy).

**Hover**

In a hover situation, the aircraft maintains altitude and has zero forward velocity.

**Climb**

During a climb segment, the aircraft climbs at a constant climb speed and angle.

**Vertical Climb**

During a vertical climb segment, the aircraft climbs at a constant climb speed perpendicular to the ground.

**Acceleration**

In an acceleration segment, the aircraft changes speed while maintainng a constant altitude.

**Cruise**

In a cruise segment, the aircraft flights at constant altitude and speed for a given range.

**Hold**

The hold segment is equivalent to a cruise segment, but the hold time is used instead of the cruise range.

**Descent**

During a descent segment, the aircraft descends at a constant descent speed and angle.

**Vertical Descent**

During a vertical descent segment, the aircraft descends at a constant descent speed perpendicular to the ground.

**Landing**

In a landing segment, the aircraft touches down and decelerates to a complete stop.

**Drop**

In a drop segment, payload is dropped from the aircraft.

**Load**

Duing a load segment, payload is added to the aircraft.

## Project File

The mission profile and aircraft configuration need to be defined in a project file. The project file uses [JSON](https://www.json.org/json-en.html) notation. An example project file is as follows (with comments added):

```json5
{
    "mission": {
        "mf_struct": 0.24, // Structural mass fraction
        "segments": [
            {
                "type": "taxi",
                "energy": {
                    "type": "electric"
                },
                "time": 600.0, // Taxi time (s)
                "altitude": 0.0 // Taxi altitude (m)
            },
            {
                "type": "vertical_climb",
                "energy": {
                    "type": "electric"
                },
                "velocity": 20.0, // Rate of climb (m/s)
                "altitude": [ 0.0, 1000.0] // Altitude range (m)
            },
            {
                "type": "cruise",
                "propulsion": {
                    "type": "prop"
                },
                "energy": {
                    "type": "electric"
                },
                "velocity": 100.0, // Cruise velocity (m/s)
                "range": 5000.0, // Cruise range (m)
                "altitude": 1000.0 // Cruise altitude (m)
            },
            {
                "type": "descent",
                "energy": {
                    "type": "electric"
                },
                "velocity": -60.0, // Rate of descent (m/s)
                "altitude": [ 1000.0, 100.0], // Altitude range (m)
                "angle": -20.0 // Descent angle (deg)
            },
            {
                "type": "drop",
                "mass_drop": 1000.0,
                "time": 0.0, // Assuming instantaneous drop
                "altitude": 100.0 // Drop altitude (m)
            },
            {
                "type": "hold",
                "propulsion": {
                    "type": "prop"
                },
                "energy": {
                    "type": "fuel",
                    "sfc": 4.25e-5 // Specific fuel Consumption
                },
                "velocity": 40.0, // Loiter velocity (m/s)
                "time": 300.0, // Loiter time (s)
                "altitude": 100.0 // Loiter altitude (m)
            },
            {
                "type": "load",
                "mass_reload": 1000.0, // Load mass
                "time": 0.0, // Assuming instantaneous reload
                "altitude": 100.0 // Drop altitude (m)
            },
            {
                "type": "climb",
                "propulsion": {
                    "type": "prop"
                },
                "energy": {
                    "type": "fuel"
                },
                "velocity": 50.0, // Rate of climb (m/s)
                "altitude": [100.0, 1000.0], // Altitude range (m)
                "angle": 20.0 // Climb angle (deg)
            },
            {
                "type": "cruise",
                "propulsion": {
                    "type": "jet"
                },
                "energy": {
                    "type": "fuel",
                    "sfc": 4.25e-5 // Specific fuel Consumption
                },
                "velocity": 100.0, // Cruise velocity (m/s)
                "range": 5000.0, // Cruise range (m)
                "altitude": 1000.0 // Cruise altitude (m)
            },
            {
                "type": "vertical_descent",
                "energy": {
                    "type": "electric"
                },
                "velocity": -50, // Rate of descent (m/s)
                "altitude": [1000.0, 0.0] // Altitude range (m)
            },
            {
                "type": "landing",
                "energy": {
                    "type": "electric"
                },
                "time": 600.0, // Landing time (s)
                "altitude": 0.0 // Landing altitude (m)
            }
        ]
    },
    "aircraft": {
        "mass_to": 4000.0, // Initial estimate for maximum take-off mass
        "mass_payload": 680.0, // Payload mass
        "propulsion": {
          "gear_efficiency": 0.6, // Gearbox efficiency
          "em_efficiency": 0.9, // Electric motor efficiency
          "esc_efficiency": 0.8, // Electronic speed controller efficiency
          "config": "series", // Propulsion configuration: 'series', 'parallel'
          "dist_efficiency": 0.6, // Power distribution system efficiency
          "prop_efficiency": 0.8, // Propeller efficiency
          "k_i": 1.15, // Factor to account for losses in hover
          "c_d": 0.02, // Average blade drag coefficient
          "ss": 0.08, // Main rotor solidity ratio
          "tip_velocity": 240.1, // Speed at the blade tip (m/s)
          "fm": 0.6, // Figure of merit
          "a": 10.0, // Rotor area (m^2)
          "n": 4.0, // Number of rotors
          "tt_tilt": 40.0, // Final rotor tilt angle during transition (deg)
          "fwd_power": 500000.0, // Engine power for forward flight (W)
          "vert_power": 500000.0, // Engine power for vertical flight (W)
          "mass": 500.0 // Engine mass (kg)
        },
        "energy": {
            "e_spec_batt": 360000.0, //Battery specific energy (J/kg)
            "batt_efficiency": 0.9, // Battery efficiency
            "f_usable_batt": 0.9, // Usable capacity, i.e. ratio between usable capacity and stored energy of the battery
            "reserve_batt": 1.2, // Battery reserve factor
            "reserve_fuel": 1.06 // Fuel reserve factor
        },
        "performance": {
            "c_d0": 0.02, // Aircraft base drag
            "aspect_ratio": 5.0, // Aspect ratio
            "ld_max": 15.0, // Maximum L/D ratio
            "dl": 700.0, // Disk loading (N/m^2)
            "area_ref": 15.0,
            "area_wet": 30.0
        },
        "fuselages": [
            {
                "interf_factor": 1.0,
                "diameter": 1.0,
                "length": 4.0,
                "area_ref": 1.0,
                "area_wet": 2.0
            }
        ],
        "lifting_surfaces": [
            {
                "type": "wing",
                "interf_factor": 1.0,
                "aspect_ratio": 5.0,
                "span": 10.0,
                "mean_chord": 1.5,
                "airfoil": {
                    "type": "naca0012",
                    "tc_max": 0.15,
                    "xc_max": 0.3,
                    "cl_aa": 6.2,
                    "cl_max": 2.0
                },
                "sweep_le": 10.0,
                "sweep_c4": 15.0,
                "sweep_tc_max": 20.0,
                "area_ref": 15.0,
                "area_wet": 30.0
            },
            {
                "type": "h-tail",
                "interf_factor": 1.0,
                "aspect_ratio": 5.0,
                "span": 2.0,
                "mean_chord": 0.5,
                "airfoil": {
                    "type": "naca0012",
                    "tc_max": 0.15,
                    "xc_max": 0.3,
                    "cl_aa": 6.2,
                    "cl_max": 2.0
                },
                "sweep_le": 10.0,
                "sweep_c4": 15.0,
                "sweep_tc_max": 20.0,
                "area_ref": 1.0,
                "area_wet": 2.0
            },
            {
                "type": "v-tail",
                "interf_factor": 1.0,
                "aspect_ratio": 5.0,
                "span": 2.0,
                "mean_chord": 1.0,
                "airfoil": {
                    "type": "naca0012",
                    "tc_max": 0.15,
                    "xc_max": 0.3,
                    "cl_aa": 6.2,
                    "cl_max": 2.0
                },
                "sweep_le": 10.0,
                "sweep_c4": 15.0,
                "sweep_tc_max": 20.0,
                "area_ref": 2.0,
                "area_wet": 4.0
            }
        ]
    }
}
```

## Design Modules

**`mtow`**

Calculates the Maximum Take-off Weight of the aircraft

**`plot_mission`**

Plot the aircraft's mission profile.

**`design_plot`**

Plots the forward flight and vertical flight design spaces and lets the user pick a design point.

**`lifting_surface`**

Computes lift and drag coefficients for each individual lifting surface.

**`fuselage`**

Computes the drag coefficient for each individual fuselage body (non-lifting body).

**`drag_buildup`**

Computes the drag coefficient for the whole aircraft.