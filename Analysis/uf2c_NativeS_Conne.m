function varargout = uf2c_NativeS_Conne(varargin)
% UF�C M-file for uf2c_NativeS_Conne.fig
% UF�C - User Friendly Functional Connectivity
% Brunno Machado de Campos
% University of Campinas, 2017
%
% Copyright (c) 2017, Brunno Machado de Campos
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @uf2c_NativeS_Conne_OpeningFcn, ...
                   'gui_OutputFcn',  @uf2c_NativeS_Conne_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

warning('off','all')

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end

function uf2c_NativeS_Conne_OpeningFcn(hObject, eventdata, handles, varargin)
global PsOri ps
ps = parallel.Settings;
PsOri = ps.Pool.AutoCreate;

handles.output = hObject;
guidata(hObject, handles);

function varargout = uf2c_NativeS_Conne_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function AddFunc_Callback(hObject, eventdata, handles)
global fileFunc pathFunc numofVoluF nOFsubjects matrixF VoxSizeF

if ~get(handles.FazPrep,'Value') 
    set(handles.checkReg,'Enable','on')
end

try
    clear('regVets');
end
try
    delete([tmpDIR 'additional_Reg.mat']);
end

[fileFunc,pathFunc] = uigetfile({'*.nii','NIfTI files';'*.img','ANALIZE files'},'Select all the functional images','MultiSelect','on');

if ~isequal(fileFunc,0)
    
    set(handles.txtFunc,'String','Analyzing files. Wait....')
    drawnow

    if ~iscell(fileFunc)   % CREATING A CELL VARIABLE FOR SINGULAR INPUTS
        fileFunc = {fileFunc};
    end
    fileFunc = sort(fileFunc); % SORT FILES IN THE ALPHABETIC ORDER
    nOFsubjects = size(fileFunc,2);

    for yt = 1:nOFsubjects
        tmpDir = dir([pathFunc fileFunc{yt}]);
        bitS(yt) = tmpDir.bytes;
    end
    sxs = unique(bitS);
    nDiftypes = size(sxs,2);
    if ~isequal(nDiftypes,1)
        warndlg({sprintf('There are %d distinct protocol types among the functional images that you added.',nDiftypes);...
          sprintf('Check the size of your files, it is the easiest way to identify the protocol homogeneity');'We can continue, but some errors and/or interpolations with distinct weights can occur.'},'Attention!');
    end
    clear bitS

    set(handles.txtFunc,'String',sprintf('%d functional image(s) added',nOFsubjects))
    drawnow

    previewF = nifti([pathFunc fileFunc{1}]);
    matrixF = previewF.dat.dim(1:3);
    numofVoluF = previewF.dat.dim(4);
    VoxSizeF = previewF.hdr.pixdim(2:4);
    VoxS_Res = [num2str(VoxSizeF(1,1)),'x',num2str(VoxSizeF(1,2)),'x',num2str(VoxSizeF(1,3))];
    MatS_Res = [num2str(matrixF(1,1)),'x',num2str(matrixF(1,2)),'x',num2str(matrixF(1,3))];

    set(handles.numDyna,'String',numofVoluF)
    set(handles.wsIn,'Enable','on')
    set(handles.wsIn,'String',numofVoluF)
    set(handles.SizeVoxFunc,'String',VoxS_Res)
    set(handles.SizeMatFunc,'String',MatS_Res)
    set(handles.txtregress,'String','0 added')
    set(handles.checkReg,'Value',0)
    set(handles.pushbutton6,'Enable','on')
    
    if get(handles.FazPrep,'Value') && get(handles.AddROIm,'Value')
        set(handles.Run,'Enable','on')
    end
    clear previewF
end

function AddStru_Callback(hObject, eventdata, handles)
global fileStru pathStru matrixS VoxSizeS

[fileStru,pathStru] = uigetfile({'*.nii','NIfTI files';'*.img','ANALIZE files'},'Select all the Structural images','MultiSelect','on');

if ~isequal(fileStru,0)
    if ~iscell(fileStru)   % CREATING A CELL VARIABLE FOR SINGULAR INPUTS
        fileStru = {fileStru};
    end

    fileStru = sort(fileStru);

    for yt = 1:size(fileStru,2)
        tmpDir = dir([pathStru fileStru{yt}]);
        bitS(yt) = tmpDir.bytes;
    end
    sxs = unique(bitS);
    nDiftypes = size(sxs,2);
    if ~isequal(nDiftypes,1)
        warndlg({sprintf('There are %d distinct protocol types among the structural images that you added.',nDiftypes);...
          sprintf('Check the size of your files, this is the easiest way to check the protocol homogeneity');'We can continue, but some errors and/or interpolations with distinct weights can occur.'},'Attention!');
    end
    clear bitS

    set(handles.txtstru,'String',sprintf('%d Structural image(s) added',size(fileStru,2)))

    previewS = nifti([pathStru fileStru{1}]);
    matrixS = previewS.dat.dim;
    VoxSizeS = previewS.hdr.pixdim(2:4);

    VoxS_Res = [num2str(VoxSizeS(1,1)),'x',num2str(VoxSizeS(1,2)),'x',num2str(VoxSizeS(1,3))];
    MatS_Res = [num2str(matrixS(1,1)),'x',num2str(matrixS(1,2)),'x',num2str(matrixS(1,3))];

    set(handles.edit9,'String',num2str(VoxS_Res))
    set(handles.edit10,'String',num2str(MatS_Res))
    set(handles.pushbutton7,'Enable','on')
    clear previewS
end

function AddROIm_Callback(hObject, eventdata, handles)
global VoxSizeF pathROI matrixF VoxSizeS matrixS nOfClust fileROI

if get(handles.AddROIm,'Value')
    
    [fileROI,pathROI] = uigetfile({'*.nii','NIfTI files'},'Select 3D ROI masks','MultiSelect','on');
    
    if ~isequal(fileROI,0)
        if ~iscell(fileROI)   % CREATING A CELL VARIABLE FOR SINGULAR INPUTS
            fileROI = {fileROI};
        end
        fileROI = sort(fileROI);
        previewF2 = nifti([pathROI fileROI{1}]);
        ROImaskMAt = previewF2.dat(:,:,:);
        nOfClust = unique(ROImaskMAt);
        nOfClust = nOfClust(2:end);
        matrixF2 = previewF2.dat.dim(1:3);
        VoxSizeF2 = previewF2.hdr.pixdim(2:4);

        if get(handles.AliFunc,'Value')
           if isequal(matrixF2,matrixF) && isequal(round(double(VoxSizeF2),2),round(double(VoxSizeF),2))
               set(handles.text7,'String',sprintf('%d ROIs File(s) added!',size(fileROI,2)))
               set(handles.textNETS,'String',sprintf('%d ROIs in the mask!',size(nOfClust,1)))
               set(handles.Run,'Enable','on')
           else
               warndlg('The ROI mask added do not match to the native functional image parameter!', 'Ops!');
               set(handles.AddROIm,'Value',0)
               set(handles.Run,'Enable','off')
           end
        end
        
        if get(handles.AliStru,'Value')
           if isequal(matrixF2,matrixS) && isequal(round(double(VoxSizeF2),2),round(double(VoxSizeS),2))
               set(handles.text7,'String',sprintf('%d ROIs File(s) added!',size(fileROI,2)))
               set(handles.textNETS,'String',sprintf('%d ROIs per mask!',size(nOfClust,1)))
               set(handles.Run,'Enable','on')
           else
               warndlg('The ROI mask added do not match to the native structural image!', 'Ops!');
               set(handles.AddROIm,'Value',0)
               set(handles.Run,'Enable','off')
           end
        end
    else
        set(handles.AddROIm,'Value',0)
    end
else
    set(handles.text7,'String','')
    set(handles.textNETS,'String','')
end

function checkReg_Callback(hObject, eventdata, handles)
if isequal(get(handles.checkReg,'Value'),1)
    set(handles.addreg,'Enable','on')
    set(handles.refreshb,'Enable','on')
else
    set(handles.addreg,'Enable','off')
    set(handles.refreshb,'Enable','off')
    set(handles.txtregress,'String','0 added')
end

function addreg_Callback(hObject, eventdata, handles)
global regVets
try
    clear(regVets)
end
Addreg

function refreshb_Callback(hObject, eventdata, handles)
global nrg 
try
    if nrg < 0
        nrg = 0;
    end
    
    nrT = num2str(nrg);
    set(handles.txtregress,'String',[nrT ' added'])
end

if nrg == 0
     set(handles.checkReg,'Value',0)
     set(handles.addreg,'Enable','off')
     set(handles.refreshb,'Enable','off')
end

function Run_Callback(hObject, eventdata, handles)
global fileStru pathStru fileFunc pathFunc numofVoluF nrg pathROI nOfClust fileROI PsOri ps

SPMdir2 = which('spm');
SPMdir2 = SPMdir2(1:end-5);
EPCo = get(handles.EPCo,'Value');

UDV = uf2c_defaults('NativeS_Conne');

