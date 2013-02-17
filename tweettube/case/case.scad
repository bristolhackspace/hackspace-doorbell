//smooth curves
$fs=0.5;

//fundamental measurements
case_height=40;
thickness=4.85; //thickness of material
bit_radius=1.5; //radius of cutting bit

button_r=16.5/2;
bolt_r=2.7;
dc_jack_r=12/2;
dc_jack_l=14;

//display measurements
d_width=240.0;
d_length=70;
d_height=11.4;

//how close things should be together
spacing =10;
bolt_spacing=5;

//pi measurments
p_width= 85.60;
p_length =56;
p_height =21;

//some calculated bits
case_width = d_width + 2*spacing;
case_length=d_length+3*spacing+p_length;

bolt_hole_space_x=case_width/2-bolt_spacing;
bolt_hole_space_y=case_length/2-bolt_spacing;

back_z=-2*thickness;
d_y=case_length/2-d_length/2-spacing;


////////////////////////////////////////////////
//first we have all the models. These are mostly centred at the 0,0,0 position, and can be used for exporting to DXFs

//the left and right side
module side()
{
  w=case_length-3*spacing;
  tab_w=w/8-thickness;
  tab_height=thickness;
  cube([w,case_height,thickness],center=true);
  translate([-w/2+tab_w/2+bit_radius,0,0])
    minkowski()
    {
    cube([tab_w,case_height+tab_height,thickness],center=true);
    cylinder(r=thickness/2,h=0.01);
    }
  translate([w/2-tab_w/2-bit_radius,0,0])
  minkowski()
  {
    cube([tab_w,case_height+tab_height,thickness],center=true);
    cylinder(r=thickness/2,h=0.01);
    }
}

//the left and right side, for using to cut slots
module side_diff()
{
  w=case_length-3*spacing;
  tab_w=w/8+2*bit_radius;
  tab_height=8*thickness;
  cube([w,case_height,thickness],center=true);
  translate([-w/2-thickness/2+tab_w/2,0,0])
    cube([tab_w,case_height+tab_height,thickness],center=true);
  translate([w/2+thickness/2-tab_w/2,0,0])
    cube([tab_w,case_height+tab_height,thickness],center=true);
}

//the top and bottom sides
module top_side()
{
  w=case_width-3*spacing;
  tab_w=w/8-thickness;
  tab_height=thickness;
  cube([w,case_height,thickness],center=true);
  translate([-w/2+tab_w/2+bit_radius,0,0])
  minkowski()
  {
    cube([tab_w,case_height+tab_height,thickness],center=true);
    cylinder(r=thickness/2,h=0.01);
    }
  translate([w/2-tab_w/2-bit_radius,0,0])
  minkowski()
  {
    cube([tab_w,case_height+tab_height,thickness],center=true);
    cylinder(r=thickness/2,h=0.01);
    }
}

//top and bottom sides for cutting slots
module top_side_diff()
{
  w=case_width-3*spacing;
  tab_w=w/8+2*bit_radius;
  tab_height=8*thickness;
  cube([w,case_height,thickness],center=true);
  translate([-w/2-thickness/2+tab_w/2,0,0])
    cube([tab_w,case_height+tab_height,thickness],center=true);
  translate([w/2+thickness/2-tab_w/2,0,0])
    cube([tab_w,case_height+tab_height,thickness],center=true);
}

//the VFD display, with cylinders for cutting bolt holes
module display()
{
  hole_r=3.4/2;
  bolt_x=7.5;
  bolt_y=11.5;
  bolt_hole_space_x = 215;
  bolt_hole_space_y = 44;
  display_x=180;
  display_y=15;
  translate([-d_width/2,-d_length/2,-d_height/2])
  {
  //display base
  cube([d_width,d_length,d_height]);

  //bolts - wrong on the datasheet!
  translate([bolt_x+bolt_hole_space_x,bolt_y+bolt_hole_space_y,-case_height/2])
    cylinder(r=hole_r,h=case_height,center=true);
  translate([bolt_x,bolt_y,-case_height/2])
    cylinder(r=hole_r,h=case_height,center=true);
  translate([bolt_x+bolt_hole_space_x,bolt_y,-case_height/2])
    cylinder(r=hole_r,h=case_height,center=true);
  translate([bolt_x,bolt_y+bolt_hole_space_y,-case_height/2])
    cylinder(r=hole_r,h=case_height,center=true);
    }

}

//the raspberry pi. With bits sticking out so they can get cut out of the case
module pi()
{
  hole_r=3.1/2;
  sd_slot=30;

