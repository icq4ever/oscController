import controlP5.*;
import oscP5.*;
import netP5.*;

ControlP5 cp5;

// OSC setting
OscP5 oscP5;
NetAddress remoteLocation;
int oscListenPort;
int oscTargetPort;
String oscTargetIP;

PFont titleFont, tFont;
int marginLeft = 300;
Knob knobs[] = new Knob[16];
Knob tickKnobs[] = new Knob[16];
Slider2D xyPad;

// osc setting
void setupOSC() {
  oscListenPort = 30000;
  oscTargetPort = 30001;
  oscTargetIP = "127.0.0.1";  // 127.0.0.1 means localhost

  oscP5 = new OscP5(this, oscListenPort);
  remoteLocation = new NetAddress(oscTargetIP, oscTargetPort);
}

void setupUI(){
  cp5 = new ControlP5(this);

  xyPad = cp5.addSlider2D("XYPAD").setPosition(40, 205).setSize(200, 200).setMinMax(0, 0, 255, 255).setValue(127, 127);
  cp5.addColorWheel("color", 40, 480, 200).setRGB(color(255, 255, 0));

  for (int i=0; i<16; i++) {
    cp5.addToggle("toggle_A"+i).setPosition(marginLeft+i*60, 20).setSize(40, 20).setColorActive(color(255, 255, 0)).setColorForeground(color(200, 200, 0)).setColorBackground(color(100, 100, 0));
    cp5.addToggle("toggle_B"+i).setPosition(marginLeft+i*60, 60).setSize(40, 20).setColorActive(color(255, 0, 0)).setColorForeground(color(200, 0, 0)).setColorBackground(color(100, 0, 0));
    cp5.addToggle("toggle_C"+i).setPosition(marginLeft+i*60, 100).setSize(40, 20).setColorActive(color(0, 255, 255)).setColorForeground(color(0, 200, 200)).setColorBackground(color(0, 100, 100));
    cp5.addToggle("toggle_D"+i).setPosition(marginLeft+i*60, 140).setSize(40, 20).setColorActive(color(255, 0, 255)).setColorForeground(color(200, 0, 200)).setColorBackground(color(100, 0, 100));

    cp5.addButton("btn_A"+i).setPosition(marginLeft+i*60, 200).setSize(40, 20).setColorActive(color(255, 255, 0)).setColorForeground(color(200, 200, 0)).setColorBackground(color(100, 100, 0));
    cp5.addButton("btn_B"+i).setPosition(marginLeft+i*60, 225).setSize(40, 20).setColorActive(color(255, 0, 0)).setColorForeground(color(200, 0, 0)).setColorBackground(color(100, 0, 0));
    cp5.addButton("btn_C"+i).setPosition(marginLeft+i*60, 250).setSize(40, 20).setColorActive(color(0, 255, 255)).setColorForeground(color(0, 200, 200)).setColorBackground(color(0, 100, 100));
    cp5.addButton("btn_D"+i).setPosition(marginLeft+i*60, 275).setSize(40, 20).setColorActive(color(255, 0, 255)).setColorForeground(color(200, 0, 200)).setColorBackground(color(100, 0, 100));
    
    knobs[i] = cp5.addKnob("knob_A"+i).setRange(0, 255).setValue(0).setPosition(marginLeft+i*60, 305).setRadius(20).setDragDirection(Knob.VERTICAL);
    knobs[i] = cp5.addKnob("knob_B"+i).setRange(0, 255).setValue(0).setPosition(marginLeft+i*60, 365).setRadius(20).setDragDirection(Knob.VERTICAL).snapToTickMarks(true).setNumberOfTickMarks(8).setTickMarkLength(2);
    
    cp5.addSlider("sldr_"+i).setPosition(marginLeft+5+i*60, 440).setSize(15, 240).setRange(0, 255);
  }
}

void setup() {
  size(1280, 720);
  frameRate(30);
  smooth();

  titleFont = loadFont("Iosevka-Term-24.vlw");
  tFont = loadFont("Iosevka-Term-12.vlw");

  setupOSC();
  setupUI();
}

void draw() {
  background(15);

  textFont(titleFont);
  fill(255, 255, 0);
  text("OSC CONTROLLER", 40, 44);
  
  textFont(tFont);
  fill(255, 255, 255);
  text("V1.0 / by icq4ever@gmail.com", 40, 72);
  
  fill(200, 200, 200);
  text("LISTEN PORT : " + oscListenPort + "\nTARGET PORT : " + oscTargetPort + "\nTARGET IP : " + oscTargetIP, 40, 120);
}

void sendFloatMessage(String _addr, float _f) {
  OscMessage m = new OscMessage(_addr.toUpperCase());
  m.add(_f);
  oscP5.send(m, remoteLocation);
}

void sendIntMessage(String _addr, int _i) {
  OscMessage m = new OscMessage(_addr.toUpperCase());
  m.add(_i);
  oscP5.send(m, remoteLocation);
}

void sendColorMessage(String _addr, float _r, float _g, float _b) {
  OscMessage m = new OscMessage(_addr.toUpperCase());
  m.add(_r);
  m.add(_g);
  m.add(_b);
  oscP5.send(m, remoteLocation);
}

void sendXYPadMessage(String _addr, float[] ar) {
  OscMessage m = new OscMessage(_addr.toUpperCase());
  for(int i=0; i<ar.length; i++) m.add(ar[i]);
  oscP5.send(m, remoteLocation);
}

void sendToggleMessage(String _addr, float _f) {
  OscMessage m = new OscMessage(_addr.toUpperCase());
  if (_f == 1.0)  m.add(true);
  else            m.add(false);
  oscP5.send(m, remoteLocation);
}

void sendButtonMessage(String _addr) {
  OscMessage m = new OscMessage(_addr.toUpperCase());
  m.add(1);
  oscP5.send(m, remoteLocation);
}

public void controlEvent(ControlEvent theEvent) {
  String controlName = theEvent.getController().getName();

  if (controlName.startsWith("toggle"))    sendToggleMessage("/" + controlName, theEvent.getController().getValue());
  if (controlName.startsWith("btn"))       sendButtonMessage("/" + controlName);
  if (controlName.startsWith("knob"))      sendFloatMessage("/" + controlName, theEvent.getController().getValue());
  if (controlName.startsWith("sldr"))      sendFloatMessage("/" + controlName, theEvent.getController().getValue());
  if (controlName == "XYPAD")              sendXYPadMessage("/" + controlName, xyPad.getArrayValue());
  if (controlName == "color")              sendColorMessage("/" + controlName, cp5.get(ColorWheel.class, "color").r(), cp5.get(ColorWheel.class, "color").g(), cp5.get(ColorWheel.class, "color").b());
}