if isequal(get(handles.FazPrep,'Value'),0)
    if EPCo
        vxx = ver;
        delete(gcp('nocreate'))
        if any(strcmp(cellstr(char(vxx.Name)), 'Parallel Computing Toolbox'))
            numcores = feature('numcores');
            try
                parpool(numcores-UDV.NC2R);
            end
        else
            set(handles.EPCo,'Value',0);
        end
    else
        ps.Pool.AutoCreate = false;
    end
    if ~isequal(size(fileStru,2),size(fileFunc,2))
        warndlg({sprintf('The numbers of functional (%d) and structural (%d) images are different.',size(fileFunc,2),size(fileStru,2));...
          'You need to add one functional image for each strutural and vice versa.';...
          'If you have more than one functional section from the same subject, make copies of the structural image and add all!'},...
          'Attention: process aborted!');
        return
    end
end

set(handles.status,'String','Running....')
drawnow

fprintf('\r\n')
fprintf('UF�C =============== %s\n',spm('time'));
fprintf('Process started\n');
fprintf('==========================================\r\n');

WS = str2num(get(handles.wsIn,'String')); %Window Size (SIZE OF THE MOVING AVERAGE TO CALC DE CORRELATIONS)
TR = str2num(get(handles.TRInp,'String'));    % repetition time (s)

smWin = str2double(get(handles.wsIn, 'String'));
ratioVol = numofVoluF/smWin;

multiWaitbar('Total Progress', 0, 'Color', 'g' );  %CHARGE WAIT BAR
if isequal(get(handles.FazPrep,'Value'),0)
    multiWaitbar('Filtering & Regression', 0, 'Color', 'y' ); %CHARGE WAIT BAR
end
multiWaitbar('Extracting and processing ROIs time-series', 0, 'Color', 'b' ); %CHARGE WAIT BAR

dateNow = clock;
foldername = sprintf('1-Total_Log_%d_%d_%d--%d_%d', dateNow(3),dateNow(2),dateNow(1),dateNow(4),dateNow(5));

mkdir(pathFunc,foldername)

fideSJ = fopen([pathFunc,filesep,foldername,filesep,'1-Subjects.txt'],'w+'); 
for yTy = 1:size(fileFunc,2)
    fprintf(fideSJ,'%d: \t%s\r\n',yTy,fileFunc{1,yTy});
end
fclose(fideSJ);

imgRR = getframe(NativeS_Conne);
imwrite(imgRR.cdata, [pathFunc,filesep,foldername,filesep,'1-Your_Choices.png']);

fideG = fopen([pathFunc,filesep,foldername,filesep,'1-Seeds_Order.txt'],'w+'); % CHARGE OUTPUT LOG FILE
pathFLOG =  [pathFunc,foldername,filesep];
fprintf(fideG,'                                UF�C - Cross_Correlation ROI Analysis\r\n\r\n');

fprintf(fideG,'Number of seeds per mask: \t%d \r\n\r\n', size(nOfClust,1));
for jh = 1:size(fileROI,2)
    fprintf(fideG,'%d: \t%s\r\n',jh,fileROI{jh});
end
fclose(fideG);

if isequal(get(handles.FazPrep,'Value'),0) % just if you need preprocessing
    
    Totmovtxt = fopen([pathFunc,filesep,foldername,filesep,'Total_Movement.txt'],'w+'); % CHARGE OUTPUT LOG FILE
    fprintf(Totmovtxt,'Subject \t Maximum Displacemente (mm) \t Maximum Rotation (degree) \t Avg Framiwise Displacemente (FD) (mm) \t numb of FD Censored scans \t Avg DVARs (%%) \t numb of DVAR Censored scans \t Total Censored scans \r\n');
    
    if get(handles.FazFilt,'Value') % just if you want pass-band filtering
        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Designing filters\n');
        %%%%%%%%%%%%%%%%%%%%%% FILTER DESIGN %%%%%%%%%%%%%%%%%%%%%%%%%%%%
        Fs = 1/TR;     % sampling frequency (Hz)

        FpassLOW = str2double(get(handles.LPF,'String'));   % passband frequency   (Hz) (default: 0.1)
        FstopLOW = str2double(get(handles.LPF,'String')) + (Fs/numofVoluF); % stopband frequency   (Hz) (default: 0.15)
        ApassLOW = 1;                                       % passband ripple      (dB) (default: 1)
        AstopLOW = str2double(get(handles.stba,'String'));  % stopband attenuation (dB) (default: 40)

        FpassHIGH = str2double(get(handles.HPF,'String'));  % passband frequency   (Hz) (default: 0.008)
        FstopHIGH = str2double(get(handles.HPF,'String')) - (Fs/numofVoluF); % stopband frequency   (Hz) (default: 0.005)
                        
        if FstopHIGH<0
            FstopHIGH = str2double(get(handles.HPF,'String'))-(str2double(get(handles.HPF,'String')).*0.9);
        end
        
        AstopHIGH = str2double(get(handles.stba,'String')); % stopband attenuation (dB) (default: 40)
        ApassHIGH = 1;
        
        hLOW = fdesign.lowpass('Fp,Fst,Ap,Ast',FpassLOW,FstopLOW,ApassLOW,AstopLOW,Fs);
        HdLOW = design(hLOW,'equiripple');

        hHIGH  = fdesign.highpass('Fst,Fp,Ast,Ap',FstopHIGH,FpassHIGH,AstopHIGH,ApassHIGH,Fs);
        HdHIGH = design(hHIGH, 'equiripple');
        fprintf('Done! ============== %s\r\n',spm('time'));
        
        aFil = 1;
        tmp1 = 3*(max(length(HdLOW.Numerator),length(aFil))-1);
        tmp2 = 3*(max(length(HdHIGH.Numerator),length(aFil))-1);
    else
        FpassLOW = [];  % passband frequency   (Hz) (default: 0.1)
        FstopLOW = []; % stopband frequency   (Hz) (default: 0.15)
        ApassLOW = [];                                     % passband ripple      (dB) (default: 1)
        AstopLOW = [];  % stopband attenuation (dB) (default: 40)
        FpassHIGH = [];  % passband frequency   (Hz) (default: 0.008)
        FstopHIGH = []; % stopband frequency   (Hz) (default: 0.005)
        AstopHIGH = []; % stopband attenuation (dB) (default: 40)
        ApassHIGH = [];
        hLOW = [];
        HdLOW = [];
        hHIGH  = [];
        HdHIGH = [];
        aFil = [];
        tmp1 = [];
        tmp2 = [];
    end 
end

ScreSize = get(0,'screensize');
ScreSize = ScreSize(3:end);

WinAvSave = struct;
ExclSub = 0;

FunpreT = nifti([pathFunc,fileFunc{1}]);

if isequal(WS,FunpreT.dat.dim(4))
    dynStu= 0;
else
    dynStu= 1;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%% START OF SUBJECT LOOP %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%% START OF SUBJECT LOOP %%%%%%%%%%%%%%%%%%%
