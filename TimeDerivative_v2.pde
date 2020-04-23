
// Time derivative made for Bridges 2020 conference 
// v0.2 Tuomo Rainio

import processing.video.*; // Processing video library from Camera capture
import com.hamoid.*; // Video recording library, uses FFMPEG

VideoExport videoExport;
Capture cameraInput;

// SETTINGS
// MODIFY settings > settings.txt outside Processing
boolean recording = false;
boolean mirror = false; // TO DO: Add horizontal flipping,
boolean frameToFrameDifference = true;
boolean useThreshold = true;
int threshold = 0;
int method = 1; // CHOOSE THE DEFAULT METHOD HERE (1-5)
int exposureTime = 1000; // frames

// DON*T CHANGE FOLLOWING
String[] filePathToSaveVideo;
int numPixels;
int total = 0;
int[] referenceFrame;
int [] previousFrame;
FColor [] outputBuffer;
FColor[] heatmap;
FColor [] floatBuffer;
boolean captureFrameInSetup = true;
boolean drawUI = false;
boolean isMirrored = false;
int frame = 0;
int plotFR_x;
ArrayList<PVector> points = new ArrayList<PVector>();


void setup() {
  size(1280, 720); // Default camera ratio, try 640*360 for lower resolution
  //size(640, 360);
  // frameRate(30);
  surface.setTitle("Time Derivative");

  filePathToSaveVideo = loadStrings("settings/settings.txt");

  videoExport = new VideoExport(this);
  customizeVideoFileSettings(filePathToSaveVideo[2]);

  if (filePathToSaveVideo[1].compareTo("true")==0) {
    recording = true;
  }
  if (recording) {
    videoExport.setMovieFileName(filePathToSaveVideo[0]+"video "+videoID()+".mp4");
    videoExport.startMovie();
  } else {
    videoExport.setDebugging(false);
  }

  cameraInput = new Capture(this, width, height);
  cameraInput.start();  

  // Some buffer matrices for storing pixels
  numPixels = cameraInput.width * cameraInput.height;
  referenceFrame = new int[numPixels];
  previousFrame = new int[numPixels];
  outputBuffer = new FColor[numPixels];
  heatmap = new FColor[numPixels];
  floatBuffer = new FColor[numPixels];
  clearBuffer(floatBuffer);
  // Make the pixels[] array available for direct manipulation
  loadPixels();
}

void draw() {

  if (cameraInput.available()) {
    // READ CAMERA DATA
    cameraInput.read();
    cameraInput.loadPixels(); 

    // CALCULATE
    switch (method) {
    case 1:
      copyPixelsToOutputBuffer(calculateDifferenceOf(cameraInput, referenceFrame, "ABSOLUTE"));
      break;
    case 2:  
      copyPixelsToOutputBuffer(calculateDifferenceOf(cameraInput, referenceFrame, "SQUAREROOT"));
      break;
    case 3: 
      copyPixelsToOutputBuffer(calculateDifferenceOf(cameraInput, previousFrame, "ABSOLUTE"));
      break;
    case 4:  
      copyPixelsToOutputBuffer(calculateDifferenceOf(cameraInput, previousFrame, "SQUAREROOT"));
      break;
    case 5:  
      calculateDifferenceOf(cameraInput, previousFrame, "HEATMAP");
      copyPixelsToOutputBuffer(heatmap, "RGB");
      break;
    case 6:
      addPixelsToBuffer(calculate32bitDifferenceOf(cameraInput, referenceFrame, "ABSOLUTE"), 0.001);
      break;
    default:
      println("Define method!");
      break;
    }
    if (total>0) {
      updatePixels(); // Skip empty frames before drawing to screen
      if(isMirrored){
         drawMirroredBuffer();
      } else {
         drawBuffer();
      }
    }

    frame++;
    if (frame>=exposureTime) {
      frame = 0; 
      clearBuffer(floatBuffer);
    }

    // RECORD
    if (recording) videoExport.saveFrame();
    
    // RUN ONCE IN SETUP
    if (captureFrameInSetup) { 
      recordStillFrame();
      captureFrameInSetup=false;
    } 
  }
     points.add(new PVector(plotFR_x, map(frameRate, 0,60,height,0)));

  if(drawUI){
    
   stroke(128,0,0);
   
   PVector p_prev = new PVector(0,0);
   for (PVector p : points) {
     
   //  point(p.x,p.y);
     line(p_prev.x, p_prev.y, p.x,p.y);
     p_prev = p;
   }
   
   plotFR_x++;
   if (plotFR_x>width){ 
     plotFR_x=0;
     points.clear();
   }
      drawUI();
  } else {
      if(recording){
      surface.setTitle("Recording..");
      } else {
      surface.setTitle(nf(frameRate,2,1));
      }

  }
}


void mousePressed() {
  recording = true;
  videoExport.setMovieFileName(filePathToSaveVideo[0]+"video "+videoID()+".mp4");
  videoExport.startMovie();
  println("Start recording...");
}
void mouseReleased() {
  recording = false;
  videoExport.endMovie();
}

void keyPressed() {
  if (key=='c') {
    recordStillFrame();
  }
    if (key=='d') {
    drawUI=!drawUI;
  }
      if (key=='m') {
    isMirrored=!isMirrored;
  }
      if (key=='t') {
    threshold=mouseX;
  }
  if (key == 'q') {
    recording = false;
    videoExport.endMovie();
    if (recording) {
      println("... stopped recording.");
    }
    exit();
  }
  if (key=='1') {
    method = 1;
    frameToFrameDifference = false;
  }
  if (key=='2') {
    method = 2;
    frameToFrameDifference = false;
  }
  if (key=='3') {
    method = 3;
    frameToFrameDifference = true;
  }
  if (key=='4') {
    method = 4;
    frameToFrameDifference = true;
  }
  if (key=='5') {
    method = 5;
    frameToFrameDifference = true;
  }
  if (key=='6') {
    method = 6;
    frameToFrameDifference = true;
  }
}


void recordStillFrame() {
  cameraInput.loadPixels();
// TODO: make your own   copyToBuffer(cameraInput);
  arraycopy(cameraInput.pixels, referenceFrame);
}

void customizeVideoFileSettings(String _quality) {
  int q = parseInt(_quality);
  videoExport.setQuality(q, 0);
  videoExport.setLoadPixels(false);
  videoExport.setFrameRate(10);
}

String videoID() {
  String result = year()+"-"+month()+"-"+day()+"-"+hour()+"-"+minute()+"-"+second();
  return result;
}
