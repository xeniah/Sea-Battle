// ******************* Torpedo *****************
class Torpedo
{
  float centerX = int(width/2);
  float centerY = height;
  float destinationX;
  float destinationY;
  boolean amShooting = false;
  
  Torpedo(int destX, int destY)
  {
    destinationX = destX;
    destinationY = destY;
  }
  
  void move()
  {
    float distance1 = dist(width/2, height, destinationX, destinationY);
    float distance2 = dist(centerX, centerY, destinationX, destinationY);
    //println("Distance: " + (distance1 - distance2)/10.0);
    float speedConst = 30.0;
    float amt = (distance1 - distance2)/(float)(height*speedConst)+0.001;
    centerX = lerp(centerX, destinationX, amt) ;
    centerY = lerp(centerY, destinationY, amt); 
  }
  
  void drawTorpedo()
  {
    if(centerY < height/3 + 1 )
    {
      amShooting = false;
    }
    
    if(amShooting)
    {
   //    println("TORPEDO DRAWN");
        stroke(50);
        fill(66);
        ellipse(centerX,centerY,10.0,10.0);
        move();
    }
  }
  
  void hit()
  {
     amShooting = false;
  }
  
  void shoot()
  {
    amShooting = true;
    centerX = width/2;
    centerY = height;
    //println("centerX: " + centerX + " centerY: " + centerY);
  }
}

// ********************* Torpedo ********************
// *************** Target *******************
class Target
{
  //position
  int centerX = 100;
  int centerY = int(height/3); 
  int speed = 2;
  
  String dirState = "right";

  void moveRight()
  {
    dirState = "right";
    centerX += speed;
  }

  void moveLeft()
  {
    dirState = "left";
    centerX -= speed;
  }
  
  void drawTarget()
  {
      ellipseMode(CENTER);
      stroke(0);
      strokeWeight(2);
      noFill();
      ellipse(centerX, centerY, 40,40);
      strokeWeight(1);
//      line(centerX-5, centerY, centerX+5, centerY);
      line(centerX, centerY+8, centerX, centerY+15);
      line(centerX, centerY-8, centerX, centerY-15);
      line(centerX+8, centerY, centerX+15, centerY);
      line(centerX-8, centerY, centerX-15, centerY);
      
//      line(centerX, centerY-5, centerX, centerY+5);
  }
 
  void checkState()
  {
    if (dirState == "right"){
      moveRight();
    } 
    else if (dirState == "left"){
      moveLeft();
    } 
  }

}

// *************** Target *******************
// ************** Ship *******************

class Ship
{
  
 int centerX = 0;
 int centerY = int(height/3);
 int shipLength = 100;
 int shipHeight = 50;
 int speed = int(random(4)+1);
 boolean blownUp = false;
  
 PImage shipImage; 

 Ship()
 {
     shipImage = getShipImage();
 } 
 void move()
 {
   if(blownUp){
     speed = 3;
     centerX = centerX + speed;
     centerY = centerY + speed;
   }
   centerX = centerX + speed;
   println("about to check width");
   if ((centerX > width)) {
      centerX = -30;
      centerY = int(height/3);
      blownUp = false;
      speed = 1;
      shipImage = getShipImage();
      speed = int(random(2)+1);
    }
 }
 
 PImage getShipImage()
 {
   int imageIndex = int(random(10));
   return loadImage("ship"+imageIndex+".png");
 }

 void blowUp()
 {
   //fill(255,0,0);
   blownUp = true;
 }

 void drawShip()
 {
   stroke(100);
   if(blownUp)
   {
      fill(255,0,0); 
   }else
   {
      fill(100);
   }
 
   imageMode(CORNERS);
   image(shipImage, centerX-(shipLength/2),centerY+shipHeight/2,centerX+shipLength/2,centerY-shipHeight/2);
   println("drawn image");
   move();
 } 
}

// ************** Ship *******************


// *************** MAIN ******************
//import ddf.minim.* ;
//Minim minim;

//AudioPlayer au_player1;

int x = 0;
int y = 100;
int speed = 1;
boolean instructionMode = true;
boolean hasPlayed = false;
PFont f;
int level = 120;
PImage bg;

Target target;
Ship ship;
int MAX_TORPEDOES = 10;
Torpedo [] torpedoes = new Torpedo[MAX_TORPEDOES];
int currentTorpedo = 0;
int numShipsSunk = 0;


void setup() {
  size(600,300);
  background(255, 0, 0);
  smooth();
  target = new Target();
  ship = new Ship();
  //minim = new Minim(this);
  f = loadFont("PressStart2P-48.vlw");
  textFont(f, 18);
}

//AudioPlayer getSound()
//{
//  int soundIndex = int (random(12));
//  return minim.loadFile("boom" + soundIndex + ".wav") ;
//  
//}

