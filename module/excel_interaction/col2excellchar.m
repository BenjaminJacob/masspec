function colchar=col2excellchar(col)

if col<=26 %1 Buschstabe in excel
colchar=char(col+64);
    
elseif col<=702 %2Buchstaben in excel
n=floor(col/26);
m=mod(col,26);
r=col-(n-(m==0))*26;
char2=char(64+r);
char1=char(n+65-1-(m==0));
colchar=[char1 char2];%regionende unten rechts

    else   %3 Buchstaben in excel

n1=floor((col-26-1)./(26*26));% stelle 1 und 2 durhclaufen +ZZ
u2626=col-26-1-n1*26*26;
n2=mod(floor(u2626/26),26);
n3=mod(u2626,26);
char1=char(64+n1);        
char2=char(65+n2);
char3=char(65+n3);
colchar=[char1 char2 char3];%regionende unten rechts

end