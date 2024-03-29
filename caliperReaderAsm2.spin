{{

┌──────────────────────────────────────────┐
│ Digital Caliper Reader v1.0              │
│ Author: H Lou                            │               
│ Copyright (c) 2013 H Lou                 │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

This object can read the data port on digital calipers that output data in the BCD format


How to hook it up:


Digital Caliper side     3.3v       Propeller chip
                                    ┌───────┐
                          ┣─┐        │P8X32A │
    Ruler end          10k │        │       │
       ┌────┐             ┣─┼──────┐ │       │
       │1.5v├   10k    ┌─ │      │ │       │
       │ DAT├────────┘   │      │ │       │
       │ CLK├───────┐     10k   └─┤dpin   │     
       │ GND├───┐     │   ┌─┻────────┤cpin   │
       └────┘        └──          └───────┘
  Pointy end              

                                                

}}                           
VAR
             
 long _dpin
 long _cpin
 long _timeout 
 long lock    
 long data[28]
 long convert [7]
 
 long finalValue
 long cog 
 
PUB start(dpin, cpin) : okay
                                
  setpins(dpin, cpin)

  _timeout := clkfreq / 78125
                                
  okay := cog := cognew(@initreader, @_dpin) + 1
                     
PUB stop

  if cog
    cogstop(cog~ - 1)

PUB setpins(dpin, cpin)

  _dpin := dpin
  _cpin := cpin
  
PUB reading | k, j, e10

  repeat until not lock

  lock := true
  
  repeat k from 0 to 27
    data[k] &= |<14
        
  k:=0
  j := 0                       
  repeat j from 0 to 6   'convert binary to single decimal digits
  
    convert[j] := 0
                       
    ifnot data[k++]
      convert[j] += 1  
    ifnot data[k++]
      convert[j] += 2
    ifnot data[k++]
      convert[j] += 4
    ifnot data[k++]
      convert[j] += 8
                                      
    if j <6 and convert[j] > 9  'Any numbers above 9 in BCD are an error     
      return   

  e10 := 1
  finalvalue := 0
  repeat k from 0 to 5              'take the single decimal digits and combine them
    finalValue += convert[k] * e10
    e10 *= 10

  if data[26]         'is inches?
    finalvalue *= 10   'multiply by 10 again to allow for a half
    ifnot data[25]       'half?
      finalvalue += 5    

  ifnot data[24]          'is negative?
    finalvalue *= -1

  lock := 0       
  return finalvalue
  
PUB isinches 'true if units are inches, false if millimeters

  return data[26]
   
DAT

ORG 0
 
initreader                  
              mov       lockaddr, par
              add       lockaddr, #4*3                                                                                                                      

beginread
              mov       parloc, par        'update parameters
              
              rdlong    pintemp, parloc
              mov       datpin, #1
              shl       datpin, pintemp
 
              add       parloc, #4              
              rdlong    pintemp, parloc     
              mov       clkpin, #1
              shl       clkpin, pintemp

              add       parloc, #4              
              rdlong    timeoutcon, parloc


                                   
              mov       daddr, #inbuf0
              mov       i, #0               

:waithigh     test   clkpin,INA wz
        if_z  jmp    #:waithigh                        
               
readloop                                  'record value from calipers
              movd      bufferwrite, daddr 'note the space between movd and cachewrite                  

                                         
              mov       timeout, timeoutcon           'resync if timeout
:waitlow      testn     clkpin,INA wz    'waitlow
        if_z  djnz      timeout, #:waitlow wz
        if_z  jmp      #beginread
        
              mov       timeout, timeoutcon
:waithigh     test      clkpin, INA wz   'waithigh
        if_z  djnz      timeout, #:waithigh wz
        if_z jmp      #beginread                     

                                   
bufferwrite   mov       daddr, ina   
              add       daddr, #1
                                            
              add       i ,#1 
              cmp       i, #28  wz             
        if_nz jmp       #readloop                                                     

        
beginhubwrite
:loop         rdlong    lock_, lockaddr
        if_nz jmp       #:loop                                            
              wrlong    one, lockaddr                  
   
              mov       daddr, #inbuf0
              mov       i, #0   
              mov       parloc, par
              add       parloc, #4*4         
writeloop                                                                     
              movd      cacheread, daddr
              nop                    'need a nop or some other instruction here to give d-field time to write
cacheread     wrlong    daddr, parloc
              add       parloc, #4
              
              add       daddr, #1
              
              add       i, #1    
              cmp       i, #28  wz             
        if_nz jmp       #writeloop 
              
              wrlong    zero, lockaddr                                   
              jmp       #beginread              

                            

zero    long 0 '
one     long -1                    

timeoutcon res 1

parloc  res 1 'parameter location
                          
lockaddr res 1                        
lock_   res 1                                                                      

pintemp res 1 'workspace for decoding pin numbers 
clkpin  res 1' caliper clock pin     
datpin  res 1 'caliper data pin         

i       res 1

timeout res 1

daddr   res 1 '(destination field address)keeps address of next element of list

inbuf0  res 28


              fit 496


{{

┌─────────────────────────────────────────────────────────────────────────────────────────┐
│                                TERMS OF USE: MIT License                                │                                                            
├─────────────────────────────────────────────────────────────────────────────────────────┤
│Permission is hereby granted, free of charge, to any person obtaining a copy of this     │
│software and associated documentation files (the "Software"), to deal in the Software    │
│without restriction, including without limitation the rights to use, copy, modify, merge,│
│publish, distribute, sublicense, and/or sell copies of the Software, and to permit       │
│persons to whom the Software is furnished to do so, subject to the following conditions: │
│                                                                                         │
│The above copyright notice and this permission notice shall be included in all copies or │
│substantial portions of the Software.                                                    │
│                                                                                         │
│THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED,    │
│INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR │
│PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE│
│FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR     │
│OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER   │
│DEALINGS IN THE SOFTWARE.                                                                │
└─────────────────────────────────────────────────────────────────────────────────────────┘
}}           