int rect_length = 80;
int rect_height = 80;
PGraphics pg;
String shaderFile = "blur.glsl";
PImage image;
PShader shader;


void setup(){
    size(800, 640, P2D);
    textSize(22);
    pg = createGraphics(800, 640);
    image = loadImage("city.jpg");
    shader = loadShader("blur.glsl");
}


void draw(){    
    background(0);
    pGraphics_draw();
    setShaderParameters();
    shader(shader);
    image(image, 0, 0, width, height);
    resetShader();
    image(pg, 0, 0);
}


void setShaderParameters(){
    float mouse_x = float(mouseX);
    float mouse_y = float(height - mouseY);
    float x_length = float(rect_length/2);
    float y_length = float(rect_height/2);
    shader.set("pixelX", mouse_x);
    shader.set("xLength", x_length);
    shader.set("pixelY", mouse_y);
    shader.set("yLength", y_length);
    float sigma = 1000.0;
    int blur_size = 50;
    shader.set("sigma", sigma);
    shader.set("blurSize", int(blur_size));
}


void pGraphics_draw(){
    pg.beginDraw();
    pg.clear();
    pg.strokeWeight(0);
    pg.stroke(0, 0, 0, 0);
    pg.noFill();
    pg.rectMode(CENTER);
    pg.rect(mouseX, mouseY, rect_length, rect_height);
    pg.endDraw();
}