  //not centering the cuboids because the dimensions of the holes are relative to 0,0
  translate([-p_width/2,-p_length/2,-p_height/2])
  {
    cube([p_width,p_length,p_height]);
    //gpio
    translate([0,p_length-5,p_height])
      cube([30,5,5]);

    //sdcard hole
    translate([-sd_slot,-sd_slot/2+p_length/2,-case_height])
    minkowski()
    {
      cube([sd_slot,sd_slot,case_height]);
      cylinder(r=thickness,h=0.01);
    }

    //hole for usb and etc
    translate([p_length+30-thickness,thickness/2,p_height-thickness/2])
    rotate([0,90,0])
    minkowski()
    {
      cube([p_height-thickness,p_length-thickness,30]);
      cylinder(r=thickness/2,h=0.01);
    }
    /*
    Corner: 0.0mm,0.0mm
    First Mount: 25.5mm,18.0mm
    Second Mount: 80.1mm, 43.6mm
    */
    translate([25.5,18,-case_height/2])
      cylinder(r=hole_r,h=case_height,center=true);
    translate([80.1,43.6,-case_height/2])
      cylinder(r=hole_r,h=case_height,center=true);

  }
}

//front and back
module front()
{
  color("grey")
  minkowski()
  {
    cube([case_width-spacing,case_length-spacing,thickness],center=true); 
    cylinder(r=spacing,h=0.01,center=true);
  }
}

////////////////////////////////////////////////
//now all the build_ modules, these move things into the right position, so they can be booleaned out of other modules

//make in it's right position
module build_buttons()
{
  translate([-d_width/4,0,case_height])
    cylinder(r=button_r,h=case_height,center=true);
  translate([d_width/4,0,case_height])
    cylinder(r=button_r,h=case_height,center=true);
}

//make in it's right position
module build_bolts()
{
  bolt_l=case_height*3;
  translate([bolt_hole_space_x,bolt_hole_space_y,0])
    cylinder(r=bolt_r,h=bolt_l,center=true);
  translate([-bolt_hole_space_x,bolt_hole_space_y,0])
    cylinder(r=bolt_r,h=bolt_l,center=true);
  translate([bolt_hole_space_x,-bolt_hole_space_y,0])
    cylinder(r=bolt_r,h=bolt_l,center=true);
  translate([-bolt_hole_space_x,-bolt_hole_space_y,0])
    cylinder(r=bolt_r,h=bolt_l,center=true);

}

//make in it's right position
module build_display()
{
translate([0,d_y,d_height/2])
  display();
}

//make in it's right position
module build_pi()
{
translate([p_width/2-d_width/2,d_y-p_length/2-d_length/2-spacing,p_height/2])
  rotate([0,0,180])
    pi();
}

//make in it's right position
module build_back()
{
  difference()
  {
    translate([0,0,back_z])
      front();
    build_pi();
    build_display();
    build_bolts();
    build_top_sides_diff(2+thickness);
    build_sides_diff(2+thickness);
  }
}

//make in it's right position
module build_front()
{
  difference()
  {
    translate([0,0,case_height-thickness])
      front();
    build_bolts();
    build_buttons();
    build_top_sides_diff();
    build_sides_diff();
  }
}

//make in it's right position
module build_sides_diff()
{
  translate([bolt_hole_space_x,0,back_z+case_height/2+thickness/2])
      rotate([90,0,90])
        side_diff();
  translate([-bolt_hole_space_x,0,back_z+case_height/2+thickness/2])
      rotate([90,0,90])
        side_diff();
}

//make in it's right position
module build_side_l()
{
  translate([bolt_hole_space_x,0,back_z+case_height/2+thickness/2])
      rotate([90,0,90])
        side();
}

//make in it's right position
module build_side_r()
{
  difference()
  {
      translate([-bolt_hole_space_x,0,back_z+case_height/2+thickness/2])
          rotate([90,0,90])
            side();
      build_pi();
      build_dc_jack();
  }
}

//make in it's right position
module build_dc_jack()
{
  translate([-bolt_hole_space_x,spacing,back_z+case_height/2+spacing])
      rotate([90,0,90])
        hull()
        {
          translate([0,-dc_jack_l/2+dc_jack_r])
              cylinder(r=dc_jack_r,h=thickness*4,center=true);
          translate([0,+dc_jack_l/2-dc_jack_r])
              cylinder(r=dc_jack_r,h=thickness*4,center=true);
        }
}

//make in it's right position
module build_top_sides_diff()
{
  translate([0,bolt_hole_space_y,back_z+case_height/2+thickness/2])
      rotate([90,0,0])
        top_side_diff();
  translate([0,-bolt_hole_space_y,back_z+case_height/2+thickness/2])
      rotate([90,0,0])
        top_side_diff();
}

//make in it's right position
module build_top_sides()
{
  translate([0,bolt_hole_space_y,back_z+case_height/2+thickness/2])
      rotate([90,0,0])
        top_side();
  translate([0,-bolt_hole_space_y,back_z+case_height/2+thickness/2])
      rotate([90,0,0])
        top_side();
}

//for exporting to DXF
//projection() build_front();
//projection() build_back();
//projection()rotate([0,90,0])build_side_r();
//projection()rotate([0,90,0])build_side_l();
//projection() top_side();

//for showing the model
build_front();
build_back();
build_top_sides();
build_side_l();
build_side_r();

//other bits
//build_display();
//build_pi();
//build_bolts();
