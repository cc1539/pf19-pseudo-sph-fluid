
int IPF = 1;
PartSystem ps = new PartSystem();

PImage bg;

float h = 5;

void setup() {
  
  size(640,640,P2D);
  noSmooth();
  
  int res = ceil(h);
  ps.setGridWidth(width/res+1);
  ps.setGridHeight(height/res+1);
  ps.setGridResolution(res);
  
  bg = loadImage("bg.jpg");
  
  /*
  for(int i=0;i<20;i++) {
  for(int j=0;j<50;j++) {
  for(int k=0;k<5;k++) {
    
    final int xi = i;
    final int yi = j;
    final int zi = k;
    
    ps.add(new Part(){{
          
      this.x = xi*10;
      this.y = height-yi*10;
      this.z = zi*10;
      
      m = 1;
      u = 0.04;
      er = 5;
      cr = 3;
      
      shade = color(0,128,255,48);
    }});
  }
  }
  }
  */
  
}

void keyPressed() {
  switch(key) {
    case 'c': {
      ps.clear();
    } break;
  }
}

void draw() {
  
  //background(0);
  tint(64);
  image(bg,0,0,width,height);
  /*
  translate(width/2,height/2,400);
  rotateY(mouseX*0.02);
  rotateX(mouseY*0.02);
  scale(.1);
  translate(-width/2,-height/2);
  */
  if(mousePressed) {
    if(mouseButton==LEFT) {
      
      for(int i=0;i<30;i++) {
        final float r = sqrt(random(0,1))*30;
        final float w = random(0,TWO_PI);
        ps.add(new Part(){{
          
          x = mouseX+r*cos(w);
          y = mouseY+r*sin(w);
          
          vx += (float)(mouseX-pmouseX)/IPF;
          vy += (float)(mouseY-pmouseY)/IPF;
          
          m = 1;
          u = 0.2;
          er = h;
          cr = h/5.*3.;
          
          switch(key) {
            case 'q': T=-10; break;
            case 'w': T= 0; break;
            case 'e': T= 100; break;
          }
          c = 0.5;
          
          shade = color(0,128,255,48);
        }});
      }
      
    } else if(mouseButton==RIGHT) {
      
      for(Part part : ps) {
        float dx = mouseX-part.x;
        float dy = mouseY-part.y;
        float f = 2/((dx*dx+dy*dy)/15+1);
        part.vx += (dx)*f;
        part.vy += (dy)*f;
      }
      
    }
  }
  
  for(int i=0;i<IPF;i++) {
    ps.run();
    
    float border = 5;
    ps.applyBorders(
      border,
      border,
      width-border,
      height-border);
  }
  
  /*
  rectMode(CORNER);
  fill(128);
  noStroke();
  ps.drawGrid();
  */
  
  /*
  noFill();
  stroke(255);
  */
  rectMode(CENTER);
  fill(0,0,255);
  noStroke();
  
  ps.draw();
  
  fill(255);
  textAlign(LEFT,TOP);
  text("Particles: "+ps.size(),4,4);
  
  surface.setTitle("FPS: "+frameRate);
}
