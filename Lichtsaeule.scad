
// the nominal diameter of the PVC pipe
pipe_d = 100;

// how thick should the walls be?
pipe_wall = 1.4;

// how tall should the rings be where the PVC pipe fits into?
pipe_height = 8;

// what should the total inner height be?
pipe_base_height = 80;

// how much wider does the spiral of the PVC pipe get when compressed?
pipe_d_growth = 10;

// how wide is the space inside the compressed PVC pipe?
stow_d = 72;

// how thick should the top/bottom plates be?
plates_t = 1;

// how much space do you need for your chips and battery?
chip_height = 18;

// Warning: Outer Diameter vs Hole Diameter problem.
// You will need to add about 0.15 to the measured outer diameter
// of your stakes, but it's pretty much related to your printer's 
// tolerances and the print profile chosen.
stake_small_d = 7.32;
stake_big_d = 8.86;

// how much wall should be around holes for stakes?
stake_wall = 1;

// how much rim should be on the cap?
cap_rim = 2;

// how much tolerance to leave between parts that should move against each other?
tol = 0.1;

// how much gap to leave for the PVC pipe foil to get stuck in there?
foil_gap = 0.3;

// locking notches: how big to make the notches and the grooves they are sliding in?
notch_r = 1.5;
notch_groove_r = 1.8;

// preview part placement: either "exploded" or "compact"
preview = "exploded";

$fn=32;

module ring(height, outer_d, inner_d) {
    render() translate([0,0,height/2]) difference() {
        cylinder(h = height, r=outer_d/2, center=true, $fn=96);
        cylinder(h = height, r=inner_d/2, center=true, $fn=96);
    }
}


module cap(height, thick, rim, outer_d, inner_d) {
    render() union() {
        ring(height, outer_d, inner_d);
        translate([0,0,thick/2])
            cylinder(h=thick, r=outer_d/2 + rim, center=true, $fn=96);
    }
}

module with_center_hole(hole_d) {
    render() difference() {
        children();
        cylinder(h=800, r=hole_d/2, center=true, $fn=24);
    }
}

module volcano(height, base_inner_d, outer_d, inner_d) {
    render() translate([0,0,height/2]) 
    with_center_hole(inner_d) {
        cylinder(h = height, r1=base_inner_d/2, r2=outer_d/2, center=true);
    }
}

module donut(r_center, r_tyre) {
    render() rotate_extrude(angle=360) {
        translate([r_center, 0]) circle(r=r_tyre, $fn=96, $fa=1, $fs=0.4);
    }
}

module with_center_nut(height, inner_d, hole_d, wall) {
    render() {
        children();
        volcano(height, inner_d + wall, hole_d + wall, hole_d);
    }
}

base_inner_d = pipe_d + (pipe_wall*2) + pipe_d_growth + (tol*2);

module upper_cap() {
    with_center_hole(stake_small_d) {
        _height = pipe_height;
        _inner_d = stake_small_d*3;
        _hole_d = stake_small_d;
        _wall = (stake_wall*2);
        volcano(_height, _inner_d+_wall, _hole_d+_wall, _hole_d);
        difference() {
            cap(pipe_height, plates_t, cap_rim, base_inner_d-(tol*2), pipe_d);
            for(a = [0:30:360]) {
                rotate([0,0,a])
                translate([base_inner_d/2-tol,0,pipe_height/2])
                cylinder(h=pipe_height/2, r=notch_groove_r, $fn=12);
            }
            translate([0,0,pipe_height/2])
                donut(base_inner_d/2-tol, notch_groove_r);
        }
    }
}

module upper_ring() {
    ring(pipe_height, pipe_d+(pipe_wall*2), pipe_d);
    render() difference() {
        ring(pipe_height, base_inner_d-(tol*4), pipe_d+(pipe_wall*2)+(foil_gap*2));
        for(a = [0:30:360]) {
            rotate([0,0,a])
            translate([(base_inner_d-(tol*4))/2,0,0])
            cylinder(h=pipe_height, r=notch_groove_r);
        }
    }
}

