import processing.serial.*;

Serial myPort;
int muestras=1000;
int[] B1 =  new int [muestras]; //Vectores Auxiliares que van almacenando valores leidos
int[] B2 =  new int [muestras];
int[] B3 =  new int [muestras];

int[] CA1 =  new int [muestras];//Vectores que representan cada canal, es decir, almacenan los datos ya arreglados
int[] CD1 =  new int [muestras];
int[] CD2 =  new int [muestras];

float[] ChannelA1= new float[muestras];
float[] ChannelD1= new float[muestras];
float[] ChannelD2= new float[muestras];
int t=0;
float tiempo = 0.3; //variables para controlar la grafica tanto en tiempo como en amplitud
float amplitud = 60;

boolean Amplitud1= false;//flags para cada boton
boolean Amplitud2= false;
boolean Amplitud3= true;
boolean Tiempo1= true;
boolean Tiempo2= false;
boolean Tiempo3= false;
boolean Analogico1= true;
boolean Analogico2= true;
boolean Digital1= true;
boolean Digital2= true;


void CrearBotonCirc(int x, int y, int ancho, int alto, String texto){//Funcion que crea botones circulares o elipticos
  stroke(0);                                                         // Recibe coordenadas del centro, ancho y alto, y el texto que lleva debajo
  strokeWeight(5);
  fill(230);
  ellipse(x,y,ancho,alto);
  fill(0);
  textSize(15);
  text(texto, x-28, y+50);
}

void CrearBotonRect(int x, int y, int ancho, int alto, String texto){//Funcion que crea botones rectangulares
  stroke(0);                                                         // Recibe coordenadas de punto superior izquierdo, ancho y alto, y el texto que recibe
  fill(230);
  rect(x,y,ancho, alto);
  fill(0);
  textSize(15);
  text(texto,x+10,y+20);
}

boolean BotonRectangular (int xizq, int yizq, int ancho, int alto) { //Funcion que determina si se presiona sobre uno de los botones rectangulares
  if ((mouseX>=xizq) && (mouseX<=xizq+ancho) && (mouseY>=yizq) && (mouseY<=yizq+alto))
    {return true;
  }
  else {
  return false;
  }
}

boolean BotonCircular (int x, int y, int diametro){ //Funcion que determina si se presiona sobre uno de los botones circulares
  float distanciaX= x - mouseX;
  float distanciaY= y - mouseY;
  if (sqrt(sq(distanciaX) + sq(distanciaY)) < diametro/2 ) {
    return true;
  } 
  else {
    return false;
  }
}
void setup() {     //Funcion que inicializa el puerto serial y tamaño de ventana
      myPort = new Serial(this, Serial.list()[0],115200);
      myPort.buffer(muestras*3); //tamano del buffer
      size(1000,520);
}

void leer(){ //Funcion que lee y desentrama lo recibido por puerto serial

  for(int j=0;j<muestras;j++){ //Ciclo quelee los datos del mismo y los almacena en los vectores de lectura
    if(myPort.available()>0) {
      do
      {B1[j]=myPort.read();
      } while(B1[j] > 0x40); //Se almacena 1 byte en B1 y se modifica hasta que se lee el byte que inicia con 01 o 00, como establece el protocolo
       B2[j]=myPort.read(); // Una vez sincronizada la lectura se procede a almacenar los bytes en el orden que se requiere
       B3[j]=myPort.read();
    }
  }
 
  if (B1[0]==0x40) //caso sin fltro
 
  {
    for(int i=0;i<muestras;i++){//Ciclo que desentrama los datos recibidos para obtener los datos correctos de cada byte del bloque
       CA1[i] = ((B2[i]&0xF)<<4)|(B3[i]&0xF); // Se obtienen los 4 bits menos significativos del byte 1 y se suma a los 4 bits del byte 2 para Canal Analogico 1
       CA1[i] = CA1[i]&0xFFF; // Se multiplica el vector por 111111111111 (12 bits) para evitar cualquier ruido en el valor
       CD1[i] = (B2[i]&0x20)>>5; //Shifteo el byte 2 cinco veces para obtener el bit digital 1
       CD1[i] = CD1[i]&0x1;
       CD2[i] = (B3[i]&0x20)>>5; //Shifteo el byte 3 cinco veces para obtener el bit digital 2
       CD2[i] = CD2[i]&0x1;
       ChannelA1[i]=map(CA1[i],0,255,0,amplitud); //Se adapta el valor obtenido por serial al necesario para la grafica dependiendo de la escala de amplitud seleccionada
       ChannelD1[i]=map(CD1[i],0,1,0,amplitud);
       ChannelD2[i]=map(CD2[i],0,1,0,amplitud);
     }
  }
  else //desentramado para el caso con filtro
  {
    for (int i=0;i<muestras;i++){
      CA1[i] = ((B1[i]& 0x3F)<<10)|((B2[i]&0x1F)<<5)|(B3[i]&0x1F);

      CA1[i] = (CA1[i])&0xFFFF;
      print(binary(CA1[i]), " ");
      CD1[i] = (B2[i]&0x20)>>5; //Shifteo el segundo byte cinco veces para obtener el bit digital 1
      CD1[i] = CD1[i]&0x1;
      CD2[i] = (B3[i]&0x20)>>5; //Shifteo el tercer byte cinco veces para obtener el bit digital 2
      CD2[i] = CD2[i]&0x1;
      ChannelA1[i]=CA1[i]>>8;
      ChannelA1[i]=map(CA1[i],0,255,0,amplitud); //Se adapta el valor obtenido por serial al necesario para la grafica dependiendo de la escala de amplitud seleccionada
      ChannelD1[i]=map(CD1[i],0,1,0,amplitud);
      ChannelD2[i]=map(CD2[i],0,1,0,amplitud);
    }
  }
}
 
