use <../../Meta/Debug.scad>;
use <../../Meta/Manifold.scad>;
use <../../Meta/Resolution.scad>;
use <../../Meta/RenderIf.scad>;

use <../../Shapes/Chamfer.scad>;
use <../../Shapes/Semicircle.scad>;
use <../../Shapes/Teardrop.scad>;

use <../Receiver.scad>;

use <Lugs.scad>;
use <Lower.scad>;
use <Trigger.scad>;

/* [Print] */

// Select a part, Render (F6), then Export to STL (F7)
_RENDER = ""; // ["", "LowerMount_Front", "LowerMount_Rear"]

/* [Assembly] */
_SHOW_RECEIVER = true;
_SHOW_LOWER = true;
_SHOW_LOWERMOUNT_FRONT = true;
_SHOW_LOWERMOUNT_REAR = true;
_CUTAWAY_RECEIVER = true;
_CUTAWAY_LOWERMOUNT_FRONT = false;
_CUTAWAY_LOWERMOUNT_REAR = false;

// Settings: Positions
function LowerOffsetZ() = ReceiverBottomZ();


//************
//* Vitamins *
//************
module LowerMount_TakedownPinRetainer(cutter=false, clearance=0.005) {
  clear = cutter ? clearance : 0;
  clear2 = clear*2;
  
  color("Silver") RenderIf(!cutter)
  translate([-LowerMaxX()+ReceiverLugRearMaxX(), 0, ReceiverTakedownPinZ()-0.125])
  rotate([0,-90,0])
  cylinder(r=(3/32/2)+clear, h=ReceiverLugRearMaxX()-ReceiverTakedownPinX()-LowerMaxX()+0.125, $fn=20);
  
  if (cutter)
  translate([-LowerMaxX()+ReceiverLugRearMinX(), 0, ReceiverTakedownPinZ()-0.125])
  rotate([0,-90,0])
  cylinder(r=0.125, h=2, $fn=20);
  
}

//*****************
//* Printed Parts *
//*****************
module LowerMount_Front(id=ReceiverID(), alpha=1, debug=false) {
  mountLength = 1.75-0.01;
  
  color("Chocolate")
  render() DebugHalf(enabled=debug)
  translate([-LowerMaxX(),0,0])
  difference() {
    union() {
      translate([0,0,LowerOffsetZ()])
      ReceiverLugFront(extraTop=-LowerOffsetZ());
      
      translate([ReceiverLugFrontMaxX(),0,0])
      ReceiverBottomSlotInterface(length=mountLength, height=abs(LowerOffsetZ()));
    }
    
    difference() {
      
      // Receiver ID
      translate([ReceiverLugFrontMaxX(),0,0])
      rotate([0,-90,0])
      ChamferedCircularHole(r1=id/2, r2=1/8, h=mountLength, $fn=80,
                            teardropBottom=true,
                            teardropTop=true);
      // Sear support
      hull() {
        translate([0.125,-0.3125/2,-(id/2)-0.3125])
        ChamferedCube([0.25, 0.3125, id/2], r=1/16, teardropFlip=[true,true,true]);
        
        translate([LowerMaxX()-1.25,-0.3125/2,-(id/2)-0.25])
        ChamferedCube([0.25, 0.3125, 0.25], r=1/16, teardropFlip=[true,true,true]);
      }
    }
    
    translate([-0.01,0,LowerOffsetZ()])
    Sear(length=SearLength()+abs(LowerOffsetZ()), cutter=true);
  }
}

module LowerMount_Rear(id=ReceiverID(), alpha=1, debug=false) {
  mountLength = ReceiverLength()
              - abs(ReceiverLugRearMaxX())
              - LowerMaxX()
              - ManifoldGap();
  
  color("Chocolate")
  render() DebugHalf(enabled=debug)
  translate([-LowerMaxX(),0,0])
  difference() {
    union() {
      
      translate([0,0,LowerOffsetZ()])
      ReceiverLugRear(extraTop=-LowerOffsetZ());
      
      translate([ReceiverLugRearMaxX(),0,-0.26])
      ReceiverBottomSlotInterface(length=mountLength, height=abs(LowerOffsetZ())-0.26);
    }
      
    translate([LowerMaxX(),0,0])
    ReceiverTakedownPin(cutter=true);
    
    translate([LowerMaxX(),0,0])
    LowerMount_TakedownPinRetainer(cutter=true);
    
    difference() {
      
      // Receiver ID
      translate([ReceiverLugRearMaxX(),0,0])
      rotate([0,-90,0])
      ChamferedCircularHole(r1=id/2, r2=1/8, h=mountLength, $fn=80,
                            teardropBottom=true,
                            teardropTop=true);
      
      // Hammer Guide
      translate([ReceiverLugRearMaxX(),-0.3125/2,-(id/2)-0.375])
      mirror([1,0,0])
      ChamferedCube([mountLength, 0.3125, id/2], r=1/16, teardropFlip=[true,true,true]);
      
      // Bevel
      translate([LowerMaxX()-ReceiverLength()+00.75,-ReceiverIR(),-ReceiverIR()])
      rotate([0,-90-45,0])
      cube([ReceiverID(), ReceiverID(), ReceiverID()]);
      
    }
  }
}

//**************
//* Assemblies *
//**************
module LowerMount(id=ReceiverID(), alpha=1, debug=false) {
  LowerMount_TakedownPinRetainer();
  
  ReceiverTakedownPin();
  
  if (_SHOW_LOWERMOUNT_FRONT)
  LowerMount_Front(debug=_CUTAWAY_LOWERMOUNT_FRONT);
  
  if (_SHOW_LOWERMOUNT_REAR)
  LowerMount_Rear(debug=_CUTAWAY_LOWERMOUNT_REAR);
}


//*************
//* Rendering *
//*************


echo("Sear length: ", SearLength()+abs(LowerOffsetZ()));
*!scale(25.4)
translate([0.125,abs(LowerOffsetZ()),0.125])
rotate([90,0,0])
Sear(length=SearLength()+abs(LowerOffsetZ()));

scale(25.4)
if ($preview) {
  if (_SHOW_RECEIVER)
  ReceiverAssembly(debug=_CUTAWAY_RECEIVER);
  
  LowerMount();

  if (_SHOW_LOWER)
  translate([-LowerMaxX(),0,LowerOffsetZ()])
  Lower(showTrigger=true,
        showReceiverLugBolts=true, showGuardBolt=true, showHandleBolts=true,
        searLength=SearLength()+abs(LowerOffsetZ())+SearTravel()-(0.25/2));
} else {
  if (_RENDER == "LowerMount_Front") {
    rotate([0,90,0])
    translate([0.5,0,-LowerOffsetZ()])
    LowerMount_Front();
    
  } else if (_RENDER == "LowerMount_Rear") {
    rotate([0,90,0])
    translate([LowerMaxX()-ReceiverLugRearMaxX(),0,-LowerOffsetZ()])
    LowerMount_Rear();
  }
}