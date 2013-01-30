module display()
{
  hole_r=3.2/2;
  height=11.4;
  width=209.5;
  length=59.7;
  hole_space_x = 201.9/2;
  hole_space_y = 52/2;

  cube([width,length,height],center=true);
  translate([hole_space_x,hole_space_y,-height/2])
    cylinder(r=hole_r,h=10,center=true);
  translate([-hole_space_x,hole_space_y,-height/2])
    cylinder(r=hole_r,h=10,center=true);
  translate([hole_space_x,-hole_space_y,-height/2])
    cylinder(r=hole_r,h=10,center=true);
  translate([-hole_space_x,-hole_space_y,-height/2])
    cylinder(r=hole_r,h=10,center=true);

}

module raspberry()
{
  width= 85.60;
  length =56;
  height =21;
  hole_r=2.9/2;

  //not centering the cuboids because the dimensions of the holes are relative to 0,0
  translate([-width/2,-length/2,-height/2])
  {
    cube([width,length,height]);
    //gpio
    translate([0,length-5,height])
      cube([30,5,5]);
    /*
    Corner: 0.0mm,0.0mm
    First Mount: 25.5mm,18.0mm
    Second Mount: 80.1mm, 43.6mm
    */
    translate([25.5,18,-5])
      cylinder(r=hole_r,h=10,center=true);
    translate([80.1,43.6,-5])
      cylinder(r=hole_r,h=10,center=true);

  }
}
*display();
raspberry();