for yy = 1:size(fileFunc,2)
    
    multiWaitbar('Total Progress', (yy/size(fileFunc,2))*0.95 );
    multiWaitbar('Extracting and processing ROIs time-series', 'Reset' );
    
    fprintf('\r\n')
    fprintf('UF�C ===================== %s\n',spm('time'));
    if isequal(get(handles.FazPrep,'Value'),0)
        fprintf('Starting subj. %d  (%s...)\n',yy,fileFunc{yy}(1:round(size(fileFunc{yy},2)/3)));
    else
        fprintf('Starting subj. %d  (%s...)\n',yy,fileFunc{yy}(12:12+round(size(fileFunc{yy},2)/3)));
    end
    fprintf('================================================\r\n\r\n');
    
    try
        close(fig)
    end
    
    Funpre = nifti([pathFunc,fileFunc{yy}]);
    
    if dynStu
         if mod(Funpre.dat.dim(4),WS)
             ExclSub = ExclSub+1;
                 if isequal(get(handles.FazPrep,'Value'),0)
                     fprintf('subj. %d  (%s...) process aborted!\n',yy,fileFunc{yy}(1:round(size(fileFunc{yy},2)/3)));
                 else
                     fprintf('subj. %d  (%s...) process aborted!\n',yy,fileFunc{yy}(12:12+round(size(fileFunc{yy},2)/3)));
                 end
             fprintf('The number of dynamics and the time blocks are not multiple\n');
             continue
         end
    else
        WS = Funpre.dat.dim(4);
    end
             
    fvs = double(Funpre.hdr.pixdim(2:4)); %GET PIXEL SIZE (FUNCTIONAL)
    
    if isequal(get(handles.FazPrep,'Value'),0)
        multiWaitbar('Filtering & Regression', 'Reset' );
        dirname = Funpre.dat.fname;
        [ax,dirname,cx] = fileparts(dirname);
        
        if numel(dirname)>UDV.MSDN
            fprintf('Attention!\n');
            fprintf('The filename is long. A shorter version will be used.\r\n')
            dirname = dirname(1:UDV.MSDN);
        end

        nfidx = 1;
        while isequal(exist([pathFunc,dirname],'dir'),7)
            dirname = [dirname '_' num2str(nfidx)];
            nfidx = nfidx + 1;
        end

        mkdir(pathFunc,dirname)
        copyfile([pathStru,fileStru{yy}],[pathFunc,dirname,filesep,fileStru{yy}])
        file2 = fullfile(pathFunc,dirname,filesep,fileStru{yy});
        Strpre = nifti(file2);
        Svs = double(Strpre.hdr.pixdim(2:4)); % GET PIXEL SIZE (STRUCTURAL)
        copyfile([pathFunc,fileFunc{yy}],[pathFunc,dirname,filesep,fileFunc{yy}])
        
        file1 = cell(Funpre.dat.dim(4),1);
        for tt = 1:Funpre.dat.dim(4)
            file1{tt,1} = [pathFunc,dirname,filesep,fileFunc{yy},',',sprintf('%d',tt)];
        end
        
        fprintf(Totmovtxt,'%s \t',dirname);

    else
        dirname = Funpre.dat.fname;
        [ax,dirname,cx] = fileparts(dirname);
        dirname = dirname(12:end);
        
        if numel(dirname)>UDV.MSDN
            fprintf('Attention!\n');
            fprintf('The filename is long. A shorter version will be used.\r\n')
            dirname = dirname(1:30);
        end
        
        nfidx = 1;
        while isequal(exist([pathFunc,dirname],'dir'),7)
            dirname = [dirname '_' num2str(nfidx)];
            nfidx = nfidx + 1;
        end

        mkdir(pathFunc,dirname)
    end
    

    mkdir([pathFunc,dirname,filesep,'ROI_mask'])
    mkdir([pathFunc,dirname],'Results_Log')
    
    fideSubP = fopen([pathFunc,dirname,filesep,'Results_Log',filesep,'Positive_Corr_Values.txt'],'w+'); % CHARGE OUTPUT LOG FILE
    fprintf(fideSubP,'                           UF�C - Cross_Correlation ROI Analysis\r\n\r\n');
    fprintf(fideSubP,'Case name: %s \r\n', fileFunc{yy});
    fprintf(fideSubP,'Number of temporal blocks: \t%d \r\n',ratioVol);
    
    fideSubN = fopen([pathFunc,dirname,filesep,'Results_Log',filesep,'Negative_Corr_Values.txt'],'w+'); % CHARGE OUTPUT LOG FILE
    fprintf(fideSubN,'                           UF�C - Cross_Correlation ROI Analysis\r\n\r\n');
    fprintf(fideSubN,'Case name: %s \r\n', fileFunc{yy});
    fprintf(fideSubN,'Number of temporal blocks: \t%d \r\n',ratioVol);
    
    mkdir([pathFunc,dirname],'Correlation_map')
    
    if isequal(get(handles.FazPrep,'Value'),0)
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Preprocessing
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            STC = get(handles.STCo,'Value');
            BounB = get(handles.SPMbb,'Value');
            fileFuncX = fileFunc{yy};
            fileStruX = fileStru{yy};
            Preproc_uf2c(file1,file2,BounB,SPMdir2,Svs,fvs,pathFunc,dirname,STC,Funpre,TR,fileFuncX,fileStruX,UDV.NativeS)
        catch
             set(handles.status,'String','Error...')
             warndlg(sprintf('An error occured during subject %d preprocessing. This is a SPM error. Check your data',yy), 'Process Aborted')
             return
        end
        try
            close(fig);
        end
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot and save the motion series
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        mkdir([pathFunc,dirname,filesep,'Motion_Controls_Params'])
        Motfid = fopen([pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'1-Motion_Quantifications.txt'],'w+');
        fprintf(Motfid,'Motion Quantifications\r\n\r\n');
        fprintf(Motfid,'Subject Name: \t%s\r\n',dirname);

        [Mot_fig,HDvV,HTvV] = uf2c_plot_motion([pathFunc,dirname,filesep,'rp_',fileFunc{yy}(1:end-3),'txt'],UDV.MFVstr);
        imgRR = getframe(Mot_fig);
        imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'Realignment_Parameters_Plot.png']);
        saveas(Mot_fig,[pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'Realignment_Parameters_Plot'],'fig')

        fprintf(Motfid,'Maximum Displacemente (mm):\t %s\r\n',HDvV);
        fprintf(Motfid,'Maximum Rotation (degree):\t %s\r\n',HTvV);
        fprintf('Done! ============== %s\r\n',spm('time'));   
        
        fprintf(Totmovtxt,'%s \t %s \t',HDvV,HTvV);
       
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BRAMILA's Framewise Displacemente (FD)
        % Code from: Brain and Mind Lab at Aalto University
        % Power et al. (2012) doi:10.1016/j.neuroimage.2011.10.018 and also 
        % Power et al. (2014) doi:10.1016/j.neuroimage.2013.08.048
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Quantifying Framewise Displacemente (FD)\r\n');

        if get(handles.FDcheck,'Value')
            cfg.motionparam = [pathFunc,dirname,filesep,'rp_',fileFunc{yy}(1:end-3),'txt'];
            cfg.prepro_suite = 'spm';
            cfg.radius = UDV.FDBR;
            
            [FDts,rms] = bramila_framewiseDisplacement(cfg);
            
            save([pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'FramewiseDisplacement.mat'],'FDts')

            figuFD = figure('Visible','off');
            set(figuFD,'Name','Framewise Displacemente (FD) TS',...
                'Position', round([ScreSize(1)*.15 ScreSize(2)*.15 ScreSize(1)*.4 ScreSize(1)*.2]),...
                'Color',[1 0.94 0.86]);
            plot(FDts);
            hold on
            plot(ones(1,numel(FDts)).*str2num(get(handles.FDthres,'String')));
            ylabel('FD (mm)')
            xlabel('Time Points')
            title('Average Framewise Displacement TS','FontSize', 14);
            drawnow
            
            imgRR = getframe(figuFD);
            imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'FramewiseDisplacement_avgTS.png']);
            saveas(figuFD,[pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'FramewiseDisplacement_avgTS'],'fig')
            close(figuFD)
            fprintf(Motfid,'BRAMILA''s average Framiwise Displacemente (FD):\t %.3f\r\n',mean(FDts));
            fprintf('Done! ============== %s\r\n',spm('time'));
            
            fprintf(Totmovtxt,'%.5f \t',mean(FDts));
        else
            fprintf(Totmovtxt,'N/A \t');
        end
        
        if get(handles.TM_FD,'Value')
            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Creating FD Temporal Mask\r\n');

            FD_TM = FDts>str2num(get(handles.FDthres,'String'));
            fprintf('Done! ============== %s\r\n',spm('time'));
            
            fprintf(Totmovtxt,'%d \t',sum(FD_TM));
        else
            FD_TM = [];
            fprintf(Totmovtxt,'N/A \t');
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Extracting Globals and Masking
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            [sizeFunc,finalEPI,MeanWM,MeanCSF,Func] = mask_globals_uf2c(fvs,pathFunc,dirname,fileFunc{yy},fileStru{yy},get(handles.SPMbb,'Value'),UDV.FI,UDV.WMI,UDV.NativeS);
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d globals and mask extraction. Check your data.',yy), 'Process Aborted')
            return
        end
        try
            close(Mot_fig)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Reshapeing and Thresholding
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            Dx = size(finalEPI,1);
            Dy = size(finalEPI,2);
            Dz = size(finalEPI,3);
            Dt = size(finalEPI,4);

            [finalEPI,histCut] = imgthres_uf2c(finalEPI,Dx,Dy,Dz,ScreSize,pathFunc,dirname);
            imgRR = getframe(histCut);
            imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Avg_Img_Histogram.tif']);
            
            newEPI1 = Func;
            newEPI1.dat.fname = [pathFunc,dirname,filesep,'sr',fileFunc{yy}];
            newEPI1.descrip = 'UF�C Thresholded Masked swEPI';
            newEPI1.dat.dtype = 'INT16-LE';
            newEPI1.dat(:,:,:,:) = finalEPI;
            create(newEPI1)
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d thresholding. Check your data.',yy), 'Process Aborted')
            return
        end

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % BRAMILA DVARS - Computes Derivative VARiance
        % Code from: Brain and Mind Lab at Aalto University
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        extGMvar = get(handles.extGM,'Value');
        extWMvar = get(handles.extWM,'Value');
        extCSFvar = get(handles.extCSF,'Value');
        DVARthresV = str2num(get(handles.DVARthres,'String'));

        if extGMvar || extWMvar || extCSFvar
            [dvarsC1,dvarsC2,dvarsC3,MeanDvars] = bramila_dvars_uf2c(pathFunc,dirname,finalEPI,extGMvar,extWMvar,extCSFvar,DVARthresV);
            fprintf(Motfid,'BRAMILA''s Average Derivative VARiance (DVAR) GM masked: %.3f \r\n',mean(dvarsC1));
            fprintf(Motfid,'BRAMILA''s Average Derivative VARiance (DVAR) WM masked: %.3f \r\n',mean(dvarsC2));
            fprintf(Motfid,'BRAMILA''s Average Derivative VARiance (DVAR) CSF masked: %.3f \r\n',mean(dvarsC3));
            fprintf(Totmovtxt,'%.4f \t',mean(MeanDvars));
        else
            MeanDvars = [];
            fprintf(Totmovtxt,'N/A \t');
        end
        
        if get(handles.TM_DVARs,'Value')
            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Creating DVARs Temporal Mask\r\n');

            dvars_TM = zeros(size(finalEPI,4),1);
            dvars_TM = MeanDvars>str2num(get(handles.DVARthres,'String'));
            fprintf('Done! ============== %s\r\n',spm('time'));
            fprintf(Totmovtxt,'%d \t',sum(dvars_TM));
        else
            dvars_TM = [];
            fprintf(Totmovtxt,'N/A \t');
        end

        fclose(Motfid);
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Creating the regression Matrix
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if ~get(handles.checkReg,'Value')
             nrg = 0;
        end

        if get(handles.checkMOV,'Value') || get(handles.checkOsc,'Value') || get(handles.checkReg,'Value')
            try
                [Frgval,Regstr,figu,thicksL] = regrprep_uf2c(yy,get(handles.checkMOV,'Value'),pathFunc,dirname,fileFunc{yy},get(handles.checkOsc,'Value'),get(handles.checkReg,'Value'),ScreSize,MeanWM,MeanCSF,size(finalEPI,4),nrg);
                if ~isempty(figu)
                    if isequal(get(handles.TM_FD,'Value'),0) && isequal(get(handles.TM_DVARs,'Value'),0)
                        imgRR = getframe(figu);
                        imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Regression Matrix.tif']);
                    end
                end
            catch
                set(handles.status,'String','Error...')
                warndlg(sprintf('An error occured during subject %d regressors creation. Check your data.',yy), 'Process  Aborted')
                return
            end
        else
            Regstr = '';
            Frgval = [];
            thicksL = {};
        end            

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Adding the FD and DVAR regressors
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        TM_DVARsV = get(handles.TM_DVARs,'Value');
        TM_FDV = get(handles.TM_FD,'Value');
        DVAR_tsV = get(handles.DVAR_TS,'Value');

        if TM_DVARsV || TM_FDV || DVAR_tsV
           [Frgval,figu,Censu] = Add_FD_DVAR_uf2c(figu,thicksL,Frgval,pathFunc,dirname,TM_DVARsV,TM_FDV,DVAR_tsV,MeanDvars,FD_TM,dvars_TM,size(finalEPI,4));
            if size(Frgval,2)>1
                Regstr = [Regstr,'_tmpMask'];
            end
            if TM_DVARsV || TM_FDV
                nOfSensu = size(Censu,2);
                fprintf(Totmovtxt,'%d \r\n',nOfSensu);
            end
        else
            fprintf(Totmovtxt,'N/A \r\n');
        end

        try
            close(figu)
        end
        try
            close(histCut)
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Smooth %%%%%%%%%%%%%%%%%%
        %%%%%%%%%%%%%%%%%%%%%%%%%%%

        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Smoothing\r\n');
        
        newEPI = Func;
        newEPI.dat.fname = [pathFunc,dirname,filesep,'tmpW_',fileFunc{yy}];
        newEPI.descrip = 'UF�C-Filtered_Regressed_sw_EPI';
        newEPI.dat.dtype = 'INT16-LE';
        newEPI.dat(:,:,:,:) = finalEPI;
        create(newEPI)
        
        clear file1
        for tt = 1:newEPI.dat.dim(4)
            file1{tt,1} = [pathFunc,dirname,filesep,'tmpW_',fileFunc{yy},',',sprintf('%d',tt)];
        end
        
        clear matlabbatch
        matlabbatch{1}.spm.spatial.smooth.data = file1;
        if BounB
            matlabbatch{1}.spm.spatial.smooth.fwhm = [UDV.SmoFac*fvs(1) UDV.SmoFac*fvs(2) UDV.SmoFac*fvs(3)];
        else
            matlabbatch{1}.spm.spatial.smooth.fwhm = [6 6 6];
        end
        matlabbatch{1}.spm.spatial.smooth.dtype = 0;
        matlabbatch{1}.spm.spatial.smooth.im = 1;
        matlabbatch{1}.spm.spatial.smooth.prefix = 's';
        spm_jobman('run',matlabbatch)
        
        preFiReStru = nifti([pathFunc,dirname,filesep,'stmpW_',fileFunc{yy}]);
        finalEPI = preFiReStru.dat(:,:,:,:);
        clear preFiReStru
        delete([pathFunc dirname filesep 'stmpW_' fileFunc{yy}])
        delete([pathFunc dirname filesep 'tmpW_' fileFunc{yy}])
        fprintf('Done! ============== %s\n\r',spm('time'));

        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Filtering and regressions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%
        if  get(handles.FazFilt,'Value') || ~isequal(Regstr,'') || TM_DVARsV || TM_FDV
            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Performing regressions and/or filtering\r\n');

            BinFazFilt = get(handles.FazFilt,'Value');
            finalEPI = filtregr_uf2c(finalEPI,BinFazFilt,Dx,Dy,Dz,Dt,Frgval,HdLOW,HdHIGH,aFil,tmp1,tmp2,Regstr);
        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Creating the FiltRegre Image
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        try
            if  get(handles.FazFilt,'Value') || ~isequal(Regstr,'')
                if  get(handles.FazFilt,'Value') && ~isequal(Regstr,'')
                    newEPI = Func;
                    newEPI.dat.fname = [pathFunc,dirname,filesep,'FiltRegrSR_',fileFunc{yy}];
                    newEPI.descrip = 'UF�C-Filtered_Regressed_sr_EPI';
                    newEPI.dat.dtype = 'INT16-LE';
                    newEPI.dat(:,:,:,:) = finalEPI;
                    create(newEPI)
                    fprintf('Done! ============== %s\n\r',spm('time'));
                else if get(handles.FazFilt,'Value') && isequal(Regstr,'')
                        newEPI = Func;
                        newEPI.dat.fname = [pathFunc,dirname,filesep,'FiltSR_',fileFunc{yy}];
                        newEPI.descrip = 'UF�C-Filtered_sr_EPI';
                        newEPI.dat.dtype = 'INT16-LE';
                        newEPI.dat(:,:,:,:) = finalEPI;
                        create(newEPI)
                        fprintf('Done! ============== %s\n\r',spm('time'));
                    else
                        newEPI = Func;
                        newEPI.dat.fname = [pathFunc,dirname,filesep,'RegrSR_',fileFunc{yy}];
                        newEPI.descrip = 'UF�C-Regressed_sr_EPI';
                        newEPI.dat.dtype = 'INT16-LE';
                        newEPI.dat(:,:,:,:) = finalEPI;
                        create(newEPI)
                        fprintf('Done! ============== %s\n\r',spm('time'));
                    end
                end
            else
                newEPI = Func;
                newEPI.dat.fname = [pathFunc,dirname,filesep,'ThreSR_',fileFunc{yy}];
                newEPI.descrip = 'UF�C-Masked and Thresholded_sr_EPI';
                newEPI.dat.dtype = 'INT16-LE';
                newEPI.dat(:,:,:,:) = finalEPI;
                create(newEPI)
                fprintf('Done! ============== %s\n\r',spm('time'));
            end
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d image creation. Check the avaiable disk space.',yy), 'Process Aborted')
            return
        end
        
    else   % case preprocessing was not performed
        try
            Func = nifti([pathFunc,fileFunc{yy}]);
            finalEPI = Func.dat(:,:,:,:);
            Dx = size(finalEPI,1);
            Dy = size(finalEPI,2);
            Dz = size(finalEPI,3);
            Dt = size(finalEPI,4);
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured trying to read the subject %d processed image. Check your data.',yy), 'Process Aborted')
            return
        end
    end
    
    if get(handles.AddROIm,'Value')
        
        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Processing ROIs\r\n');
        
        copyfile([pathROI filesep fileROI{yy}],[pathFunc,dirname,filesep,fileROI{yy}])
        
        if get(handles.AliStru,'Value')
            copyfile([pathStru,fileStru{yy}],[pathFunc,dirname,filesep,'Sec',fileStru{yy}])
            spm_jobman('initcfg')
            clear matlabbatch
            
            matlabbatch{1}.spm.spatial.coreg.estwrite.ref = {[pathFunc,dirname,filesep,'mean',fileFunc{yy}]};
            matlabbatch{1}.spm.spatial.coreg.estwrite.source = {[pathFunc,dirname,filesep,'Sec',fileStru{yy}]};
            matlabbatch{1}.spm.spatial.coreg.estwrite.other = {[pathFunc,dirname,filesep,fileROI{yy}]};
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
            matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
            matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';
            
            spm_jobman('run',matlabbatch)
            
            aROI = nifti([pathFunc,dirname,filesep,'r',fileROI{yy}]);
        else
            aROI = nifti([pathFunc,dirname,filesep,fileROI{yy}]);
        end
        
        parcel_mat = double(aROI.dat(:,:,:));
        parcel_mat = round(parcel_mat);  
        vet = unique(parcel_mat);

        vet = vet(2:end);
        vet = double(vet);
        
        for ind = 1:size(nOfClust,1)
           ROIMAt(:,:,:,ind) = double((parcel_mat==vet(ind)));
        end
        
        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Extracting and processing ROIs time-series\r\n');
        
        MatrixSeeds = zeros(Dt,size(fileROI,2));
        
        roiF = zeros(Dx,Dy,Dz); %Prelocation
        roiF2 = zeros(Dx,Dy,Dz); %Prelocation
        
        for jh = 1:size(nOfClust,1)
            multiWaitbar('Extracting and processing ROIs time-series', jh/size(nOfClust,1));
            roi1 = squeeze(ROIMAt(:,:,:,jh));
            
            %%%% Loop option
            [iCo,jCo,kCo]= ind2sub(size(roi1), find(roi1>0));
            coords = [iCo,jCo,kCo];
            for vx = 1:Dt % get the ROI voxels time series. This step exclude from the ROI eventuals with matter voxels.
                final3D(:,:,:) = roi1.*finalEPI(:,:,:,vx);
                for hj = 1:size(coords,1)
                    vetsCor(vx,hj) = final3D(coords(hj,1),coords(hj,2),coords(hj,3));
                end
            end
            %%%%
            
            %%%%% Tester of corregistering - Uncomment to create image
            roiF =  (roi1.*finalEPI(:,:,:,1))+roiF; % add matriz value to the NIfTI object
            roiF2 =  (roi1.*jh)+roiF2; % add matriz value to the NIfTI object
            %%%%% Tester of corregistering

            verifCor = mean(vetsCor,2);
            xxX = corr(vetsCor(:,:),verifCor);
            xxX(isnan(xxX)) = 0;
            
            % Option 1: Outliers (lower than 1 IQR, for "severe") would be removed         
            xxXxx = outlierdetec_uf2c(xxX,UDV.RMOR,'lowerside');
            vetsCorF = vetsCor;
            vetsCorF(:,xxXxx) = [];
            
            mean4D = (mean(vetsCorF,2))';
            MatrixSeeds(:,jh) = mean4D;
            save([pathFunc,fileFunc{yy}(1:end-4),'_SeedsTS.mat'],'MatrixSeeds')
            clear coords iCo jCo kCo vetsCor verifCor xxX xxX_Z stdxxX meanxxX lowerCut CutFinal mean4D
        end
        
        fprintf('Done! ============== %s\r\n',spm('time'));
        
        RoiNii = Func;   % Creates a NIfTI object
        RoiNii.dat.dim = [Dx Dy Dz]; % Apply the correct matrix size
        RoiNii.dat.fname = [pathFunc,dirname,filesep,'ROI_mask',filesep,dirname,'_Roi.nii']; % Change file name
        RoiNii.dat.dtype = 'FLOAT32-LE'; % verify matrix datatype
        RoiNii.descrip = dirname; % Apply Name information in the Nii struct (description field)
        RoiNii.dat(:,:,:) = roiF; % add matriz value to the NIfTI object
        create(RoiNii) % creates the NIfTI file from the Object
        
        RoiNii2 = Func;   % Creates a NIfTI object
        RoiNii2.dat.dim = [Dx Dy Dz]; % Apply the correct matrix size
        RoiNii2.dat.fname = [pathFunc,dirname,filesep,'ROI_mask',filesep,dirname,'_ALL_ROIs.nii']; % Change file name
        RoiNii2.dat.dtype = 'FLOAT32-LE'; % verify matrix datatype
        RoiNii2.descrip = dirname; % Apply Name information in the Nii struct (description field)
        RoiNii2.dat(:,:,:) = roiF2; % add matriz value to the NIfTI object
        create(RoiNii2) % creates the NIfTI file from the Object
        
        fprintf('Done! ============== %s\r\n',spm('time'));
    end
    
    save([pathFunc,dirname,filesep,'Seeds_TimeSeries.mat'],'MatrixSeeds')
    Vn = 1;
    
    fprintf('\r\n')
    fprintf('UF�C =============== %s\n',spm('time'));
    fprintf('Performing Cross-Correlations\r\n');
    
    for MA = 1:WS:Dt
        for SP = 1:size(nOfClust,1)
            map(:,SP,Vn) = corr(MatrixSeeds(MA:MA+(WS-1),:),MatrixSeeds(MA:MA+(WS-1),SP));
        end
        Vn = Vn+1;
    end
    Vn = Vn-1;
    
    map = squeeze(map);
    if Vn ==1
        LowMaTTT = tril(map,-1);
    else
        LowMaTTT = tril(map(:,:,1),-1);
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Done! ============== %s\r\n',spm('time'));
    clear MatrixSeeds mean4D vetsCorF
    
    ffff = isnan(LowMaTTT(:,1));
    
    if sum(sum(ffff))>0 %%%%%%%%% conditional of "volunteer aborted!
        beep
        [dsa asd] = find(ffff);
        dsa = unique(dsa);
        warndlg(sprintf('Volunteer %d process aborted! Outside cortex cordinate(s). Indices: %s',yy,num2str(transpose(dsa))),'Ops!');
        ExclSub = ExclSub+1;
        fprintf('WARNING!\n');
        fprintf('Volunteer %d process aborted! Outside cortex cordinate(s). Indices: %s',yy,num2str(transpose(dsa)));

        fprintf(fideSubP,'VOLUNTEER PROCESS ABORTED!\r\n');
        fprintf(fideSubP,'THERE IS NOT OVERLAPPING BETWEEN COORDINATE %s AND THE CONSIDERED CORTEX\r\n',num2str(transpose(dsa)));
        fprintf(fideSubN,'VOLUNTEER PROCESS ABORTED!\r\n');
        fprintf(fideSubN,'THERE IS NOT OVERLAPPING BETWEEN COORDINATE %s AND THE CONSIDERED CORTEX\r\n',num2str(transpose(dsa)));
        
        if isequal(get(handles.FazPrep,'Value'),0)
            delete([pathFunc dirname filesep fileFunc{yy}])
            delete([pathFunc dirname filesep fileStru{yy}])
            delete([pathFunc dirname filesep 'y_' fileStru{yy}])
            delete([pathFunc dirname filesep fileFunc{yy}(1:end-4) '.mat'])
            delete([pathFunc dirname filesep fileStru{yy}(1:end-4) '_seg_inv_sn.mat'])
            delete([pathFunc dirname filesep fileStru{yy}(1:end-4) '_seg_sn.mat'])
            delete([pathFunc dirname filesep 'sw' fileFunc{yy}])
            delete([pathFunc dirname filesep 'rp_' fileFunc{yy}(1:end-4) '.txt'])
            delete([pathFunc dirname filesep 'mean' fileFunc{yy}])
            if STC
                delete([pathFunc dirname filesep 'a' fileFunc{yy}])
                delete([pathFunc dirname filesep 'wa' fileFunc{yy}])
            end
            delete([pathFunc dirname filesep 'm' fileStru{yy}])
            delete([pathFunc dirname filesep 'mwc1' fileStru{yy}])
            delete([pathFunc dirname filesep 'mwc2' fileStru{yy}])
            delete([pathFunc dirname filesep 'mwc3' fileStru{yy}])
            delete([pathFunc dirname filesep 'wc1' fileStru{yy}])
            delete([pathFunc dirname filesep 'wc2' fileStru{yy}])
            delete([pathFunc dirname filesep 'wc3' fileStru{yy}])
            delete([pathFunc dirname filesep 'w' fileFunc{yy}])
            delete([pathFunc dirname filesep 'w' fileFunc{yy}(1:end-4) '.mat'])
            delete([pathFunc dirname filesep 'sw' fileFunc{yy}(1:end-4) '.mat'])
            delete([pathFunc dirname filesep 'c1interp.nii'])
            delete([pathFunc dirname filesep 'sc1interp.nii'])
            delete([pathFunc dirname filesep 'c1interpF.nii'])
            delete([pathFunc dirname filesep 'c2interp.nii'])
            delete([pathFunc dirname filesep 'c3interp.nii'])
            delete([pathFunc dirname filesep 'Template.nii'])
            delete([pathFunc dirname filesep 'Template.mat'])
        end
        rmdir([pathFunc dirname filesep 'Correlation_map'],'s')
    else
        map(isnan(map))=0;
        PlotSize  = ceil(sqrt(Vn));
        fontSize = (144/Vn);
        if fontSize>12
            fontSize = 12;
        end
        if fontSize<7
            fontSize = 7;
        end

        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Saving individual results\r\n');

        if Vn>1
            fig = figure('Visible','on');
            set(fig,'Name',dirname,...
                'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.6 ScreSize(1)*.4]),...
                     'Color',[1 0.94 0.86]);
                 
            title('Cross-Correlation Matrices','FontSize',14);
            for bn = 1:Vn
                subplot(PlotSize,PlotSize,bn)
                set(subplot(PlotSize,PlotSize,bn),'FontSize',(fontSize-1))
                imagesc(map(:,:,bn))
                colorbar
                set(colorbar,'fontsize',(fontSize-1));
