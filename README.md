# Zadání
## Pneumatické obráběcí centrum

a) Cílem práce je realizovat připojení sestavené stavebnice pneumatické obráběcí centrum Fischertechnik 24V k PLC Tecomat Foxtrot a naprogramovat obsluhu pracoviště podle následujících kroků.

b) Polohu otočného pracovního stolu kontrolujeme pomocí tří koncových spínačů – výchozí poloha „připraven“, poloha „lis“ a koncová poloha „dopravník“. Přítomnost obrobku ve vstupní komoře je indikována pomocí světelné závory. Dojetí obrobku na konec dopravníku je indikováno také světelnou závorou. Model má tlačítko Start/Stop.

c) Po spuštění program čeká na stisk tlačítka Start/Stop. Po jeho stisknutí se kontroluje, zda pracovní stůl je ve výchozí poloze (pokud ne, tak se do ní otočí) a pak se na displeji PLC objeví nápis „Vložte obrobek“ a počet obrobků, které již byly zpracovány (0 až 99). Dále program čeká na vložení obrobku do vstupní komory a současně testuje, zda na výstupním dopravníku není neodebraný předchozí obrobek (čeká na jeho odebrání). Po vložení zhasne nápis na displeji PLC a následuje prodleva 2s. Po ní je obrobek pístem vysunut na otočný stůl. Následuje prodleva 3s a pak se stůl otočí do pracovní pozice „lis“. Zde je na 5s aktivován pohon lisu. Potom se pracovní stůl otočí do pozice „dopravník“. Dále se rozjede dopravník a po 1s se na dopravník vysune obrobek. Až tento dojede k světelné závoře na dopravníku, tak se dopravník zastaví, inkrementuje se počet zpracovaných obrobků a obrobek se odebere z dopravníku. Potom se pracovní stůl otočí zpět do výchozí pozice a program opět čeká na stisk tlačítka Start/Stop pro opakování celého procesu.

d) Běží-li proces, lze jej kdykoliv zastavit tlačítkem Start/Stop. Po jeho stisknutí se všechny akční členy zastaví a program čeká na ruční odebrání obrobku. Dále program čeká na další stisknutí tlačítka Start/Stop pro zpracování dalšího obrobku. Obrobek, jehož zpracování bylo zastaveno se do opracovaných obrobků nepočítá.

# Licence
Veškerý obsah na této stránce je licencován pod Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License
![Test](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png)
