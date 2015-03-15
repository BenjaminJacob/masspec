function [data2 p_asgnd_num p_asgnd_txt row row_p p_rel no_refs i_no_refs]=assign_data(master_data,i_master,mu_master,sig_master,master_formulas,match,...
            data,i_data,mu_data,sig_data,i,...
            data2,row,dest_col,id_range,p,row_p,choice,p_asgnd_num,p_asgnd_txt,l_p,no_refs,i_no_refs)
           
        [~,intens,~]=set_column_index;
        
        row0=row;
                
                %Neue Master Referenz ? -> Neue Zeile anlegen !
                if row==0 || master_data(match(choice(1)),1)>data2(row,1)
                    %Zeile Zaehlen (weiter nur wenn belegt)
                    row=row+1;
                    row0=row0+1;
                    
                    %Problem übereinstimmung mit vorheriger zeile
                elseif row > 1 && master_data(match(choice(1)),1)==data2(row-1,1)
                    row=row-1;      %Zeile vorher nehmen
                    
                    %Zeile zwischen fügen
                elseif master_data(match(choice(1)),1)<data2(row,1)
                    row0=row0+1;
                    data2(row0,:)=data2(row,:);
                    data2(row,1)=master_data(match(choice(1)));
                    data2(row,2:end)=0;
                    
                end
                
                %Wenn bereits Match aus selber Probe nimm/behalte den mit größerem Overlay
                if data2(row,dest_col(i))
                 
                    i_vgl=find(p_asgnd_num(1:min(i,l_p),1)==data2(row,dest_col(i)));%changed to last
                    
                    %Neuer Wert Besser
                    if max(p) >= max(p_asgnd_num(i_vgl(1),5:4:end),[],2)
                        no_refs(i_no_refs)=data2(row,dest_col(i));
                        i_no_refs=i_no_refs+1;
                        
                        %Zeile neu berechnen
                        data2(row,dest_col(i))=i;
                        
                        %Alter Wert besser
                    else
                        no_refs(i_no_refs)=i;
                        i_no_refs=i_no_refs+1;
                        row=row0;
                        p_rel=0;
                        return
                    end
                    
                end
        
        
        
        
                %Ordne informationen zu
                p_rel=p(choice(1))/sum(p);                                                        %Relative Wahrscheinlichkeit
                
                %Probe-Master infos
                data2(row,1)= mu_master(choice(1));                                               %Master Masse
                data2(row,dest_col(i))=i;                                                       %Inensität
                
                %Proben-Master Wahrscheinlichkeitsrelationen
                p_asgnd_num(row_p,1:4)=[i mu_data sig_data p_rel ];
                p_asgnd_txt(row_p,1)=id_range(dest_col(i)-3);
                
                %Infos zu (mehreren) möglichen Mastern
                p_asgnd_num(row_p,5:4:4+4*length(mu_master))=p;                                 %Overlays
                p_asgnd_num(row_p,6:4:5+4*length(mu_master))=i_master;                          %Intensitäten
                p_asgnd_num(row_p,7:4:6+4*length(mu_master))=mu_master;                         %Massen
                p_asgnd_num(row_p,8:4:7+4*length(mu_master))=sig_master;                        %std's
                
                i_form=1+(1:length(mu_master));
                p_asgnd_txt(row_p,i_form)=master_formulas(match(i_form-1));%Formeln
                
                
                %Zeilen Zählen
                row_p=row_p+1;
                row=row0;