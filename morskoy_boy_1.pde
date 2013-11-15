
// *************** MAIN ******************
/* @pjs
crisp=true;
font=PressStart2P.ttf;
*/
int x = 0;
int y = 100;
int speed = 1;
boolean instructionMode = true;
boolean hasPlayed = false;
PFont f;
int level = 120;
PImage bg;
Audio audio = new Audio();

Target target;
Ship ship;
int MAX_TORPEDOES = 10;
Torpedo [] torpedoes = new Torpedo[MAX_TORPEDOES];
int currentTorpedo = 0;
int numShipsSunk = 0;


void setup() {
  size(1000,500);
  background(255, 0, 0);
  smooth();
  target = new Target();
  ship = new Ship();
  f = createFont("PressStart2P.ttf", 48);
//  f = loadFont("PressStart2P.ttf");
  textFont(f, 18);
}

String getSoundSource()
{
  int soundIndex = int (random(12));
  return "boom" + soundIndex + ".wav";
  
}

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
              audio.setAttribute("src", getSoundSource());
              audio.play();
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
  int topX = 460;
  int topY = 30;
  rectMode(CENTER);
  stroke(0, 0, 0, 70);
  strokeWeight(2);
  rect(topX, topY, 320, 40, 3);
 
  fill(40, 40, 40);
  textSize(14);
  text("Torpedoes: " + (10-currentTorpedo) + " Hits: " + numShipsSunk, 610, 40); 
}

void displayInstructions(){
  rectMode(CORNERS);
  fill(0, 0, 0, 50);
  rect(0, 0, width, height);
  fill(0, 0, 0, 100);
  stroke(0, 0, 0, 70);
  strokeWeight(4);
  rect(100, 100, width-100, height-100, 10);
  
  
  fill(255, 255, 255);
  textAlign(CENTER, TOP);
  int y = 140;
  textSize(32);
  if(!hasPlayed)
  {
    text("Welcome to Sea Battle", 500, y);
  }else
  {
    y = y-15;
    text("Game Over!", 500, y);
    textSize(25);
    y += 60;
    textSize(18);
    text("FINAL SCOREE: " + numShipsSunk + " ships destroyed!", 500, y);
  }
  y += 70;  
  textSize(19);
  text("press Space Bar to play", 500, y);
  y += 50;
  text("press <- and -> to move the target window", 500, y);
  y+= 50;
  text("press Up to shoot a torpedo", 500, y);
  fill(0, 255, 255);
  textAlign(RIGHT, BOTTOM);
  
  strokeWeight(1);
}


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
    float speedConst = 15.0;
    float amt = (distance1 - distance2)/(float)(height*speedConst)+0.001;
    if(distance1 > 0.1)
    {
        centerX = lerp(centerX, destinationX, amt);
        centerY = lerp(centerY, destinationY, amt); 
    }else
    {
      centerX += 1;
      centerY += 1;
    }
  
  }
  
  void drawTorpedo()
  {
    if(centerY < height/3 + 1 )
    {
      amShooting = false;
    }
    
    if(amShooting)
    {
        stroke(50);
        fill(66);
        ellipse(centerX,centerY,20.0, 20.0);
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
  }
}

// ********************* Torpedo ********************
// *************** Target *******************
class Target
{
  //position
  int centerX = width/2 - 20;
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
      ellipse(centerX, centerY, 70,70);
      strokeWeight(1);
//      line(centerX-5, centerY, centerX+5, centerY);
      line(centerX, centerY+10, centerX, centerY+20);
      line(centerX, centerY-10, centerX, centerY-20);
      line(centerX+10, centerY, centerX+20, centerY);
      line(centerX-10, centerY, centerX-20, centerY);
      
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
 int shipLength = 180;
 int shipHeight = 80;
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
      centerY = int(random(50, height-100));
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
   imageMode(CORNERS);
   if(blownUp)
   {
      pushMatrix();
      fill(255,0,0); 

      //rotateX(PI/300);
      image(shipImage, centerX-(shipLength/2),centerY+shipHeight/2,centerX+shipLength/2,centerY-shipHeight/2);

      //popMatrix();
   }else
   {
      fill(100);
      image(shipImage, centerX-(shipLength/2),centerY+shipHeight/2,centerX+shipLength/2,centerY-shipHeight/2);

   }
 
   
   
   println("drawn image");
   move();
 } 
}

// ************** Ship *******************










