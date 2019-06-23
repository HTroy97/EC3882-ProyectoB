import processing.serial.*;

Serial myPort;
int muestras=1000; //numero de muestras a leer en cada canal
int[] B1 =  new int [muestras]; //Vectores Auxiliares que van almacenando valores leidos
int[] B2 =  new int [muestras];
int[] B3 =  new int [muestras];

int[] CA1 =  new int [muestras];//Vectores que representan cada canal, es decir, almacenan los datos ya arreglados
int[] CD1 =  new int [muestras];
int[] CD2 =  new int [muestras];

int saltos = 0; //declaracion de variables globales y flags a utilizar
int calorias = 0;
boolean boton = false;
boolean digital1 = false;
boolean digital2=false;
boolean salto=false;
int timeinicial=0;
int timefinal=0;
PImage img;
PImage imagen;
PImage imagencalorias;
PFont font;
PFont fuentetitulo;

void CrearBotonRect(int x, int y, int ancho, int alto, String texto){//Funcion que crea botones rectangulares
  stroke(0);                                                         // Recibe coordenadas de punto superior izquierdo, ancho y alto, y el texto que recibe
  fill(230);
  rect(x,y,ancho, alto);
  fill(0);
  textSize(30);
  text(texto,x+60,y+35);
}

boolean BotonRectangular (int xizq, int yizq, int ancho, int alto) { //Funcion que determina si se presiona sobre uno de los botones rectangulares
  if ((mouseX>=xizq) && (mouseX<=xizq+ancho) && (mouseY>=yizq) && (mouseY<=yizq+alto))
    {return true;
  }
  else {
  return false;
  }
}

void setup() {     //Funcion que inicializa el puerto serial, tamaño de ventana, carga imágenes y fuentes a utilizar
  myPort = new Serial(this, Serial.list()[0],115200);
  myPort.buffer(muestras*4); //tamano del buffer
  imagen=loadImage("Cuerda (1).jpg");
  img=loadImage("Saltoconcuerda.jpg");
  imagencalorias=loadImage("calorias.jpg");
  fuentetitulo=loadFont("Rockwell-48.vlw");
  size(450,600);
  font = loadFont ("PalatinoLinotype-Roman-30.vlw");
}

void leer(){ //Funcion que lee y desentrama lo recibido por puerto serial
  for(int p=0;p<muestras;p++){ //Ciclo que limpia los vectores que se utilizan para la lectura del puerto
    B1[p]=0;
    B2[p]=0;
    B3[p]=0;
    }
  for(int j=0;j<muestras;j++){ //Ciclo que, si el puerto tiene datos, lee los datos del mismo y los almacena en los vectores de lectura
    if(myPort.available()>0) {
      do
      {B1[j]=myPort.read(); //La lectura se hace de un byte a la vez, asi que se estaria almacenando el primer byte leido en la variable B1
      } while(B1[j]>0x40); //Se continua leyendo hasta que se guarda en B1 el byte igual a 01000000 o de la forma 00xxxxxx
      B2[j]=myPort.read(); // Una vez sincronizada la lectura se procede a almacenar los bytes en el orden que se requiere
      B3[j]=myPort.read();
     
    }
  }
 // myPort.clear(); // Una vez finalizada la lectura se limpia el buffer
 
  if(B1[0]==0x40){ //caso :1 byte 1 igual a 01000000, caso sin filtro donde el canal analogico es un vector de 8 bits
    for(int i=0;i<muestras;i++){//Ciclo que desentrama los vecotres de lectura para obtener los datos correctos de cada byte del bloque
       CA1[i] = ((B2[i]&0xF)<<4)|(B3[i]&0xF); // Se obtienen los 4 bits menos significativos del byte 2 y se suma a los 4 bits mas significativos del byte 3 para Canal Analogico 1
       CA1[i] = CA1[i]&0xFFF; // Se multiplica el vector por 111111111111 (12 bits) para evitar cualquier ruido en el valor
       CD1[i] = (B2[i]&0x20)>>5;//Se obtiene el bit 6 del byte 2 y se shiftea 5 veces a la derecha para obtener bit digital 1
       CD1[i] = CD1[i]&0x1;
       CD2[i] = (B3[i]&0x20)>>5; //Se obtiene el bit 6 del byte 3 y se shiftea 5 veces para obtener el bit digital 2
       CD2[i] = CD2[i]&0x1;
       if (CD1[i]==1) //condiciones de banderas para los canales digitales, si estan en 1 se activa su flag y en caso contrario se desactivan
        {digital1=true;
      }
      else{
        digital1=false;
      }
      if (CD2[i]==1)
        {digital2=true;
      }
      else{
        digital2=false;
      }
    }
  }
  
  else{ //caso 2: byte 1 igual a 00xxxxxx, caso con filtro, donde el vector recibido del canal analogico es de 16 bits
    for(int i=0;i<muestras;i++){
      CA1[i]= (B1[i]<<10)|((B2[i]&0x1F)<<5)|(B3[i]&0x1F); //se obtienen los primeros 6 bits del dato shifteando los 6 menos significativos del primer byte 10 veces
      CA1[i]= CA1[i]&0xFFFF;                     //se concatena con los 5 bits menos significativos del segundo byte y los 5 menos significativos del tercer byte
      CD1[i]= (B2[i]&0x20)>>5; //Se obtiene el bit 6 del byte 2 y se shiftea 5 veces a la derecha para bit digital 1
      CD1[i]= CD1[i]&0x1;
      CD2[i]= (B3[i]&0x20)>>5;//Se obtiene el bit 6 del byte 3 y se shiftea 5 veces a la derecha para bit digital 2
      CD2[i]= CD2[i]&0x1;
      CA1[i]= CA1[i]/255; // se divide el vector del canal analogico, ahora el maximo valor posible es 257
      if (CD1[i]==1) //condiciones para banderas de los canales digitales
        {digital1=true;
      }
      else{
        digital1=false;
      }
      if (CD2[i]==1)
        {digital2=true;
      }
      else{
        digital2=false;
      }
    }
  }
}

