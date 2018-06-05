/**
 * DOF.
 * by Jean Pierre Charalambos.
 *
 * This example implements a Depth-Of-Field (DOF) shader effect
 * using the traverse(), traverse(PGraphics), display() and
 * display(PGraphics) Scene methods.
 */

import frames.input.*;
import frames.core.*;
import frames.processing.*;

PShader depthShader, dofShader;
PGraphics srcPGraphics, depthPGraphics, dofPGraphics;
Scene scene;
OrbitShape[] models;
PShape[] boxes;
int totalBoxes = 100;
float sceneRadius = 1000.0;
float focusDistance = -0.5f;
float minDistance =  -0.5f;
float maxDistance = 1.5f;
float movementFactor = 0.13f;

void setup() {
  size(800, 600, P3D);
  colorMode(HSB, 255);
  srcPGraphics = createGraphics(width, height, P3D);
  scene = new Scene(this, srcPGraphics);
  OrbitShape eye = new OrbitShape(scene);
  scene.setEye(eye);
  scene.setFieldOfView(PI / 3);
  //interactivity defaults to the eye
  scene.setDefaultGrabber(eye);
  scene.setRadius(sceneRadius);
  scene.fitBallInterpolation();

  models = new OrbitShape[totalBoxes];
  boxes = new PShape[totalBoxes];
  
  for (int i = 0; i < models.length; i++) {
    boxes[i] = boxShape();
    boxes[i].translate(random(-sceneRadius, sceneRadius),
                       random(-sceneRadius, sceneRadius),
                       random(-sceneRadius, sceneRadius));
    models[i] = new OrbitShape(scene);
    models[i].set(boxes[i]);
  }
  
  depthShader = loadShader("depth.glsl");
  depthShader.set("maxDepth", scene.radius() * 2);
  depthPGraphics = createGraphics(width, height, P3D);
  depthPGraphics.shader(depthShader);

  dofShader = loadShader("dof.glsl");
  dofShader.set("aspect", width / (float) height);
  dofShader.set("maxBlur", (float) 0.015);
  dofShader.set("aperture", (float) 0.02);
  dofPGraphics = createGraphics(width, height, P3D);
  dofPGraphics.shader(dofShader);

  scene.frontBuffer().hint(ENABLE_BUFFER_READING);
  frameRate(1000);
}

void draw() {
  // 1. Draw into main buffer
  scene.beginDraw();
  scene.frontBuffer().background(0);
  scene.traverse();
  scene.endDraw();

  // 2. Draw into depth buffer
  depthPGraphics.beginDraw();
  depthPGraphics.background(0);
  scene.traverse(depthPGraphics);
  depthPGraphics.endDraw();

  // 3. Draw destination buffer
  dofPGraphics.beginDraw();
  dofShader.set("focus", focusDistance);
  //dofShader.set("focus", map(getZDistance(boxes[0]), -sceneRadius, sceneRadius, -0.5f, 1.5f));
  //dofShader.set("focus", map(mouseX, 0, width, -0.5f, 1.5f));
  //Seems broken, check an approximate result with previous instead
  //of this one. Test with other hardware and please report.
  //dofShader.set("focus", map(scene.pixelDepth(mouseX, mouseY), 0, 1, -0.5f, 1.5f));
  dofShader.set("tDepth", depthPGraphics);
  dofPGraphics.image(scene.frontBuffer(), 0, 0);
  dofPGraphics.endDraw();
  
  scene.display(dofPGraphics);
  println(boxes[10].getVertex(0).z);
}


PShape boxShape() {
  PShape box = createShape(BOX, 60);
  box.setFill(color(random(0, 255), random(0, 255), random(0, 255)));
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


void keyPressed(){
  
  if (key == '+' && focusDistance < maxDistance)
    focusDistance += movementFactor;
  
  if (key == '-' && focusDistance > minDistance)
    focusDistance -= movementFactor;
}