VAR_GLOBAL

//OUTPUT
Pist1 at %Y33.1:BOOL;                                                  //pist pod otvorem na vlozeni obrobku
Pist2 at %Y33.0:BOOL;                                                  //pist pro lisovani obrobku
kompr at %Y33.2:BOOL;                                                  //kompresor
MotorStolu at %Y32.5:BOOL;                                             //motor otocneho stolu
DvoucinnyPist1 at %Y32.6:BOOL;                                         //vysunuti dvoucinneho pistu nad dopravnikem
DvoucinnyPist2 at %Y32.7:BOOL;                                         //zasunuti dvoucinneho pistu nad dopravnikem
MotorDopravniku at %Y32.4:BOOL;

//INPUT
Dioda1 at %X100.6:BOOL;                                                //svetelna zavora pod otvorem na vlozeni obrobku
Dioda2 at %X100.0:BOOL;                                                //svetelna zavora na dopravniku
StartStop at %X100.7:BOOL;                                             //tlacitko start-stop
tlacitkoStolu at %X100.5:BOOL;                                         //tlacitko, ktere stiskava otoc. stul
tlacitkoPist2 at  %X100.4:BOOL;                                        //tlacitko pod lisem
tlacitkoDopravniku at %X100.1:BOOL;                                    //tlacitko u dopravniku
pocetVyrobku: UDINT := 0;
pomSTTrig: USINT := 0;
pomocnaStav:USINT;
//prnt at %R1:array[0..79] of USINT;
END_VAR

PROGRAM prgMain

VAR

data:TIME;
nabez1,nebezHotovo:R_TRIG;
sestup1:F_TRIG;
SestupPist2:F_TRIG;
SestuptlacitkoDopravniku:F_TRIG;
Casovac1,Casovac2:TOF;
Zpozdovac1,Zpozdovac2,Zpozdovac3,Zpozdovac4:TON;
pomStart,pomPist1,pomPist2,pomMotorS,pom1,pom3,pom5,pom6,pom7,pom9,pom10,pom11,pom12,pom13,pom14,pom15,pom16,pom17,pom18,pomZap,pomses,pomStop,pomPist1kon,pomZpozdeni,pomHotovo,pomHotovo2,pomHotovo3,pomDonePist1,pomTlacPist2,pomTlacDoublePist3,pomNeco,pomPozastav:BOOL; //pomocne promenne
END_VAR

if pomStart = false then
pomocnaStav:=0;                                                       //zobrazuje na display PLC "Stisknete tlacitko"
pomHotovo2:=false;                                                    //nuluje mezipamet
end_if;

nabez1(CLK:=StartStop,Q=>pom1);

if pom1 then
pomStart:=pomStart xor pom1;                                           //vypinani a zapinani linky
pomocnaStav:=1;                                                        //zobrazuje na display PLC "Vlozte obrobek"
pomSTTrig:=pomSTTrig + 1;
end_if;

(*if (pomSTTrig MOD 2)=0 then;                                         //kazde druhe stisknuti spusti podminku
pomocnaStav:=4;                                                        //obrazuje na display PLC "Pozastaveno"
pomPozastav:=true;                                                     //zaznam o pozastaveni linky
pomSTTrig:=1;
end_if;  *)

if tlacitkoStolu = false and pomStart = true then MotorStolu:= true;   //pocatecni podminka pro nastveni stolu na vychozi pozici
elsif tlacitkoStolu = true then MotorStolu:= false;
end_if;

if not Dioda1 and pomStart and Dioda2 then                             //podminka pro spusteni Pist1, kdyz je vlozen obrobek a je odebrán obrobek z dopravníku
pom10:= true;                                                          //pomocna pro zaznamenani aktivace casovace se zpozdenim 2s

elsif Pist1 = true then
//pomocnaStav:=0;
pom7:= true;                                                           //pomocna pro zaznamenani aktivace Pist1
pomDonePist1:=true;

elsif pom10 and pom7 and pomStart then                                 //pokud probehl casovac (Zpozdovac1) se spozdenim 2s a Pist1 se vysunul
pomMotorS:= not tlacitkoPist2 and Dioda1 and pomStart;                 //pomocna pro spusteni casovace Zpozdovac2
MotorStolu:= pom5;                                                     //zapinani motoru otocneho stolu
pom12:= true;                                                          //zaznamenani o probehlem otoceni stolu
end_if;

