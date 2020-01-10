import netP5.*;
import oscP5.*;

import java.io.InputStreamReader;
import java.awt.GraphicsDevice;
import java.awt.GraphicsEnvironment;
import java.awt.DisplayMode;
import java.awt.geom.Rectangle2D;
import java.awt.Rectangle;

OscP5 osc;
NetAddress remote;

void setup() {
  osc = new OscP5(this, 12000);
  remote = new NetAddress("127.0.0.1", 6448);
}

void draw() { 
  background(0);
  fill(255, 50);
  stroke(255);
  
  int[] result = toIntArray(getWindowCoordinatesAsString());

  PVector screen = totalScreenSize();
  surface.setSize((int) screen.x / 4, (int) screen.y / 4);

  float[] normalized = new float[result.length];

  OscMessage msg = new OscMessage("/wek/inputs");
  
  for (int i=0; i<result.length / 4; i++) {
    float x = result[i * 4 + 0];
    float y = result[i * 4 + 1];
    float w = result[i * 4 + 2];
    float h = result[i * 4 + 3];

    x /= screen.x;
    y /= screen.y;
    w /= screen.x;
    h /= screen.y;

    normalized[i * 4 + 0] = x; 
    normalized[i * 4 + 1] = y;
    normalized[i * 4 + 2] = w;
    normalized[i * 4 + 3] = h;
    
    rect(x * width, y * height, w * width, h * height);
    
    msg.add(x);
    msg.add(y);
    msg.add(w);
    msg.add(h);
  }
  
  osc.send(msg, remote);
}

PVector totalScreenSize() {
  PVector size = new PVector();
  Rectangle2D rectangle = new Rectangle();

  GraphicsDevice[] screens = GraphicsEnvironment.getLocalGraphicsEnvironment().getScreenDevices();

  for (GraphicsDevice screen : screens) {
    rectangle = rectangle.createUnion(screen.getDefaultConfiguration().getBounds());
  }

  size.set((float) rectangle.getWidth(), (float) rectangle.getHeight());

  return size;
}

int[] toIntArray(String windowCoordinatesAsString) {
  String[] windows = windowCoordinatesAsString.split("#");
  int[] intArray = new int[16];

  for (int i=0; i<4; i++) {
    if (windows.length > i) {
      try {
        String[] values = windows[i].split(";");
        String[] positionAsString = values[0].split(",");
        String[] sizeAsString = values[1].split(",");
  
        intArray[i * 4 + 0] = parseInt(positionAsString[0]);
        intArray[i * 4 + 1] = parseInt(positionAsString[1]);
        intArray[i * 4 + 2] = parseInt(sizeAsString[0]);
        intArray[i * 4 + 3] = parseInt(sizeAsString[1]);
      } catch (Exception ignored) {
      }
    }
  }

  return intArray;
}

String getWindowCoordinatesAsString() {
  String[] commands = {
    "osascript", 
    "-e", "tell application \"System Events\"", 
    "-e", "  set r to \" \"", 
    "-e", "  set {AppleScript's text item delimiters, TID} to {\",\", AppleScript's text item delimiters}", 
    "-e", "  repeat with _process in (processes whose background only = false)", 
    "-e", "    repeat with _window in windows of _process", 
    "-e", "      set r to r & (_window's position as text) & \";\" & _window's size & \"#\"", 
    "-e", "    end repeat", 
    "-e", "  end repeat", 
    "-e", "  set AppleScript's text item delimiters to TID", 
    "-e", "  r", 
    "-e", "end tell", 
    "-s", "so"
  };

  try {
    Runtime r = Runtime.getRuntime();

    Process p = r.exec(commands);
    p.waitFor();

    BufferedReader bufferedReader = new BufferedReader(new InputStreamReader(p.getInputStream()));
    String untrimmed = bufferedReader.readLine();

    return untrimmed.substring(2, untrimmed.length() - 2);
  } 
  catch (Exception e) {
    System.err.println("Could not run AppleScript");
  }

  return "";
}
