package com.devistorm.feard;

import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Feard extends PApplet {


PImage test;
PGraphics back;
PImage back_img;

Chemin chemin;
Player player;

int parcours[][];


PImage chemin_droit;
PImage chemin_virage;

int ratio;



public void setup(){
  
    
  //on calcul le ratio à adopter en fonction de la taille de l'écran
  ratio = width / 350;
    
  parcours = new int[5][3];
  
  for(int i = 0; i < parcours.length; i++){
    for(int j = 0; j < parcours[0].length; j++){  
      parcours[i][j] = 0;
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
  
  
  chemin = new Chemin(PApplet.parseInt(width/(ratio*2) / 100) * 100, PApplet.parseInt(height/(ratio*2) / 100) * 100);
  player = new Player(PApplet.parseInt(width/(ratio*2) / 100) * 100, PApplet.parseInt(height/(ratio*2) / 100) * 100);
  
  
  thread("moveThread");
}


public void draw(){
  background(0);  
  
  

  back_img = back.get();
  back_img.mask(chemin.generateMask());
  
  image(back_img, width/2, height/2, width, height);
  
  
  //println(chemin.position);  
  //println(frameRate);

  player.move();
}

public void moveThread(){
  while(true){
    chemin.move(parcours);  
    player.show();
    
    if(!chemin.testCollision(player.getPosition()))
      delay(1000);
    
    delay(1000/60); // 60FPS

  }
  
}

class Chemin{
  
  private PVector position;
  private PVector direction = new PVector(1, -1);
  
  private int direction_code = 0;
  
  private PVector coordones[] = new PVector[50];
  
  private PGraphics ombre;
  private PGraphics chemin_mask;
  
  public final float vitesse = 5;
  
  private final int largeur = 100;
  
  public Chemin(float x, float y){
    this.position = new PVector(x, y);
    
    for(int i = 0; i < this.coordones.length; i++){
      this.coordones[this.coordones.length - i - 1] = new PVector(this.position.x, this.position.y + i * 5);  
    }
    
    this.chemin_mask = createGraphics(width/ratio, height/ratio);
    
    //Création du modèle d'ombre (dégradé)
    this.ombre = createGraphics(this.largeur, this.largeur);
    this.ombre.beginDraw();
    this.ombre.background(0, 0, 0, 0);
    this.ombre.noStroke();
    for(int i = 0; i < 10; i++){
      this.ombre.fill(255, 255, 255, 5);
      this.ombre.ellipse(this.largeur/2, this.largeur/2, this.largeur - i * 7, this.largeur - i * 7);
    }
    this.ombre.endDraw();
    
  }
  
  public PGraphics generateMask(){
    this.chemin_mask.beginDraw();
    this.chemin_mask.background(0);
    this.chemin_mask.noStroke();
    this.chemin_mask.imageMode(CENTER);
    for(int i = 0; i < this.coordones.length; i++){        
      this.chemin_mask.image(this.ombre, this.coordones[i].x, this.coordones[i].y); 
    }
    
    this.chemin_mask.endDraw();  
    
    return this.chemin_mask; 
  }
  
  public void move(int parcours[][]){ 
    
    if(this.isOnCentre()){
      println(getCasePosition());
      //on change la direction
      int new_direction_code = parcours[PApplet.parseInt(this.getCasePosition().y)][PApplet.parseInt(this.getCasePosition().x)];
      
      if(new_direction_code == 0)
        this.direction = new PVector(0, -1);  
      if(new_direction_code == 1)
        this.direction = new PVector(1, 0); 
      if(new_direction_code == 2)
        this.direction = new PVector(0, 1);
      if(new_direction_code == 3)
        this.direction = new PVector(-1, 0); 
        
      //on définis la suite du parcours
      PVector next_case = this.getCasePosition().add(this.direction.normalize());
    
      //println(this.getCasePosition());
      PVector new_direction = new PVector(0, 0);
      
      do{
        if(random(0, 100) > 30){
          new_direction_code = this.direction_code + ((random(0, 100) > 50) ? -1 : 1);
          
          if(new_direction_code > 3)
            new_direction_code = 0;
          if(new_direction_code < 0)
            new_direction_code = 3;
          
        }
        else 
          new_direction_code = this.direction_code;
        
        if(new_direction_code == 0)
          new_direction = new PVector(0, -1);
        if(new_direction_code == 1)
          new_direction = new PVector(1, 0);
        if(new_direction_code == 2)
          new_direction = new PVector(0, 1);
        if(new_direction_code == 3)
          new_direction = new PVector(-1, 0);
        
      }while(next_case.x + new_direction.x < 0 || next_case.x + new_direction.x > parcours[0].length - 1
      || next_case.y + new_direction.y < 0 || next_case.y + new_direction.y > parcours.length - 1);
      
      //on ajoute la case correspondante au virage
      back.beginDraw();

      back.pushMatrix();
      back.translate(next_case.x * 100 + 100, next_case.y * 100 + 100);
      if(new_direction_code == direction_code){
        if(direction_code == 1 || direction_code == 3){  
          back.rotate(PI/2);
        } 
        back.image(chemin_droit, 0, 0);
      }     
      else{
        //on oriente bien l'image
        if((this.direction_code == 0 && new_direction_code == 3) || (this.direction_code == 1 && new_direction_code == 2)){
          back.scale(1, 1);  
        }
        if((this.direction_code == 0 && new_direction_code == 1) || (this.direction_code == 3 && new_direction_code == 2)){
          back.scale(-1, 1);  
        }    
        if((this.direction_code == 2 && new_direction_code == 1) || (this.direction_code == 3 && new_direction_code == 0)){
          back.scale(-1, -1);  
        }
        if((this.direction_code == 1 && new_direction_code == 0) || (this.direction_code == 2 && new_direction_code == 3)){
          back.scale(1, -1);  
        }
        
        back.image(chemin_virage, 0, 0);    
      }
      
      back.popMatrix();
      
      back.endDraw();
      
      this.direction_code = new_direction_code;
     
      parcours[PApplet.parseInt(next_case.y)][PApplet.parseInt(next_case.x)] = new_direction_code;

      
    }
    
    //On génère la suite du parcours  
    
        
    //on décale tout
    for(int i = 0; i < this.coordones.length - 1; i++){
      this.coordones[i] = new PVector(this.coordones[i+1].x, this.coordones[i+1].y);  
    }
    
    this.coordones[this.coordones.length - 1] = new PVector(this.position.x, this.position.y);
    
    this.position.add(new PVector(this.direction.x, this.direction.y).normalize().mult(vitesse));
      
  
  }
  
  public boolean isOnCentre(){ 
    return (this.getPosition().x % this.largeur < this.vitesse && this.getPosition().y % this.largeur < this.vitesse); 
    
  }
  
  public PVector getPosition(){
    return this.position;  
    
  }
  
  public PVector getCasePosition(){
    return new PVector(PApplet.parseInt(this.position.x / this.largeur) - 1, PApplet.parseInt(this.position.y / this.largeur) - 1);  
  }
  
  public boolean testCollision(PVector pos){
    for(PVector c : this.coordones){
      float dist = sqrt(pow(c.x - pos.x, 2) + pow(c.y - pos.y, 2));
      
      if(dist < this.largeur/2 - 20)
        return true;
      
    }  
    return false;
  }
  
  
  
}
class Player{
  private PVector position = new PVector(0, 0);  
  
  public Player(float x, float y){
    this.position.x = x;
    this.position.y = y;
  }
  
  
  public void move(){
    if(mousePressed){ 
      //il faut mettre à l'échelle
      this.position.x = mouseX / ratio;
      this.position.y = mouseY / ratio;
    }
  }
  
  public void show(){
    
  }

  public PVector getPosition(){
    return new PVector(this.position.x, this.position.y);  
  }
  
}
  public void settings() {  fullScreen(P2D); }
}
