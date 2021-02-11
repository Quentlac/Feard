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
