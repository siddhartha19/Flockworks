/* ------------------------------------------------------------------- *
                                FLOCKWORKS
 * --------------Interactive active matter flocks paintings ---------- *
 * --------------------- by Siddhartha Mukherjee --------------------- *
 * ------------------- ICTS-TIFR, Bangalore, 2020 -------------------- *
 * -- Generative artist at https://www.instagram.com/decodingkunst/ -- *
 * ------------------------------------------------------------------- */

/* This code solves a system of "self-propelling" active disks, of varying 
sizes and velocities, with alignment interactions and some noise. A few 
different rendering techniques are available for different visualizations.

The colours show the direction of motion of each particle, with a legend
given on the top right diagnostics panel. 

                  How to interact with the code:
1. Moving the mouse cursor changes the "alignment interaction neighbourhood" 
of each particle, visualized as a white circle around one of the particles.
2. Making this circle smaller leads to a disordered state
3. Making it larger leads to flocking
4. Mouse click freezes the motion of the particles, while keeping on their 
reorientation, this can be used to demonstrate the effect of orientation alone
5. In the draw function, the rendering can be changed
6. Right click will save a frame

Caution: Some functions and variables may be vestigial */

//-- Parameters
float dt              = 0.1;    //-- Integration timestep
float zeta            = 0.05;   //-- Noise term
float fmag            = 15.0;
float rho             = 0.0005;
float dia             = 18;
float diaRange        = 0.4; //-- Variations in diameter
float velMeanRad      = 100.0; //-- How many particle diameters to probe for velocity alignment
float velMeanRadBase  = 100.0;
float opac            = 50.0;
float krep            = 1.0;
float friction        = 0.995;
int N                 = 1000; //-- Number of particles - be mindful of your computer specs!
int Nroot             = int(sqrt(N)); //-- Will make a square grid of particles
float flutterFrac     = 0.04;
float outProb         = 0.075;
float avoidFac        = 1.2;
int iter              = 0;
float vAlignFrac      = 0.2;
float velrange        = 10.0;

float [] thetaNudge;
particle [] p;

