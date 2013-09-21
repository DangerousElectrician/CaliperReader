{{
  Read data port from digital calipers and send the reading to serial terminal 
}}                                                  
CON
   
  _clkmode = xtal1 + pll16x                             ' Crystal and PLL settings.
  _xinfreq = 5_000_000                                  ' 5 MHz crystal (5 MHz x 16 = 80 MHz).
  
OBJ

  pst    : "Parallax Serial Terminal"                   ' Serial communication object
  clpr  : "caliperReaderAsm2"
  
PUB go                                   

  pst.Start(115200)                  
  pst.clear
  clpr.start(14, 15)
  waitcnt(cnt + clkfreq/5)      
      
 repeat
      
    pst.dec(clpr.reading)
    
    if clpr.isinches
      pst.str(string(" in"))
    else
      pst.str(string(" mm"))
                                             
    pst.newline   
    'waitcnt(cnt+clkfreq/20)   
                