%                 xlabel('Seeds'  ,'FontSize',fontSize);
%                 ylabel('Seeds','FontSize',fontSize);
                axis off
                title(['Time window ' num2str(bn)],'FontSize',(fontSize+1));
            end
            
           axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
           text(0.5, 1,'\bf Cross-Correlation Matrices','HorizontalAlignment','center','VerticalAlignment','top','FontSize',14);

           drawnow
           imgRR = getframe(fig);
           imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Correlation_map',filesep,'All_Windows_Corr_Matrix.png']);

           saveas(fig,[pathFunc,dirname,filesep,'Correlation_map',filesep,'All_Windows_Corr_Matrix'],'fig')

           try
               close(fig)
           end

           figi = figure('Visible','on');
           set(figi,'Name',dirname,...
                 'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.6 ScreSize(1)*.4]),...
                        'Color',[1 0.94 0.86]);
                    
           imagesc(mean(map,3))
           
           title('Cross-Correlation Matrix (Averaging across time windows)','FontSize',14);
           colorbar
           set(colorbar,'FontSize',(fontSize-1));
           xlabel('Seeds'  ,'FontSize',fontSize);
           ylabel('Seeds','FontSize',fontSize);
           sasrt = mean(map,3);

    %        Plot line in over imagesc
            hold on;
            min_x = 1;
            max_x = size(seedList,1); %cross cor map size
            xy = min_x:max_x; % line
            rt = nEle(1);
            for io = 2:size(nEle,2)
               yt = (rt+0.5)*(ones(1,size(seedList,1))); % 10.5 � a altua da linha
               plot(xy,yt,'b','linewidth',1.3,'Color','Black');
               rt = rt+nEle(io);
               hold on;
            end

           drawnow
           imgRR = getframe(figi);
           imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Correlation_map',filesep,'AverageAcrossWindows.png']);
           
           saveas(figi,[pathFunc,dirname,filesep,'Correlation_map',filesep,'AverageAcrossWindows'],'fig')

           try
               close(figi)
           end

       else
           fig = figure('Visible','on');
           set(fig,'Name',dirname,...
                 'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.6 ScreSize(1)*.4]),...
                        'Color',[1 0.94 0.86]);
                    
           imagesc(map(:,:))
           title('Cross-Correlation Matrix','FontSize',14);
           colorbar
           set(colorbar,'FontSize',(fontSize-1));
           xlabel('Seeds'  ,'FontSize',fontSize);
           ylabel('Seeds','FontSize',fontSize);

            hold on;
            min_x = 1;
            max_x = size(nOfClust,1); %cross cor map size
            xy = min_x:max_x; % line
            
            % saveas(fig,[pathFunc,dirname,filesep,'Correlation_map',filesep,'Correlation_Matrix'],'png')
            imgRR = getframe(fig);
            imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Correlation_map',filesep,'Correlation_Matrix.png']);

            saveas(fig,[pathFunc,dirname,filesep,'Correlation_map',filesep,'Correlation_Matrix'],'fig')
            save([pathFunc,dirname,filesep,'Correlation_map',filesep,'Matrix-VAR'],'map')
            try
                close(fig)
            end
            eval(['WinAvSave.Subj',num2str(yy-ExclSub),'.maps=map;']);

        end
        fprintf('Done! ============== %s\r\n',spm('time'));

        if isequal(get(handles.OutputFil, 'Value'),1)
            if isequal(get(handles.FazPrep,'Value'),0)
                delete([pathFunc dirname filesep 'm' fileStru{yy}])
                delete([pathFunc dirname filesep fileStru{yy}])
                delete([pathFunc dirname filesep fileFunc{yy}])
                delete([pathFunc dirname filesep fileFunc{yy}(1:end-4) '.mat'])
