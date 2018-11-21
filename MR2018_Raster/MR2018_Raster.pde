/*
A project created for Magical RISO 2018 
(Jan van Eyck Academie, The Netherlands)

by Kyuha (Q) Shim 
http://www.kyuhashim.com
*/

import java.util.Date;
import processing.pdf.*;

PImage input;
PShape[] brush = new PShape[0];
PFont font;
color cyan = #235BA8, magenta = #FF48B0, yellow = #FFE800, black = #000000;
float unit = 10;
int counter = 0;
Boolean isPrint = false;
String name = "";
String[] paths;

void setup() {
  size(displayWidth, displayHeight);
  load();
  disableStyles();
}

void set_input() {
  selectInput("Select an image file to process (.jpg, png)", "fileSelected");
}

void raster(PImage img, color col, String cc) {
  if (isPrint) {
    beginRecord(PDF, getClass().getName()+"_"+name+"_"+month()+day()+"_"+hour()+minute()+second()+"_"+cc+".pdf");
  }
  noStroke();
  if (isPrint) {
    fill(black);
  } else {
    fill(col);
  }
  shapeMode(CENTER);
  for (float y=0; y<img.height; y+=unit) {
    for (float x=0; x<img.width; x+=unit) {
      color c = input.get(int(x), int(y));
      if (x>-width*.2 && x<width*1.2 && y>-height*.2 && y<height*1.2) {
        float unit_size = unit;
        float[] cmyk = rgbToCmyk(c);
        float xx = width*.5-img.width*.5+x;
        float yy = height*.5-img.height*.5+y;
        pushMatrix();
        translate(xx, yy);
        //rotate(random(TWO_PI));
        //if(random(10)<5) rotate(int(random(4))*PI*.5);
        scale(unit*.01);
        if (col == cyan) shape(brush[floor(map(cmyk[0], 1.0, 0, brush.length-1, 0))], 0, 0);
        if (col == magenta) shape(brush[floor(map(cmyk[1], 1.0, 0, brush.length-1, 0))], 0, 0);
        if (col == yellow) shape(brush[floor(map(cmyk[2], 1.0, 0, brush.length-1, 0))], 0, 0);
        if (col == black) shape(brush[floor(map(cmyk[3], 1.0, 0, brush.length-1, 0))], 0, 0);
        popMatrix();
      }
    }
  }
  if (isPrint) {
    endRecord();
  }
}

void disableStyles() {
  for (int i=0; i<brush.length; i++) {
    brush[i].disableStyle();
  }
}

void draw() {
  unit = map(mouseX, 0, width, 2, 120);
  if (input!=null) {
    if (mousePressed || isPrint) {
      disableStyles();
      blendMode(MULTIPLY);
      background(255);
      raster(input, cyan, "BLUE");
      raster(input, magenta, "FLUORESCENT PINK");
      raster(input, yellow, "YELLOW");
      raster(input, black, "BLACK");
      isPrint = false;
      counter = 100;
    } else {
      if (counter <0) {
        showPalette();
      }
      counter--;
    }
  } else {
    showPalette();
  }
}

void showPalette() {
  background(0);
  fill(255);
  blendMode(NORMAL);
  if (input==null) {
    float n = 1000/(brush.length * brush[0].width);
    float ww = brush.length * brush[0].width * n;
    float xx = (width-ww)*n, yy = height-brush[0].height;
    for (int i=0; i<brush.length; i++) {
      pushMatrix();
      translate(xx, yy);
      scale(.4);
      shape(brush[i], 0, 0);
      popMatrix();
      xx+=brush[i].width*n;
    }
    pushMatrix();
    textAlign(CENTER);
    text("Please load an image by pressing 'l'", width*.5, height*.5);
    textAlign(CORNER);
    popMatrix();
  } else {
    pushMatrix();
    textAlign(CENTER);
    text("Press and move around your mouse to render variations", width*.5, height*.5);
    textAlign(CORNER);
    popMatrix();
    
  }
  text("esc - Exit\n e  - Export PDF\n l  - Load Image\n s  - Save Image", 50, 60);
}
float[] rgbToCmyk(color rgb_)
{
  float r_ = red(rgb_), g_ = green(rgb_), b_ = blue(rgb_);
  float c, m, y, k;
  float r = r_ / 255.0, g = g_ / 255.0, b = b_ / 255.0; 
  float[] rgb = {r, g, b};
  k = (float)(1- max(rgb)); 
  c = (float)((1-r-k) / (1-k)); 
  m = (float)((1-g-k) / (1-k)); 
  y = (float)((1-b-k) / (1-k));
  return new float[] {c, m, y, k};
}

void keyPressed() {
  if (key=='l') {
    set_input();
  }
  if (key=='s') {
    saveFrame(getClass().getName()+"_"+name+"_"+month()+day()+"_"+hour()+minute()+second()+".jpg");
  }
  if (key=='e') {
    isPrint = true;
  }
}

void load() {
  String path = sketchPath()+"/svgs/";
  paths = new String[0];
  String[] filenames = listFileNames(path);
  ArrayList<File> allFiles = listFilesRecursive(path);
  for (File f : allFiles) {
    if (f.isDirectory()) {
    } else {
      String fpath = f.getAbsolutePath();
      if (fpath.substring(fpath.length()-3, fpath.length()).equals("svg")) {
        paths = (String[])append(paths, fpath);
      }
    }
  }
  paths = sort(paths);
  for (int i=0; i<paths.length; i++) {
    PShape shp = loadShape(paths[i]);
    brush = (PShape[])append(brush, shp);
  }

  float xi = 100, yi = 100;
  for (int i=0; i<brush.length; i++) {
    xi += 100;
    if (xi>width-200) {
      xi = 0;
      yi +=100;
    }
  }

  font = createFont("SpaceMono-Regular.ttf", 32);
  textFont(font);
  textLeading(36);
}

String[] listFileNames(String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    String names[] = file.list();
    return names;
  } else {
    return null;
  }
}

ArrayList<File> listFilesRecursive(String dir) {
  ArrayList<File> fileList = new ArrayList<File>(); 
  recurseDir(fileList, dir);
  return fileList;
}

void fileSelected(File selection) {
  if (selection == null) {
  } else {
    input = loadImage(selection.getAbsolutePath());
    String[] ns= split(selection.getAbsolutePath(), "/");
    name = ns[ns.length-1];
    println(name);
    if (input.width>input.height) input.resize(width, 0);
    else input.resize(0, height);
  }
}

void recurseDir(ArrayList<File> a, String dir) {
  File file = new File(dir);
  if (file.isDirectory()) {
    a.add(file);  
    File[] subfiles = file.listFiles();
    for (int i = 0; i < subfiles.length; i++) {
      recurseDir(a, subfiles[i].getAbsolutePath());
    }
  } else {
    a.add(file);
  }
}
