/* @pjs preload="data/chemin_droit.png"; */
/* @pjs preload="data/chemin_virage.png"; */

PImage test;
PGraphics back;
PImage back_img;

Chemin chemin;
Player player;

int parcours[][];


PImage chemin_droit;
PImage chemin_virage;

int ratio;



void setup(){
  size(550, 700);
    
  //on calcul le ratio à adopter en fonction de la taille de l'écran
  ratio = width / 350;
  
  //on calcul le nombre de case du terrain
  int xTaille = int((width/ratio) / 90) - 1;
  int yTaille = int((height/ratio) / 90) - 1;
  
  println(xTaille + " "  + yTaille);
  
  parcours = new int[yTaille][xTaille];
  
  for(int i = 0; i < parcours.length; i++){
    for(int j = 0; j < parcours[0].length; j++){  
      parcours[i][j] = -1;
    }
  }
  
  frameRate(60);
  
  rectMode(CENTER);
  imageMode(CENTER);

  
  chemin_droit = loadImage("chemin_droit.png");
  chemin_droit.resize(100, 100);
  
  chemin_virage = loadImage("chemin_virage.png");
  chemin_virage.resize(100, 100);
  
  back = createGraphics(width/ratio, height/ratio);
  
  back.beginDraw();
  back.imageMode(CENTER);
  back.tint(255, 240, 20);
  back.background(0);
  back.endDraw();
  
  
  chemin = new Chemin(int(width/(ratio*2) / 100) * 100, int(height/(ratio*2) / 100) * 100);
  player = new Player(int(width/(ratio*2) / 100) * 100, int(height/(ratio*2) / 100) * 100);
  
  
  thread("moveThread");
}


void draw(){
  background(0);  
  
  

  back_img = back.get();
  back_img.mask(chemin.generateMask());
  
  image(back_img, width/2, height/2, width, height);
  
  
  //println(chemin.position);  
  //println(frameRate);

  player.move();
  
  
}

void moveThread(){
  while(true){
    chemin.move(parcours);  
    player.show();
    
    if(!chemin.testCollision(player.getPosition()))
      delay(1000);
    
    delay(1000/60); // 60FPS

  }
  
}
