$fa = 1;
$fs = 0.5;

// Naming conventions:
// cg* == (0,0,0) is lower-left bottom corner of charger itself, Z axis is towards top of charger
// st* == (0,0,0) is lower-left bottom corner of printed object, Z axis is towards top of print volume
// ai == axis-independent; valid for either. May be used for radii or X-axis measurements

// Dimensions for the device we're building a stand for
aiChargerEdgeRadius = 18.5;
aiChargerX = 138;
cgChargerY = 107;
cgChargerZ = 38 + 1.4 /* feet */;

// Size and location of the wireless-charging pad on that device
cgChargePadYEdgeDist = 31;
aiChargePadXLeftEdgeDist = 67.67;
aiChargePadXRightEdgeDist = 21.61;

// Dimensions of the phone that sits on that device
aiPhoneX = 84;
cgPhoneY = 175;
cgPhoneZ = 13;

// TODO: Dimensions of hole needed for bottom vent, relative to base of charger w/o feet
aiBottomVentXLeftDist = 20;
cgBottomVentZDist = 9;
aiBottomVentXWidth = 32;
aiBottomVentXRight = (aiBottomVentXLeftDist + aiBottomVentXWidth);

// TODO: Dimensions of hole needed for power plug
aiPlugXWidth = 16;
cgPlugZWidth = 8;
cgPlugTopDist = 21;
cgPlugBottomDist = (cgChargerZ - cgPlugTopDist - cgPlugZWidth);
aiPlugLeftDist = (aiBottomVentXRight + 8);

// TODO: Minimum protrusion of power plug
cgPlugProtrusion = 55;

// TODO: Dimensions of hole needed for back vents

aiChargePadXLeft = aiChargePadXLeftEdgeDist;
aiChargePadXRight = (aiChargerX - aiChargePadXRightEdgeDist);
aiChargePadXCenter = (aiChargePadXLeft + aiChargePadXRight) / 2;
cgChargePadYCenter = (cgChargerY / 2);
    
aiPhoneXLeft = aiChargePadXCenter - (aiPhoneX/2);
aiPhoneXRight = aiChargePadXCenter + (aiPhoneX/2);
cgPhoneYTop = cgChargePadYCenter + (cgPhoneY/2);
cgPhoneYBottom = cgChargePadYCenter - (cgPhoneY/2);

mic = 0.001;

stStandAngle = 70;
aiStandWidth = 7;

module cgToSt() {
    for(i=[0:$children-1])
        translate([0, 0,
            (cgPlugProtrusion+aiStandWidth*.5) * sin(stStandAngle) -
            (cgPlugBottomDist*cos(stStandAngle))])
        rotate([stStandAngle, 0, 0])
        children(i);
}


module cgCharger() {
    hull() {
        translate([aiChargerEdgeRadius, aiChargerEdgeRadius, 0])
        cylinder(h = cgChargerZ, r1 = aiChargerEdgeRadius, r2 = aiChargerEdgeRadius);

        translate([aiChargerX - aiChargerEdgeRadius, aiChargerEdgeRadius, 0])
        cylinder(h = cgChargerZ, r1 = aiChargerEdgeRadius, r2 = aiChargerEdgeRadius);

        translate([aiChargerEdgeRadius, cgChargerY - aiChargerEdgeRadius, 0])
        cylinder(h = cgChargerZ, r1 = aiChargerEdgeRadius, r2 = aiChargerEdgeRadius);

        translate([aiChargerX - aiChargerEdgeRadius, cgChargerY - aiChargerEdgeRadius, 0])
        cylinder(h = cgChargerZ, r1 = aiChargerEdgeRadius, r2 = aiChargerEdgeRadius);
    }

    translate([aiChargePadXLeftEdgeDist, cgChargePadYEdgeDist, cgChargerZ])
        scale([aiChargerX - (aiChargePadXLeftEdgeDist + aiChargePadXRightEdgeDist), cgChargerY - (cgChargePadYEdgeDist*2), 1+mic])
        cube(1);   
}

