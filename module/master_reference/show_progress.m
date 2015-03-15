function [tt ti itot0 verbrauch]=show_progress(i,l_data,tt,mnpknmbr,verbrauch,ti,itot0,hw,wndw,wndws,ndata)

%i: nr of current sample
%(toc-tt): time since last time evaluation
%verbrauch: avergae time per f_measure samples
%ti: timestep count in f_measure samples
%itot: number of already processed peaks
%ndata: number of sample files
%mnpknmbr: average number of samples per file
%hw: waitbar handle
    
 f_measure=5000; %frequency of time evaluation in samples

        %progressbar and time estimation
        if ~mod(i,f_measure) || i==l_data

           

            %progress
            cont{3}=['match peaks: window ' num2str(wndw) '/' num2str(wndws)];
           
            verbrauch=((toc-tt)+verbrauch*ti)/(ti+1);
            tt=toc;
            itot=itot0+i;
            left=(verbrauch/f_measure*(mnpknmbr*ndata-itot));%time per sample * (nr of samples left)
            leftmin=floor(left/60);
            leftsec=round(left-leftmin*60);
            disp(['Step time left: ' num2str(leftmin) ' min ' num2str(leftsec) ' s']);
            waitbar(i/(l_data),hw,cont)
            ti=ti+1;
        end