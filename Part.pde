
public class Part {
  
  private Part[] neighbors = new Part[36];
  private int neighbor_count;
  private boolean connected;
  
  public static final int NONE = -1;
  public static final int DENSITY = 0;
  public static final int RIGID = 1;
  public static final int FLUID_PRESSURE = 2;
  public static final int FLUID_VISCOSITY = 3;
  
  public int pid; // position id
  public int gx; // grid x
  public int gy; // grid y
  
  public float x; // x position
  public float y; // y position
  public float vx; // x velocity
  public float vy; // y velocity
  public float ax; // x acceleration
  public float ay; // y acceleration
  
  public float cr; // collision radius
  public float er; // effect radius
  
  public float p; // pressure
  public float d; // density
  public float m; // mass
  public float u; // viscosity
  
  public float T; // temperature
  public float c; // conduction
  
  public color shade; // color
  
  public void addNeighbor(Part part) {
    if(neighbor_count<neighbors.length) {
      if(!this.hasNeighbor(part) &&
         !part.hasNeighbor(this)) {
        neighbors[neighbor_count++] = part;
        connected = true;
        part.connected = true;
      }
    }
  }
  
  public boolean hasNeighbor(Part part) {
    for(int i=0;i<neighbor_count;i++) {
      if(neighbors[i]==part) {
        return true;
      }
    }
    return false;
  }
  
  public void resetNeighbors() {
    neighbor_count = 0;
    connected = false;
  }
  
  public void move() {
    vx += ax;
    vy += ay;
    ax = 0;
    ay = 0;
    x += vx;
    y += vy;
    x += random(-1,1)*.02;
    y += random(-1,1)*.02;
  }
  
  public void resetDensity() {
    d = m;
  }
  
  public void updatePressure() {
    p = d;
  }
  
  public boolean interact(Part part, int type) {
    float dx = x - part.x;
    float dy = y - part.y;
    if(dx!=0 || dy!=0) {
      float dst2 = dx*dx+dy*dy;
      float crs = cr+part.cr;
      float ers = er+part.er;
      switch(type) {
        case NONE: {
          if(dst2<ers*ers) {
            return true;
          }
        } break;
        case DENSITY: {
          if(true/*dst2<ers*ers*/) {
            float q = 1-sqrt(dst2)/ers;
            d += q*part.m;
            part.d += q*m;
            return true;
          }
        } break;
        case RIGID: {
          if(dst2<crs*crs) {
            
            float avgT = (T+part.T)/2;
            float minc = min(c,part.c);
            float maxT = max(T,part.T);
            
            float repel = min(max(maxT,-1),2);
            float scale = max(min(50,abs(maxT)),1);
            float q = (1-sqrt(dst2)/(crs+repel)) * .02 * scale;
            dx *= q;
            dy *= q;
            
            ax += dx;
            ay += dy;
            part.ax -= dx;
            part.ay -= dy;
            
            /*
            x += dx;
            y += dy;
            part.x -= dx;
            part.y -= dy;
            */
            
            T += (avgT-T)*minc;
            part.T += (avgT-part.T)*minc;
            
            return true;
          }
        } break;
        case FLUID_PRESSURE: {
          if(true/*dst2<ers*ers*/) {
            
            float dst = sqrt(dst2);
            float q = 1-dst/ers;
            float k = p-3.2;//log(p-1);
            if(k>0) {
              k *= 0.1;
            }
            float scale = min(max(k,-0.04),0.04);
            float f = q*(part.p-p)/dst*scale;
            float fx = dx*f;
            float fy = dy*f;
            vx += fx;
            vy += fy;
            //part.vx -= fx;
            //part.vy -= fy;
            
            return true;
          }
        } break;
        case FLUID_VISCOSITY: {
          if(true/*dst2<ers*ers*/) {
            // viscosity
            if(u!=0 || part.u!=0) {
              
              float dst = sqrt(dst2);
              
              float dvx = part.vx-vx;
              float dvy = part.vy-vy;
              float d = abs(dvx*dx+dvy*dy)/(dst*sqrt(dvx*dvx+dvy*dvy));
              if(d>0) {
                float vx_avg = (vx+part.vx)/2;
                float vy_avg = (vy+part.vy)/2;
                
                //float freeze = exp(min(max(T,part.T),0));
                
                //float d = 0.02;
                //d *= pow(d,36*freeze);
                d *= pow(d,36); // 36 is from trial and error
                d *= min(u,part.u);
                vx += (vx_avg-vx)*d;
                vy += (vy_avg-vy)*d;
                part.vx += (vx_avg-part.vx)*d;
                part.vy += (vy_avg-part.vy)*d;
              }
              
            }
            
            return true;
          }
          
        } break;
      }
    }
    return false;
  }
  
  public void draw() {
    /*
    int x = (int)this.x;
    int y = (int)this.y;
    int vx = (int)this.vx;
    int vy = (int)this.vy;
    if(abs(vx)>1 || abs(vy)>1) {
      line(x-vx,y-vy,x,y);
    } else {
      point(x,y);
    }
    */
    //float speed = (vx*vx+vy*vy)/10.;
    //fill(lerpColor(shade,color(255),speed));
    //fill((vx-vy)*64,(vy-vx)*64,-(vx+vy)*64);
    
    if(!connected) {
      //fill(0,128,255);
      fill(255);
      noStroke();
      
      //float s = min((d-1)*3+2,8);
      float s = random(0,2);
      rect(x,y,s,s);
    } else {
      //strokeWeight(s*2);
      //pushMatrix();
      //point(x,y,z);
      //translate(x,y,z);
      //box(s);
      //popMatrix();
      
      /*
      float diff = 0;
      for(int i=0;i<neighbor_count;i++) {
        Part n = neighbors[i];
        diff += abs(n.p-p);
      }
      diff /= neighbor_count;
      if(diff>.5) {
        stroke(0,128,255);
        for(int i=0;i<neighbor_count;i++) {
          Part n = neighbors[i];
          line(x,y,n.x,n.y);
        }
      }
      */
      
      /*
      if(p<=5) {
        for(int i=0;i<neighbor_count;i++) {
          Part n = neighbors[i];
          float val = 255-(min(p,n.p)-4)*255;
          if(val>0) {
             stroke(0,128,255,val);
             line(x,y,n.x,n.y);
          }
        }
      }
      */
      
      /*
      stroke(0,128,255);
      float thresh = 4;
      if(p<thresh) {
        for(int i=0;i<neighbor_count;i++) {
          Part n = neighbors[i];
          if(n.p<thresh) {
            line(x,y,n.x,n.y);
          }
        }
      }
      */
      
      noStroke();
      fill(0,128,255);
      float s = max(min(p,6),2);
      rect(x,y,s,s);
      
    }
  }
  
}