void draw() {
     background(255);
     checkKeys();
     ship.drawShip(); 
      
     target.drawTarget();
     drawTorpedoes();
  //   drawLerp();
      println("drawn torpedoes");
     if(instructionMode)
     {
       displayInstructions();
     }else
     {
       if(currentTorpedo > MAX_TORPEDOES-1)
       {
          instructionMode = true;
       }else
       {
         drawScore();
       } 
     }
}

void drawLerp()
{
    int x1 = (int)width/2;
    int y1 = height;
    int x2 = target.centerX;
    int y2 = target.centerY;
   
    stroke(0, 0, 255);
    for (int i = 0; i <= 10; i++) {
        float x = lerp(x1, x2, i/10.0);
        float y = lerp(y1, y2, i/10.0);
        point(x, y);
    }
}

void drawTorpedoes()
{
      for(int i = 0; i < 10; i++)
      {
          if(torpedoes[i] != null)
          {
            torpedoes[i].drawTorpedo();
            Torpedo t = torpedoes[i];
  
            if(t != null && t.amShooting && isCollidingCircleRectangle(t.centerX, t.centerY, 10, ship.centerX-ship.shipLength/4, ship.centerY-ship.shipHeight/2, ship.shipLength/2, ship.shipHeight))
            {
       //   println("************************** COLLIDED *********************************");
              ship.blowUp();
              t.hit();
              numShipsSunk++;
//              au_player1 = getSound();
//              au_player1.play();
          //    blowUpSound.stop();
          //    blowUpSound.play();
            }  
        }
      }
}

void keyReleased() {
   println("key released");
   if (keyCode == UP){
     if(currentTorpedo < 10 && !instructionMode)
       {
          torpedoes[currentTorpedo] = new Torpedo(target.centerX, target.centerY);
          torpedoes[currentTorpedo].shoot();
          currentTorpedo++;
       }
    }   
}

void checkKeys(){
  
  if (keyPressed) {
    println("key pressed");
    if (keyCode == RIGHT) {
      target.moveRight();
    }   

    if (keyCode == LEFT) {
      target.moveLeft();
    } 
  } 
}

boolean isCollidingCircleRectangle(
      float circleX, 
      float circleY, 
      float radius,
      float rectangleX,
      float rectangleY,
      float rectangleWidth,
      float rectangleHeight)
{
    float circleDistanceX = abs(circleX - rectangleX - int(rectangleWidth/2));
    float circleDistanceY = abs(circleY - rectangleY - int(rectangleHeight/2));

    if (circleDistanceX > (rectangleWidth/2 + radius)) { return false; }
    if (circleDistanceY > (rectangleHeight/2 + radius)) { return false; }

    if (circleDistanceX <= (rectangleWidth/2)) { return true; } 
    if (circleDistanceY <= (rectangleHeight/2)) { return true; }

    float cornerDistance_sq = pow(circleDistanceX - rectangleWidth/2, 2) +
                         pow(circleDistanceY - rectangleHeight/2, 2);

    return (cornerDistance_sq <= pow(radius,2));
}

void keyPressed(){
  switch(key){
  case 27: // escape
    exit();
    break;
  case ' ':
    instructionMode = !instructionMode;
    hasPlayed = true;
    currentTorpedo = 0;
    numShipsSunk = 0;
    torpedoes = new Torpedo[10];
    break;
  default:
    break;
  } 
}

void drawScore()
{
  fill(0, 0, 0, 30);
  int topX = 490;
  int topY = 14;
  rectMode(CENTER);
  stroke(0, 0, 0, 70);
  strokeWeight(2);
  rect(topX, topY, 210, 20, 3);
 
  fill(40, 40, 40);
  textSize(9);
  text("torpedoes: " + (10-currentTorpedo) + " hits: " + numShipsSunk, 590, 20); 
}

void displayInstructions(){
  rectMode(CORNERS);
  fill(0, 0, 0, 30);
  rect(0, 0, width, height);
  fill(0, 0, 0, 100);
  stroke(0, 0, 0, 70);
  strokeWeight(4);
  rect(10, 20, width-10, height-40, 10);
  
  
  fill(255, 255, 255);
  textAlign(CENTER, TOP);
  int y = 40;
  textSize(21);
  if(!hasPlayed)
  {
    text("Welcome to Sea Battle", 320, y);
  }else
  {
    text("Game Over!", 320, y);
    textSize(14);
    y += 40;
    text("Final Score: " + numShipsSunk + " enemy vessels destroyed!", 320, y);
  }
  y += 50;  
  textSize(11);
  text("press Space Bar to play", 320, y);
  y += 20;
  text("press <- and -> to move the target window", 320, y);
  y+= 20;
  text("press Up to shoot a torpedo", 320, y);
  fill(0, 255, 255);
  textAlign(RIGHT, BOTTOM);
  
  strokeWeight(1);
}