module cgPhone() {
    translate([(aiChargePadXCenter - (aiPhoneX/2)), (cgChargePadYCenter - (cgPhoneY/2)), cgChargerZ + 0.001])
    hull() {
        // bottom-left
        translate([cgPhoneZ/2, cgPhoneZ/2, cgPhoneZ/2])
        sphere(cgPhoneZ/2);
        
        // top-left
        translate([cgPhoneZ/2, cgPhoneY-(cgPhoneZ/2), cgPhoneZ/2])
        sphere(cgPhoneZ/2);
        
        // bottom-right
        translate([aiPhoneX-(cgPhoneZ/2), cgPhoneZ/2, cgPhoneZ/2])
        sphere(cgPhoneZ/2);
        
        // top-right
        translate([aiPhoneX-(cgPhoneZ/2), cgPhoneY-(cgPhoneZ/2), cgPhoneZ/2])
        sphere(cgPhoneZ/2);
    }
}

module cgClearSpaces() {
    translate([aiBottomVentXLeftDist, -aiStandWidth-mic, cgBottomVentZDist/2])
        scale([aiBottomVentXWidth, aiStandWidth+mic, (cgChargerZ - (cgBottomVentZDist))])
        cube(1);
    
    translate([aiPlugLeftDist, -cgPlugProtrusion, cgPlugBottomDist])
        scale([aiPlugXWidth, cgPlugProtrusion, cgPlugZWidth])
        cube(1);
}

module leftToRight() {
    for(i=[0:$children-1]) {
        translate([aiChargerX+aiStandWidth, 0, 0])
        children(i);
    }
}

module cgBackLeftLegTop() { { translate([0, cgChargerY+aiStandWidth*.5, 0]) sphere(aiStandWidth*.5); } }

module cgBackRightLegTop() { leftToRight() { cgBackLeftLegTop(); } };

module cgMidLeftLegTop() { sphere(aiStandWidth*.5); }
module cgMidRightLegTop() { leftToRight() { cgMidLeftLegTop(); } }

module cgFrontLeftLegTop() {
    translate([0, 0, cgChargerZ])
    sphere(aiStandWidth*.5);
}

module cgFrontRightLegTop() {
    leftToRight() { cgFrontLeftLegTop(); }
}

module cgStandBack() {
    hull() {
        cgBackLeftLegTop();
        cgBackRightLegTop();
        cgMidLeftLegTop();
        cgMidRightLegTop();
    }
}

module stStandBackLeftLegBase() {
        translate([0, cos(stStandAngle)*cgChargerY, 0])
        sphere(aiStandWidth*0.5);
}
module stStandBackRightLegBase() { leftToRight() stStandBackLeftLegBase(); }

module stStandBackLeftLeg() {
    hull() {
        cgToSt() { cgBackLeftLegTop(); };
        stStandBackLeftLegBase();
    }
}
module stStandBackRightLeg() { leftToRight() stStandBackLeftLeg(); }

module connectPairs() {
    for ($i = [0: $children - 1]) {
        for ($j = [0: $children - 1]) {
            if($i != $j) {
                hull() { children($i); children($j); }
            }
        }
    }
}

module stStandMidLeftLegBase() {
    sphere(aiStandWidth*0.5);
}
module stStandMidRightLegBase() {
    leftToRight() stStandMidLeftLegBase();
}
module stStandMidLeftLeg() {
    hull() {
        cgToSt() cgMidLeftLegTop();
        stStandMidLeftLegBase();
    }
}

module stStandMidRightLeg() {
    leftToRight() stStandMidLeftLeg();
}

stStandMidLeftLeg();
stStandMidRightLeg();

module cgStandBackLeftLip() {
    hull() {
        cgBackLeftLegTop();
        cgMidLeftLegTop();
        translate([0, 0, aiStandWidth]) {
            cgBackLeftLegTop();
            cgMidLeftLegTop();
        }
    }
}

module cgStandBackRightLip() {
    leftToRight() { cgStandBackLeftLip(); }
}

