/* ###################################################################
**     Filename    : main.c
**     Project     : potenciometro ADC
**     Processor   : MC9S08QE128CLK
**     Version     : Driver 01.12
**     Compiler    : CodeWarrior HCS08 C Compiler
**     Date/Time   : 2019-02-16, 19:08, # CodeGen: 0
**     Abstract    :
**         Main module.
**         This module contains user's application code.
**     Settings    :
**     Contents    :
**         No public methods
**
** ###################################################################*/
/*!
** @file main.c
** @version 01.12
** @brief
**         Main module.
**         This module contains user's application code.
*/         
/*!
**  @addtogroup main_module main module documentation
**  @{
*/         
/* MODULE main */


/* Including needed modules to compile this module/procedure */
#include "Cpu.h"
#include "Events.h"
#include "AD1.h"
#include "TI1.h"
#include "AS1.h"
#include "Bit1.h"
#include "Bit2.h"
#include "Bit3.h"
#include "KB1.h"
#include "TI2.h"
#include "Bit4.h"
/* Include shared modules, which are used for whole project */
#include "PE_Types.h"
#include "PE_Error.h"
#include "PE_Const.h"
#include "IO_Map.h"
#include "fdacoefsFLOAT.h"


/* User includes (#include below this line is not maintained by Processor Expert) */
//Declaramos variables a utilizar

char i;
char f=0; 
signed char y[3] ={0,0,0};
char dato, k=0;
char datos[9]={0,0,0,0,0,0,0,0,0};
int z=0;

char CodError; 
char filtro=1;
char BL = 9;
//signed char B[]= {0, 0, 0, -1, 0, 3, 0, -6, 0, 11, 0, -24, 0, 79, 127, 79, 0, -24, 0, 11, 0, -6, 0, 3, 0, -1, 0, 0, 0};
signed char B[]= {0, -6, 0, 70, 127, 70, 0, -6, 0};
int j=0, x=0;
bool s_digital_1;
bool s_digital_2;


void main(void)
{
  /* Write your local variable definition here */

  /*** Processor Expert internal initialization. DON'T REMOVE THIS CODE!!! ***/
  PE_low_level_init();
  /*** End of Processor Expert internal initialization.                    ***/

  /* Write your code here */
  for(;;){
	  
		if(f){
		   do{
				CodError=AD1_Measure(TRUE); 
		   } while (CodError != ERR_OK);
		   
		   do{
				CodError=AD1_GetValue(&dato);
			} while (CodError != ERR_OK);
		   
			if (filtro){
				  /* 
				datos[x]=dato;
				z=0; //almacena la muestra filtrada
			    for(j=0;j<BL;j++){	
				 	z=z+(datos[(BL+x-j)%BL]*B[j]);
			    }
			    x=(x+1)%BL; */ 
									
			    		/*		if(x==BL){
			    					x=0; //hago que sea ciclico, x puntero a la muestra mas reciente
			    				}*/
			    				datos[x]=dato;
			    				z=0; //almacena la muestra filtrada
			    			    for(j=0;j<BL;j++){
			    			    	k=(x-j)%BL;
			    				 	/*if(k>100){
			    				 		k=k+BL;} //OJO no se si -1==255, -2==254.. revisar ESTO*/
			    				 	z=z+(datos[k]*B[j]);
			    				 	x=(x+1)%BL;
			    			    }
			    			
			 /*y[0]=z>>8;
			 y[1]=z;*/
			    y[0]=(z>>10)&(0x3f);
			    y[1]=((z>>5)&(0x1f))|(0xc0);
			    y[2]=(z & 0x1f)|(0xc0);
			    
			 }
			else{  
				
				AD1_GetValue(&dato);
				
				/*y[0]=0;
				y[1]=dato;*/
				y[0]=0x00 | 0x40;
			    y[1]=((dato>>4)&0xf)|(0xc0);
			    y[2]=(dato&0xf)|(0xc0);
			   
			}

	//Canales digitales
						  
			  s_digital_1 =Bit1_NegVal();//
				if(s_digital_1){ //Si el valor digital 1 esta activado se coloca en 1 el bit 6 del bloque b( segundo a enviar
					y[1] = y[1] | 0x40;
				}

			   s_digital_2= Bit2_NegVal();
				if(s_digital_2){ //Si el valor digital 2 esta activado se coloca en 1 el bit 7 del bloque c 
					y[2] = y[2] | 0x40;
				}								
			
			do{
				CodError = AS1_SendBlock(y, 3, &i);
				//CodError =  AS1_SendChar(y);
				} while (CodError != ERR_OK);
			f=0;
			Bit4_NegVal();
	  	}
  }
  /* For example: for(;;) { } */

  /*** Don't write any code pass this line, or it will be deleted during code generation. ***/
  /*** RTOS startup code. Macro PEX_RTOS_START is defined by the RTOS component. DON'T MODIFY THIS CODE!!! ***/
  #ifdef PEX_RTOS_START
    PEX_RTOS_START();                  /* Startup of the selected RTOS. Macro is defined by the RTOS component. */
  #endif
  /*** End of RTOS startup code.  ***/
  /*** Processor Expert end of main routine. DON'T MODIFY THIS CODE!!! ***/
  for(;;){}
  /*** Processor Expert end of main routine. DON'T WRITE CODE BELOW!!! ***/
} /*** End of main routine. DO NOT MODIFY THIS TEXT!!! ***/

/* END main */
/*!
** @}
*/
/*
** ###################################################################
**
**     This file was created by Processor Expert 10.3 [05.09]
**     for the Freescale HCS08 series of microcontrollers.
**
** ###################################################################
*/