%                 delete([pathFunc dirname filesep fileStru{yy}(1:end-4) '_seg_inv_sn.mat'])
%                 delete([pathFunc dirname filesep fileStru{yy}(1:end-4) '_seg_sn.mat'])
                delete([pathFunc dirname filesep fileStru{yy}(1:end-4) '_seg8.mat'])
                delete([pathFunc dirname filesep 'mean' fileFunc{yy}])
                delete([pathFunc dirname filesep 'sr' fileFunc{yy}])
                delete([pathFunc dirname filesep 'r' fileFunc{yy}])
                delete([pathFunc dirname filesep 'c1' fileStru{yy}])
                delete([pathFunc dirname filesep 'c2' fileStru{yy}])
                delete([pathFunc dirname filesep 'c3' fileStru{yy}])
                if STC
                    delete([pathFunc dirname filesep 'ar' fileFunc{yy}])
                end
                
                if get(handles.AliStru,'Value')
                    delete([pathFunc dirname filesep 'Sec' fileStru{yy}])
                    delete([pathFunc dirname filesep 'rSec' fileStru{yy}])
                end
                delete([pathFunc dirname filesep 'c2interpReg.nii'])
                delete([pathFunc dirname filesep 'c3interpReg.nii'])
                delete([pathFunc dirname filesep 'c1interp.nii'])
                delete([pathFunc dirname filesep 'sc1interp.nii'])
                delete([pathFunc dirname filesep 'c1interpF.nii'])
                delete([pathFunc dirname filesep 'c2interp.nii'])
                delete([pathFunc dirname filesep 'c3interp.nii'])
                delete([pathFunc dirname filesep 'Template.nii'])
                delete([pathFunc dirname filesep 'Template.mat'])
            end
        end
        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Subject %d Done!\r\n',yy);
    end % End of the conditional of "volunteer aborted!

    try
        close(fig)
    end
    try
        close(figi)
    end
    try
        close(figxT)
    end
    try
        delete('Global_SL.mat')
    end
    clear('ex1_1','ex2_1','ex1_2','ex2_2','ex3_1','ex3_2','ex4_2','ex4_1')
    fprintf('\r\n')

