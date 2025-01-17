/*************************************************************************************
* Test Sketch for TIVA AHRS v. 1.0
* 9 Degree of Measurement Attitude and Heading Reference System
* for SENSORHUB 
*
* Released under GNU GPL (General Public License) v3.0
* Copyright (C) 2011-2012 Quality & Usability Lab, Deutsche Telekom Laboratories, TU Berlin
* Written by Francisco SY (frasalyu at gmail.com)
*
* Infos, updates, bug reports and feedback:
*     
*************************************************************************************/

/*
  NOTE: There seems to be a bug with the serial library in the latest Processing
  versions 1.5 and 1.5.1: "WARNING: RXTX Version mismatch ...". The previous version
  1.2.1 works fine and is still available on the web.
*/

import processing.opengl.*;
import processing.serial.*;

// IF THE SKETCH CRASHES OR HANGS ON STARTUP, MAKE SURE YOU ARE USING THE RIGHT SERIAL PORT:
// 1. Have a look at the Processing console output of this sketch.
// 2. Look for the serial port list and find the port you need 
// 3. Set your port number here:
final static int SERIAL_PORT_NUM = 6;
// 4. Try again.



final static int SERIAL_PORT_BAUD_RATE = 115200;

float yaw = 0.0f;
float pitch = 0.0f;
float roll = 0.0f;
float yawOffset = 0.0f;

String String_RX;
String string_roll;
String string_pitch;
String string_yaw;
String string_tmp;


PFont font;
Serial serial;

boolean synched = false;

void drawArrow(float headWidthFactor, float headLengthFactor) {
  float headWidth = headWidthFactor * 200.0f;
  float headLength = headLengthFactor * 200.0f;
  
  pushMatrix();
  
  // Draw base
  translate(0, 0, -100);
  box(100, 100, 200);
  
  // Draw pointer
  translate(-headWidth/2, -50, -100);
  beginShape(QUAD_STRIP);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
    vertex(headWidth, 0 ,0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(headWidth/2, 100, -headLength);
    vertex(0, 0 ,0);
    vertex(0, 100, 0);
  endShape();
  beginShape(TRIANGLES);
    vertex(0, 0, 0);
    vertex(headWidth, 0, 0);
    vertex(headWidth/2, 0, -headLength);
    vertex(0, 100, 0);
    vertex(headWidth, 100, 0);
    vertex(headWidth/2, 100, -headLength);
  endShape();
  
  popMatrix();
}

void drawBoard() {
  pushMatrix();

  rotateY(-radians(yaw - yawOffset));
  rotateX(-radians(pitch));
  rotateZ(radians(roll)); 

  // Board body
  fill(255, 0, 0);
  box(250, 20, 400);
  
  // Forward-arrow
  pushMatrix();
  translate(0, 0, -200);
  scale(0.5f, 0.2f, 0.25f);
  fill(0, 255, 0);
  drawArrow(1.0f, 2.0f);
  popMatrix();
    
  popMatrix();
}

// Skip incoming serial stream data until token is found
boolean readToken(Serial serial, String token) {
  // Wait until enough bytes are available
  if (serial.available() < token.length())
    return false;
  
  // Check if incoming bytes match token
  for (int i = 0; i < token.length(); i++) {
    if (serial.read() != token.charAt(i))
      return false;
  }
  
  return true;
}

// Global setup
void setup() {
  // Setup graphics
  size(640, 480, OPENGL);
  smooth();
  noStroke();
  frameRate(50);
  
  // Load font
  font = loadFont("Univers-66.vlw");
  textFont(font);
  
  // Setup serial port I/O
  println("AVAILABLE SERIAL PORTS:");
  println(Serial.list());
  String portName = Serial.list()[SERIAL_PORT_NUM];
  println();
  println("HAVE A LOOK AT THE LIST ABOVE AND SET THE RIGHT SERIAL PORT NUMBER IN THE CODE!");
  println("  -> Using port " + SERIAL_PORT_NUM + ": " + portName);
  serial = new Serial(this, portName, SERIAL_PORT_BAUD_RATE);
}

void setupTiva() {
  println("Trying to setup and synch ...");
  

  delay(1000);  // 1 seconds should be enough
  
    
  // Synch 
  serial.clear();  // Clear input buffer up to here
 
}



void draw() {
   // Reset scene
  background(0);
  lights();

  // Sync with Tiva
  if (!synched) {
    textAlign(CENTER);
    fill(255);
    text("Connecting to SENSORHUB...", width/2, height/2, -200);
    
    if (frameCount == 2)
      setupTiva();  // Set ouput params and request synch token
    else if (frameCount > 2)
    
      synched = readToken(serial, "!");  // Look for synch token
    return;
  }
  
  // Read angles from serial port
  while (serial.available() >= 12) {

   
   String_RX = serial.readStringUntil('!');
    if (String_RX != null) {
      println(String_RX);
      
     string_roll=String_RX.substring(0, String_RX.indexOf(","));
     string_tmp=String_RX.substring( String_RX.indexOf(",")+1);
     
     string_pitch=string_tmp.substring(0, string_tmp.indexOf(","));
     string_tmp=string_tmp.substring(string_tmp.indexOf(",")+1);
     
     string_yaw=string_tmp.substring(0, string_tmp.indexOf("!"));
     
     println("R:"+string_roll);
     println("P:"+string_pitch);
     println("Y:"+string_yaw);
     
     
     roll=Float.valueOf(string_roll).floatValue();
     pitch=-Float.valueOf(string_pitch).floatValue();
     yaw=Float.valueOf(string_yaw).floatValue();/**/
     
    
     
      
    }
   
  }

  // Draw board
  pushMatrix();
  translate(width/2, height/2, -350);
  drawBoard();
  popMatrix();
  
  textFont(font, 20);
  fill(255);
  textAlign(LEFT);

  // Output info text
  text("Point SENSORHUB towards screen and press 'a' to align", 10, 25);
  //text("Calibrador 22º - RADAR BENEFITS", 10, 25);

  // Output angles
  pushMatrix();
  translate(10, height - 10);
  textAlign(LEFT);
  text("Yaw: " + ((int) yaw), 0, 0);
  text("Pitch: " + ((int) pitch), 150, 0);
  text("Roll: " + ((int) roll), 300, 0);
  popMatrix();
}

void keyPressed() {
  switch (key) {
    case '0':  // 
     // serial.write("xx0");
      break;
    case '1':  
     // serial.write("xx1");
      break;
   
    case 'a':  // Align screen
      yawOffset = yaw;
  }
}