inner_height = pipe_base_height - plates_t - chip_height - pipe_height;
echo("Inner Height w/o chip_height", inner_height);

if( $preview ) {
    // measurement block to see whether a 18650 fits
//    translate([-pipe_d*0.35,0,0])
//    translate([-19/2,-66/2,plates_t])
//    #cube([19,66,19]);
}

module base() {
    with_center_nut(pipe_base_height-pipe_height, stake_big_d*3, stake_big_d, (stake_wall*2)) {
        difference() {
            union() {
                with_center_hole(stake_small_d) {
                    cap(pipe_base_height, plates_t, 0, base_inner_d+(pipe_wall*2), base_inner_d);
                }
                for(phi = [0,120,240]) {
                    rotate([0,0,phi])
                    translate([stake_big_d/2,-(stake_big_d+(stake_wall*2))/2,plates_t])
                    cube([(base_inner_d-stake_big_d)/2, stake_big_d+(stake_wall*2), chip_height]);
                }
                for(a = [0,120,240]) {
                    rotate([0,0,a])
                    translate([base_inner_d/2,0,pipe_base_height+plates_t-pipe_height/2])
                    sphere(r=notch_r, $fn=24);
                }
            }
            for(phi = [0,120,240]) {
                rotate([0,0,phi])
                translate([pipe_d/2-pipe_wall, 0, 0])
                rotate([0,-30,0])
                cylinder(h=chip_height*3, r=stake_small_d/2, center=true, $fn=24);
            }
            for(phi = [0,120,240]) {
                rotate([0,0,phi])
                translate([pipe_d/2-pipe_wall, 0, 0])
                rotate([0,-60,0])
                cylinder(h=chip_height*5, r=stake_small_d/2, center=true, $fn=24);
            }
            rotate([0,0,15])
                translate([-7, -(pipe_wall*2)-(base_inner_d/2), plates_t])
                    cube([14,pipe_wall*4,8]);
        }
    }
    
}

module stow_pipe() {
    stow_pipe_height = pipe_base_height-plates_t*2;
    render() difference() {
        cylinder(h=stow_pipe_height, d=stow_d, $fn=64);
        cylinder(h=stow_pipe_height, d=stow_d-(pipe_wall*2), $fn=64);
        for(phi = [0,120,240]) {
            rotate([0,0,phi])
            translate([stake_big_d/2,-(stake_big_d+(stake_wall*2)+tol)/2,0])
            union() {
                cube([(base_inner_d-stake_big_d)/2, stake_big_d+(stake_wall*2)+(tol*2), chip_height]);
                translate([0,(stake_wall+(tol*2))/2,0])
                cube([(base_inner_d-stake_big_d)/2, stake_big_d+(stake_wall), stow_pipe_height-pipe_height*2]);
            }
            
            rotate([90,0,phi+30])
            cylinder(h=(base_inner_d-stake_big_d)/2, d=max(sin(120)*stow_d,chip_height*2));
        }
    }
}


module parts() {
    if( $preview && preview == "exploded") {
        translate([0,0,pipe_base_height+plates_t + pipe_base_height*2])
        rotate([180,0,0])
        upper_cap();

        translate([0,0,chip_height+pipe_height+plates_t  + pipe_base_height*2])
        rotate([180,0,0])
        upper_ring();

        translate([0,0,plates_t + pipe_base_height]) stow_pipe();
    } else if( $preview && preview != "exploded") {
        translate([0,0,pipe_base_height+plates_t])
        rotate([180,0,0])
        upper_cap();

        translate([0,0,chip_height+pipe_height+plates_t])
        rotate([180,0,0])
        upper_ring();

        translate([0,0,plates_t]) stow_pipe();

    } else {
        translate([base_inner_d + pipe_wall + cap_rim + 10, 0,0])    upper_cap();
        translate([0,base_inner_d + pipe_wall + cap_rim + 10,0])    upper_ring();
        translate([0,base_inner_d + pipe_wall + cap_rim + 10, pipe_base_height-plates_t*2])  
            rotate([180,0,0]) stow_pipe();
    }
}

parts();
base();
