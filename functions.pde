/* ------------------------ FLOCKWORKS: Functions -------------------- *
 * ----------------------- by Siddhartha Mukherjee ------------------- *
 * --------------------- ICTS-TIFR, Bangalore, 2020 ------------------ *
 * ---Generative artist at https://www.instagram.com/decodingkunst/ -- *
 * ------------------------------------------------------------------- */

class particle {
  
  PVector loc, vel, force;
  color col;
  int persistenceTime, viscekTime;
  float theta, fm, diameter, mass, phase, pulseRate, maxRad, al;
  
  particle( float xx, float yy ) {
    loc             = new PVector( xx,yy );
    vel             = new PVector( 0.0,0.0 );
    force           = new PVector( 0.0,0.0 );
    persistenceTime = int(random(10,20));
    viscekTime      = int(random(10,20));
    theta           = random(TWO_PI);
    fm              = random(2,5);
    diameter        = random(dia-dia*diaRange,dia+dia*diaRange);
    mass            = diameter*diameter*PI*rho;
    phase           = random(TWO_PI);
    pulseRate       = flutterFrac/diameter;
    maxRad          = width*0.5*0.75;
    if(random(1)<outProb) maxRad = width*0.5*0.9; 
    al              = random(10,250);
  }
  
  void forceCalc() {
    force.x = (-zeta*vel.x) + fm*cos(theta);
    force.y = (-zeta*vel.y) + fm*sin(theta);
    
    if(iter%persistenceTime==0){
      //-- Random reorientation
      theta = random(TWO_PI);
      fm    = random(fmag);
    }
    
    //force.x = (random(-fmag,fmag));
    //force.y = (random(-fmag,fmag));
  }
  
  void move() {
    vel.x += force.x*dt/mass;
    vel.y += force.y*dt/mass;
    
    vel.x *= friction;
    vel.y *= friction;
    
    loc.x += vel.x*dt;
    loc.y += vel.y*dt;
    
    //-- Periodicity
    loc.x = (loc.x+width)%width;
    loc.y = (loc.y+height)%height;
    
  }
 
