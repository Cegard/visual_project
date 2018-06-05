
import remixlab.proscene.*;
import remixlab.dandelion.core.*;
import remixlab.dandelion.constraint.*;

PShader depthShader, dofShader;
PGraphics srcPGraphics, depthPGraphics, dofPGraphics;
Scene scene;
InteractiveFrame[] models;
PShape[] shapes;
int totalShapes = 100;


void setup() {
  size(900, 900, P3D);
  colorMode(HSB, 255);
  srcPGraphics = createGraphics(width, height, P3D);
  scene = new Scene(this, srcPGraphics);
  scene.setEyeConstraint(new LocalConstraint());
  models = new InteractiveFrame[totalShapes];
  shapes = new PShape[totalShapes];

  for (int i = 0; i < totalShapes; i++) {
    shapes[i] = boxShape();
    models[i] = new InteractiveFrame(scene, shapes[i]);
    models[i].translate(random(-1000, 1000), 
                        random(-1000, 1000), 
                         random(-1000, 1000));
  }

  scene.setRadius(1000);
  scene.showAll();

  depthShader = loadShader("depth.glsl");
  depthShader.set("maxDepth", scene.radius()*2);
  depthPGraphics = createGraphics(width, height, P3D);
  depthPGraphics.shader(depthShader);

  dofShader = loadShader("dof.glsl");
  dofShader.set("aspect", width / (float) height);
  dofShader.set("maxBlur", 0.015);  
  dofShader.set("aperture", 0.02);
  dofPGraphics = createGraphics(width, height, P3D);
  dofPGraphics.shader(dofShader);

  frameRate(1000);
}


void draw() {
  // 1. Draw into main buffer
  scene.beginDraw();
  scene.pg().background(0);
  scene.drawFrames();
  scene.endDraw();

  // 2. Draw into depth buffer
  depthPGraphics.beginDraw();
  depthPGraphics.background(0);
  scene.drawFrames(depthPGraphics);
  depthPGraphics.endDraw();

  // 3. Draw destination buffer
  dofPGraphics.beginDraw();
  dofShader.set("focus", getZDistance(shapes[0]));
  dofShader.set("tDepth", depthPGraphics);    
  dofPGraphics.image(scene.pg(), 0, 0);
  dofPGraphics.endDraw();
  
  scene.display(dofPGraphics);
}


PShape boxShape() {
  PShape box = createShape(BOX, 60);
  box.setFill(color(random(0,255), random(0,255), random(0,255)));
  return box;
}


float getZDistance(PShape box){
  float maxDistance = box.getVertex(0).z;
  float minDistance = box.getVertex(0).z;
  
  for (int i = 1; i < box.getVertexCount(); i++){
    
    if (box.getVertex(i).z > maxDistance)
      maxDistance = box.getVertex(i).z;
    
    if (box.getVertex(i).z < minDistance)
      minDistance = box.getVertex(i).z;
  }
  
  return (maxDistance + minDistance)/2;
}