//-- Colours, toggle, save
color from            = color(204, 102, 0);
color to              = color(0, 102, 153);
color [] cols         = {#E63946, #F0A202, #457B9D, #F1FAEE};
color bgcol           = #000000; //#F1FAEE;
boolean toggleMove    = true;
int saveIter          = 0;
int saveEvery         = 2;
int saveIndx          = 0;

void setup() {
  size(800, 800);
  background(bgcol);

  N = Nroot*Nroot;
  p = new particle[N];
  thetaNudge = new float[N];

  println("Number of Particles: ", N);

  float step = width/Nroot;
  int cc = 0;
  float vtot = 0.0;
  for (int i=0; i<Nroot; ++i) {
    for (int j=0; j<Nroot; ++j) {
      p[cc] = new particle( step*0.5 + i*step, step*0.5 + j*step);
      thetaNudge[cc] = 0.0;
      cc++;
      vtot += p[i].diameter*p[i].diameter*PI/4.0;
    }
  }

  println("Volume Fraction: ", 100.0*vtot/height/width, "%" );

}

void mousePressed() {
  if (mouseButton==LEFT) {
    toggleMove = !toggleMove;
    dots();
  }
  else {
    // saveFrame("flocking.png");
    saveIndx++;
  }
}

void draw() {

  velMeanRad = velMeanRadBase*mouseX/width;  
  noStroke();
  fill(bgcol, 45);
  rect(0, 0, width, height);

  for (int i=0; i<N; ++i) {
    p[i].forceCalc();
  }

  if (toggleMove) {
    for (int i=0; i<N; ++i) {
      p[i].move();
    }
  }

  checkCollisionSimpleCenterFix(false);  
  checkCollisionSimpleCenterFix(false);
  checkCollisionSimpleCenterFix(false);

  alignGomezMassWeightedPeriodicityCorrected();

  for (int i=0; i<N; ++i) {
    // p[i].show();           //-- Simple rendering with spheres
    // p[i].showPaint();      //-- Another nice rendering I used for some paintings
    // p[i].showFlutter();    //-- Shows the active agents as fluttering spheres
    p[i].showLine();       //-- Shows only the diametric line along polar angle   
    // p[i].showLinePaint();
  }
  
  noFill();
  stroke(255);
  strokeWeight(1.5);
  ellipse(p[0].loc.x, p[0].loc.y, 2*velMeanRad,2*velMeanRad);
  diagnostics();

  if ( (iter%saveEvery==0) && (saveIter<24*30) ) {
    //-- Saves frames for a movie
    // saveFrame("Images/flock" + nf(saveIter,3) + ".jpg");
    saveIter++;
  }

  iter++;
}

void dots() {
  for (int i=1; i<N; ++i) {
    float velth = atan2( p[i].vel.y, p[i].vel.x );
    float th = velth > 0 ? velth : TWO_PI + velth;
    color cc = #ffffff;
    if(th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
    stroke(cc);
    noFill();
    strokeWeight(1.5);    
    float r = random(4,8);
    if( (p[i].loc.x > 0.05*height) && ( p[i].loc.x < 0.95*height ) && (p[i].loc.y > 0.05*height) && ( p[i].loc.y < 0.95*height ) ) {
      ellipse(p[i].loc.x, p[i].loc.y, r, r);  
    }
  }
  
}

void checkCollision() {

  for (int i=0; i<N; ++i) {
    for (int j=i+1; j<N; ++j) {
      if ( PVector.dist( p[i].loc, p[j].loc ) < dia*avoidFac) {
        PVector r = PVector.sub(p[i].loc, p[j].loc);
        float rmag = r.mag();

        p[i].force.x = krep*r.x/rmag;
        p[i].force.y = krep*r.y/rmag;

        p[j].force.x = -krep*r.x/rmag;
        p[j].force.y = -krep*r.y/rmag;
      }
    }
  }
}

void checkCollisionSimple( boolean align) {

  for (int i=0; i<N; ++i) {
    for (int j=i+1; j<N; ++j) {
      float dtot = (p[i].diameter+p[j].diameter)*0.5;
      if ( PVector.dist( p[i].loc, p[j].loc ) < dtot ) {
        PVector r = PVector.sub(p[i].loc, p[j].loc);
        float rmag = r.mag();
        float overlap = dtot - rmag;

        p[i].loc.x += r.x*overlap*0.5/rmag;
        p[i].loc.y += r.y*overlap*0.5/rmag;

        p[j].loc.x -= r.x*overlap*0.5/rmag;
        p[j].loc.y -= r.y*overlap*0.5/rmag;

        if (align) {
          //-- Not very good since align velocities not theta
          float vAngle1 = atan2( p[i].vel.y, p[i].vel.x );
          float vAngle2 = atan2( p[j].vel.y, p[j].vel.x );
          float sign = vAngle1 < vAngle2 ? 1.0 : -1.0;
          float vAngleMean = 0.5 * ( vAngle1 + vAngle2 );

          p[i].vel.rotate( sign*vAngleMean*vAlignFrac );
          p[j].vel.rotate( -sign*vAngleMean*vAlignFrac );

        }
      }
    }
  }
}


void alignGomezMassWeighted() {

  for (int i=0; i<N; ++i) {
    thetaNudge[i] = 0.0;
    int count = 0;
    float massWt = 0.0;
    float tni = atan2(p[i].vel.y, p[i].vel.x);
    if (tni<0) tni += TWO_PI;

    for (int j=0; j<N; ++j) {
      if ( ( i!=j ) && (PVector.dist( p[i].loc, p[j].loc ) < velMeanRad) ) {
        float tnj = atan2(p[j].vel.y, p[j].vel.x);
        if (tnj<0) tnj += TWO_PI;
        count++;
        thetaNudge[i] += sin(tnj-tni)*p[j].mass;
        massWt += p[j].mass;
      }
    }
    if (count>0) thetaNudge[i] /= massWt;
  }

  for (int i=0; i<N; ++i) {
    p[i].vel.rotate( thetaNudge[i]*vAlignFrac + random(-1, 1)*0.05 );
  }
}

void alignGomez() {

  for (int i=0; i<N; ++i) {
    thetaNudge[i] = 0.0;
    int count = 0;
    float tni = atan2(p[i].vel.y, p[i].vel.x);
    if (tni<0) tni += TWO_PI;

    for (int j=0; j<N; ++j) {
      if ( ( i!=j ) && (PVector.dist( p[i].loc, p[j].loc ) < velMeanRad) ) {
        float tnj = atan2(p[j].vel.y, p[j].vel.x);
        if (tnj<0) tnj += TWO_PI;
        count++;
        thetaNudge[i] += sin(tnj-tni);
      }
    }
  }

  for (int i=0; i<N; ++i) {
    p[i].vel.rotate( thetaNudge[i]*vAlignFrac + random(-1, 1)*0.05 );
  }
}

void diagnostics() {
  /* Calculates and plots some diagnostics like a radial PDF of the velocities, degree of flocking,
  and the dominant directino of motion is marked out along the 360 degrees colour distribution.

  This took long to plan and write (and debug)! */

  noStroke();
  fill(0, 200);
  float xl      = width-125.0;
  float yt      = 25.0;
  float wd      = 100.0;
  float ht      = 100.0;

  rect(xl, yt, wd, ht);
  stroke(255);
  strokeWeight(1);
  line( xl, yt+ht*0.5, xl+wd, yt+ht*0.5 );
  line( xl+wd*0.5, yt, xl+wd*0.5, yt+ht );

  float meanx   = 0.0;
  float meany   = 0.0;
  float meanth  = 0.0;
  float vmagSum = 0.0;
  float massTot = 0.0;

  for (int i=0; i<N; ++i) {
    meanx += p[i].vel.x*p[i].mass;
    meany += p[i].vel.y*p[i].mass;
    meanth += p[i].theta;
    vmagSum += p[i].vel.mag()*p[i].mass; //-- Total momentum, divide by mass later
    massTot += p[i].mass; //-- Total mass
  } 

  fill(0);
  rect( xl, yt+ht+10, wd, 42);
  fill(255);
  float flockMag = new PVector(meanx, meany).mag()/vmagSum;
  rect( xl, yt+ht+10, map(flockMag, 0.0, 1.0, 0.0, wd), 10);
  stroke(255);
  strokeWeight(3);
  textSize(20);
  text( "Flocking", xl+wd*0.1, yt+ht+40 );

  float [] thetaBin = new float[10];
  float ang = 0.0; 
  for (int i=0; i<N; ++i) {
    ang = atan2( p[i].vel.y, p[i].vel.x );
    if ( ang < 0 ) ang += TWO_PI;
    for (int n=0; n<10; ++n) {
      if ( ( ang > n*0.628 ) && ( ang <= (n+1)*0.628 )  ) {
        thetaBin[n]++;
        break;
      }
    }
  }

  float th = 0.0;
  color cc = #ffffff;
  float r_ = 10.0;
  for (int i=0; i<10; ++i) {
    th = 0.628*(i+0.5);  
    if (th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));

    noStroke();
    fill(cc, 200 + 600*(thetaBin[i]/N));
    beginShape();
    vertex(xl+wd*0.5, yt+ht*0.5);
    vertex(xl+wd*0.5 + r_*cos(0.628*i), yt+ht*0.5+ r_*sin(0.628*i));
    //vertex(xl+wd*0.5 + r_*3.0*cos(0.628*(i+0.5)), yt+ht*0.5+ r_*3.0*sin(0.628*(i+0.5)));    
    vertex(xl+wd*0.5 + r_*(1.0 + 12.0*(thetaBin[i]/N))*cos(0.628*(i+0.5)), yt+ht*0.5+ r_*(1.0 + 12.0*(thetaBin[i]/N))*sin(0.628*(i+0.5)));
    vertex(xl+wd*0.5 + r_*cos(0.628*(i+1)), yt+ht*0.5+ r_*sin(0.628*(i+1)));
    endShape();
  }  

  meanx /= N; meany /= N;

  strokeWeight(12);
  th = 0.0;
  cc = #ffffff;
  float rr = 40.0;
  while (th<TWO_PI) {
    if (th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
    else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
    else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
    else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
    stroke(cc);
    point(xl + wd/2.0 + rr*cos(th), yt + ht*0.5 + rr*sin(th));
    th += 0.2;
  }

  th = atan2(meany, meanx);
  th = th > 0 ? th : TWO_PI + th;
  if (th<PI*0.5) cc = lerpColor(cols[0], cols[1], th/(PI*0.5));
  else if (th<PI) cc = lerpColor(cols[1], cols[2], (th-PI*0.5)/(PI*0.5));
  else if (th<1.5*PI) cc = lerpColor(cols[2], cols[3], (th-PI)/(PI*0.5));
  else cc = lerpColor(cols[3], cols[0], (th-1.5*PI)/(PI*0.5));
  strokeWeight(2);
  stroke(0, map(flockMag, 0.0, 0.4, 20.0, 255));
  noFill();
  ellipse( xl + wd/2.0 + rr*cos(th), yt + ht*0.5 + rr*sin(th), 10, 10 );

  //-- Old stretching hand
  //strokeWeight(4);
  //stroke(cc);
  //line( xl + wd*0.5, yt + ht*0.5, map(meanx, -velrange, velrange, xl, xl+wd), map(meany, -velrange, velrange, yt, yt+ht) );
  //strokeWeight(2);
  //stroke(0);
  //noFill();
  //ellipse( map(meanx, -velrange, velrange, xl, xl+wd), map(meany, -velrange, velrange, yt, yt+ht), 10, 10 );
}

void connect( float dd ) {
  for (int i=1; i<N; ++i) {
    for (int j=i+1; j<N; ++j) {
      if( pow(p[i].loc.x - p[j].loc.x, 2.0) + pow(p[i].loc.y - p[j].loc.y, 2.0) < dd*dd ) {
        stroke(255, 175);
        strokeWeight(1);
        line(p[i].loc.x, p[i].loc.y, p[j].loc.x, p[j].loc.y);
      }
    }
  }
}
