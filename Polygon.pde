

class Polygon {
  
   ArrayList<Point> p     = new ArrayList<Point>();
   ArrayList<Edge>  bdry = new ArrayList<Edge>();
     
   Polygon( ){  }
   
   
   boolean isClosed(){ return p.size()>=3; }

   boolean isSimple(){
     // TODO: Check the boundary to see if it is simple or not.
     ArrayList<Edge> bdry = getBoundary();
     
     // VIVIEN
     Point arbPoint = new Point(0.0,0.0);
     Edge currentEdge = new Edge(arbPoint, arbPoint);
     Edge otherEdge = new Edge(arbPoint, arbPoint);
     
     for (int i = 0; i < bdry.size(); i++) {
       
       currentEdge = bdry.get(i);
       // skip to i + 2 edge, since adjacent edge doesn't matter
       for (int j = i + 2; j < bdry.size(); j++) {
         otherEdge = bdry.get(j);
         
         // if first edge is compared with last
         if (j == (bdry.size()-1) && i == 0) {
          continue; 
         }
         
         if (currentEdge.intersectionTest(otherEdge)) {
          return false; 
         }
       }
     }
     return true;
   }
   
   
   boolean pointInPolygon( Point p ){
     // TODO: Check if the point p is inside of the 
     ArrayList<Edge> bdry = getBoundary();
      
     // Make another "endpoint". Drag end of "ray" to "infinity" but make y constant
     Point infP = new Point(10000000.0, p.p.y);
     
     Edge infRay = new Edge(p, infP);
     Point intersectP = new Point(0.0,0.0);
     Edge currentEdge = new Edge(intersectP, intersectP);
     int edgeIntersect = 0;
     
     // Loop through all possible edges
     int i = 0;
     while (i < bdry.size()) {
       
       currentEdge = bdry.get(i);

       // if there are any intersections evaulate
       if (currentEdge.intersectionTest(infRay)) {
         // if there are any intersections get point to evalate edges on right of point
         intersectP = currentEdge.intersectionPoint(infRay);
         
         // Check if point is on vertex
         if (p.p.x == currentEdge.p0.p.x && p.p.y == currentEdge.p0.p.y || // on first end
             p.p.x == currentEdge.p1.p.x && p.p.y == currentEdge.p1.p.y)   // or second end
         {
           return true;   
         }
         
         // Check if point is on segment
         // check if collinear
         if (((p.p.y - currentEdge.p0.p.y)*(currentEdge.p1.p.x - p.p.x) - 
             (p.p.x - currentEdge.p0.p.x)*(currentEdge.p1.p.y - p.p.y)) == 0) {
           // check if between p0 and p1
           if (p.p.x <= max(currentEdge.p0.p.x,currentEdge.p1.p.x) && p.p.x >=min(currentEdge.p0.p.x,currentEdge.p1.p.x) &&
               p.p.y <= max(currentEdge.p0.p.y,currentEdge.p1.p.y) && p.p.x >=min(currentEdge.p0.p.y,currentEdge.p1.p.y)) {
             return true;    
           }          
         }
         // Make sure imaginary ray does not count vertexes, if vertex found start over
         if (intersectP.p.y == bdry.get(i).p0.p.y || intersectP.p.y == bdry.get(i).p1.p.y) {
           // increase y endpoint of ray
           infRay.p1.p.y+=50;
           // start over
           i = 0;
           edgeIntersect = 0;
           continue;
         }
         edgeIntersect++;
       }
       i++;
     }
     //// DELETE
     //println("# of Edge Intersects: ", edgeIntersect);
     // if number of intersections with edges is odd (after all special cases handled), point is in polygon
     if ((edgeIntersect % 2) == 1) {
       return true;
     }
     return false;
   }
   
   
   ArrayList<Edge> getDiagonals(){
     // TODO: Determine which of the potential diagonals are actually diagonals
     ArrayList<Edge> bdry = getBoundary();
     ArrayList<Edge> diag = getPotentialDiagonals();
     ArrayList<Edge> ret  = new ArrayList<Edge>();
     
     // make arb point and edges
     Point arbPoint = new Point(0.0,0.0);
     Edge diagC = new Edge(arbPoint, arbPoint);
     Edge bdryC = new Edge(arbPoint, arbPoint);
     Point intersectP = new Point(0.0,0.0);
     
     // compare diagonal with intersection of all boundaries
     // for each diagonal check intersection with boundaries (from first point, check intersection)
     for (int i = 0; i < diag.size(); i++) {
       boolean containsBoundary = false;
       diagC = diag.get(i);
       for (int j = 0; j < bdry.size(); j++) {
         bdryC = bdry.get(j);
         if (diagC.intersectionTest(bdryC)) {
           
           intersectP = diagC.intersectionPoint(bdryC);
           
           // Excuse intersections with vertices
           if (diagC.p0.p.x == intersectP.p.x && diagC.p0.p.y == intersectP.p.y ||
               diagC.p1.p.x == intersectP.p.x && diagC.p1.p.y == intersectP.p.y) {
           } else {
             // collinear case
             // Check if point is on segment
             // check if collinear
             if (((intersectP.p.y - bdryC.p0.p.y)*(bdryC.p1.p.x - intersectP.p.x) - 
                 (intersectP.p.x - bdryC.p0.p.x)*(bdryC.p1.p.y - intersectP.p.y)) == 0) {
               // check if between p0 and p1
               if (intersectP.p.x <= max(bdryC.p0.p.x,bdryC.p1.p.x) && intersectP.p.x >=min(bdryC.p0.p.x,bdryC.p1.p.x) &&
                   intersectP.p.y <= max(bdryC.p0.p.y,bdryC.p1.p.y) && intersectP.p.x >=min(bdryC.p0.p.y,bdryC.p1.p.y)) {   
               }        
               else {
                 containsBoundary = true;
               }
             }
             containsBoundary = true;
             
           }
           // if diagonal lies outside with no intersections
           if (!pointInPolygon(diagC.midpoint())) {
             containsBoundary = true;
           }
         }
       }
       if (!containsBoundary) {
         ret.add(diagC);
       }
       
     }
     return ret;
   }
   
   
   boolean ccw(){
    // TODO: Determine if the polygon is oriented in a counterclockwise fashion
    // VIVIEN
    // sum over edges (x2 - x1)(y2 + y1)
    double sumOfEdges = 0;
    for (Edge e : bdry ) {
    // println("*: ", e.p0.p.x);
    sumOfEdges += (e.p1.p.x - e.p0.p.x)*(e.p1.p.y + e.p0.p.y);
    }
    if (sumOfEdges < 0) {
     return true; 
    }
    if( !isClosed() ) return false;
    if( !isSimple() ) return false;
    return false;
   }
   
   
   boolean cw(){
    // TODO: Determine if the polygon is oriented in a clockwise fashion
    // sum over edges (x2 - x1)(y2 + y1)
    double sumOfEdges = 0;
    for (Edge e : bdry ) {
    // println("*: ", e.p0.p.x);
    sumOfEdges += (e.p1.p.x - e.p0.p.x)*(e.p1.p.y + e.p0.p.y);
    }
    if (sumOfEdges > 0) {
     return true; 
    }
    if( !isClosed() ) return false;
    if( !isSimple() ) return false;     
    return false;
   }
      
   
   
   
   ArrayList<Edge> getBoundary(){
     return bdry;
   }


   ArrayList<Edge> getPotentialDiagonals(){
     ArrayList<Edge> ret = new ArrayList<Edge>();
     int N = p.size();
     for(int i = 0; i < N; i++ ){
       int M = (i==0)?(N-1):(N);
       for(int j = i+2; j < M; j++ ){
         ret.add( new Edge( p.get(i), p.get(j) ) );
       }
     }
     return ret;
   }
   

   void draw(){
     //println( bdry.size() );
     for( Edge e : bdry ){
       e.draw();
     }
   }
   
   
   void addPoint( Point _p ){ 
     p.add( _p );
     if( p.size() == 2 ){
       bdry.add( new Edge( p.get(0), p.get(1) ) );
       bdry.add( new Edge( p.get(1), p.get(0) ) );
     }
     if( p.size() > 2 ){
       bdry.set( bdry.size()-1, new Edge( p.get(p.size()-2), p.get(p.size()-1) ) );
       bdry.add( new Edge( p.get(p.size()-1), p.get(0) ) );
     }
   }

}
