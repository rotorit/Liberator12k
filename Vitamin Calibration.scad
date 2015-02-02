include <Components.scad>;
include <Tee Housing.scad>;

// 3/4" Tee
scale([25.4,25.4,25.4]) {

  // Calibration model for 3_4_tee_rim_od and 3_4_tee_rim_width
  // Press the bottom rim of the tee into the print so it's flush.
  // It should fit snugly around the tee, but not so tight you can't remove it without tools.
  // It should also be tall enough to extend above any tapered portion of the tee rim.
  difference() {
    translate([0,0,3_4_tee_rim_width/2])
    cube([3_4_tee_rim_od + 1/8,
           3_4_tee_rim_od + 1/8,
           3_4_tee_rim_width], center=true);

    cylinder(r=3_4_tee_rim_od/2, h=3_4_tee_rim_width + 1, center=true);
  }


  // Tee Blocks
  translate([0,0,3_4_tee_rim_od/2 + tee_overlap]) {
    translate([0,2,0])
    rotate([90,0,0])
    difference() {
      tee_housing_block_bottom();

      translate([-2,0,-2])
      cube([4,2,4]);
    }

    translate([0,4,0])
    rotate([-90,0,0])
    difference() {
      tee_housing_block_bottom();

      translate([-2,-2,-2])
      cube([4,2,4]);
    }
  }



}


// 3/4" Pipe
scale([25.4, 25.4, 25.4])
translate([-2,0,0])
3_4_pipe_sleeve(wall=1/8, length=1/2);


// 1" Pipe
scale([25.4, 25.4, 25.4])
translate([2,0,0])
1_pipe_sleeve(wall=1/8, length=1/2);