Zpozdovac1(IN:= not Dioda1 and pomStart and Dioda2 and tlacitkoStolu,PT:= T#2s,Q=>pom3,ET=>data);//zpozdeny start 2s
kompr:= pom3;                                                          //zapnuti kompresoru
Pist1:= kompr;                                                         //zapnuti pneumatickeho lisu (Pist1), ktery vysune obrobek na otocny stul

if Pist1 = true then                                                   //blbuvzdornost pri startu Pistu2
pomPist1kon:= true;                                                    //zaznamenani akce do pameti
end_if;

Zpozdovac2(IN:= pomMotorS,PT:= T#3s,Q=>pom5,ET=>data);                 //zpozdeny start 3s
if pom5 = true then
pomZpozdeni:= true;
end_if;

if tlacitkoPist2 and pomStart and pomPist1kon then                     //pokud je stisknuto tlacitkoStolu, motor otoc. stolu se zastavi
kompr:= not pom9;                                                      //zapnuti kompresoru
Pist2:= not pom9;                                                      //zapnuti pneumatickeho lisu (Pist2), ktery stalci obrobek
DvoucinnyPist1:= not pom9;                                             //zapnuti dvoucinneho pneumatickeho lisu (DvoucinnyPist1)
DvoucinnyPist2:=false;                                                 //nulovani dvoucinneho pneumatickeho lisu (DvoucinnyPist2)
pom11:= true;                                                          //zaznamenani o probehlem spusteni pistu (Pist2)
pom10:=false;                                                          //blokace motoru otoc. stolu
pom7:=false;                                                           //blokace motoru otoc. stolu
pomTlacPist2:=true;                                                    //zaznamenani akce do pameti
end_if;

Zpozdovac3(IN:= tlacitkoPist2 and pomStart,PT:= T#5s,Q=>pom9,ET=>data);//zpozdene zapnuti 5s

SestupPist2(clk:=Pist2,Q=>pom13);                                      //zaznamenani sestupne hrany, kdyz Pist2 se vypne

if pom13 = true then                                                   //pokud byl Pist2 vypnut spusti se podminka
pom14:= true;
end_if;

if pom11 and pom14 and not tlacitkoDopravniku and pomStart then        //pokud byl Pist2 spusten a nasledne vypnut spusti se podminka pro zapnuti otoc. stolu do doby nez se dotkne tlacitkoDopravniku
MotorStolu:=true;

elsif pom17 and pomStart and Dioda2 then                               //zda-li obrobek stiskl tlacitoStolu
kompr:=true;
DvoucinnyPist1:=false;                                                 //zapnuti kompresoru
DvoucinnyPist2:= true;                                                 //zapnuti dvoucinneho pneumatickeho lisu (DvoucinnyPist2)
pomTlacDoublePist3:=true;                                              //zaznamenani akce do pameti
pom11:=false;
pom14:=false;                                                          //blokace predchozi podminky, aby se znovu nespustil otoc. stul, kdyz obrobek uz netlaci na tlacitkoStolu
pom16:=true;                                                           //zaznam o probehle akci
end_if;

Zpozdovac4(IN:= tlacitkoDopravniku,PT:= T#1s,Q=>pom15,ET=>data);       //ceka 1s na presun obrobku na dostavnik
pom17:=pom15;

if pom16 and Dioda2 and pomStart then                                  //spusti motorDopravniku do doby, kdy obrobek nedojede do svetelnou zavorou (Dioda2)
MotorDopravniku:= true;

SestuptlacitkoDopravniku(clk:=tlacitkoDopravniku,Q=>pom18);            //zaznam sestupne hrany

elsif pom18 then                                                       //pote co se obrobek odebere na pas, vypne kompresor
kompr:=false;

elsif not Dioda2 then                                                  //kdyz obrobek stoji ve svetelne zavore, tak vypina motor dopravniku a kompresor
MotorDopravniku:= false;
pom16:=false;
pom6:=pomHotovo;
end_if;

nebezHotovo(clk:= not Dioda2,Q=>pomHotovo);                            //1 zaznam o vyskytu obrobku ve druhe svetelne zavore (Dioada2)

if pom6 and pomTlacDoublePist3 and pomTlacPist2 and pomDonePist1 and not Dioda2 and not pomPozastav then
pocetVyrobku:=pocetVyrobku+1;                                          //pripocteni +1 k obrobenych obrobku
pomocnaStav:=2;                                                        //zobrazuje na display PLC "Odeberte obrobek"
pomHotovo2:=true;
end_if;

*(if pomStart and pomPozastav then
pomocnaStav:=2;
pomHotovo2:=true;
end_if;*)

if pomHotovo2 and Dioda2 then                                          //nulovani pameti
pomStart:=false;
pomTlacDoublePist3:=false;
pomTlacPist2:=false;
pomDonePist1:=false;
pomHotovo3:=true;
pomPozastav:=false;
end_if;

(*if pomHotovo3 and Dioda1 then
pomocnaStav:=1;
pomHotovo2:=false;
end_if;*)

if pomStart and not Dioda1 then                                        //zobrazuje na display PLC "_"
pomocnaStav:=3;
end_if;

(*if pom6 = true then
pomStart:=false;
pomocnaStav:=0;
end_if;*)

END_PROGRAM