end

%%%%%%%%%%%% END OF THE SUBJECT LOOP
        %%%%%%% 
        %%%%%%% 
        %%%%%%% 
        %%%%%%% 
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
yytmp = yy;        
yy = yy-ExclSub; %to exclude possible volunteers that were excluded from the number of subjects

if yy == 0
    set(handles.status,'String','Aborted');
    fprintf('Process aborted because there is nothing to do!\n')
    fprintf('All subjects analyses were aborted due ROIs spatial mismatch.\n')
    fprintf('Number of subjects included: %d. Number of aborted subjects: %d.\n',yytmp,ExclSub)
    multiWaitbar('CloseAll'); %close the progressbar window
    fclose('all');
    fprintf('==========================================\r\n');
    return
end

fprintf('\r\n')
fprintf('UF�C =============== %s\n',spm('time'));
fprintf('Generating overall results\r\n');

mkdir([pathFunc,foldername,filesep,'ROIsMeans'])
mkdir([pathFunc,foldername,filesep,'AdjacencyMatrices'])


if yy<4
    switch yy
        case 1
            nColu = 1;
        case 2
            nColu = 2;
        case 3
            nColu = 3;
    end
else
    nColu = ceil(sqrt(yy));
end


if Vn>1  %checking if there are time windows
    sumMat = zeros(loopSize,loopSize,Vn);
    AllSubj3D = zeros(loopSize,loopSize,Vn);
    for gfs = 1:yy
        eval(['sumMat = sumMat + WinAvSave.Subj' num2str(gfs) '.maps(:,:,:);'])
        eval(['AllSubj3D(:,:,gfs) = mean(WinAvSave.Subj' num2str(gfs) '.maps(:,:,:),3);'])
    end
    final3Dx = sumMat./yy; %final matrices averaging all volunteers keeping the windows
    Final2Dx = mean(final3Dx,3);%final matrices averaging all volunteers and all windows
    
    % ploting 3D averaging across subjects
    figr2 = figure;
    set(figr2,'Name','Total Results 1',...
           'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(1)*.4]),...
                    'Color',[1 0.94 0.86]);
    for bn = 1:Vn
        subplot(PlotSize,PlotSize,bn)
        set(subplot(PlotSize,PlotSize,bn),'FontSize',(fontSize-1))
        imagesc(final3Dx(:,:,bn))
        colorbar
        set(colorbar,'fontsize',(fontSize-1));