  void show() {
    noFill();
    float velth = atan2( vel.y, vel.x );
    float th = velth > 0 ? velth : TWO_PI + velth;
    color cc = #ffffff;
    if(th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
   
    stroke(0);
    strokeWeight(0.5);
    fill(cc, 200);
    ellipse(loc.x, loc.y, diameter, diameter);
  }
  
  void showPaint() {
    noFill();
    float velth = atan2( vel.y, vel.x );
    float th = velth > 0 ? velth : TWO_PI + velth;
    color cc = #ffffff;
    if(th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
  
    noStroke();
    fill(cc, al);
    float r = random(4);
    
    if( (loc.x > 0.05*height) && ( loc.x < 0.95*height ) && (loc.y > 0.05*height) && ( loc.y < 0.95*height ) ) {
      ellipse(loc.x, loc.y, r, r);
    }
  }
  
  void showFlutter() {
    noFill();
    float velth = atan2( vel.y, vel.x );
    float th = velth > 0 ? velth : TWO_PI + velth;
    color cc = #ffffff;
    if(th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
   
    stroke(0);
    strokeWeight(1);
    fill(cc);
    float dd = diameter*sin(iter*flutterFrac + phase);
    ellipse(loc.x, loc.y, dd, dd);

  }
  
  void showLine() {
    
    float velth = atan2( vel.y, vel.x );
    float th = velth > 0 ? velth : TWO_PI + velth;
    color cc = #ffffff;
    if(th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
   
    strokeWeight(2);
    stroke(cc);
    line( loc.x+diameter*0.5*cos(velth+PI), loc.y+diameter*0.5*sin(velth+PI), loc.x+diameter*0.5*cos(velth), loc.y+diameter*0.5*sin(velth) );
    
  }
  
  void showLinePaint() {
    float velth = atan2( vel.y, vel.x );
    float th = velth > 0 ? velth : TWO_PI + velth;
    color cc = #ffffff;
    if(th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
   
    strokeWeight(2);
    stroke(cc);
    if( (loc.x > 0.05*height) && ( loc.x < 0.95*height ) && (loc.y > 0.05*height) && ( loc.y < 0.95*height ) ) {
      line( loc.x+diameter*0.5*cos(velth+PI), loc.y+diameter*0.5*sin(velth+PI), loc.x+diameter*0.5*cos(velth), loc.y+diameter*0.5*sin(velth) );
    }
  }
  
}


void alignGomezMassWeightedPeriodicityCorrected() {
  /* ------- Reference : https://arxiv.org/pdf/1801.01002.pdf ---------------
  Martín-Gómez, A., Levis, D., Díaz-Guilera, A. and Pagonabarraga, I., 2018. 
  Collective motion of active Brownian particles with polar alignment. 
  Soft matter, 14(14), pp.2610-2618. */

  for (int i=0; i<N; ++i) {
    thetaNudge[i] = 0.0;
    int count = 0;
    float massWt = 0.0;
    float tni = atan2(p[i].vel.y, p[i].vel.x);
    if (tni<0) tni += TWO_PI;
    float delx = width*0.5 - p[i].loc.x;
    float dely = width*0.5 - p[i].loc.y;
    for (int j=0; j<N; ++j) {
      if ( ( i!=j ) && (PVector.dist( new PVector(width*0.5, height*0.5), new PVector( (p[j].loc.x+delx+width)%width, (p[j].loc.y+dely+height)%height) ) < velMeanRad) ) {
        float tnj = atan2(p[j].vel.y, p[j].vel.x);
        if (tnj<0) tnj += TWO_PI;
        count++;
        thetaNudge[i] += sin(tnj-tni)*p[j].mass;
        //thetaNudge[i] += sin(tnj-tni);
        massWt += p[j].mass;
      }
    }
    //if (count>1) println(count);
    //thetaNudge[i] = atan2(vely, velx) - atan2(p[i].vel.y, p[i].vel.x);  
    if (count>0) thetaNudge[i] /= massWt;
  }

  for (int i=0; i<N; ++i) {
    p[i].vel.rotate( thetaNudge[i]*vAlignFrac + random(-1, 1)*0.05 );
  }
}

void checkCollisionSimpleCenterFix( boolean align) {

  for (int i=0; i<N; ++i) {
    for (int j=i+1; j<N; ++j) {
      float dtot = (p[i].diameter+p[j].diameter)*0.5;
      if ( PVector.dist( p[i].loc, p[j].loc ) < dtot ) {
        PVector r     = PVector.sub(p[i].loc, p[j].loc);
        float rmag    = r.mag();
        float overlap = dtot - rmag;
        
        if(i>0){
          p[i].loc.x += r.x*overlap*0.5/rmag;
          p[i].loc.y += r.y*overlap*0.5/rmag;
  
          p[j].loc.x -= r.x*overlap*0.5/rmag;
          p[j].loc.y -= r.y*overlap*0.5/rmag;
        } else {
          p[j].loc.x -= r.x*overlap/rmag;
          p[j].loc.y -= r.y*overlap/rmag;
        }

        if (align) {
          //-- Not very good since align velocities not theta
          //float thetaMean = ( p[i].theta + p[j].theta ) * 0.5;
          //float sign = p[i].theta < p[j].theta ? 1.0 : -1.0;

          //p[i].theta += sign*thetaMean*0.01;
          //p[j].theta -= sign*thetaMean*0.01;

          float vAngle1     = atan2( p[i].vel.y, p[i].vel.x );
          float vAngle2     = atan2( p[j].vel.y, p[j].vel.x );
          float sign        = vAngle1 < vAngle2 ? 1.0 : -1.0;
          float vAngleMean  = 0.5 * ( vAngle1 + vAngle2 );

          p[i].vel.rotate( sign*vAngleMean*vAlignFrac );
          p[j].vel.rotate( -sign*vAngleMean*vAlignFrac );

          //float mag = p[i].vel.mag();
          //p[i].vel.x = mag*cos(vAngle1 + sign*vAngleMean*vAlignFrac);
          //p[i].vel.y = mag*sin(vAngle1 + sign*vAngleMean*vAlignFrac);

          //mag = p[j].vel.mag();
          //p[j].vel.x = mag*cos(vAngle2 - sign*vAngleMean*vAlignFrac);
          //p[j].vel.y = mag*sin(vAngle2 - sign*vAngleMean*vAlignFrac);
        }
      }
    }
  }
}
