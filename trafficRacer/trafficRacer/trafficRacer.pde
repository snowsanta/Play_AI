int speedObs = 1, leftLim, rightLim, nextConnectionNo = 1000;
int framesBwObs = 220, counFrm = 0;
Car car;
Population popul;
Utils utils = new Utils();
ArrayList<Obstacle> obsList = new ArrayList<Obstacle>();
boolean debug = false;
int gameWidth, car_height, car_width;
String playing = "AI";
PImage roadBack;
PImage roadSide;
PImage carSprite;
PImage obstacleSprite;
int frameHeight = 0;
int gen = 0;

void setup(){
    size(440,900);
    gameWidth = int(width);
    car_height = int(height*.1);
    car_width = int(gameWidth*.11);
    leftLim = int(gameWidth * .25);
    rightLim = int(gameWidth * .75);
    frameRate(60);
    car = new Car();
    popul = new Population(100);
    roadBack = loadImage("./textures/roadBack.png");
    roadSide = loadImage("./textures/roadSide.png");
    carSprite = loadImage("./textures/carSprite.png");
    obstacleSprite = loadImage("./textures/obstacleSprite.png");
    carSprite.resize(car_width, car_height);
    textSize(32);
}

void draw(){
  background(#666666);
  image(roadBack, 0, 0);
  image(roadSide, 0, frameHeight);
  image(roadSide, 0, frameHeight - height);
  counFrm++;
  update_obs();
  if(debug){
    line(utils.getx(0), 0, utils.getx(0), height);
    line(utils.getx(1), 0, utils.getx(1), height);
    line(utils.getx(2), 0, utils.getx(2), height);
    line(gameWidth, 0, gameWidth, height);
  }

  if(playing == "HUMAN"){
    text(car.score, gameWidth + (gameWidth/ 3), height * .3);
    car.show();
    if(car.collided()){
      textSize(32);
      text("GAME OVER", gameWidth / 3, height * .3);
      noLoop();
    }
  }
  else{
    if (!popul.done()) {//if any players are alive then update them
      popul.updateAlive();
    } else {//all dead
      //genetic algorithm 
      gen++;
      popul.naturalSelection();
      obsList.clear();
    }
  }
  
  text("Generation: " + String.valueOf(gen), 70, 50);
  text("Alive: " + String.valueOf(popul.aliveCount), 70, 90);
  text("Hi Score: " + String.valueOf(popul.bestScore), 70, 130);

  popul.scoreup(1);
  frameHeight++;
  if(frameHeight == height){
    frameHeight = 0;
  }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == LEFT && playing == "HUMAN") {
      car.steer(0);
    } else if (keyCode == RIGHT && playing == "HUMAN") {
      car.steer(1);
    } else if (keyCode == UP){
      debug = !debug;
    }
  }
}

void update_obs(){
    for(int i = 0; i < obsList.size(); i++){
        obsList.get(i).show();
    }
    if(counFrm >= framesBwObs){
        obsList.add(new Obstacle());
        counFrm = 0;
    }
    if(obsList.size() != 0){
        if(obsList.get(0).y > height){
            obsList.remove(obsList.get(0));
            if(playing == "HUMAN"){
              car.score += 10;
            }
            else{
              popul.scoreup(100);
            }
        }
    }
}