%         xlabel('Seeds'  ,'FontSize',fontSize);
%         ylabel('Seeds','FontSize',fontSize);
        axis off
        title(['Time Window ' num2str(bn)],'FontSize',(fontSize+1));
    end
    
    axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 1,'\bf Cross-Correlation Matrices (averaging across subjects)','HorizontalAlignment','center','VerticalAlignment','top','FontSize',14);
    
    drawnow
    imgRR = getframe(figr2);
    imwrite(imgRR.cdata, [pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Averaging_Across_Subjs.png']);
    
    saveas(figr2,[pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Averaging_Across_Subjs'],'fig')
    save([pathFunc,foldername,filesep,'Averaging_Across_Subjs-VAR'],'final3Dx')
    
    try
        close(figr2)
    end
    
    figrX = figure;
    set(figrX,'Name','Total Results 2',...
                 'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(1)*.4]),...
                    'Color',[1 0.94 0.86]);
    for bn = 1:yy
        subplot(nColu,nColu,bn)
        set(subplot(nColu,nColu,bn),'FontSize',(fontSize-1))
        imagesc(AllSubj3D(:,:,bn))
        colorbar
        set(colorbar,'fontsize',(fontSize-1));
        xlabel('Seeds'  ,'FontSize',fontSize);
        ylabel('Seeds','FontSize',fontSize);
        title(['Subject ' num2str(bn)],'FontSize',(fontSize+1));
    end

    axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 1,'\bf Cross-Correlation Matrices (averaging across time window)','HorizontalAlignment','center','VerticalAlignment','top','FontSize',14);
    
    %saveas(figr,[pathFunc,foldername,filesep,'Averaging_Across_TimeWindows'],'png')
    drawnow
    imgRR = getframe(figrX);
    imwrite(imgRR.cdata, [pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Averaging_Across_TimeWindows.png']);

    saveas(figrX,[pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Averaging_Across_TimeWindows'],'fig')
    save([pathFunc,foldername,filesep,'Averaging_Across_TimeWindows-VAR'],'AllSubj3D')
    
    try
        close(figrX)
    end

    % ploting 2D averaging across subjects and time windows
    figx = figure;
    set(figx,'Name','Total Results 3',...
            'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(1)*.4]),...
                   'Color',[1 0.94 0.86]);
               
    imagesc(Final2Dx(:,:))
    title('Cross-Correlation Matrix (Averaging across subjects and windows)','FontSize',14);
    colorbar
    set(colorbar,'FontSize',(fontSize-1));
    xlabel('Seeds'  ,'FontSize',fontSize);
    ylabel('Seeds','FontSize',fontSize);
    
    hold on;
    min_x = 1;
    max_x = size(seedList,1); %cross cor map size
    xy = min_x:max_x; % line
    rt = nEle(1);
    for io = 2:size(nEle,2)
        yt = (rt+0.5)*(ones(1,size(seedList,1))); % 10.5 � a altua da linha
        plot(xy,yt,'b','linewidth',1.3,'Color','Black');
        hold on;
        plot(yt,xy,'b','linewidth',1.5,'Color','Black');
        rt = rt+nEle(io);
        hold on;
    end
    
    drawnow
    imgRR = getframe(figx);
    imwrite(imgRR.cdata, [pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Avg_Across_TimeWindows_and_Subjs.png']);

    saveas(figx,[pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Avg_Across_TimeWindows_and_Subjs'],'fig')
    save([pathFunc,foldername,filesep,'Avg_Across_TimeWindows_and_Subjs-VAR'],'Final2Dx')
    
    try
        close(figx)
    end
    
else   % case there are no time windows
    if yy>1
        AllSubj3D = zeros(size(nOfClust,1),size(nOfClust,1),yy);
        for gfs = 1:yy
            eval(['AllSubj3D(:,:,gfs) = mean(WinAvSave.Subj' num2str(gfs) '.maps,3);']);
        end
    else
        eval('AllSubj3D(:,:) = WinAvSave.Subj1.maps;');
    end
    
    % ploting 3D across subjects
    figr = figure;
    set(figr,'Name','Total Results 1',...
             'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(1)*.4]),...
                    'Color',[1 0.94 0.86]);
    for bn = 1:yy
        subplot(nColu,nColu,bn)
        set(subplot(nColu,nColu,bn),'FontSize',7)
        imagesc(AllSubj3D(:,:,bn))
        axis off
        title(['Subject ' num2str(bn)],'FontSize',8);
    end
    
    axes('Position',[0 0 1 1],'Xlim',[0 1],'Ylim',[0 1],'Box','off','Visible','off','Units','normalized', 'clipping' , 'off');
    text(0.5, 1,'\bf Cross-Correlation Matrices (All subjects)','HorizontalAlignment','center','VerticalAlignment','top','FontSize',14);
    
    %saveas(figr,[pathFunc,foldername,filesep,'All_Subjs'],'png')
    drawnow
    imgRR = getframe(figr);
    imwrite(imgRR.cdata, [pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'All_Subjs.png']);

    saveas(figr,[pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'All_Subjs'],'fig')
    save([pathFunc,foldername,filesep,'All_Subjs-VAR'],'AllSubj3D')
    
    tmpAllSubj3D = AllSubj3D;
    Trans = AllSubj3D;
    Trans(Trans>0.99) = 1;
    Trans = 0.5.*(log(1+Trans) - log(1-Trans));
    Trans(Trans==Inf) = 18;
    AllSubj3D = Trans;
    save([pathFunc,foldername,filesep,'Z_Transf_All_Subjs-VAR'],'AllSubj3D')
    AllSubj3D = tmpAllSubj3D;
    
    try
        close(figr)
    end
    
    % ploting 2D averaging across subjects
    figx = figure;
    set(figx,'Name','Total Results 2',...
           'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(1)*.4]),...
                    'Color',[1 0.94 0.86]);
                
    imagesc(mean(AllSubj3D,3))
    title('Cross-Correlation Matrix (Total Average across subjects)','FontSize',14);
    colorbar
    set(colorbar,'FontSize',(fontSize-1));
    xlabel('Seeds'  ,'FontSize',fontSize);
    ylabel('Seeds','FontSize',fontSize);
    
    hold on;
    min_x = 1;
    max_x = size(nOfClust,1); %cross cor map size
    xy = min_x:max_x; % line
    
    %saveas(figx,[pathFunc,foldername,filesep,'Avg_Across_Subjs'],'png')
    drawnow
    imgRR = getframe(figx);
    imwrite(imgRR.cdata, [pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Avg_Across_Subjs.png']);

    saveas(figx,[pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Avg_Across_Subjs'],'fig')
    save([pathFunc,foldername,filesep,'Avg_Across_Subjs-VAR'],'AllSubj3D')

    try
        close(figx)
    end
    
   
    figxCont = figure;
    set(figxCont,'Name','Average Countour',...
            'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.5 ScreSize(1)*.4]),...
                  'Color',[1 0.94 0.86]);

    contourf(flipud(mean(AllSubj3D,3)))
    title('Average Contour Graph (Clustering)','FontSize',14);
    xlabel('ROIs'  ,'FontSize',fontSize);
    ylabel('ROIs','FontSize',fontSize);
    
    drawnow
    imgRR = getframe(figxCont);
    imwrite(imgRR.cdata, [pathFunc,foldername,filesep,'AdjacencyMatrices',filesep,'Average_Countour.png']);
    
    try
        close(figxCont)
    end

    fprintf('\r\n')
    fprintf('UF�C =============== %s\n',spm('time'));
    fprintf('Generating ROI wise Bar Plots\r\n');

    % Ploting ROI-wise Bar Plots
    meanMat = mean(AllSubj3D,3);
    stdMat = std(AllSubj3D,0,3);
    stdeMat = stdMat./sqrt(size(AllSubj3D,3));
    
    for ty = 1:size(AllSubj3D,1)
        Rme = meanMat(1:end,ty);
        Rse = stdeMat(1:end,ty);
        figxBar = figure('Visible','off');
        set(figxBar,'Name',['ROI ' num2str(ty) ' Bar Plot'],...
            'Position', round([ScreSize(1)*.1 ScreSize(2)*.1 ScreSize(1)*.6 ScreSize(1)*.3]),...
                  'Color',[1 0.94 0.86]);


        bar(Rme,0.9,'blue','green');
        hold on
        errorbar(Rme,Rse,'.','Color','red');
        legend('Average r-score value','Standard error')
        title(['ROI ' num2str(ty) ' Connectivity Averages'],'FontSize',14);
        xlim([0 size(AllSubj3D,1)+1])
        xlabel('ROIs','FontSize',fontSize);
        ylabel('ROIs','FontSize',fontSize);

        drawnow
        imgRR = getframe(figxBar);
        imwrite(imgRR.cdata, [pathFunc,foldername,filesep,'ROIsMeans',filesep,'ROI_' num2str(ty) '_BarPlot.png']);
        saveas(figxBar,[pathFunc,foldername,filesep,'ROIsMeans',filesep,'ROI_' num2str(ty) '_BarPlot'],'fig')
        close(figxBar)
    end
    
    try
        close(figxBar)
    end
    
    fprintf('\r\n')
    fprintf('UF�C =============== %s\n',spm('time'));
    fprintf('Done!\r\n');
end

try
    close(fig)
end
try
    close(figr)
end
try
    close(figx)
end
try
    close(figr2)
end

if isequal(get(handles.FazPrep,'Value'),0)
	ps.Pool.AutoCreate = PsOri;
end

multiWaitbar('CloseAll'); %close the progressbar window
fclose('all');
save([pathFunc,foldername,filesep,'Total_Variable'],'WinAvSave')
set(handles.status,'String','Done!!!')
fprintf('\r\n')
fprintf('All Done! ========== %s\n',spm('time'));
fprintf('==========================================\r\n');

function FazPrep_Callback(hObject, eventdata, handles)
if get(handles.FazPrep,'Value')
    set(handles.AddStru,'Enable','off')
    set(handles.txtstru,'String','')
    set(handles.txtFunc,'String','')
    set(handles.FazFilt,'Enable','off')
    set(handles.LPF,'Enable','off')
    set(handles.HPF,'Enable','off')
    set(handles.stba,'Enable','off')
    set(handles.checkMOV,'Enable','off')
    set(handles.checkOsc,'Enable','off')
    set(handles.checkReg,'Enable','off')
    set(handles.text8,'Enable','off')
    set(handles.text9,'Enable','off')
    set(handles.text20,'Enable','off')
    set(handles.text19,'Enable','off')
    set(handles.text21,'Enable','off')
    set(handles.STCo,'Enable','off')
    set(handles.AddFunc,'String','Add FiltRegrSW Files')
    set(handles.FDcheck,'Enable','off')
    set(handles.extGM,'Enable','off')
    set(handles.extWM,'Enable','off')
    set(handles.extCSF,'Enable','off')
    set(handles.TM_FD,'Enable','off')
    set(handles.TM_DVARs,'Enable','off')
    set(handles.DVAR_TS,'Enable','off')
else
    set(handles.AddStru,'Enable','on')
    set(handles.FazFilt,'Enable','on')
    set(handles.LPF,'Enable','on')
    set(handles.HPF,'Enable','on')
    set(handles.stba,'Enable','on')
    set(handles.checkMOV,'Enable','on')
    set(handles.checkOsc,'Enable','on')
    set(handles.checkReg,'Enable','on')
    set(handles.text8,'Enable','on')
    set(handles.text9,'Enable','on')
    set(handles.text20,'Enable','on')
    set(handles.text19,'Enable','on')
    set(handles.text21,'Enable','on')
    set(handles.STCo,'Enable','on')
    set(handles.AddFunc,'String','Add Functional Files')
    set(handles.FDcheck,'Enable','on')
    set(handles.extGM,'Enable','on')
    set(handles.extWM,'Enable','on')
    set(handles.extCSF,'Enable','on')
    set(handles.TM_FD,'Enable','on')
    set(handles.TM_DVARs,'Enable','on')
    set(handles.DVAR_TS,'Enable','on')

end

function wsIn_Callback(hObject, eventdata, handles)
global numofVoluF ratioVol
smWin = str2num(get(handles.wsIn,'String'));
ratioVol = numofVoluF/smWin;

if ~isequal(ratioVol,round(ratioVol)) || smWin==0
    warndlg('The "Windows size" value can not be zero and should to be multiple of the "Number of Dynamics"','Attention')
    set(handles.wsIn,'String',num2str(numofVoluF))
    set(handles.fancyRes,'Enable','on')
    set(handles.fancyRes,'Value',1)
else if ~isequal(numofVoluF,smWin)
        set(handles.fancyRes,'Enable','off')
        set(handles.fancyRes,'Value',0)
    else
        set(handles.fancyRes,'Enable','on')
        set(handles.fancyRes,'Value',1)
    end
end

function SPMbb_Callback(hObject, eventdata, handles)
if isequal(get(handles.SPMbb,'Value'),1)
    set(handles.SSInp,'String','2 2 2')
else
    set(handles.SSInp,'String','4 4 4')
end


function pushbutton6_Callback(hObject, eventdata, handles)
global fileFunc

UF2Cdir = which('uf2c');
tmpDIR = [UF2Cdir(1:end-6) 'Analysis' filesep 'FC_tmp' filesep];

try
    delete([tmpDIR 'Subject_List_Func.txt']);
end

subL = transpose(fileFunc);
sList = size(subL,1);
fideSL = fopen([tmpDIR 'Subject_List_Func.txt'],'w+');

for lt = 1:sList
    fprintf(fideSL,'%d - %s\r\n',lt,fileFunc{lt});
end

fclose(fideSL)
open([tmpDIR 'Subject_List_Func.txt'])

function pushbutton7_Callback(hObject, eventdata, handles)
global fileStru

UF2Cdir = which('uf2c');
tmpDIR = [UF2Cdir(1:end-6) 'Analysis' filesep 'FC_tmp' filesep];

try
    delete([tmpDIR 'Subject_List_Stru.txt']);
end

subL = transpose(fileStru);
sList = size(subL,1);
fideSL = fopen([tmpDIR 'Subject_List_Stru.txt'],'w+');

for lt = 1:sList
    fprintf(fideSL,'%d - %s\r\n',lt,fileStru{lt});
end

fclose(fideSL)
open([tmpDIR 'Subject_List_Stru.txt'])

function HPF_Callback(hObject, eventdata, handles)
function FazFilt_Callback(hObject, eventdata, handles)
function TRInp_Callback(hObject, eventdata, handles)
    
function OutputFil_Callback(hObject, eventdata, handles)
function checkMOV_Callback(hObject, eventdata, handles)
function checkOsc_Callback(hObject, eventdata, handles)
function LPF_Callback(hObject, eventdata, handles)
function stba_Callback(hObject, eventdata, handles)
function SSInp_Callback(hObject, eventdata, handles)
function fancyRes_Callback(hObject, eventdata, handles)
function STCo_Callback(hObject, eventdata, handles)
function DVARthres_Callback(hObject, eventdata, handles)
function FDthres_Callback(hObject, eventdata, handles)

function FDcheck_Callback(hObject, eventdata, handles)
if get(handles.FDcheck,'Value')
    set(handles.TM_FD,'Value',0)
    set(handles.TM_FD,'Enable','on')
    set(handles.text28,'Enable','on')
    set(handles.FDthres,'Enable','on')
else
    set(handles.TM_FD,'Value',0)
    set(handles.TM_FD,'Enable','off')
    set(handles.text28,'Enable','off')
    set(handles.FDthres,'Enable','off')
end

function extGM_Callback(hObject, eventdata, handles)
if get(handles.extGM,'Value')
    set(handles.TM_DVARs,'Enable','on')
    set(handles.DVAR_TS,'Enable','on')
    set(handles.DVAR_TS,'Value',1)
else
    if get(handles.extWM,'Value') || get(handles.extCSF,'Value')
        set(handles.TM_DVARs,'Enable','on')
        set(handles.DVAR_TS,'Enable','on')
        set(handles.DVAR_TS,'Value',1)
    else
        set(handles.TM_DVARs,'Enable','off')
        set(handles.TM_DVARs,'Value',0)
        set(handles.text27,'Enable','off')
        set(handles.DVARthres,'Enable','off')
        set(handles.DVAR_TS,'Enable','off')
        set(handles.DVAR_TS,'Value',0)
    end
end
    
function extWM_Callback(hObject, eventdata, handles)
if get(handles.extWM,'Value')
    set(handles.TM_DVARs,'Enable','on')
    set(handles.DVAR_TS,'Enable','on')
    set(handles.DVAR_TS,'Value',1)
else
    if get(handles.extGM,'Value') || get(handles.extCSF,'Value')
        set(handles.TM_DVARs,'Enable','on')
        set(handles.DVAR_TS,'Enable','on')
        set(handles.DVAR_TS,'Value',1)
    else
        set(handles.TM_DVARs,'Enable','off')
        set(handles.TM_DVARs,'Value',0)
        set(handles.text27,'Enable','off')
        set(handles.DVARthres,'Enable','off')
        set(handles.DVAR_TS,'Enable','off')
        set(handles.DVAR_TS,'Value',0)
    end
end

function extCSF_Callback(hObject, eventdata, handles)
if get(handles.extCSF,'Value')
    set(handles.TM_DVARs,'Enable','on')
    set(handles.TM_DVARs,'Enable','on')
    set(handles.DVAR_TS,'Enable','on')
else
    if get(handles.extGM,'Value') || get(handles.extWM,'Value')
        set(handles.TM_DVARs,'Enable','on')
        set(handles.TM_DVARs,'Enable','on')
        set(handles.DVAR_TS,'Enable','on')
    else
        set(handles.TM_DVARs,'Enable','off')
        set(handles.TM_DVARs,'Value',0)
        set(handles.text27,'Enable','off')
        set(handles.DVARthres,'Enable','off')
        set(handles.DVAR_TS,'Enable','off')
        set(handles.DVAR_TS,'Value',0)
    end
end

function TM_DVARs_Callback(hObject, eventdata, handles)
if get(handles.TM_DVARs,'Value')
    set(handles.text27,'Enable','on')
    set(handles.DVARthres,'Enable','on')
else
    set(handles.text27,'Enable','off')
    set(handles.DVARthres,'Enable','off')
end

function TM_FD_Callback(hObject, eventdata, handles)
if get(handles.TM_FD,'Value')
    set(handles.text28,'Enable','on')
    set(handles.FDthres,'Enable','on')
else
    set(handles.text28,'Enable','off')
    set(handles.FDthres,'Enable','off')
end

function SSInp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function TRInp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function HPF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function LPF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function stba_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function wsIn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function FDthres_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function DVARthres_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function DVAR_TS_Callback(hObject, eventdata, handles)

function AliStru_Callback(hObject, eventdata, handles)
if get(handles.AliStru,'Value')
    set(handles.AliFunc,'Value',0)
else
    set(handles.AliFunc,'Value',1)
end

function AliFunc_Callback(hObject, eventdata, handles)
if get(handles.AliFunc,'Value')
    set(handles.AliStru,'Value',0)
else
    set(handles.AliStru,'Value',1)
end

function EPCo_Callback(hObject, eventdata, handles)

function figure1_CloseRequestFcn(hObject, eventdata, handles)
global PsOri ps

ps.Pool.AutoCreate = PsOri;

delete(hObject);
