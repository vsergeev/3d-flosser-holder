/********************************************************
 * Flosser Holder - vsergeev
 * https://github.com/vsergeev/3d-flosser-holder
 * CC-BY-4.0
 *
 * Release Notes
 *  * v1.0 - 06/20/2023
 *      * Initial release.
 ********************************************************/

/* [Basic] */

// flosser capacity
flosser_capacity = 30;

// enable riser pegs
risers_enabled = true;

/* [Advanced] */

// in mm
cutoff_x_offset = 30;

// in mm
base_z_thickness = 2;

// in mm
wall_xy_thickness = 2;

// in mm
drainage_xy_diameter = 10;

// in mm
riser_xy_diameter = 5;

// in mm
riser_z_height = 2;

/* [Hidden] */

$fn = 100;

overlap_epsilon = 0.01;

/******************************************************************************/
/* Constants */
/******************************************************************************/

flosser_z_height = 2;

flosser_xy_offset = 0.875;

flosser_polygon = [[0, 0], [70, 0], [76, 17.25], [50.5, 26.5], [46, 11.75], [0, 0.25]];

drainage_center = [60.95, 13.00];

riser_centers = [[32.00, 4.90], [70.08, 2.00], [75.45, 17.45], [52.11, 25.91]];

/******************************************************************************/
/* 2D Profiles */
/******************************************************************************/

module profile_flosser_footprint() {
    translate([flosser_xy_offset, flosser_xy_offset])
        offset(r=flosser_xy_offset)
            polygon(flosser_polygon);
}

module profile_flosser_cutoff_footprint() {
    difference() {
        profile_flosser_footprint();
        translate([0, -cutoff_x_offset / 2])
            square([cutoff_x_offset, cutoff_x_offset]);
    }
}

module profile_base_footprint() {
    offset(r=wall_xy_thickness)
        profile_flosser_cutoff_footprint();
}

module profile_wall_footprint() {
    difference() {
        profile_base_footprint();
        profile_flosser_footprint();
    }
}

module profile_drainage_footprint() {
    translate(drainage_center)
        circle(d=drainage_xy_diameter);
}

module profile_riser_footprint() {
    circle(d = riser_xy_diameter);
}

/******************************************************************************/
/* 3D Extrusions */
/******************************************************************************/

module flosser_holder() {
    union() {
        /* Base */
        linear_extrude(base_z_thickness) {
            difference() {
                /* Base Footprint */
                profile_base_footprint();
                /* Drainage Hole */
                profile_drainage_footprint();
            }
        }

        /* Walls */
        linear_extrude(base_z_thickness + (flosser_capacity + 1) * flosser_z_height, convexity=2)
            profile_wall_footprint();

        /* Riser Pegs */
        if (risers_enabled) {
            for (pos = riser_centers) {
                translate(concat(pos, -riser_z_height))
                    linear_extrude(riser_z_height + overlap_epsilon)
                        profile_riser_footprint();
            }
        }
    }
}

/******************************************************************************/
/* Top Level */
/******************************************************************************/

flosser_holder();
