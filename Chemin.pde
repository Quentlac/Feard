
class Chemin{
  
  private PVector position;
  private PVector direction = new PVector(0, 0);
  
  private int direction_code = 0;
  
  private PVector coordones[] = new PVector[50];
  
  private PGraphics ombre;
  private PGraphics chemin_mask;
  
  public final float vitesse = 5;
  private float proba_virage = 20; //40% de chance de tourner à chaque intersection
  
  private final int largeur = 100;
  
  public Chemin(float x, float y){
    //on définit la position de base
    this.position = new PVector(x, y);
    
    //on initialise la position de tous les élements du chemin
    for(int i = 0; i < this.coordones.length; i++){
      this.coordones[this.coordones.length - i - 1] = new PVector(this.position.x, this.position.y);  
    }
    
    //On créé le masque permettant d'afficher le chemin
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
    
    //Lorsque le chemin arrive à une intersection
    if(this.isOnCentre()){
      
      //on change la direction par rapport au tableau
      int new_direction_code = parcours[int(this.getCasePosition().y)][int(this.getCasePosition().x)];
      
      if(new_direction_code == 0)
        this.direction = new PVector(0, -1);  
      if(new_direction_code == 1)
        this.direction = new PVector(1, 0); 
      if(new_direction_code == 2)
        this.direction = new PVector(0, 1);
      if(new_direction_code == 3)
        this.direction = new PVector(-1, 0); 
        
      
      this.generateChemin();
      
    }
        
        
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
    return new PVector(int(this.position.x / this.largeur) - 1, int(this.position.y / this.largeur) - 1);  
  }
  
  public boolean testCollision(PVector pos){
    for(PVector c : this.coordones){
      float dist = sqrt(pow(c.x - pos.x, 2) + pow(c.y - pos.y, 2));
      
      if(dist < this.largeur/2 - 20)
        return true;
      
    }  
    return false;
  }
  
  
  private void generateChemin(){
    //on définis la suite du parcours
    PVector next_case = this.getCasePosition().add(this.direction.normalize());
  
    PVector new_direction = new PVector(0, 0);
    int new_direction_code;
    
    //Tant que la prochaine direction ne vas pas on continu (en cas d'obstacle)
    do{
      //valeur aléatoire pour choisir le comportement à adopter
      int random_num = round(random(0, 100));
      if(random_num > 100 - this.proba_virage)
        new_direction_code = this.direction_code + ((random(0, 100) > 50) ? -1 : 1);

      else 
        new_direction_code = this.direction_code;
        
      if(new_direction_code > 3)
        new_direction_code = 0;
      if(new_direction_code < 0)
        new_direction_code = 3;
      
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
   
    parcours[int(next_case.y)][int(next_case.x)] = new_direction_code;   
  }
  
  
}
