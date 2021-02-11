abstract class Temple{
  
  private PImage virage_sprite;
  private PImage droit_sprite;
  
  private color light_color;
  
  public Temple(PImage a, PImage b, color c){
    this.virage_sprite = a;
    this.droit_sprite = b;
    
    this.light_color = c;
    
  }
  
  abstract void generationChemin(Chemin c);
  abstract void run();
  
  
}