void plotear (){//Funcion que se llama para graficar para cada canal dependiendo del flag del mismo
 
  float x= 60;//define en 60 el valor inicial del punto en x a partir del cual se empieza a graficar ya que esta es la coordenada X de donde inicia el Grid
  //
  for(int i=0;i<muestras-1;i++){ //Para graficar se hace un ciclo que toma todas las muestras guardadas y las coloca como puntos en la pantalla del osciloscopio
      if(Analogico1){
      stroke(#FF0808);//Si el flag para el canal analogico 1 esta activado Grafica canal analogico 1
      strokeWeight(3);
      point(x,400-ChannelA1[i]);
      //line(x, 400-ChannelA1[i],x+tiempo, 400-ChannelA1[i+1]);
     }

    if(Digital1){
      stroke(#0CED1C); //Si el flag para el canal digital 1 esta activado Grafica canal digital 1
      strokeWeight(3);
      point(x,400-ChannelD1[i]);
    }
    
    if (Digital2){
      stroke(#EDDB0C); //Si el flag para el canal digital 2 esta activado grafica canal digital 2
      strokeWeight(3);
      point(x,450-ChannelD2[i]);
    }
    x=x+tiempo;//Antes de avanzar en el 'for' se incrementa la coordenada X en la que se colocara el siguiente punto, esta varia dependiendo de los segundos por division
  }
}

//Funcion "main" que se repite ciclicamente y dentro de la cual se definen los elementos de la interfaz
void draw (){
 // clear();
  stroke(0);
  fill(#5F6E71);  //marco del grid
  rect(10,10,620,500);
  fill(0);  //fondo del grid
  rect(20,20,600,480);
  
  leer(); //LLama a la funcion de lectura
  
  plotear();//Llama a la funcion de grafica

  dibujo(); //se llama a la funcion dibujo que contiene mas elementos de la interfaz
 
}

void dibujo(){
  fill(#5F6E71);  //fondo
  stroke(#5F6E71);
  strokeWeight(1);
  rect(0,0,1000,20);
  rect(0,0,60,500);
  rect(0,500,1000,20);
  rect(600,0,480,500);
  
  //Creacion del Grid
  
  stroke(#EBFAEC);
  for(int i=60;i<640;i+=60)//Grid
    {line(i,20,i,500);}
  for(int w=20;w<600;w+=60)
    {line(60,w,600,w);}
    
  //Creacion de los botones de la interfaz con las funciones creadas anteriormente
  CrearBotonCirc(710,80,50,50, "0.3V/div");
  CrearBotonCirc(830,80,50,50, "1V/div");
  CrearBotonCirc(950,80,50,50, "3V/div");
  CrearBotonCirc(710,210,50,50, "100ms/div");
  CrearBotonCirc(830,210,50,50, "10ms/div");
  CrearBotonCirc(950,210,50,50, "1ms/div");
  CrearBotonRect(675,350,120,30, "Analogico 1");
  CrearBotonRect(850,350,120,30, "Analogico 2");
  CrearBotonRect(675,450,120,30, "Digital 1");
  CrearBotonRect(850,450,120,30, "Digital 2");
  
  //Textos en el osciloscopio
  stroke(0);
  textSize(30);
  text("Escala de amplitud", 690, 40);
  text("Escala de tiempo", 700, 170);
  text("Canales", 750, 330);
  
  //marco del grid
  strokeWeight(1);
  //fill(#5F6E71);  
  line(50,10,50,510);
  line(50,10,610,10);
  line(610,10,610,510);
  line(50,510,610,510);
   
  //Los botones seleccionados de las escalas de amplitud y de tiempo quedaran marcados
  //el boton circular seleccionado estara resaltado por un circulo negro
  if(Amplitud1){
    ellipse(710,80,40,40);
    fill(#171717); }

  if(Amplitud2){
    ellipse(830,80,40,40);
    fill(#171717); }

  if(Amplitud3){
    ellipse(950,80,40,40);
    fill(#171717);  }
  
  if(Tiempo1){
    ellipse(710,210,40,40);
    fill(#171717);}
    
  if(Tiempo2){
    ellipse(830,210,40,40);
    fill(#171717);}
    
  if(Tiempo3){
    ellipse(950,210,40,40);
    fill(#171717);}
    //los canales encendidos tendran una marca del color que corresponde a su grafica
  if(Analogico1){
    stroke(#FF0808);
    fill(#FF0808);
    ellipse(780,365, 10, 10) ;
  }
  if(Analogico2){
    stroke(#0CEDD1);
    fill(#0CEDD1);
    ellipse(955,365,10,10);
  }
  if(Digital1){
    stroke(#0CED1C);
    fill(#0CED1C);
    ellipse(780,465,10,10);
  }
  if(Digital2){
    stroke(#EDDB0C);
    fill(#EDDB0C);
    ellipse(955,465,10,10);
  }
}

void mousePressed (){//Funcion que define la accion a realizar si se presiona el mouse
  if (BotonCircular (710, 80, 100)) { //Define las condiciones para la cual se activa cierto boton
    if (Amplitud1){ //Si el boton ya estaba activado no hace nada
    }
    else{
      amplitud=600; //Si otro boton estaba activado cambia la escala de amplitud y desactiva los otros botones porque solo puede haber una escala de voltaje a la vez
      Amplitud1=true;
      Amplitud2=false;
      Amplitud3=false;
    }
  }
  else if (BotonCircular (830, 80, 100)){ 
    if (Amplitud2){
    }
    else{
      amplitud=180;
      Amplitud2=true;
      Amplitud1=false;
      Amplitud3=false;
    }
  }
  else if (BotonCircular (950, 80, 100)){
    if (Amplitud3){
    }
    else{
      amplitud=60;
      Amplitud3=true;
      Amplitud1=false;
      Amplitud2=false;
    }
  }
  else if (BotonCircular (710, 210, 100)){//Hace lo mismo que los botones de voltaje pero este modifica la escala de tiempo
    if (Tiempo1){
    }
    else{
      tiempo=0.3;
      Tiempo1=true;
      Tiempo2=false;
      Tiempo3=false;
    }
  }
  else if (BotonCircular (830, 210, 100)){
    if (Tiempo2){
    }
    else{
      tiempo=3;
      Tiempo2=true;
      Tiempo1=false;
      Tiempo3=false;
    }
  }
  else if (BotonCircular (950, 210, 100)){
    if (Tiempo3){
    }
    else{
      tiempo=30;
      Tiempo3=true;
      Tiempo1=false;
      Tiempo2=false;
    }
  }
  //Para los botones rectangulares no hace falta desactivar los otros botones, es decir, solo se prende o apaga el canal del boton presionado
  else if (BotonRectangular (675, 350, 120, 30)){
    if (Analogico1){
      Analogico1=false;
    }
    else{
      Analogico1=true;
    }
  }
  else if (BotonRectangular (850, 350, 120, 30)){
    if (Analogico2){
      Analogico2=false;
    }
    else{
      Analogico2=true;
    }
  }
  else if (BotonRectangular (675, 450, 120, 30)){
    if (Digital1){
      Digital1=false;
    }
    else{
      Digital1=true;
    }
  }
  else if (BotonRectangular (850, 450, 120, 30)){
    if (Digital2){
      Digital2=false;
    }
    else{
      Digital2=true;
    } 
  }
}