module cgStandBottomWithoutCutouts() {
    hull() {
        cgMidLeftLegTop();
        cgMidRightLegTop();
        cgFrontLeftLegTop();
        cgFrontRightLegTop();
    }
}

module aiSupportLeftToRight() {
    for(i=[0:$children-1]) {
        translate([aiChargerX-aiPhoneXLeft+aiStandWidth*.5, 0, 0])
        children(i);
    }
}

// left of phone-support where it meets the base
module cgPhoneSupportLeftTop() {
    translate([aiPhoneXLeft, 0, cgChargerZ])
    sphere(aiStandWidth*0.5);
}
module cgPhoneSupportLeftMid() {
    translate([aiPhoneXLeft, cgPhoneYBottom, cgChargerZ])
    sphere(aiStandWidth*0.5);
}
module cgPhoneSupportLeftFoot() {
    translate([aiPhoneXLeft, cgPhoneYBottom, cgChargerZ+cgPhoneZ+(aiStandWidth*.5)])
    sphere(aiStandWidth*0.5);    
}
module cgPhoneSupportRightTop() { aiSupportLeftToRight() cgPhoneSupportLeftTop(); }
module cgPhoneSupportRightMid() { aiSupportLeftToRight() cgPhoneSupportLeftMid(); }
module cgPhoneSupportRightFoot() { aiSupportLeftToRight() cgPhoneSupportLeftFoot(); }

module cgStandFoot() {
    hull() {
        cgPhoneSupportLeftTop();
        cgPhoneSupportRightTop();
        cgPhoneSupportLeftMid();
        cgPhoneSupportRightMid();
    }
    
    hull() {
        cgPhoneSupportLeftMid();
        cgPhoneSupportRightMid();
        cgPhoneSupportLeftFoot();
        cgPhoneSupportRightFoot();
    }
}

module stPhoneSupportRightLegBase() {
    aiSupportLeftToRight() { stPhoneSupportLeftLegBase(); }
}
module stPhoneSupportLeftLegBase() {
    translate([aiPhoneXLeft, -(cgChargerZ+cgPhoneZ)*sin(stStandAngle), 0])
    sphere(aiStandWidth*0.5);
}
module stPhoneSupportLeftLeg() {
    hull() {
        cgToSt() cgPhoneSupportLeftMid();
        stPhoneSupportLeftLegBase();
    }
}

module stPhoneSupportRightLeg() {
    aiSupportLeftToRight() {
        stPhoneSupportLeftLeg();
    }
}

module cgStandBottom() {
    difference() {
        cgStandBottomWithoutCutouts();
        translate([aiStandWidth*.5, aiStandWidth*.5, aiStandWidth*.5])
cgClearSpaces();
    }
}

stStandBackLeftLeg();
stStandBackRightLeg();
hull() {
    stStandBackLeftLegBase();
    stStandBackRightLegBase();
    stStandMidLeftLegBase();
    stStandMidRightLegBase();
}
hull() {
    stStandMidLeftLegBase();
    stStandMidRightLegBase();
    stPhoneSupportLeftLegBase();
    stPhoneSupportRightLegBase();
}
hull() {
    stStandMidLeftLeg();
    stStandMidRightLeg();
}
hull() {
    stStandMidLeftLeg();
    cgToSt() {
        cgFrontLeftLegTop();
    }
}
hull() {
    stStandMidRightLeg();
    cgToSt() { cgFrontRightLegTop(); }
}

// fill left back
hull() {
    stStandBackLeftLeg();
    stStandMidLeftLeg();
}
hull() {
    stStandBackRightLeg();
    stStandMidRightLeg();
}


stPhoneSupportLeftLeg();
stPhoneSupportRightLeg();

cgToSt() {
    cgStandBack();
    cgStandBackLeftLip();
    cgStandBackRightLip();
    cgStandBottom();
    cgStandFoot();
    translate([aiStandWidth*.5, aiStandWidth*.5, aiStandWidth*.5])
    {
        %cgCharger();
        %cgPhone();
        %color("red", 0.5) cgClearSpaces();
    }
}
