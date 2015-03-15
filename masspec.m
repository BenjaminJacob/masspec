%% masspec frontend calls main program
%
% Programm call
%       a) without input arguments -> start gui version
%       b) with input arguments -> non-gui version with settings set from input arguments

%call
%masspec('C:\Users\user\Desktop\Benjamin\masspec7\testcase\samples',...
    %'C:\Users\user\Desktop\Benjamin\masspec7\testcase\assigned',...
    %'C:\Users\user\Desktop\Benjamin\masspec7\testcase\master\Nelha red Masterlist 20110211.xlsx',...
    %3,0.9,0.5,50,1)

function masspec(sample_dir,assigned_dir,masterlist,tol,psave,pcrit,nsamples,overlap)

addpath(genpath('GUI'));
addpath(genpath('module'));

if nargin==0 %START GUI %
     
    
    handles.gui=1;
    masspec_GUI
     
elseif nargin==8 % START NON GUI VERSION
    handles.sample_dir=sample_dir;     % arg 1) directory where sample files reside
    handles.assigned_dir=assigned_dir; % arg 2) directory where to save output
    handles.masterlist=masterlist;     % arg 3) path to masterlist file
    handles.tol=tol;                   % arg 4) tolerance window for preselction [multiples of sample standard deviation]
    handles.psave=psave;               % arg 5) min. overlap score implying secure match
    handles.pcrit=pcrit;               % arg 6) min. overlap score implying possible match
    handles.wndw_sze=nsamples;         % arg 7) number of simultaniously prcessed sample-xlsx files [memory vs cpu]
    handles.overlap=overlap;           % arg 8) Overlap Score to Base decision On
    %Overlap =1) default score without intensity > peak height irrelevant score between [0 1]
    %Overlap =2) default with intensity  -> non normalized sccore NOT USE YET
    handles.workdir=pwd;
    hObject=[];
    eventdata=[];
    handles.gui=0;
    
    main(hObject,eventdata, handles) %start programm
    
else  %wrong number of input arguments
  return
end
end