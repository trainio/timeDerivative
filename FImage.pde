public class FColor {
  float r, g, b;
  
  public FColor(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  public FColor(float x) {
    this.r = x;
    this.g = x;
    this.b = x; 
  }
  
  public FColor(FColor c) {
    this.r = c.r;
    this.g = c.g;
    this.b = c.b; 
  }
  
  public void set(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  public void set(float x) {
    this.r = x;
    this.g = x;
    this.b = x;
  }
  
  public color asColor() {
    return color(r*255, g*255, b*255);
  }
  
  public FColor fromColor(color c) {
    return new FColor(red(c), green(c), blue(c));
  }
  
  public FColor mul(FColor c) {
    return new FColor(r * c.r, g * c.g, b * c.b);
  }
  
  public FColor mul(float f) {
    return new FColor(r * f, g * f, b * f);
  }
  
  public FColor add(FColor c) {
    return new FColor(r + c.r, g + c.g, b + c.b);
  }
  
  public FColor add(float f) {
    return new FColor(r + f, g + f, b + f);
  }
  
  public float getIntensity() {
    return r*0.3 + g*0.6 + b*0.1; 
  }
}

public class FImage {
  public FColor[] pixels;
  public int[] samples;
  public int width, height;

  public FImage(int width, int height) {
    this.width = width;
    this.height = height;
    pixels = new FColor[width*height];
    samples = new int[width*height];
    for(int i = 0; i < pixels.length; i++) {
      pixels[i] = new FColor(0, 0, 0);
      samples[i] = 0;
    }
  }

  public void set(int x, int y, FColor c) {
    pixels[x + y * width] = c;
  }
  
  public void addSample(int x, int y, FColor c) {
    int pos = x + y * width;
    pixels[pos].r += c.r;
    pixels[pos].g += c.g;
    pixels[pos].b += c.b;
    samples[pos] += 1;
  }
  
  public void addSample(int x, int y, float f) {
    int pos = x + y * width;
    pixels[pos].r += f;
    pixels[pos].g += f;
    pixels[pos].b += f;
    samples[pos] += 1;
  }
  
  public void add(int x, int y, FColor c) {
    int pos = x + y * width;
    pixels[pos].r += c.r;
    pixels[pos].g += c.g;
    pixels[pos].b += c.b;
  }
  
  public void add(int x, int y, float f) {
    int pos = x + y * width;
    pixels[pos].r += f;
    pixels[pos].g += f;
    pixels[pos].b += f;        
  }
  
  public void mul(int x, int y, float f) {
    int pos = x + y * width;
    pixels[pos].r *= f;
    pixels[pos].g *= f;
    pixels[pos].b *= f;        
  }
  
  public FColor get(int x, int y) {
    if(x < 0) x = 0;
    if(x >= width) x = width-1;
    if(y < 0) y = 0;
    if(y >= height) y = height-1;
    return pixels[x + y * width];
  }
  
  public float getIntensityAveraged(int x, int y) {
    if(x < 0) x = 0;
    if(x >= width) x = width-1;
    if(y < 0) y = 0;
    if(y >= height) y = height-1;
    int pos = x + y * width;
    return pixels[pos].getIntensity() / samples[pos];
  }
  
  public void clear() {
    for(int i = 0; i < pixels.length; i++) {
      pixels[i].set(0, 0, 0);
      samples[i] = 0;
    }
  }
  
  public void toPixelBuffer(int[] buffer) {
    for(int i = 0; i < pixels.length; i++) {
      buffer[i] = color(pixels[i].r*255/samples[i], pixels[i].g*255/samples[i], pixels[i].b*255/samples[i]);
    }
  }
  
  public void toPixelBuffer(int[] buffer, float exposure) {
    for(int i = 0; i < pixels.length; i++) {
      buffer[i] = color(expose(pixels[i].r, exposure), expose(pixels[i].g, exposure), expose(pixels[i].b, exposure));
    }
  }  
}

float expose(float light, float exposure) {
  return (1 - exp(-light * exposure)) * 255;
}
