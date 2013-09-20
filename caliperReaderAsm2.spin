{{

┌──────────────────────────────────────────┐
│ <object name and version>                │
│ Author: <author(s)>                      │               
│ Copyright (c) <year> <copyright holders> │               
│ See end of file for terms of use.        │                
└──────────────────────────────────────────┘

<object details, schematics, etc.>

}}                           
VAR

 long data[28]
 long convert [7]
 long finalValue
 long cog

PUB start : okay

  okay := cog := cognew(@initreader, @data) + 1

PUB stop

  if cog
    cogstop(cog~ - 1)

PUB reading | k, j, e10

  repeat k from 0 to 27
    data[k] &= |<14
        
  k:=0
  j := 0                       
  repeat j from 0 to 6
  
    convert[j] := 0
                       
    ifnot data[k++]
      convert[j] += 1  
    ifnot data[k++]
      convert[j] += 2
    ifnot data[k++]
      convert[j] += 4
    ifnot data[k++]
      convert[j] += 8
                                      
    if j <6 and convert[j] > 9            
      stop
      start
      return 'finalvalue  

  e10 := 1
  finalvalue := 0
  repeat k from 0 to 5
    finalValue += convert[k] * e10
    e10 *= 10

  if data[26]         'is inches?
    finalvalue *= 10
    ifnot data[25]       'half?
      finalvalue += 5

  ifnot data[24]          'is negative?
    finalvalue *= -1
         
  return finalvalue
  
PUB isinches 'true if unit is inches, false if millimeters

  return data[26]
   
DAT

ORG 0
 
initreader    
             
              mov dira, statpin                                                                                  

beginread        
              xor outa, statpin
              
              mov       daddr, #inbuf0
              mov       i, #0              
              waitpeq   pinclk, pinclk              
               
readloop                                 
              movd      bufferwrite, daddr 'note the space between movd and cachewrite
                 
              waitpeq   zero, pinclk
              waitpeq   pinclk, pinclk 
                                         
bufferwrite   mov       daddr, ina
              add       daddr, #1
                                            
              add       i ,#1 
              cmp       i, #28  wz             
        if_nz jmp       #readloop
              
              xor outa, statpin
              
        
beginwrite                             
              mov       daddr, #inbuf0
              mov       i, #0   
              mov       parloc, par 
writeloop                                                                                    
                                         
              movd      cacheread, daddr
              nop                    'need a nop or some other instruction here to give d-field time to write. I found out the hard way and it's also in the manual
cacheread     wrlong    daddr, parloc
              add       parloc, #4
              
              add       daddr, #1
              
              add       i, #1    
              cmp       i, #28  wz             
        if_nz jmp       #writeloop
                                
              jmp       #beginread              

                            

zero    long 0 '

parloc  long 0 'parameter location
  
statpin long 1 'debug led pin                

pinclk  long |<15 'decoded caliper clock pin
caldat  long |<14 'decoded caliper data pin     

i       res 1

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