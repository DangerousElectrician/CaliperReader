{{
  Read data port from digital calipers and send the reading to serial terminal 
}}                                                  
CON
   
  _clkmode = xtal1 + pll16x                             ' Crystal and PLL settings.
  _xinfreq = 5_000_000                                  ' 5 MHz crystal (5 MHz x 16 = 80 MHz).
  
OBJ

  pst    : "Parallax Serial Terminal"                   ' Serial communication object

VAR

 long data[28]
 long convert [7]
                          
PUB go | value, converti, badresult                                  

  pst.Start(115200)                                                             ' Start the Parallax Serial Terminal cog

  start
  pst.clear
  value:=0
  converti := 0                                                                            

  waitcnt(cnt+2*clkfreq)
repeat
  repeat value from 0 to 27
    data[value] &= |<14

  repeat value from 0 to 27
    if data[value] == |<14
      data[value] := false
    else
      data[value] := true
        
  value:=0
  converti := 0
  badresult := false  
  repeat converti from 0 to 7
  
    convert[converti] := 0
                       
    if data[value++]
      convert[converti] += 1  
    if data[value++]
      convert[converti] += 2
    if data[value++]
      convert[converti] += 4
    if data[value++]
      convert[converti] += 8

    if converti <7 and convert[converti] == 15
      badresult := true
    
    'value -= 4
  ifnot badresult  
    
    repeat converti from 7 to 0
        pst.Dec(convert[converti])
    pst.newline
                      
PUB start
                                                    
  cognew(@initreader, @data)  


DAT

ORG 0
 
initreader    
             
              mov dira, statpin                                                                                  

beginread        
              xor outa, statpin
              
              mov       digadd, #inbuf0
              mov       i, #0              
              waitpeq   pinclk, pinclk              
               
readloop                                    
              waitpeq   zero, pinclk
              waitpeq   pinclk, pinclk 
              
              movd      cachewrite, digadd
              nop
cachewrite    mov       digadd, ina
              add       digadd, #1
                                            
              add       i ,#1 
              cmp       i, #28  wz             
        if_nz jmp       #readloop
              
              xor outa, statpin
              
        
beginwrite                             
              mov       digadd, #inbuf0
              mov       i, #0
              mov       parloc, par 
writeloop                                                                                    
     
              movd      cacheread, digadd
              nop                    'need a nop, d-field of cacheread won't change
cacheread     wrlong    digadd, parloc
              add       parloc, #4
              
              add       digadd, #1
              
              add       i, #1    
              cmp       i, #28  wz             
        if_nz jmp       #writeloop
                                
              jmp       #beginread              

                            

zero    long 0

parloc  long 0 'parameter location

pinclk  long |<15 'decoded caliper clock pin
caldat  long |<14 'decoded caliper data pin
statpin long 1                  

i       res 1

digadd  res 1 'digit number address

inbuf0  res 28


              fit 496