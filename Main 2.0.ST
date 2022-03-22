VAR_GLOBAL

//OUTPUT
glob_Pist1 at %Y33.1:BOOL;                                             //pist pod otvorem na vlozeni obrobku
glob_Pist2 at %Y33.0:BOOL;                                             //pist pro lisovani obrobku
glob_Kompresor at %Y33.2:BOOL;                                         //kompresor
glob_MotorStolu at %Y32.5:BOOL;                                        //motor otocneho stolu
glob_DvoucinnyPist1 at %Y32.6:BOOL;                                    //vysunuti dvoucinneho pistu nad dopravnikem
glob_DvoucinnyPist2 at %Y32.7:BOOL;                                    //zasunuti dvoucinneho pistu nad dopravnikem
glob_MotorDopravniku at %Y32.4:BOOL;

//INPUT
glob_Dioda1 at %X100.6:BOOL;                                           //svetelna zavora pod otvorem na vlozeni obrobku
glob_Dioda2 at %X100.0:BOOL;                                           //svetelna zavora na dopravniku
glob_Start_Stop at %X100.7:BOOL;                                       //tlacitko start-stop
glob_TrigStolu at %X100.5:BOOL;                                        //tlacitko, ktere stiskava otoc. stul
glob_tlacitkoPist2 at  %X100.4:BOOL;                                   //tlacitko pod lisem
glob_TlacitkoDopravniku at %X100.1:BOOL;                               //tlacitko u dopravniku

pocetVyrobku: UDINT := 0;
pomSTTrig: USINT := 0;
pomocnaStav:USINT;

glob_KillSwitch:BOOL;

END_VAR

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_VychoziStav                                          //pocatecni funkce pro nastveni stolu na vychozi pozici

VAR_INPUT
talcitko:BOOL;
END_VAR

VAR_OUTPUT
vystup:BOOL;
END_VAR

VAR
stisknuto:BOOL;
nabezna:R_TRIG;
END_VAR

nabezna(CLK := talcitko,Q => stisknuto);

glob_KillSwitch := glob_KillSwitch XOR stisknuto;

IF glob_TrigStolu = FALSE AND glob_KillSwitch = TRUE THEN
vystup := TRUE;
ELSIF glob_TrigStolu = TRUE THEN
vystup := FALSE;
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_VypnouLinku                                           //funkce pro vypinani cele linky

VAR_INPUT
talcitko:BOOL;
END_VAR

VAR_OUTPUT
vystup:BOOL;
END_VAR

VAR
stisknuto:BOOL;
nabezna:R_TRIG;
END_VAR

nabezna(CLK := talcitko,Q => stisknuto);

vystup := vystup XOR stisknuto;

IF vystup = FALSE THEN
pomocnaStav:=4;                                                        //obrazuje na display PLC "Pozastaveno"
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_PozicePist1

VAR_INPUT
dioda1:BOOL;
dioda2:BOOL;
END_VAR

VAR_OUTPUT
vystup1:BOOL;
vystup2:BOOL;
vystup3:BOOL;
END_VAR

VAR
zapnuto:BOOL;
zpozdovac:TON;
END_VAR

zpozdovac1(IN := glob_KillSwitch AND glob_TrigStolu AND NOT dioda1 AND dioda2,PT := T#2s,Q => zapnuto);
vystup1 := zapnuto;
vystup2 := zapnuto;
zpozdovac2(IN := glob_KillSwitch AND dioda1 AND dioda2 AND NOT glob_TlacitkoPist2,PT := T#3s,Q => vystup3);

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

FUNCTION_BLOCK fb_PoziceLis

VAR_INPUT
tlacitko:BOOL;
END_VAR

VAR_OUTPUT
vystup1:BOOL;
vystup2:BOOL;
vystup3:BOOL;
END_VAR

VAR
zapnuto:BOOL;
zpozdovac:TON;
END_VAR

IF tlacitko = TRUE THEN
zpozdovac(IN := glob_KillSwitch AND glob_TlacitkoPist2,PT := T#5s,Q => zapnuto);
vystup1 := zapnuto;
vystup2 := zapnuto;
vystup3 := zapnuto;
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

fb_PoziceDopravnik

VAR_INPUT
pist:BOOL;
END_VAR

VAR_OUTPUT
vystup:BOOL;
END_VAR

VAR
vypnut,zapnuto:BOOL;
zpozdovac:TON;
sestupna:F_TRIG;
nabezna:R_TRIG;
END_VAR

sestupna(CLK := pist,Q => vypnut);

IF vypnut = TRUE THEN
glob_MotorStolu := TRUE;
ELSIF glob_TlacitkoDopravniku = TRUE THEN
glob_MotorStolu := FALSE;
END_IF;

zpozdovac(IN := glob_KillSwitch AND glob_TlacitkoDopravniku AND glob_Dioda2,PT := T#1s,Q => vystup);

nabezna(CLK := vystup,Q => zapnuto);

IF zapnuto AND glob_Dioda2 THEN
glob_Kompresor := FALSE;
glob_MotorDopravniku := TRUE;
ELSIF glob_KillSwitch AND NOT glob_Dioda2 THEN
glob_MotorDopravniku := FALSE;
//pocetVyrobku:= pocetVyrobku + 1;
pomocnaStav:=2;                                                        //zobrazuje na display PLC "Odeberte obrobek"
END_IF;

END_FUNCTION_BLOCK
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

PROGRAM Main

fb_VychoziStav(glob_Start_Stop := tlacitko,vystup := glob_MotorStolu);
fb_VypnouLinku(glob_Start_Stop := tlacitko,vystup := glob_KillSwitch);
fb_PozicePist1(glob_Dioda1 := dioda1,glob_Dioda2 := dioda2,glob_Kompresor := vystup1,glob_Pist1 := vystup2,glob_MotorStolu := vystup3);
fb_PoziceLis(glob_TlacitkoPist2 := tlacitko,glob_Kompresor := vystup1,glob_Pist2 := vystup2,glob_DvoucinnyPist1 := vystup3);
fb_PoziceDopravnik(glob_Pist2 := pist,);

END_PROGRAM
