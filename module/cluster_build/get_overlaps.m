function ovlp_part=get_overlaps(I,val,hI,hJ,hO,pos0,pos1)
% Extracts Overlaps for current cluster from global Overlapmatrix (Overlaps between all samples)
% and stores them in partial overlapmaitrix (ovlp_part)
%
%INPUT
%I
%val: range of row indices  - identifying given cluster
%hI: file identifier for row indices (I) of cluster members
%hJ: file identifier for column indices (J) of cluster members
%hO: file identifier for Overlaps (O) of cluster members  (peak I and peak J have overlapscore O )
%pos0: position in row marking beginning of cluster
%pos1:             marking beginning end of cluster
%
%OUTPUT:
% ovlp_part: Overlapmatrix of overlapscores between peaks of given cluster

fstart=pos0;
fseek(hI,(pos0-1)*8,'bof');%Int32
del=[];
count=0;
while fread(hI,1,'double') < val(1)
    count=count+1;
    del=[del count]; 
end
I(del)=[];
fstart=fstart+count;

file_entry=I(end);
fseek(hI,(pos1)*8,'bof');%Int32
fend=pos1;
l_append=0;
while I(end)==file_entry
file_entry=fread(hI,1,'double');
l_append=l_append+(pos1==file_entry);
end

%Append elements of same row i where j > i
fend=fend+l_append;
fseek(hI,(pos1)*8,'bof');
I(end+1:l_append)=fread(hI,l_append,'double');


%fstart=find(I>=min(val), 1, 'first' );
%fend=find(I<=max(val), 1, 'last' );
fseek(hJ,(fstart-1)*8,'bof');%Int32
fseek(hO,(fstart-1)*8,'bof');
Js=fread(hJ,(fend-fstart+1),'double');
Os=fread(hO,(fend-fstart+1),'double');

% %allow collumns j > row i
% maxcol=max(Js-I(fstart)+1);
% ovlp_part=sparse(I(fstart:fend)-I(fstart)+1,Js-I(fstart)+1,Os,val(end)-val(1)+1,maxcol,length(Js));

%reduce selection to row count to reduce fractal character
%Is=I(fstart:fend)-I(fstart)+1;
Is=I-I(1)+1;
% Is(Js>val(end))=[];
% Os(Js>val(end))=[];
% Js(Js>val(end))=[];

%maxcol=max(Js-I(fstart)+1);
maxcol=max(Js-I(1)+1);%here I is only a part of all I because I was save to file to save memory
%ovlp_part=sparse(Is,Js-I(fstart)+1,Os,val(end)-val(1)+1,maxcol,length(Js));
ovlp_part=sparse(Is,Js-I(1)+1,Os,val(end)-val(1)+1,maxcol,length(Js));
%ovlp_part=sparse(Is,Js-I(fstart)+1,Os,val(end)-val(1)+1,maxcol,length(Js));
% figure(2)
% imagesc(ovlp_part);
% keyboard
%ovlp_part=sparse(I(fstart:fend)-I(fstart)+1,Js-I(fstart)+1,Os,val(end)-val(1)+1,maxcol,length(Js));
%val(end)-val(1)+1 statt maxcol