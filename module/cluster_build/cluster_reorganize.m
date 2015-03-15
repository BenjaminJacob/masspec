
function sects=cluster_reorganize(data,val,ovlp)
% Seperates one cluster (data(val,:)) into multiple clusters to ensure the
% paradigm that all members of one clusters originate from different samples.
% The resulting clusters are selected such that the sum over aller
% remaining overlaps between elements of the multiple clusters gets
% maximized
%
%
%INPUT:
%data:
%val: 
%ovlp:
%
%Output:
%sects:



sample=4;


%% sample ids too check -non unique samples
checks=0;  %sample indices of non unique entrys
checkpos=0; %position of non unique sample numbers in cunrrent cluster
n=0;
for i=1:length(val)
    
    if sum(data(val(i:end),sample)==data(val(i),sample))>1 ...%non unique samples (without last double)
            
    n=n+1;
    checks(n)=data(val(i),sample);
    checkpos(n)=i;
    
    end
    
end

%  figure(2)  %uncomment to visualize cluster situation
%  imagesc(ovlp)
%  hold on
%  text(1:length(val),1:length(val),num2str(data(val,sample)))


%%
k=1;
%loop over sample indices to check
for i=1:length(checks)
    
    sect0=0;
    low=0;
    repeat=1;
    loopcount=0;
    sect_best=0;
    
    %interval where to make cut within
    %sect_start=out1b((smpls1==check))+1;
    sect_start=checkpos(i)+1;
    sect_end=checkpos(i)+find(data(val(checkpos(i)+1:end),sample)==checks(i));%next out of same sample
    if isempty(sect_end)
        sect_end=length(val);
    end
    
    
    mes=0;%default mesure for sum
    
    while repeat % -repeat with lowered section conditions in case of no sectionpoint
        
        loopcount=loopcount+1;
        
        if loopcount>10;keyboard;end
        
        %loop for cut position over allowed interval
        for sect=sect_start:sect_end
            
      
           
%             ph=plot([sect sect],[1 length(val)]);
%             
%             
%               pause(1)
%             delete(ph);
%             
            %do not seperate one values (criteria might be lowerd later on when yielding no new clusters)
            if  ~low && ovlp(sect-1,sect)>=0.998;continue;end
            
            
            %Evaluate sectionpoint score
            sect0=max(sect0,1);
            c1=ovlp(sect0:sect-1,sect0:sect-1);%Overlap matrix of first seperated cluster
            c2=ovlp(sect:sect_end,sect:sect_end);    %Overlap matrix of second seperated cluster
            
            if sum(c1(:))+sum(c2(:)) > mes %maximize criteria
                mes=sum(c1(:))+sum(c2(:));%temporary best sum to beat
                sect_best=sect;%best possible section
            end
            
            %in case of two peaks of same sample are neighbours stop when cut is between them
            if sect>1 && data(val(sect-1),sample) == data(val(sect),sample);break;end
            
          
            
        end
    
        
    if exist('c1','var')
        %save best sectionpoint in outputvector
        if ~isempty(c1) && ~isempty(c2) && sect_best
            %determine irst cuts
            sects(k)=sect_best;
            sect0=checkpos(k);
            
                       
        else
            
            sect_best=sect_start;
            sects(k)=sect_start;
            sect0=checkpos(k);
            
        end
    end
    
    
    
    %CHECK for lowering criteria: Allow sepearting connection with one if else no seperation is possible
    if ~sect_best 
        low=1; %lower criteria allow seperating messure 1 connections 0=no
        
    else
        low=0;
        k=k+1;
        repeat=0;
    end
    
    
    end
    
    
    
    
end




% figure(2)
% imagesc(ovlp)
% hold on
% plot(out1b,out1b,'kx','markersize',12,'linewidth',4)
% plot(out2b,out2b,'ko','markersize',12,'linewidth',4)
% text(1:length(val),1:length(val),num2str(data(val,sample)))
% text(out1b,out1b,num2str(data(out1,sample)),'color','yellow');
% text(out2b,out2b,num2str(data(out2,sample)),'color','green');
% for j=1:length(sects)
%     plot([sects(j) sects(j)],[val(1)-val(1) val(end)-val(1)]+1,'r--','linewidth',2)
% end

sects=unique(sects);

del=zeros(1,length(sects));
for j=1:length(sects)-1
    
    %possible to right shift first border
    if length(unique(data(val(1:sects(j+1)-1),sample)))==length(data(val(1:sects(j+1)-1),sample))
        del(j)=1;
        
        %possible to lef shift left borders
    elseif j > 1
        
        start=find(~del(1:j-1),1,'last');
        
        if ~isempty(start)
            
            if length(data(val(sects(start)):val(sects(j+1)-1),sample))==length(unique(data(val(sects(start)):val(sects(j+1)-1),sample)))
                
                del(j)=1;
                
            end
            
        end
        
    end
end

sects(logical(del))=[];

% figure(3)
% clf
% imagesc(ovlp)
% hold on
% % plot(out1b,out1b,'kx','markersize',12,'linewidth',4)
% % plot(out2b,out2b,'ko','markersize',12,'linewidth',4)
% text(1:length(val),1:length(val),num2str(data(val,sample)))
% % text(out1b,out1b,num2str(data(out1,sample)),'color','yellow');
% % text(out2b,out2b,num2str(data(out2,sample)),'color','green');
% for j=1:length(sects)
%     plot([sects(j) sects(j)],[val(1)-val(1) val(end)-val(1)]+1,'r--','linewidth',2)
% end
% keyboard
% pause(1)
%close(3)