VAR_GLOBAL

//OUTPUT
glob_Pist1 at %Y33.1:BOOL;                                             //pist pod otvorem na vlozeni obrobku
glob_Pist2 at %Y33.0:BOOL;                                             //pist pro lisovani obrobku
glob_Kompresor at %Y33.2:BOOL;                                         //kompresor
glob_MotorStolu at %Y32.5:BOOL;                                        //motor otocneho stolu
glob_DvojcinnyPist1 at %Y32.6:BOOL;                                    //vysunuti dvoucinneho pistu nad dopravnikem
glob_DvojcinnyPist2 at %Y32.7:BOOL;                                    //zasunuti dvoucinneho pistu nad dopravnikem
glob_MotorDopravniku at %Y32.4:BOOL;

//INPUT
glob_Dioda1 at %X100.6:BOOL;                                           //svetelna zavora pod otvorem na vlozeni obrobku
glob_Dioda2 at %X100.0:BOOL;                                           //svetelna zavora na dopravniku
glob_Start_Stop at %X100.7:BOOL;                                       //tlacitko start-stop
glob_TrigStolu at %X100.5:BOOL;                                        //tlacitko, ktere stiskava otoc. stul
glob_tlacitkoPist2 at  %X100.4:BOOL;                                   //tlacitko pod lisem
glob_TlacitkoDopravniku at %X100.1:BOOL;                               //tlacitko u dopravniku

pocetVyrobku: UDINT := 0;
pomocnaStav:USINT;
pomPist1:BOOL;
pomPist2:BOOL;
pomPist3:BOOL;

glob_KillSwitch:BOOL;

END_VAR

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_VychoziStav

VAR_INPUT
tlacitko:BOOL;
END_VAR

VAR
stisknuto:BOOL;
nabezna:R_TRIG;
END_VAR

nabezna(CLK := tlacitko,Q => stisknuto);
glob_KillSwitch := glob_KillSwitch XOR stisknuto;

IF stisknuto = TRUE THEN
 pomocnaStav := 0;
END_IF;

IF NOT glob_TrigStolu AND glob_KillSwitch THEN
 glob_MotorStolu := TRUE;
ELSIF glob_TrigStolu AND glob_KillSwitch THEN
 glob_MotorStolu := FALSE;
END_IF;

IF glob_KillSwitch = FALSE THEN
 pomocnaStav:=2;
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_PozicePist1

VAR_INPUT
dioda1:BOOL;
END_VAR

VAR
zapnuto1,zapnuto2,probehlo,pom:BOOL;
zpozdovac1,zpozdovac2:TON;
sestup:F_TRIG;
END_VAR

IF NOT dioda1 THEN
 pomocnaStav:=4;
END_IF;

zpozdovac1(IN := NOT dioda1,PT := T#2s0ms,Q => zapnuto1);

IF zapnuto1 AND glob_TrigStolu and glob_Dioda2 THEN
 glob_Kompresor := TRUE;
 glob_Pist1 := TRUE;
 pomPist1 := TRUE;
 pomocnaStav:=3;
ELSE
 glob_Kompresor := FALSE;
 glob_Pist1 := FALSE;
END_IF;

sestup(CLK := glob_Pist1,Q => probehlo);

IF probehlo THEN;
   pom := TRUE;
ELSIF glob_Start_Stop AND pom THEN
   pom:=FALSE;
END_IF;

zpozdovac2(IN := pom,PT := T#3s0ms,Q => zapnuto2);

IF zapnuto2 and glob_KillSwitch THEN
   glob_MotorStolu := TRUE;
END_IF;

IF glob_tlacitkoPist2 = TRUE THEN
   glob_MotorStolu := FALSE;
   pom := FALSE;
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_PoziceLis

VAR_INPUT
tlacitko:BOOL;
END_VAR

VAR
casovac:TP;
sestup:F_TRIG;
zapnuto,probehlo,pom:BOOL;
END_VAR

IF tlacitko = TRUE THEN
 pomPist2:= TRUE;
 casovac(IN := glob_KillSwitch AND glob_TlacitkoPist2,PT := T#5s0ms,Q => zapnuto);
 glob_Kompresor := zapnuto;
 glob_Pist2 := zapnuto;
 glob_DvojcinnyPist1 := zapnuto;
ELSE
 casovac(IN := FALSE);
END_IF;

sestup(CLK := glob_Pist2,Q => probehlo);

IF probehlo THEN;
 pom := TRUE;
ELSIF glob_Start_Stop AND pom then
 pom:=FALSE;
END_IF;

IF pom AND glob_KillSwitch THEN
 glob_MotorStolu := TRUE;
END_IF;

IF glob_TlacitkoDopravniku = TRUE THEN
 glob_MotorStolu := FALSE;
 pom := FALSE;
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_PoziceDopravnik

VAR_INPUT
tlacitko:BOOL;
END_VAR

VAR
zapnuto,konec,pom:BOOL;
zpozdovac:TON;
nabez:R_TRIG;
END_VAR

IF tlacitko = TRUE THEN
 pomPist3 := TRUE;
 glob_MotorDopravniku := TRUE;
END_IF;

zpozdovac(IN := glob_KillSwitch AND glob_MotorDopravniku AND glob_Dioda2,PT := T#1s,Q => zapnuto);

IF zapnuto = TRUE THEN
 glob_Kompresor := TRUE;
 glob_DvojcinnyPist2 := TRUE;
END_IF;

nabez(CLK:= NOT glob_Dioda2,Q => konec);

IF glob_Dioda2 = FALSE THEN
 glob_MotorDopravniku := FALSE;
END_IF;

IF konec AND pomPist1 AND pomPist2 AND pomPist3 THEN
 pomocnaStav := 1;
 pocetVyrobku := pocetVyrobku + 1;
 pom := TRUE;
END_IF;

IF pom AND glob_Dioda2 THEN
 glob_KillSwitch := FALSE;
 pom := FALSE;
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION kill : BOOL
         glob_Pist1           :=0;
         pomPist1             :=0;
         pomPist2             :=0;
         pomPist3             :=0;
         glob_Pist2           :=0;
         glob_Kompresor       :=0;
         glob_MotorStolu      :=0;
         glob_DvojcinnyPist1  :=0;
         glob_DvojcinnyPist2  :=0;
         glob_MotorDopravniku :=0;
END_FUNCTION

VAR_GLOBAL
 fb_VS : fb_VychoziStav;
 fb_PP : fb_PozicePist1;
 fb_PL : fb_PoziceLis;
 fb_PD : fb_PoziceDopravnik;
END_VAR

PROGRAM prgMain
fb_VS(tlacitko := glob_Start_Stop);
IF glob_killswitch = TRUE THEN
 fb_PP(dioda1 := glob_Dioda1);
 fb_PL(tlacitko := glob_TlacitkoPist2);
 fb_PD(tlacitko := glob_TlacitkoDopravniku);
ELSE
 kill();
END_IF;

END_PROGRAM
