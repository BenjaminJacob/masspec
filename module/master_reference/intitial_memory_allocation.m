function [l_data,data2,l_data2,data2_uncrtn,l_data2_uncrtn...
    p_asgnd_num,p_asgnd_txt,l_p,p_uncrt_num,p_uncrt_txt,l_uncrt,no_refs,i_no_refs block p_block p_cellblock l_block l_p_block]=intitial_memory_allocation(data,probe_size,nmaster)    

    %memory Management - Matritzen/Cells allocating (later on dynamical growth) -----------------------------------------
    l_block=round(size(data,1)/10);
    block=zeros(l_block,3+probe_size);
    %Vorinitialisieren 'sheet 1' Probeninfos und zuordnung
    l_data=length(data);
    data2=zeros(2*l_block,3+probe_size);    %Massen und Intensitäten
    l_data2=2*l_block;
    data2_uncrtn=block;
    l_data2_uncrtn=l_block;
    
    %Vorinitialisieren 'sheet 2' Wahrscheinlichketen
    l_p_block=round(size(data,1)/5);
    p_block=zeros(l_p_block,4+nmaster*4);
    p_cellblock=cell(l_p_block,1+nmaster*4);
    p_asgnd_num=zeros(2*l_p_block,4+nmaster*4);%numerisch: für Probe c p_relaitv und je Masster Overlay
    p_asgnd_txt=cell(2*l_p_block,1+nmaster*4);
    l_p=l_p_block*2;
    p_uncrt_num=p_block;
    p_uncrt_txt=p_cellblock;
    l_uncrt=l_p_block;
    %----------------------------------------------------------------------
    %-
    %Sammelmatrix für die Clusterung nicht masterreferenzierbarer Dateien
    no_refs=zeros(5*l_block,1,'int32');
    i_no_refs=1;