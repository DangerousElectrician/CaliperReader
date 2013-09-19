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
 long finalValue                         
PUB go | value, converti, badresult, e10                                  

  pst.Start(115200)                                                             ' Start the Parallax Serial Terminal cog

  start
  pst.clear
  value:=0
  converti := 0                                                                            

  waitcnt(cnt+2*clkfreq)
repeat
  repeat value from 0 to 27
    data[value] &= |<14
        
  value:=0
  converti := 0
  badresult := false  
  repeat converti from 0 to 6
  
    convert[converti] := 0
                       
    ifnot data[value++]
      convert[converti] += 1  
    ifnot data[value++]
      convert[converti] += 2
    ifnot data[value++]
      convert[converti] += 4
    ifnot data[value++]
      convert[converti] += 8
                                      
    if converti <6 and convert[converti] > 9
      badresult := true
                
  if badresult  
    pst.tab
    pst.tab

  e10 := 1
  finalvalue := 0
  repeat converti from 0 to 5
    finalValue += convert[converti] * e10
    e10 *= 10
                  

  if data[26]         'is inches?
    finalvalue *= 10
    ifnot data[25]       'half?
      finalvalue += 5

  ifnot data[24]          'is negative?
    finalvalue *= -1
    
  pst.dec(finalvalue)
  if data [26]
    pst.str(string(" in"))
  else
    pst.str(string(" mm"))
    
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
              movd      cachewrite, digadd
                 
              waitpeq   zero, pinclk
              waitpeq   pinclk, pinclk 
                                              
              'nop
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