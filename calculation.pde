
int[] calculateDifferenceOf(Capture _cameraInput, int[] referenceArray, String METHOD) {
  int d = 0;
  int a = 0;
  int b = 0;
  total = 0;
  int[] output = new int[numPixels];

  for (int i = 0; i < numPixels; i++) { 

    // Extract the green channel values of the current pixel's color
    a = (_cameraInput.pixels[i] >> 8) & 0xFF;
    b = (referenceArray[i] >> 8) & 0xFF;

    if (frameToFrameDifference) {
      // save current values to pixel array for frame diffence
      previousFrame[i] = 0xFF000000 | (a << 16) | (a << 8) | a;
    }

    // DIFFERENT METHODS HERE:

    if (METHOD.compareTo("ABSOLUTE")==0)
    {
      d = abs(a-b);
      if (abs(d)>threshold) {
        output[i] = d;
        total+=d;
      }
    } else if (METHOD.compareTo("SQUAREROOT")==0)
    {
      // VÄÄRIN d = int(pow(sqrt(float(a)-float(b)), 2));
      d = int( sqrt( pow(float(a)-float(b),2) )); // L2 norm
      
      //frameBufferInt[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
      // output[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
      // output[i] = new FColor(d,d,d);
      if (abs(d)>threshold) {
        output[i] = d;
        total+=d;
      }
    } else if (METHOD.compareTo("HEATMAP")==0)
    {
      d = a-b;
      float r =  int(map(d, -255, 255, 0, 255));
      float g =  int(map(d, -255, 255, 255, 0));
      if (abs(d)>threshold) {
        heatmap[i] = new FColor(r, g, 128);
        total+=r;
      } else {
        heatmap[i] = new FColor(128);
      }
    } else {
      output[i] = 0xFF000000;
    }

    // other methods of computing? add here...
  }
  return output;
}

FColor[] calculate32bitDifferenceOf(Capture _cameraInput, int[] referenceArray, String METHOD) {
  float d = 0;
  int a = 0;
  int b = 0;
  total = 0;
  FColor[] output = new FColor[numPixels];

  for (int i = 0; i < numPixels; i++) { 

    // Extract the green channel values of the current pixel's color
    a = (_cameraInput.pixels[i] >> 8) & 0xFF;
    b = (referenceArray[i] >> 8) & 0xFF;

    if (frameToFrameDifference) {
      // save current values to pixel array for frame diffence
      previousFrame[i] = 0xFF000000 | (a << 16) | (a << 8) | a;
    }

    // DIFFERENT METHODS HERE:

    if (METHOD.compareTo("ABSOLUTE")==0)
    {
      d = abs(a-b);
      //frameBufferInt[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
      //output[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
      output[i] = new FColor(d, d, d);
      total+=d;
    } else if (METHOD.compareTo("SQUAREROOT")==0)
    {
  //    d = int(pow(sqrt(float(a)-float(b)), 2));
      d = int( sqrt( pow(float(a)-float(b),2) )); // L2 norm
      //frameBufferInt[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
      // output[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
      output[i] = new FColor(d, d, d);

      total+=d;
    } else if (METHOD.compareTo("HEATMAP")==0)
    {
      d = a-b;
      float r =  int(map(d, -255, 255, 0, 255));
      float g =  int(map(d, -255, 255, 255, 0));
      heatmap[i] = new FColor(r, g, 128);
      total+=r;
    } else {
      // frameBufferInt[i] = 0xFF000000 | (0 << 16) | (0 << 8) | 0;
      //output[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
      output[i] = new FColor(0);
    }

    // other methods of computing? add here...
  }
  return output;
}

void mirror(FColor [] input) {
/*
  FColor[] temp = new FColor[numPixels];
  
      for (int j = 0; j < height; j++) {
        for (int i = 0; i < width/2; i++) {
        int x = i;
        int y = j;
        int loc = (width - x - 1) + y*width; // Reversing x to mirror the image
      
        temp[loc] = input[j*width+i];
      }
      }
       for (int j = 0; j < height; j++) {
        for (int i = 0; i < width ; i++) {
        int x = i;
        int y = j;
        int loc = (width - x - 1) + y*width; // Reversing x to mirror the image
        
        if(i<width/2){
        outputBuffer[loc] = input[j*width+i];
        } else {
          outputBuffer[loc] = temp[loc];
        }
      }      
    }
    */
}

void drawMirroredBuffer() {
       for (int j = 0; j < height; j++) {
        for (int i = 0; i < width ; i++) {           
          int loc = (width - i - 1) + j*width; // Reversing x to mirror the image
          int orig = i + j*width;
          pixels[orig] = 0xFF000000 | (int(outputBuffer[loc].r) << 16) | (int(outputBuffer[loc].g) << 8) | int(outputBuffer[loc].b);
  }
 }
}

float getLum(color c)
{
  return (red(c)*0.35 + green(c)*0.45 + blue(c)*0.2)/255.0;
}



//void addPixelsToBuffer(Capture _cameraInput, int[] referenceArray) {
//  for (int i = 0; i < numPixels; i++) {
//    floatBuffer[i] = new FColor((_cameraInput.pixels[i] - referenceArray[i]));
//  }
//}
void addPixelsToBuffer(FColor[] inputArray, float exposure) {
  for (int i = 0; i < numPixels; i++) {
    floatBuffer[i] = new FColor(floatBuffer[i].g+(inputArray[i].g * exposure));
    outputBuffer[i] = floatBuffer[i];
    // imgTargetFloat.add(i%width, i/width, mix);
  }
}

void clearBuffer(int[] frameBufferInt) {
  for (int i = 0; i < numPixels; i++) { 
    frameBufferInt[i] = 0xFF000000 | (0 << 16) | (0 << 8) | 0;
  }
}
void clearBuffer(float[] frameBufferFloat) {
  for (int i = 0; i < numPixels; i++) { 
    frameBufferFloat[i] = 0xFF000000 | (0 << 16) | (0 << 8) | 0;
  }
}
void clearBuffer(FColor[] floatBuffer) {
  for (int i = 0; i < numPixels; i++) { 
    floatBuffer[i] = new FColor(0, 0, 0);
  }
}

void drawBuffer(int[] frameBufferInt) {
  for (int i = 0; i < numPixels; i++) { 
    int d = frameBufferInt[i];
    if (d>threshold || !useThreshold) {
      // write new values to pixel array
      pixels[i] = 0xFF000000 | (d << 16) | (d << 8) | d;
    } else {
      pixels[i] = 0xFF000000 | (0 << 16) | (0 << 8) | 0;
    }
  }
}

void drawBuffer() {
  for (int i = 0; i < numPixels; i++) {
    pixels[i] = 0xFF000000 | (int(outputBuffer[i].r) << 16) | (int(outputBuffer[i].g) << 8) | int(outputBuffer[i].b);
  }
}

void copyPixelsToOutputBuffer(int[] inputArray) {
  for (int i = 0; i < numPixels; i++) {
    outputBuffer[i] = new FColor(float(inputArray[i]));
  }
}

void copyPixelsToOutputBuffer(FColor[] heatmapBuffer, String CHANNELS) {
  for (int i = 0; i < numPixels; i++) {
    outputBuffer[i] = heatmapBuffer[i];
  }
}

void copyPixelsToOutputBuffer(FColor[] inputArray) {
  for (int i = 0; i < numPixels; i++) {
    outputBuffer[i] = inputArray[i];
  }
}