//Funcion "main" que se repite ciclicamente y dentro de la cual se definen los elementos de la interfaz
void draw (){
 // clear();
  leer(); //LLama a la función de lectura y desentramado
  
  dibujo(); //llama a la función de dibujo donde se manejan distintos elementos de diseño de la interfaz
  image(img, 110, 60); //imagen en la interfaz
  contarSaltos(); //llama a la funcion que cuenta saltos
  textSize(40);
  fill(#FFFFFF);
  text(saltos, 350, 330); // impresión del valor de saltos calculado hasta el momento
  calcularCalorias(); //LLama a la funcion que calcula calorías quemadas
  if(digital1){
    text(calorias, 350, 400);
    text(" kcal", 375,400);
  }//impresion del valor calculado de calorías hasta ahora
  else{
    text(calorias, 350, 400);
    text(" cal", 375, 400);
  }
  if (boton){
    text((millis()-timeinicial)/1000, 200,560);
  }
}

void dibujo(){ //función con diferentes elementos de interfaz como textos, colores y botones
  stroke(0);
  fill(#C9AD1C);
  rect(0,0,450,600);    //fondo del grid
  textSize(30);
  fill(#FFFFFF);
  textFont(fuentetitulo);
  text("SALTÓMETRO", 80, 50); 
  textSize(25);
  textFont(font);
  text("Saltos Realizados: ", 50, 330);
  text("Calorías Quemadas: ", 50, 400);
  fill(#FCF996);
  CrearBotonRect(125,450,200,50, "Start"); //creación del botón de la interfaz
}

//funcion encargada de contar saltos mediantes deteccion de nivel, conociendo el maximo valor del canal analogico en 257
//se activa una bandera si se detecta un valor mayor al umbral fijado en 190 y si luego se obtiene un valor menor la bandera se desactiva, y se contabiliza un salto
void contarSaltos(){
   if (boton)
     {for(int i=0;i<muestras;i++){
       if (CA1[i]>190 && salto==false){
         salto=true;
       }
       if (CA1[i]<190 && salto==true){
         salto=false;
         saltos++;
       }     
     }
   }
}

//Si se salta continuamente durante 30 minutos se queman alrededor de 340 calorias, si se salta continuamente desde el momento en que inicia el contador 
//se obtiene el numero aproximado de calorias quemadas 
void calcularCalorias() {
  calorias= (timefinal-timeinicial)*340/1800000;
  if (digital1){
    calorias=calorias/1000;
  }
}

//funcion que define que hacer al hacer click sobre el boton de "start"
void mousePressed (){//Funcion que define la accion a realizar si se presiona el mouse
  if (BotonRectangular (125, 450, 200, 50)){
    if (boton){
      boton=false;
      timefinal=millis();
    }
    else{
      boton=true;
      saltos=0;
      calorias=0;
      timeinicial=millis();
    }
  }
}
