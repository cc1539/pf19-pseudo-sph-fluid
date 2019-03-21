
class PartSystem extends ArrayList<Part> {
  
  private Part[] parts;
  
  private int[][] pgrid; // position grid
  private float res; // grid resolution
  private int g_width;
  private int g_height;
  
  public void setGridWidth(int value) { g_width=value; }
  public void setGridHeight(int value) { g_height=value; }
  public void setGridResolution(float value) { res=value; }
  
  public int getGridWidth() { return g_width; }
  public int getGridHeight() { return g_height; }
  public float getGridResolution() { return res; }
  
  void updatePartArray() {
    if(parts==null) {
      parts = toArray(new Part[size()]);
    }
  }
  
  boolean add(Part part) { parts=null; return super.add(part); }
  void remove(Part part) { parts=null; super.remove(part); }
  void clear() { parts=null; super.clear(); }
  
  void assertPGrid() {
    if(pgrid==null ||
        pgrid.length!=g_width ||
        pgrid.length!=g_height) {
      pgrid = new int[g_width][g_height];
    }
  }
  
  public void updatePIDs() {
    for(Part part : this) {
      part.gx = floor(part.x/res);
      part.gy = floor(part.y/res);
      part.pid = part.gx+part.gy*g_width;
    }
  }
  
  public void sortByPIDs() {
    sortByPIDs(0,size()-1);
  }
  
  public void sortByPIDs(int head, int tail) {
    if(tail>head+1) {
      int old_tail = tail;
      int old_head = head;
      int pivot = parts[(head+tail)/2].pid;
      while(tail>head) {
        while(parts[head].pid<pivot) { head++; }
        while(parts[tail].pid>pivot) { tail--; }
        if(tail>head) {
          
          Part temp = parts[head];
          parts[head] = parts[tail];
          parts[tail] = temp;
          
          head++;
          tail--;
        }
      }
      sortByPIDs(old_head,tail);
      sortByPIDs(head,old_tail);
    }
  }
  
  public void resetPGrid() {
    for(int i=0;i<getGridWidth();i++) {
    for(int j=0;j<getGridHeight();j++) {
      pgrid[i][j] = -1;
    }
    }
  }
  
  void updatePGrid() {
    
    resetPGrid();
    
    int last_pid = -1;
    for(int i=0;i<size();i++) {
      Part part = parts[i];
      if(part.pid!=last_pid) {
        if(part.gx<0 || part.gx>=getGridWidth()) { continue; }
        if(part.gy<0 || part.gy>=getGridHeight()) { continue; }
        last_pid = part.pid;
        pgrid[part.gx][part.gy] = i;
      }
    }
    
  }
  
  void resetDensity() {
    for(Part part : this) {
      part.resetDensity();
    }
  }
  
  void updatePressure() {
    for(Part part : this) {
      part.updatePressure();
    }
  }
  
  void interact(int type) {
    for(Part p0 : this) {
    for(int i=0;i<p0.neighbor_count;i++) {
      Part p1 = p0.neighbors[i];
      p0.interact(p1,type);
      if(type==Part.FLUID_PRESSURE) {
        p1.interact(p0,type);
      }
    }
    }
  }
  
  void move() {
    for(Part part : this) {
      part.move();
    }
  }
  
  void applyGravity(float g) {
    for(Part part : this) {
      //part.vy += g;
      float dx = width/2-part.x;
      float dy = height/2-part.y;
      float dst = sqrt(dx*dx+dy*dy);
      part.vx += dx*g/dst;
      part.vy += dy*g/dst;
    }
  }
  
  void draw() {
    for(Part part : this) {
      part.draw();
    }
  }
  
  void run() {
    
    updatePartArray();
    
    updatePIDs();
    sortByPIDs();
    assertPGrid();
    updatePGrid();
    
    updateNeighbors();
    
    resetDensity();
    interact(Part.DENSITY);
    updatePressure();
    
    interact(Part.FLUID_PRESSURE);
    interact(Part.FLUID_VISCOSITY);
    
    interact(Part.RIGID);
    
    move();
    applyGravity(0.02);
  }
  
  void updateNeighbors() {
    
    for(Part part : this) {
      part.resetNeighbors();
    }
    
    /*
    for(int i=0;i<size();i++) {
    for(int j=i+1;j<size();j++) {
      if(get(i).interact(get(j),Part.NONE)) {
        get(i).addNeighbor(get(j));
      }
    }
    }
    */
    
    for(Part part : this) {
      for(int i=-1;i<=1;i++) {
      for(int j=-1;j<=1;j++) {
        int x=i+part.gx; if(x<0||x>=getGridWidth()) { continue; }
        int y=j+part.gy; if(y<0||y>=getGridHeight()) { continue; }
        if(pgrid[x][y]!=-1) {
          
          int pid = parts[pgrid[x][y]].pid;
          for(int a=pgrid[x][y];a<size()&&parts[a].pid==pid;a++) {
            if(part.interact(parts[a],Part.NONE)) {
              part.addNeighbor(parts[a]);
            }
          }
          
        }
      }
      }
    }
    
  }
  
  void applyBorders(
      float x0, float y0,
      float x1, float y1) {
    float drag = 0.5;
    for(Part part : this) {
      if(part.x<x0||part.x>x1){part.x=2*(part.x<x0?x0:x1)-part.x;part.vx*=-drag;}
      if(part.y<y0||part.y>y1){part.y=2*(part.y<y0?y0:y1)-part.y;part.vy*=-drag;}
    }
  }
  
  void drawGrid() {
    for(int i=0;i<getGridWidth();i++) {
    for(int j=0;j<getGridHeight();j++) {
      rect(i*res,j*res,res,res);
    }
    }
  }
  
}
