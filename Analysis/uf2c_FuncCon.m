function varargout = uf2c_FuncCon(varargin)
% UF�C - User Friendly Functional Connectivity
% Brunno Machado de Campos
% University of Campinas, 2019
%
% Copyright (c) 2019, Brunno Machado de Campos
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
                   'gui_OpeningFcn', @uf2c_FuncCon_OpeningFcn, ...
                   'gui_OutputFcn',  @uf2c_FuncCon_OutputFcn, ...
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

function uf2c_FuncCon_OpeningFcn(hObject, eventdata, handles, varargin)
global PsOri ps

if license('test','Distrib_Computing_Toolbox')
    ps = parallel.Settings;
    PsOri = ps.Pool.AutoCreate;
end

handles.output = hObject;
guidata(hObject, handles);

function varargout = uf2c_FuncCon_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function addFunc_Callback(hObject, eventdata, handles)
global fileFunc pathFunc numofVoluF nOFsubjects matrixF VoxSizeF

if get(handles.FazPrep,'Value')
    set(handles.checkReg,'Enable','off')
else
    set(handles.checkReg,'Enable','on')
end

try
    clear('regVets');
    delete([tmpDIR 'additional_Reg.mat']);
end

[fileFunc,pathFunc] = uigetfile({'*.nii','NIfTI files'},'Select all the functional images','MultiSelect','on');

if ~isequal(fileFunc,0)
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

    previewF = nifti([pathFunc fileFunc{1}]);
    
    if isequal(get(handles.FazPrep,'Value'),0)
        TRvalue = previewF.timing.tspace;
        if ~isequal(TRvalue,0) && TRvalue>1
            set(handles.TRInp,'String',num2str(TRvalue))
        end
    end
    
    matrixF = previewF.dat.dim(1:3);
    numofVoluF = previewF.dat.dim(4);
    VoxSizeF = previewF.hdr.pixdim(2:4);
    VoxS_Res = [num2str(VoxSizeF(1,1)),'x',num2str(VoxSizeF(1,2)),'x',num2str(VoxSizeF(1,3))];
    MatS_Res = [num2str(matrixF(1,1)),'x',num2str(matrixF(1,2)),'x',num2str(matrixF(1,3))];

    set(handles.numDyna,'String',numofVoluF)
    set(handles.wsIn,'String',numofVoluF)
    set(handles.SizeVoxFunc,'String',num2str(VoxS_Res))
    set(handles.SizeMatFunc,'String',num2str(MatS_Res))
    set(handles.txtregress,'String','0 added')
%     set(handles.checkReg,'Value',0)
    set(handles.pushbutton6,'Enable','on')
end

function addStru_Callback(hObject, eventdata, handles)
global fileStru pathStru

[fileStru,pathStru] = uigetfile({'*.nii','NIfTI files'},'Select all the Structural images','MultiSelect','on');

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
          sprintf('Check the size of your files, it is the easiest way to identify the protocol homogeneity');'We can continue, but some errors and/or interpolations with distinct weights can occur.'},'Attention!');
    end
    clear bitS

    set(handles.txtstru,'String',sprintf('%d Structural image(s) added',size(fileStru,2)))

    previewS = nifti([pathStru fileStru{1}]);
    matrixS = previewS.dat.dim;
    VoxSizeS = previewS.hdr.pixdim(2:4);

    VoxS_Res = [num2str(VoxSizeS(1,1)),'x',num2str(VoxSizeS(1,2)),'x',num2str(VoxSizeS(1,3))];
    MatS_Res = [num2str(matrixS(1,1)),'x',num2str(matrixS(1,2)),'x',num2str(matrixS(1,3))];

    set(handles.edit9,'String',VoxS_Res)
    set(handles.edit10,'String',MatS_Res)
    set(handles.pushbutton7,'Enable','on')
end

function AddROIm_Callback(hObject, eventdata, handles)
global previewF2 matrixF2 VoxSizeF2  VoxSizeF ROImaskMAt

if get(handles.AddROIm,'Value')
    set(handles.ROIinp,'Enable','off')
    set(handles.SSInp,'Enable','off')
    [fileROI,pathROI] = uigetfile({'*.nii','NIfTI files'},'Select a 3D ROI mask','MultiSelect','off');

    previewF2 = nifti([pathROI fileROI]);
    ROImaskMAt = previewF2.dat(:,:,:);
    ROImaskMAt(ROImaskMAt<=0) = 0;
    ROImaskMAt(ROImaskMAt>0) = 1;
    matrixF2 = previewF2.dat.dim(1:3);
    VoxSizeF2 = previewF2.hdr.pixdim(2:4);
    
    VoxSizeF2 = num2str(VoxSizeF2);
    VoxSizeF2 = double(str2num(VoxSizeF2));

    VoxSizeFtmp = num2str(VoxSizeF);
    VoxSizeFtmp = double(str2num(VoxSizeFtmp));

    if ~get(handles.FazPrep,'Value')
        if isequal(matrixF2,matrixF) && isequal(VoxSizeF2,VoxSizeFtmp)
           set(handles.Run,'Enable','on')
        else
           warndlg('The ROI mask added do not match to the Preprocessed functional images that you previously added!', 'My Warn Dialog');
           set(handles.AddROIm,'Value',0)
           set(handles.Run,'Enable','off')
        end
    else
        if get(handles.SPMbb,'Value')
           if isequal(matrixF2,[53 63 46]) && isequal(VoxSizeF2,VoxSizeF)
               set(handles.Run,'Enable','on')
           else
               warndlg('The ROI mask added do not match to the functional images that you previously added!', 'My Warn Dialog');
               set(handles.AddROIm,'Value',0)
               set(handles.Run,'Enable','off')
           end
        else
            tmpStr = num2str(VoxSizeF2);
            VoxSizeF2 = str2num(tmpStr);
            if isequal(matrixF2,[91 109 91]) && isequal(double(VoxSizeF2),[2 2 2])
               set(handles.Run,'Enable','on')
            else
               warndlg('The ROI mask added do not match to the functional images that you previously added!', 'My Warn Dialog');
               set(handles.AddROIm,'Value',0)
               set(handles.Run,'Enable','off')
            end
        end
    end
else
    set(handles.ROIinp,'Enable','on')
    set(handles.SSInp,'Enable','on')
end

function Run_Callback(hObject, eventdata, handles)
global fileStru pathStru fileFunc pathFunc numofVoluF...
    nrg tmpDIR ROImaskMAt nOFsubjects PsOri ps EPCo

    UDV = uf2c_defaults('FuncCon');
    
    EPCo = get(handles.EPCo,'Value');
    if isequal(get(handles.FazPrep,'Value'),0)
        if EPCo
            delete(gcp('nocreate'))
            if license('test','Distrib_Computing_Toolbox')
                numcores = feature('numcores');
                try
                    parpool(numcores-UDV.NC2R);
                end
            else
                set(handles.EPCo,'Value',0);
            end
        else
            if license('test','Distrib_Computing_Toolbox')
                ps.Pool.AutoCreate = false;
            end
        end
        if ~isequal(size(fileStru,2),size(fileFunc,2))
            warndlg({sprintf('The numbers of functional (%d) and structural (%d) images are different.',size(fileFunc,2),size(fileStru,2));...
              'You need to add one functional image for each strutural and vice versa.';...
              'If you have more than one functional section from the same subject, make copies of the structural image and add all!'},...
              'Attention: process aborted!');
          fclose('all');  
          return
        end
    end

    set(handles.status,'String','Running...')
    drawnow

    try
        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Process started\n');
        fprintf('==========================================\r\n');
        
        dateNow = clock;
        foldername = sprintf('1-Total_Log_%d_%d_%d--%d_%d', dateNow(3),dateNow(2),dateNow(1),dateNow(4),dateNow(5));

        mkdir(pathFunc,foldername)

        imgRR = getframe(uf2c_FuncCon);
        imwrite(imgRR.cdata, [pathFunc,filesep,foldername,filesep,'1-Your_Choices.png']);
        
        options = struct('format','pdf','outputDir',[pathFunc,filesep,foldername,filesep]);
        publish('uf2c_defaults.m',options);
        
        roicoord = str2num(get(handles.ROIinp,'String')); % Center ROI coordinate (MNI152) (PCC)
        seedSizeMat = str2num(get(handles.SSInp,'String'));

        x = seedSizeMat(1); % ROI size in voxels (HALF VALUE FOR EACH SIDE)
        y = seedSizeMat(2);
        z = seedSizeMat(3);

        WS = str2num(get(handles.wsIn,'String')); %Window Size (SIZE OF THE MOVING AVERAGE TO CALC DE CORRELATIONS)
        TR = str2num(get(handles.TRInp,'String'));    % repetition time (s)

        multiWaitbar('Total Progress', 0, 'Color', 'g' );  %CHARGE WAIT BAR

        if isequal(get(handles.FazPrep,'Value'),0)
            multiWaitbar('Filtering & Regression', 0, 'Color', 'y' ); %CHARGE WAIT BAR
            if ~isequal(nOFsubjects,size(fileStru,2)) %VERIFY COERENCE IN THE FILES NUMBER
                warndlg('The number of functional and structural files needs to match','Attention, runninng aborted!')
                fclose('all');
                return
            end
        end

        smWin = str2double(get(handles.wsIn, 'String'));
        ratioVol = numofVoluF/smWin;

        if ~isequal(ratioVol,round(ratioVol))
            warndlg('The "Window Size" and "Number of Dynamics" should to be multiples','Attention, runninng aborted!')
            return
        end
        
        fideSJ = fopen([pathFunc,filesep,foldername,filesep,'1-Subjects.txt'],'w+'); 
        for yTy = 1:size(fileFunc,2)
            fprintf(fideSJ,'%d: \t%s\r\n',yTy,fileFunc{1,yTy});
        end
        fclose(fideSJ);

        fideG = fopen([pathFunc,filesep,foldername,filesep,'Total_Results.txt'],'w+'); % CHARGE OUTPUT LOG FILE

        fprintf(fideG,'                                          Functional Conectivity ROI Analysis\r\n\r\n');
        fprintf(fideG,'Number of subjects included: \t%d \r\n\r\n', nOFsubjects);
        fprintf(fideG, 'Subject_file_name \t Average_Positive_Correlation_Value \t Average_Negative_Correlation_Value \t Average_Positive_Right_Value \t Average_Positive_Left_Value \t Average_Negative_Right_Value \t Average_Negative_Left_Value\r\n');

        if isequal(get(handles.FazPrep,'Value'),0) % just if you need preprocessing
            
            Totmovtxt = fopen([pathFunc,filesep,foldername,filesep,'Total_Movement.txt'],'w+'); % CHARGE OUTPUT LOG FILE
            fprintf(Totmovtxt,'Subject \t Maximum Displacemente (mm) \t Maximum Rotation (degree) \t Avg Framiwise Displacemente (FD) (mm) \t numb of FD Censored scans \t Avg DVARs (%%) \t numb of DVAR Censored scans \t Total Censored scans \r\n');

            if isequal(get(handles.FazFilt,'Value'),1)
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
                HdLOW = design(hLOW, 'equiripple');

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

        WinAvSavePos = struct;
        WinAvSaveNeg = struct;
        SPMdir2 = which('spm');
        SPMdir2 = SPMdir2(1:end-5);
    catch
        set(handles.status,'String','Error...')
        warndlg('An error occured before subject loop. Check your data, and your uf�C pre-requirements.', 'Process Aborted')
        return
    end
    
    FunpreT = nifti([pathFunc,fileFunc{1}]);

    if isequal(WS,FunpreT.dat.dim(4))
        dynStu= 0;
    else
        dynStu= 1;
    end

    ExclSub = 0;
    
    if ~get(handles.SPMbb,'Value')
        fideGxPT = fopen([pathFunc,filesep,foldername,filesep,'TOTAL_Anatomical_Quantification-Positive.txt'],'w+'); % CHARGE OUTPUT LOG FILE
        fideGxNT = fopen([pathFunc,filesep,foldername,filesep,'TOTAL_Anatomical_Quantification-Negative.txt'],'w+'); % CHARGE OUTPUT LOG FILE

        fprintf(fideGxPT,'UF�C: TOTAL ROIs Anatomical Labelling and Quantifications\r\n\r\n');
        fprintf(fideGxNT,'UF�C: These are the average connectivity  values (r-score) between each\r\n');
        fprintf(fideGxNT,'UF�C: anatomical label and the defined seed.\r\n\r\n');
        fprintf(fideGxPT,'These data are better visualized if imported to a MS Excel type software\r\n\r\n');
        fprintf(fideGxPT,'Credits:\r\n');
        fprintf(fideGxPT,'Maximum probability tissue labels derived from:\r\n');
        fprintf(fideGxPT,'''MICCAI 2012 Grand Challenge and Workshop on Multi-Atlas Labeling''\r\n');
        fprintf(fideGxPT,'These data were released under the Creative Commons Attribution-NonCommercial (CC BY-NC) with no end date.\r\n');
        fprintf(fideGxPT,'Labeled data provided by Neuromorphometrics, Inc. (http://Neuromorphometrics.com/) under academic subscription".\r\n\r\n\r\n');


        fprintf(fideGxNT,'UF�C: ROIs Anatomical Labelling and Quantifications\r\n\r\n');
        fprintf(fideGxNT,'UF�C: These are the average connectivity  values (r-score) between each\r\n');
        fprintf(fideGxNT,'UF�C: anatomical label and the defined seed.\r\n\r\n');
        fprintf(fideGxNT,'These data are better visualized if imported to a MS Excel type software\r\n\r\n');
        fprintf(fideGxNT,'Credits:\r\n');
        fprintf(fideGxNT,'Maximum probability tissue labels derived from:\r\n');
        fprintf(fideGxNT,'''MICCAI 2012 Grand Challenge and Workshop on Multi-Atlas Labeling''\r\n');
        fprintf(fideGxNT,'These data were released under the Creative Commons Attribution-NonCommercial (CC BY-NC) with no end date.\r\n');
        fprintf(fideGxNT,'Labeled data provided by Neuromorphometrics, Inc. (http://Neuromorphometrics.com/) under academic subscription".\r\n\r\n\r\n');
    

        DirUF2C = which('uf2c');
        try
            load([DirUF2C(1:end-6) 'Utilities' filesep 'NeuromorphometricsLabels.mat']); 
        catch
            load([DirUF2C(1:end-13) 'Utilities' filesep 'NeuromorphometricsLabels.mat']); 
        end

        loopSize = numel(NeuromorphometricsLabels.Index);

        fprintf(fideGxPT,'Subject\t');
        fprintf(fideGxNT,'Subject\t');

        for jh = 1:loopSize
            fprintf(fideGxPT,'%s\t',NeuromorphometricsLabels.Label{jh});
            fprintf(fideGxNT,'%s\t',NeuromorphometricsLabels.Label{jh});
        end

        fprintf(fideGxPT,'\r\n');
        fprintf(fideGxNT,'\r\n');
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%% START OF SUBJECT LOOP %%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%% START OF SUBJECT LOOP %%%%%%%%%%%%%%%%%%%
    for yy = 1:nOFsubjects

        multiWaitbar('Total Progress', (yy/nOFsubjects)*0.95 );
        multiWaitbar('Filtering & Regression', 'Reset' );

        fprintf('\r\n')
        fprintf('UF�C ===================== %s\n',spm('time'));
        if isequal(get(handles.FazPrep,'Value'),0)
            fprintf('Starting subj. %d  (%s...)\n',yy,fileFunc{yy}(1:round(size(fileFunc{yy},2)/3)));
        else
            fprintf('Starting subj. %d  (%s...)\n',yy,fileFunc{yy}(12:12+round(size(fileFunc{yy},2)/3)));
        end
        fprintf('================================================\r\n\r\n');

        Funpre = nifti([pathFunc,fileFunc{yy}]);

        if dynStu
             if mod(Funpre.dat.dim(4),WS)
                 ExclSub = ExclSub+1;
                 if isequal(get(handles.FazPrep,'Value'),0)
                     fprintf('subj. %d  (%s...) process aborted!\n',yy,fileFunc{yy}(1:round(size(fileFunc{yy},2)/3)));
                 else
                     fprintf('subj. %d  (%s...) process aborted!\n',yy,fileFunc{yy}(12:12+round(size(fileFunc{yy},2)/3)));
                 end
                 fprintf('The number of dynamics and the time blocs are not multiple\n');
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
                dirname = dirname(1:UDV.MSDN);
            end
            
            nfidx = 1;
            while isequal(exist([pathFunc,dirname],'dir'),7)
                dirname = [dirname '_' num2str(nfidx)];
                nfidx = nfidx + 1;
            end

            mkdir(pathFunc,dirname)
        end
        
        mkdir([pathFunc,dirname],'Results_Log')
        mkdir([pathFunc,dirname],'ROI_mask')
        mkdir([pathFunc,dirname],'Correlation_map')

        fide = fopen([pathFunc,dirname,filesep,'Results_Log',filesep,'Results_Log.txt'],'w+');

        if isequal(get(handles.FazPrep,'Value'),0)
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Preprocessing
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                STC = get(handles.STCo,'Value');
                BounB = get(handles.SPMbb,'Value');
                fileFuncX = fileFunc{yy};
                fileStruX = fileStru{yy};
                uf2c_Preproc(file1,file2,BounB,SPMdir2,Svs,fvs,pathFunc,dirname,STC,Funpre,TR,fileFuncX,fileStruX)
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
            Motfid = fopen([pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'Motion_Quantifications.txt'],'w+');
            fprintf(Motfid,'Motion Quantifications\r\n\r\n');
            fprintf(Motfid,'Subject Name: \t%s\r\n',dirname);

            [Mot_fig,HDvV,HTvV] = uf2c_plot_motion([pathFunc,dirname,filesep,'rp_',fileFunc{yy}(1:end-3),'txt'],UDV.MFVstr);
            imgRR = getframe(Mot_fig);
            imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'Realignment_Parameters_Plot.png']);
            saveas(Mot_fig,[pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'Realignment_Parameters_Plot'],'fig')

            fprintf(Motfid,'Maximum Displacemente (mm): %s \r\n',HDvV);
            fprintf(Motfid,'Maximum Rotation (degree): %s \r\n',HTvV);
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
                    'Position', round([ScreSize(2)*.1 ScreSize(2)*.1 ScreSize(2)*.8 ScreSize(2)*.4]),...
                    'Color',[1 0.94 0.86]);
                
                BinVetFDMEAN = double(FDts>str2num(get(handles.FDthres,'String')));
                BinVetFDMEAN = BinVetFDMEAN.*FDts;

                plot(FDts);
                hold on
                plot(ones(1,numel(FDts)).*str2num(get(handles.FDthres,'String')));
                area(BinVetFDMEAN,'FaceColor','r')
                ylabel('FD (mm)')
                xlabel('Time Points')
                title('Average Framewise Displacement TS','FontSize', 14);
                drawnow    
                
                imgRR = getframe(figuFD);
                imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'FramewiseDisplacement_avgTS.png']);
                saveas(figuFD,[pathFunc,dirname,filesep,'Motion_Controls_Params',filesep,'FramewiseDisplacement_avgTS'],'fig')
                close(figuFD)
                fprintf(Motfid,'BRAMILA''s average Framiwise Displacemente (FD): %.3f \r\n',mean(FDts));
                fprintf('Done! ============== %s\r\n',spm('time'));
                fprintf(Totmovtxt,'%.5f \t',mean(FDts));
            else
                fprintf(Totmovtxt,'N/A\t');
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
                fprintf(Totmovtxt,'N/A\t');
            end

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Extracting Globals and Masking
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                FI = UDV.FI;
                [sizeFunc,finalEPI,MeanWM,MeanCSF,Func] = uf2c_mask_globals(fvs,pathFunc,dirname,fileFunc{yy},fileStru{yy},get(handles.SPMbb,'Value'),FI,UDV.WMI,UDV.NativeS);
            catch
                set(handles.status,'String','Error...')
                warndlg(sprintf('An error occured during subject %d globals and mask extraction. Check your data.',yy), 'Process Aborted')
                return
            end
            
            try
                close(Mot_fig)
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Reshaping and Thresholding
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                Dx = size(finalEPI,1);
                Dy = size(finalEPI,2);
                Dz = size(finalEPI,3);
                Dt = size(finalEPI,4);

                [finalEPI,histCut] = uf2c_imgthres(finalEPI,Dx,Dy,Dz,ScreSize,pathFunc,dirname);
                imgRR = getframe(histCut);
                imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Avg_Img_Histogram.tif']);
            catch
                set(handles.status,'String','Error...')
                warndlg(sprintf('An error occured during subject %d thresholding. Check your data.',yy), 'Process Aborted')
                return
            end
            
            
            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Smoothing\r\n');
            newEPI = Func;
            newEPI.dat.fname = [pathFunc,dirname,filesep,'tmpW_',fileFunc{yy}];
            newEPI.descrip = 'UF�C-Filtered_Regressed_sw_EPI';
            newEPI.dat.dtype = 'INT16-LE';
            newEPI.dat(:,:,:,:) = finalEPI;
            create(newEPI)
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Smooth %%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            clear file1
            for tt = 1:newEPI.dat.dim(4)
                file1{tt,1} = [pathFunc,dirname,filesep,'tmpW_',fileFunc{yy},',',sprintf('%d',tt)];
            end
            clear job
            job.data = file1;
            if BounB
                job.fwhm = [UDV.SmoFac*fvs(1) UDV.SmoFac*fvs(2) UDV.SmoFac*fvs(3)];
            else
                job.fwhm = [6 6 6];
            end
            job.dtype = 0;
            job.im = 1;
            job.prefix = 's';
            spm_run_smooth(job);
            
            preFiReStru = nifti([pathFunc,dirname,filesep,'stmpW_',fileFunc{yy}]);
            finalEPI = preFiReStru.dat(:,:,:,:);
            clear preFiReStru
            delete([pathFunc dirname filesep 'stmpW_' fileFunc{yy}])
            delete([pathFunc dirname filesep 'tmpW_' fileFunc{yy}])
            fprintf('Done! ============== %s\n\r',spm('time'));

            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % BRAMILA DVARS - Computes Derivative VARiance
            % Code from: Brain and Mind Lab at Aalto University
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            extGMvar = get(handles.extGM,'Value');
            extWMvar = get(handles.extWM,'Value');
            extCSFvar = get(handles.extCSF,'Value');
            DVARthresV = str2num(get(handles.DVARthres,'String'));
            
            if extGMvar || extWMvar || extCSFvar
                [dvarsC1,dvarsC2,dvarsC3,MeanDvars] = uf2c_bramila_dvars(pathFunc,dirname,finalEPI,extGMvar,extWMvar,extCSFvar,DVARthresV);
                fprintf(Motfid,'BRAMILA''s Average Derivative VARiance (DVAR) GM masked: %.3f \r\n',mean(dvarsC1));
                fprintf(Motfid,'BRAMILA''s Average Derivative VARiance (DVAR) WM masked: %.3f \r\n',mean(dvarsC2));
                fprintf(Motfid,'BRAMILA''s Average Derivative VARiance (DVAR) CSF masked: %.3f \r\n',mean(dvarsC3));
                fprintf(Totmovtxt,'%.4f \t',mean(MeanDvars));
            else
                MeanDvars = [];
                fprintf(Totmovtxt,'N/A\t');
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
                fprintf(Totmovtxt,'N/A\t');
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
                    [Frgval,Regstr,figu,thicksL] = uf2c_regrprep(yy,get(handles.checkMOV,'Value'),...
                        pathFunc,dirname,fileFunc{yy},get(handles.checkOsc,'Value'),...
                        get(handles.checkReg,'Value'),ScreSize,MeanWM,MeanCSF,...
                        size(finalEPI,4),nrg);
                    
                    if ~isempty(figu)
                        if isequal(get(handles.TM_FD,'Value'),0) && isequal(get(handles.TM_DVARs,'Value'),0)
                            imgRR = getframe(figu);
                            imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Regression Matrix.png']);
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
                [Frgval,figu,Censu] = uf2c_Add_FD_DVAR(figu,thicksL,Frgval,pathFunc,dirname,TM_DVARsV,TM_FDV,DVAR_tsV,MeanDvars,FD_TM,dvars_TM,size(finalEPI,4));
                if size(Frgval,2)>1
                    Regstr = [Regstr,'_tmpMask'];
                end
                if TM_DVARsV || TM_FDV
                    nOfSensu = size(Censu,2);
                    fprintf(Totmovtxt,'%d\r\n',nOfSensu);
                end
            else
                fprintf(Totmovtxt,'N/A\r\n');
            end

            try
                close(figu)
            end
            try
                close(histCut)
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Filtering and regressions
            %%%%%%%%%%%%%%%%%%%%%%%%%%%
            if  get(handles.FazFilt,'Value') || ~isequal(Regstr,'') || TM_DVARsV || TM_FDV
                fprintf('\r\n')
                fprintf('UF�C =============== %s\n',spm('time'));
                fprintf('Performing regressions and/or filtering\r\n');

                BinFazFilt = get(handles.FazFilt,'Value');
                finalEPI = uf2c_filtregr(finalEPI,BinFazFilt,Dx,Dy,Dz,Dt,Frgval,HdLOW,HdHIGH,aFil,tmp1,tmp2,Regstr);
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            % Creating the FiltRegre Image
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            try
                if  get(handles.FazFilt,'Value') || ~isequal(Regstr,'')
                    if  get(handles.FazFilt,'Value') && ~isequal(Regstr,'')
                        newEPI = Func;
                        newEPI.dat.fname = [pathFunc,dirname,filesep,'FiltRegrSW_',fileFunc{yy}];
                        newEPI.descrip = 'UF�C-Filtered_Regressed_sw_EPI';
                        newEPI.dat.dtype = 'INT16-LE';
                        newEPI.dat(:,:,:,:) = finalEPI;
                        create(newEPI)
                        
                        fprintf('Done! ============== %s\n\r',spm('time'));
                    else
                        if get(handles.FazFilt,'Value') && isequal(Regstr,'')
                            newEPI = Func;
                            newEPI.dat.fname = [pathFunc,dirname,filesep,'FiltSW_',fileFunc{yy}];
                            newEPI.descrip = 'UF�C-Filtered_sw_EPI';
                            newEPI.dat.dtype = 'INT16-LE';
                            newEPI.dat(:,:,:,:) = finalEPI;
                            create(newEPI)
                            
                            fprintf('Done! ============== %s\n\r',spm('time'));
                        else
                            newEPI = Func;
                            newEPI.dat.fname = [pathFunc,dirname,filesep,'RegrSW_',fileFunc{yy}];
                            newEPI.descrip = 'UF�C-Regressed_sw_EPI';
                            newEPI.dat.dtype = 'INT16-LE';
                            newEPI.dat(:,:,:,:) = finalEPI;
                            create(newEPI)
                            
                            fprintf('Done! ============== %s\n\r',spm('time'));
                        end
                    end
                else
                    newEPI = Func;
                    newEPI.dat.fname = [pathFunc,dirname,filesep,'ThreSW_',fileFunc{yy}];
                    newEPI.descrip = 'UF�C-Masked and Thresholded_sw_EPI';
                    newEPI.dat.dtype = 'INT16-LE';
                    newEPI.dat(:,:,:,:) = finalEPI;
                    create(newEPI)
                    fprintf('Done! ============== %s\n\r',spm('time'));
                end
            catch
                set(handles.status,'String','Error...')
                warndlg(sprintf('An error occured during subject %d image creation. Check the avaiable disk space.',yy), 'Process Aborted')
                fclose('all');
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
                fclose('all');
                return
            end
        end

        try
            if isequal(get(handles.AddROIm,'Value'),1)
                fprintf('\r\n')
                fprintf('UF�C =============== %s\n',spm('time'));
                fprintf('Processing ROI\n');
                roi1 = ROImaskMAt;
                fprintf('Done! ============== %s\r\n',spm('time'));
            else
                fprintf('\r\n')
                fprintf('UF�C =============== %s\n',spm('time'));
                fprintf('Processing coordinate\n');
                fprintf('    Converting to voxel space\r\n');

            %   Convert from MNI coord to matrix coord.
                if isequal(get(handles.FazPrep,'Value'),0)
                    Vhdr = spm_vol([pathFunc,dirname,filesep,'sw',fileFunc{yy}]);
                else
                    Vhdr = spm_vol([pathFunc,fileFunc{yy}]);
                end

                TcM = Vhdr.mat;
                EPIcoord = [roicoord(:,1) roicoord(:,2) roicoord(:,3) ones(size(roicoord,1),1)]*(inv(TcM))';
                EPIcoord(:,4) = [];
                EPIcoord = round(EPIcoord);

                fprintf('    Done!\r\n');
                
%                 roi1 = zeros(Dx,Dy,Dz);%Prelocation
%                 Sxx = x/2;
%                 Syy = y/2;
%                 Szz = z/2;
% 
%                 if Sxx<1
%                     Sxx=0;
%                 end
%                 if Syy<1
%                     Syy=0;
%                 end
%                 if Szz<1
%                     Szz=0;
%                 end
%                 %%%%%%%%%%%%%%%%%%%% Create A cubic ROI centered in the input coordinate %%%%%%%%%%%%%%%%%%%%%%
%                 roi1(EPIcoord(1):EPIcoord(1)+Sxx, EPIcoord(2):EPIcoord(2)+Syy, EPIcoord(3):EPIcoord(3)+Szz) = 1;
%                 roi1(EPIcoord(1)-Sxx:EPIcoord(1), EPIcoord(2):EPIcoord(2)+Syy, EPIcoord(3):EPIcoord(3)+Szz) = 1;
% 
%                 roi1(EPIcoord(1):EPIcoord(1)+Sxx, EPIcoord(2)-Syy:EPIcoord(2), EPIcoord(3):EPIcoord(3)+Szz) = 1;
%                 roi1(EPIcoord(1):EPIcoord(1)+Sxx, EPIcoord(2):EPIcoord(2)+Syy, EPIcoord(3)-Szz:EPIcoord(3)) = 1;
% 
%                 roi1(EPIcoord(1)-Sxx:EPIcoord(1), EPIcoord(2):EPIcoord(2)+Syy, EPIcoord(3)-Szz:EPIcoord(3)) = 1;
%                 roi1(EPIcoord(1):EPIcoord(1)+Sxx, EPIcoord(2)-Syy:EPIcoord(2), EPIcoord(3)-Szz:EPIcoord(3)) = 1;
% 
%                 roi1(EPIcoord(1)-Sxx:EPIcoord(1), EPIcoord(2)-Syy:EPIcoord(2), EPIcoord(3)-Szz:EPIcoord(3)) = 1;
%                 roi1(EPIcoord(1)-Sxx:EPIcoord(1), EPIcoord(2)-Syy:EPIcoord(2), EPIcoord(3):EPIcoord(3)+Szz) = 1;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                roi1 = zeros(Dx,Dy,Dz);%Prelocation
                [Xtt,Ytt,Ztt] = ndgrid(linspace(-1,1,x+1),linspace(-1,1,y+1),linspace(-1,1,z+1));
                Rcoo = sqrt((Xtt).^2+(Ytt).^2+(Ztt).^2);
                SphM = zeros(size(Xtt));
                SphM(Rcoo<=1) = 1;
                SphM(Rcoo>1) = 0;
                roi1(EPIcoord(1)-(x/2):EPIcoord(1)+(x/2),EPIcoord(2)-(y/2):EPIcoord(2)+(y/2),EPIcoord(3)-(z/2):EPIcoord(3)+(z/2)) = SphM;
                
            end
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d ROI creation. Check your data and/or coordinate.',yy), 'Process Aborted')
            fclose('all');
            return
        end
        try
            [iCo,jCo,kCo]= ind2sub(size(roi1), find(roi1>0));
            coords = [iCo,jCo,kCo];
            IniNofVox = numel(iCo);
            
            for vx = 1:Dt % get the ROI voxels time series. This step exclude from the ROI eventuals with matter voxels.
                final3D(:,:,:) = roi1.*finalEPI(:,:,:,vx);
                for hj = 1:size(coords,1)
                    vetsCor(vx,hj) = final3D(coords(hj,1),coords(hj,2),coords(hj,3));
                end
            end

            %%%%% Tester of corregistering
            struX = Func;
            struX.dat.fname = [pathFunc,dirname,filesep,'ROI_mask',filesep,dirname,'_TesterRoi.nii'];
            struX.dat.dim = [Dx Dy Dz];
            struX.dat.dtype = 'FLOAT32-LE'; % verify matrix datatype
            struX.dat(:,:,:) =  roi1.*finalEPI(:,:,:,1); % add matrix value to the NIfTI object
            create(struX) % creates the NIfTI file from the Object
            %%%%% Tester of corregistering
            
            vetsCor(:,~any(vetsCor,1) ) = [];
            verifCor = mean(vetsCor,2);
            xxX = corr(vetsCor(:,:),verifCor);
            xxX(isnan(xxX)) = 0;
            
% Option 1: Outliers (lower ('lowerside') than 1 ('severe') IQR) would be removed         
            xxXxx = uf2c_outlierdetec(xxX,UDV.RMOR,'lowerside');
            vetsCorF = vetsCor;
            vetsCorF(:,xxXxx) = [];
            
% Option 2: Mean minus 1 STD would be removed            
%             xxX_Z = 0.5.*(log(1+xxX) - log(1-xxX)); %Z transf
%             stdxxX = std(xxX_Z);
%             meanxxX = mean(xxX_Z);
%             lowerCut = meanxxX-stdxxX;
%             alower = (xxX_Z<lowerCut);  
%             CutFinal = alower;
%             CutFinal = (abs(CutFinal-1))';
%             CutFinal = repmat(CutFinal,size(vetsCor,1),1);
%             vetsCorF = CutFinal.*vetsCor;
%             vetsCorF(:,~any(vetsCorF,1) ) = [];
            
            Size4D = size(vetsCorF,2);
            mean4D = (mean(vetsCorF,2))';
            
            finalNofVox = size(vetsCorF,2);
            
            Rois_N_of_Voxels__Init_vs_Final(1,1) = IniNofVox;
            Rois_N_of_Voxels__Init_vs_Final(1,2) = finalNofVox;

            fprintf('Attention!\n');
            fprintf('%d of %d voxel(s) was (were) removed from the seed due \n',(size(coords,1)-Size4D),numel(xxX));
            fprintf('hight temporal variability when compared to the anothers \r\n\r\n');
            fprintf(fide,'%d of %d voxel(s) was (were) removed from the \r\n',(size(coords,1)-Size4D),numel(xxX));
            fprintf(fide,'seed due hight temporal variability when compared to the anothers \r\n\r\n');

            fprintf('Done! ============== %s\r\n',spm('time'));
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d time series extraction and processing. Check your data and/or coordinate.',yy), 'Process Aborted')
            fclose('all');
            return
        end
        
        save([pathFunc,dirname,filesep,'Rois_NofVoxels_Init_vs_Final.mat'],'Rois_N_of_Voxels__Init_vs_Final')
        save([pathFunc,dirname,filesep,'Seed_TimeSeries.mat'],'mean4D')

        
        try
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
            %Correlation %%%%%%%%%%%%%%%%%%%%%
            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Performing Cross-Correlations\n');

            finalEPI = reshape(finalEPI,prod([Dx,Dy,Dz]),Dt)';
            map = zeros(Dt/WS,prod([Dx,Dy,Dz]));%Prelocation
            Vn = 1;
            for MA = 1:WS:Dt
                map(Vn,:) = corr(finalEPI(MA:MA+(WS-1),:),mean4D(MA:MA+(WS-1))');
                Vn = Vn+1;
            end
            map(isnan(map)) = 0;
            map = reshape(map',Dx,Dy,Dz,Dt/WS);
            map = squeeze(map);
            fprintf('Done! ============== %s\r\n',spm('time'));
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d connectivity estimation. Check your data.',yy), 'Process Aborted')
            fclose('all');
            return
        end
        try
            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Tabulating Results\n');

            asP = map>0;
            mapP = map.*asP;
            asN = map<0;
            mapN = map.*asN;
            mapN2 = abs(mapN);
            
            if ~get(handles.SPMbb,'Value')
                
                fideGxP = fopen([pathFunc,filesep,dirname,filesep,'Results_Log',filesep,'Anatomical_Quantification-Positive.txt'],'w+'); % CHARGE OUTPUT LOG FILE
                fideGxN = fopen([pathFunc,filesep,dirname,filesep,'Results_Log',filesep,'Anatomical_Quantification-Negative.txt'],'w+'); % CHARGE OUTPUT LOG FILE

                fprintf('\r\n')
                fprintf('UF�C =============== %s\n',spm('time'));
                fprintf('Processing ROIs Files\n');
                    fprintf('\tPerforming ROIs anatomical labeling\n');

                fprintf(fideGxP,'UF�C: ROIs Anatomical Labelling and Quantifications\r\n\r\n');
                fprintf(fideGxP,'These data are better visualized if imported to a MS Excel type software\r\n\r\n');
                fprintf(fideGxP,'Credits:\r\n');
                fprintf(fideGxP,'Maximum probability tissue labels derived from:\r\n');
                fprintf(fideGxP,'''MICCAI 2012 Grand Challenge and Workshop on Multi-Atlas Labeling''\r\n');
                fprintf(fideGxP,'These data were released under the Creative Commons Attribution-NonCommercial (CC BY-NC) with no end date.\r\n');
                fprintf(fideGxP,'Labeled data provided by Neuromorphometrics, Inc. (http://Neuromorphometrics.com/) under academic subscription".\r\n\r\n\r\n');


                fprintf(fideGxN,'UF�C: ROIs Anatomical Labelling and Quantifications\r\n\r\n');
                fprintf(fideGxN,'These data are better visualized if imported to a MS Excel type software\r\n\r\n');
                fprintf(fideGxN,'Credits:\r\n');
                fprintf(fideGxN,'Maximum probability tissue labels derived from:\r\n');
                fprintf(fideGxN,'''MICCAI 2012 Grand Challenge and Workshop on Multi-Atlas Labeling''\r\n');
                fprintf(fideGxN,'These data were released under the Creative Commons Attribution-NonCommercial (CC BY-NC) with no end date.\r\n');
                fprintf(fideGxN,'Labeled data provided by Neuromorphometrics, Inc. (http://Neuromorphometrics.com/) under academic subscription".\r\n\r\n\r\n');

                DirUF2C = which('uf2c');
                try
                    LabelImgS = nifti([DirUF2C(1:end-6) 'Utilities' filesep 'labels_Neuromorphometrics_91-109-91.nii']);
                    load([DirUF2C(1:end-6) 'Utilities' filesep 'NeuromorphometricsLabels.mat']); 
                catch
                    LabelImgS = nifti([DirUF2C(1:end-13) 'Utilities' filesep 'labels_Neuromorphometrics_91-109-91.nii']);
                    load([DirUF2C(1:end-13) 'Utilities' filesep 'NeuromorphometricsLabels.mat']); 
                end
                LabelImgMAT = LabelImgS.dat(:,:,:);

                loopSize = numel(NeuromorphometricsLabels.Index);
           
                fprintf(fideGxP,'The number of correlation windows  is: %d\r\n\r\n',Vn-1);
                fprintf(fideGxN,'The number of correlation windows  is: %d\r\n\r\n',Vn-1);

                fprintf(fideGxPT,'%s\t',dirname);
                fprintf(fideGxNT,'%s\t',dirname);

                for jh = 1:loopSize
                    fprintf(fideGxP,'ROI %d:\t%s\r\n',jh,NeuromorphometricsLabels.Label{jh});
                    fprintf(fideGxN,'ROI %d:\t%s\r\n',jh,NeuromorphometricsLabels.Label{jh});

                    LabelImgMATbin = double(LabelImgMAT==NeuromorphometricsLabels.Index(jh,1));

                    fprintf(fideGxP,'Time Window\tAverage Score\tConsidered N Voxels\t%% of Label overlapings\r\n');
                    fprintf(fideGxN,'Time Window\tAverage Score\tConsidered N Voxels\t%% of Label overlapings\r\n');

                    for ix = 1:(Vn-1)
                        MultROILabP(:,:,:,ix) = LabelImgMATbin.*mapP(:,:,:,ix);
                        MultROILab2P = squeeze(MultROILabP(:,:,:,ix));
                        nOfvoxP = nnz(MultROILab2P);
                        SomavP = sum(sum(sum(MultROILab2P)));
                        AvgVP = SomavP/nOfvoxP;
                        Mean4DVetPOSlab(jh,ix) = AvgVP;
                        Mean4DVetPOS(ix) = sum(sum(sum(mapP(:,:,:,ix))))/nnz(mapP(:,:,:,ix));

                        MultROILabN(:,:,:,ix) = LabelImgMATbin.*mapN(:,:,:,ix);
                        MultROILab2N = squeeze(MultROILabN(:,:,:,ix));
                        nOfvoxN = nnz(MultROILab2N);
                        SomavN = sum(sum(sum(MultROILab2N)));
                        AvgVN = SomavN/nOfvoxN;
                        Mean4DVetNEGlab(jh,ix) = AvgVN;
                        Mean4DVetNEG(ix) = sum(sum(sum(mapN(:,:,:,ix))))/nnz(mapN(:,:,:,ix));

                        fprintf(fideGxP,'%d\t%.3f\t%d\t%.1f\r\n',ix,AvgVP,nOfvoxP,100*(nOfvoxP/sum(sum(sum(LabelImgMATbin)))));
                        fprintf(fideGxN,'%d\t%.3f\t%d\t%.1f\r\n',ix,AvgVN,nOfvoxN,100*(nOfvoxN/sum(sum(sum(LabelImgMATbin)))));
                    end
                    Mean4DVetPOSlab = mean(Mean4DVetPOSlab,2);
                    Mean4DVetNEGlab = mean(Mean4DVetNEGlab,2);

                    MultROILabP = squeeze(MultROILabP);
                    MultROILabN = squeeze(MultROILabN);

                    fprintf(fideGxP,'\r\n');
                    fprintf(fideGxN,'\r\n');

                    meanPosR = mean(Mean4DVetPOS);
                    meanNegR = mean(Mean4DVetNEG);

                    fprintf(fideGxPT,'%.3f\t',Mean4DVetPOSlab(jh));
                    fprintf(fideGxNT,'%.3f\t',Mean4DVetNEGlab(jh));
                end
                Mean4DVetPOS = mean(Mean4DVetPOS,1);
                Mean4DVetNEG = mean(Mean4DVetNEG,1);
            end
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d results quantification. Check your data.',yy), 'Process Aborted')
            fclose('all');
            return
        end
        try
            if ~isequal(WS,Dt)
                fprintf('\r\n')
                fprintf('UF�C =============== %s\n',spm('time'));
                fprintf('Plotting graphical results\n');

                fig = figure;
                
                set(fig,'Name',dirname,...
                    'Position', round([ScreSize(2)*.1 ScreSize(2)*.1 ScreSize(2).*0.9 ScreSize(2).*0.7]),...
                                'Color',[1 0.94 0.86]);
                            
                subplot1 = subplot(1,2,1);
                plot(Mean4DVetPOS,'Parent',...
                                subplot1,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.','LineWidth',1);
                xlabel('Window Start point' ,'FontSize',12);
                ylabel('Correlation value','FontSize',12);
                title('Positive Moving Window Average Cor value');

                subplot2 = subplot(1,2,2);
                plot(Mean4DVetNEG,'Parent',...
                                subplot2,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.','LineWidth',1);
                xlabel('Window Start point','FontSize',12);
                ylabel('Correlation value','FontSize',12);

                title('Negative Moving Window Average Cor value');

                Y1 = Mean4DVetPOS;
                Y2 = Mean4DVetNEG;

                box(subplot1,'on');
                hold(subplot1,'all');
                plot1 = plot(Y1,'Parent',subplot1,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.',...
                    'LineWidth',1,...
                    'DisplayName','data 1');
                xdata1 = get(plot1, 'xdata');
                ydata1 = get(plot1, 'ydata');
                xdata1 = xdata1(:);
                ydata1 = ydata1(:);
                nanMask1 = isnan(xdata1(:)) | isnan(ydata1(:));
                if any(nanMask1)
                    warning('GenerateMFile:IgnoringNaNs', ...
                        'Data points with NaN coordinates will be ignored.');
                    xdata1(nanMask1) = [];
                    ydata1(nanMask1) = [];
                end
                axesLimits1 = xlim(subplot1);
                xplot1 = linspace(axesLimits1(1), axesLimits1(2));
                fitResults1 = polyfit(xdata1, ydata1, 2);
                yplot1 = polyval(fitResults1, xplot1);
                fitLine1 = plot(xplot1,yplot1,'DisplayName','quadratic',...
                    'Parent',subplot1,'Tag','quadratic','Color',[0 0.75 0.75]);

                box(subplot2,'on');
                hold(subplot2,'all');
                plot2 = plot(Y2,'Parent',subplot2,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.',...
                    'LineWidth',1,...
                    'DisplayName','data 1');
                xlabel('Window Start point','FontSize',12);
                ylabel('Correlation value','FontSize',12);
                title('Total Negative Moving Window Average Corrrelation value');
                xdata2 = get(plot2, 'xdata');
                ydata2 = get(plot2, 'ydata');
                xdata2 = xdata2(:);
                ydata2 = ydata2(:);
                nanMask2 = isnan(xdata2(:)) | isnan(ydata2(:));
                if any(nanMask1)
                    warning('GenerateMFile:IgnoringNaNs', ...
                        'Data points with NaN coordinates will be ignored.');
                    xdata2(nanMask2) = [];
                    ydata2(nanMask2) = [];
                end
                axesLimits2 = xlim(subplot2);
                xplot2 = linspace(axesLimits2(1), axesLimits2(2));
                fitResults2 = polyfit(xdata2, ydata2, 2);
                yplot2 = polyval(fitResults2, xplot2);
                fitLine2 = plot(xplot2,yplot2,'DisplayName','quadratic',...
                'Parent',subplot2,...
                'Tag','quadratic',...
                'Color',[0 0.75 0.75]);

                drawnow
                imgRR = getframe(fig);
                imwrite(imgRR.cdata, [pathFunc,dirname,filesep,'Correlation_map',filesep,'Corr_Window_Graph.png']);
                try    
                    close(fig)
                end
             end
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d graphics creation.',yy), 'Process Aborted')
            fclose('all');
            return
        end

        fprintf('Done! ============== %s\r\n',spm('time'));

        fprintf('\r\n')
        fprintf('UF�C =============== %s\n',spm('time'));
        fprintf('Creating NIfTI correlation maps\n');

        try
            if ~get(handles.SPMbb,'Value')
                eval(sprintf('WinAvSavePos.suj_%d = Mean4DVetPOS;',yy));
                eval(sprintf('WinAvSaveNeg.suj_%d = Mean4DVetNEG;',yy));

                eval(sprintf('WinAvSavePosLab.suj_%d = Mean4DVetPOSlab;',yy));
                eval(sprintf('WinAvSaveNegLab.suj_%d = Mean4DVetNEGlab;',yy));

                save([pathFunc,dirname,filesep,'Correlation_map',filesep,'Positive_Serie'],'Mean4DVetPOS')
                save([pathFunc,dirname,filesep,'Correlation_map',filesep,'Negative_Serie'],'Mean4DVetNEG')

                save([pathFunc,dirname,filesep,'Correlation_map',filesep,'Positive_AnatLabel'],'Mean4DVetPOSlab')
                save([pathFunc,dirname,filesep,'Correlation_map',filesep,'Negative_AnatLabel'],'Mean4DVetNEGlab')
            end
            RoiNii = Func;   % Creates a NIfTI object
            WinCorr4DP = Func; 
            WinCorr4DN = Func; 

            RoiNii.dat.dim = [Dx Dy Dz];
            WinCorr4DP.dat.dim = [Dx Dy Dz (Vn-1)]; % Apply the correct matrix size
            WinCorr4DN.dat.dim = [Dx Dy Dz (Vn-1)];

            RoiNii.dat.fname = [pathFunc,dirname,filesep,'ROI_mask',filesep,dirname,'_Roi.nii']; % Change file name
            WinCorr4DP.dat.fname = [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_Cr4D_P.nii'];
            WinCorr4DN.dat.fname = [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_Cr4D_N.nii'];

            RoiNii.dat.dtype = 'FLOAT32-LE'; % verify matrix datatype
            WinCorr4DP.dat.dtype = 'FLOAT32-LE';
            WinCorr4DN.dat.dtype = 'FLOAT32-LE';

            RoiNii.descrip = dirname; % Apply Name information in the Nii struct (description field)
            WinCorr4DP.descrip = dirname;
            WinCorr4DN.descrip = dirname;

            RoiNii.dat(:,:,:) =  roi1; % add matriz value to the NIfTI object
            WinCorr4DP.dat(:,:,:,:) = mapP;
            WinCorr4DN.dat(:,:,:,:) = mapN2;

            create(RoiNii) % creates the NIfTI file from the Object
            create(WinCorr4DP)
            create(WinCorr4DN)
            
            if isequal(get(handles.FazPrep,'Value'),0)
                if (Vn-1)==1
                    uf2c_SliceView([pathFunc,dirname,filesep,'wm',fileStru{yy}],...
                        [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_Cr4D_P.nii'],...
                        UDV.SVOT,UDV.SVUT,'axial','hot',UDV.SVNoS,...
                        'Positive R-Score Map',...
                        'SliceView_Positive_R-Score_Map.png',[pathFunc,dirname,filesep,'Correlation_map']);

                    uf2c_SliceView([pathFunc,dirname,filesep,'wm',fileStru{yy}],...
                        [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_Cr4D_N.nii'],...
                        UDV.SVOT,UDV.SVUT,'axial','winter',UDV.SVNoS,...
                        'Negative R-Score Map',...
                        'SliceView_Negative_R-Score_Map.png',[pathFunc,dirname,filesep,'Correlation_map']);
                end
            else
                 if (Vn-1)==1
                    uf2c_SliceView([DirUF2C(1:end-6) 'Utilities' filesep 'Controls_Template.nii'],...
                        [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_Cr4D_P.nii'],...
                        UDV.SVOT,UDV.SVUT,'axial','hot',UDV.SVNoS,...
                        'Positive R-Score Map',...
                        'SliceView_Positive_R-Score_Map.png',[pathFunc,dirname,filesep,'Correlation_map']);

                    uf2c_SliceView([DirUF2C(1:end-6) 'Utilities' filesep 'Controls_Template.nii'],...
                        [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_Cr4D_N.nii'],...
                        UDV.SVOT,UDV.SVUT,'axial','winter',UDV.SVNoS,...
                        'Negative R-Score Map',...
                        'SliceView_Negative_R-Score_Map.png',[pathFunc,dirname,filesep,'Correlation_map']);
                 end
            end
            
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d resultant maps saving.',yy), 'Process Aborted')
            fclose('all');
            return
        end
        try
            % Smoothing
            Corr4D_MultP = cell((Vn-1),1);
            for tx=1:(Vn-1)
                Corr4D_MultP{tx,1} = [pathFunc dirname filesep 'Correlation_map' filesep dirname '_Cr4D_P.nii' ',' num2str(tx)];
            end
            
            clear job
            job.data = Corr4D_MultP;
            job.fwhm = [UDV.SmoFac*fvs(1) UDV.SmoFac*fvs(2) UDV.SmoFac*fvs(3)];
            job.dtype = 0;
            job.im = 1;
            job.prefix = 'smoothed_';
            spm_run_smooth(job);

            Corr4D_MultN = cell((Vn-1),1);
            for tx=1:(Vn-1)
                Corr4D_MultN{tx,1} = [pathFunc dirname filesep 'Correlation_map' filesep dirname '_Cr4D_N.nii' ',' num2str(tx)];
            end
            
            job.data = Corr4D_MultN;
            spm_run_smooth(job);
            
            equa = 'i1';  %creates the equation to use in ImCalc
            if Dt>WS
                for eqn = 2:(Dt/WS)
                    equa = sprintf('%s+i%d',equa,eqn);
                end
                equa = ['(' equa ')' sprintf('./%d',eqn)];
                
                clear flags
                flags.dmtx = 0;
                flags.mask = 1;
                flags.interp = 1;
                flags.dtype = 16;
                
                spm_imcalc(Corr4D_MultP,...
                    [pathFunc dirname filesep 'Correlation_map' filesep dirname,'_MeanP.nii'],...
                    equa,flags);

                spm_imcalc(Corr4D_MultN,...
                    [pathFunc dirname filesep 'Correlation_map' filesep dirname,'_MeanN.nii'],...
                    equa,flags);
                
                clear Corr4D_MultP Corr4D_MultN flags

                uf2c_SliceView([DirUF2C(1:end-6) 'Utilities' filesep 'Controls_Template.nii'],...
                    [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_MeanP.nii'],...
                    UDV.SVOT,UDV.SVUT,'axial','hot',UDV.SVNoS,...
                    'Positive R-Score Map',...
                    'SliceView_Positive_temporalAVERAGE_R-Score_Map.png',[pathFunc,dirname,filesep,'Correlation_map']);

                uf2c_SliceView([DirUF2C(1:end-6) 'Utilities' filesep 'Controls_Template.nii'],...
                    [pathFunc,dirname,filesep,'Correlation_map',filesep,dirname,'_MeanN.nii'],...
                    UDV.SVOT,UDV.SVUT,'axial','winter',UDV.SVNoS,...
                    'Negative R-Score Map',...
                    'SliceView_Negative_temporalAVERAGE_R-Score_Map.png',[pathFunc,dirname,filesep,'Correlation_map']);
                
                % Smoothing    
                clear job
                job.data = {[pathFunc dirname filesep 'Correlation_map' filesep dirname '_MeanP.nii']};
                job.fwhm = [UDV.SmoFac*fvs(1) UDV.SmoFac*fvs(2) UDV.SmoFac*fvs(3)];
                job.dtype = 0;
                job.im = 1;
                job.prefix = 'smoothed_';
                spm_run_smooth(job);
                
                % Smoothing
                job.data = {[pathFunc dirname filesep 'Correlation_map' filesep dirname '_MeanN.nii']};
                spm_run_smooth(job);
                
                fprintf('Done! ============== %s\r\n',spm('time'));

                % positive values
                    StruPF = nifti([pathFunc dirname filesep 'Correlation_map' filesep dirname '_Cr4D_P.nii']);
                    matSF = StruPF.dat.dim;
                    matlat = StruPF.dat(:,:,:,:);
                        %Left values
                        MaskR = zeros(matSF(1),matSF(2),matSF(3));
                        MaskR(ceil(matSF(1)/2):matSF(1),:,:)=1;
                        %Right values
                        MaskL = zeros(matSF(1),matSF(2),matSF(3));
                        MaskL(1:floor(matSF(1)/2),:,:)=1;
                    leftR = zeros(1,matSF(4));
                    rightR = zeros(1,matSF(4));

                % negative values
                    StruNF = nifti([pathFunc dirname filesep 'Correlation_map' filesep dirname '_Cr4D_N.nii']);   
                    matSF2 = StruNF.dat.dim;
                    matlat2 = StruNF.dat(:,:,:,:);
                        %Left values
                        MaskR2 = zeros(matSF2(1),matSF2(2),matSF2(3));
                        MaskR2(ceil(matSF2(1)/2):matSF2(1),:,:)=1;
                        %Right values
                        MaskL2 = zeros(matSF2(1),matSF2(2),matSF2(3));
                        MaskL2(1:floor(matSF2(1)/2),:,:)=1;
                    leftR2 = zeros(1,matSF2(4));
                    rightR2 = zeros(1,matSF2(4));

                for rt = 1:matSF(4)
                    % positive values
                        %Right values
                        matlatL = matlat(:,:,:,rt).*MaskL;
                        NumRLP = sum(sum(sum(matlatL(matlatL(:,:,:)>0))));
                        DenRLP = nnz(matlatL(:,:,:)>0);
                        leftR(rt) = NumRLP/DenRLP;
                        %Left values
                        matlatR = matlat(:,:,:,rt).*MaskR;
                        NumRRP = sum(sum(sum(matlatR(matlatR(:,:,:)>0))));
                        DenRRP = nnz(matlatR(:,:,:)>0);
                        rightR(rt) = NumRRP/DenRRP;

                    % negative values
                        %Right values
                        matlatL2 = matlat2(:,:,:,rt).*MaskL2;
                        NumRLP2 = sum(sum(sum(matlatL2(matlatL2(:,:,:)>0))));
                        DenRLP2 = nnz(matlatL2(:,:,:)>0);
                        leftR2(rt) = -1.*(NumRLP2/DenRLP2);
                        %Left values
                        matlatR2 = matlat2(:,:,:,rt).*MaskR2;
                        NumRRP2 = sum(sum(sum(matlatR2(matlatR2(:,:,:)>0))));
                        DenRRP2 = nnz(matlatR2(:,:,:)>0);
                        rightR2(rt) = -1.*(NumRRP2/DenRRP2);
                end
            else    %in case that there is no 4D volume (no window corr)
                % positive values
                StruPF = nifti([pathFunc dirname filesep 'Correlation_map' filesep dirname '_Cr4D_P.nii']);
                matSF = StruPF.dat.dim;
                matlat = StruPF.dat(:,:,:);
                    %Left values
                    MaskR = zeros(matSF(1),matSF(2),matSF(3));
                    MaskR(ceil(matSF(1)/2):matSF(1),:,:)=1;
                    %Right values
                    MaskL = zeros(matSF(1),matSF(2),matSF(3));
                    MaskL(1:floor(matSF(1)/2),:,:)=1;

                % negative values
                    StruNF = nifti([pathFunc dirname filesep 'Correlation_map' filesep dirname '_Cr4D_N.nii']);   
                    matSF2 = StruNF.dat.dim;
                    matlat2 = StruNF.dat(:,:,:,:);
                    %Left values
                    MaskR2 = zeros(matSF2(1),matSF2(2),matSF2(3));
                    MaskR2(ceil(matSF2(1)/2):matSF2(1),:,:)=1;
                    %Right values
                    MaskL2 = zeros(matSF2(1),matSF2(2),matSF2(3));
                    MaskL2(1:floor(matSF2(1)/2),:,:)=1;

                    % positive values
                        %Right values
                        matlatL = matlat(:,:,:).*MaskL;
                        NumRLP = sum(sum(sum(matlatL(matlatL(:,:,:)>0))));
                        DenRLP = nnz(matlatL(:,:,:)>0);
                        leftR = NumRLP/DenRLP;
                        %Left values
                        matlatR = matlat(:,:,:).*MaskR;
                        NumRRP = sum(sum(sum(matlatR(matlatR(:,:,:)>0))));
                        DenRRP = nnz(matlatR(:,:,:)>0);
                        rightR = NumRRP/DenRRP;

                    % negative values
                        %Right values
                        matlatL2 = matlat2(:,:,:).*MaskL2;
                        NumRLP2 = sum(sum(sum(matlatL2(matlatL2(:,:,:)>0))));
                        DenRLP2 = nnz(matlatL2(:,:,:)>0);
                        leftR2 = -1.*(NumRLP2/DenRLP2);
                        %Left values
                        matlatR2 = matlat2(:,:,:).*MaskR2;
                        NumRRP2 = sum(sum(sum(matlatR2(matlatR2(:,:,:)>0))));
                        DenRRP2 = nnz(matlatR2(:,:,:)>0);
                        rightR2 = -1.*(NumRRP2/DenRRP2);
            end
            if isequal(get(handles.FazPrep,'Value'),0)
                if isequal(get(handles.OutputFil, 'Value'),1)
                    delete([pathFunc dirname filesep fileFunc{yy}])
                    delete([pathFunc dirname filesep fileStru{yy}])
                    delete([pathFunc dirname filesep fileFunc{yy}(1:end-4) '.mat'])
                    delete([pathFunc dirname filesep fileStru{yy}(1:end-4) '_seg_inv_sn.mat'])
                    delete([pathFunc dirname filesep fileStru{yy}(1:end-4) '_seg_sn.mat'])
                    delete([pathFunc dirname filesep 'mean' fileFunc{yy}])
                    if STC
                        delete([pathFunc dirname filesep 'a' fileFunc{yy}])
                        delete([pathFunc dirname filesep 'wa' fileFunc{yy}])
                    end
                    delete([pathFunc dirname filesep 'm' fileStru{yy}])
                    delete([pathFunc dirname filesep 'wc1' fileStru{yy}])
                    delete([pathFunc dirname filesep 'wc2' fileStru{yy}])
                    delete([pathFunc dirname filesep 'wc3' fileStru{yy}])
                    delete([pathFunc dirname filesep 'w' fileFunc{yy}])
                    delete([pathFunc dirname filesep 'w' fileFunc{yy}(1:end-4) '.mat'])
                    delete([pathFunc dirname filesep 'sw' fileFunc{yy}(1:end-4) '.mat'])
                    delete([pathFunc dirname filesep 'sw' fileFunc{yy}])
                    delete([pathFunc dirname filesep 'y_' fileStru{yy}])
                    delete([pathFunc dirname filesep 'c1interp.nii'])
                    delete([pathFunc dirname filesep 'sc2interp.nii'])
                    delete([pathFunc dirname filesep 'c2interpReg.nii'])
                    delete([pathFunc dirname filesep 'c3interpReg.nii'])
                    delete([pathFunc dirname filesep 'sc1interp.nii'])
                    delete([pathFunc dirname filesep 'c2interpF.nii'])
                    delete([pathFunc dirname filesep 'c1interpF.nii'])
                    delete([pathFunc dirname filesep 'c2interp.nii'])
                    delete([pathFunc dirname filesep 'c3interp.nii'])
                    delete([pathFunc dirname filesep 'Template.nii'])
                    delete([pathFunc dirname filesep 'Template.mat'])
                end
            end

            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Saving individual results\n');
            
            if ~get(handles.SPMbb,'Value')
                rightAverageP = mean(leftR);  % Yes, the name here should to be exchanged
                leftAverageP = mean(rightR);% Yes, the name here should to be exchanged

                rightAverageN = mean(leftR2);% Yes, the name here should to be exchanged
                leftAverageN = mean(rightR2);% Yes, the name here should to be exchanged
            
                fprintf(fide,'%s \r\n\r\n',dirname);   % Write data in the output log file
                fprintf(fide,'Average Positive Correlation Value: %.5f\r\n\r\n',mean(meanPosR));% Write data in the output log file
                fprintf(fide,'Average Negative Correlation Value: %.5f\r\n\r\n',mean(meanNegR));% Write data in the output log file
                fprintf(fide,'Right Side Positive Correlation Value: %.5f\r\n\r\n',rightAverageP);% Write data in the output log file
                fprintf(fide,'Left Side Positive Correlation Value: %.5f\r\n\r\n',leftAverageP);% Write data in the output log file
                fprintf(fide,'Right Side Negative Correlation Value: %.5f\r\n\r\n',rightAverageN);% Write data in the output log file
                fprintf(fide,'Left Side Negative Correlation Value: %.5f\r\n\r\n',leftAverageN);% Write data in the output log file
                
                fprintf(fideGxPT,'\r\n');
                fprintf(fideGxNT,'\r\n');

                fprintf(fideG,'%s \t %.5f \t %.5f \t %.5f \t %.5f \t %.5f \t %.5f\r\n',dirname,meanPosR,meanNegR,rightAverageP,leftAverageP,rightAverageN,leftAverageN);% Write data in the output log file
                fclose(fide); %close the writable txt file
            end
            fprintf('\r\n')
            fprintf('UF�C =============== %s\n',spm('time'));
            fprintf('Subject %d Done!\r\n',yy);
        catch
            set(handles.status,'String','Error...')
            warndlg(sprintf('An error occured during subject %d results saving.',yy), 'Process Aborted')
            fclose('all');
            return
        end
    end

    fprintf('\r\n')
    fprintf('UF�C =============== %s\n',spm('time'));
    fprintf('Generating overall results\n');
    try
        if get(handles.AddROIm,'Value')
            clear fileROI pathROI previewF2  ROImaskMAt matrixF2 VoxSizeF2
        %     set(handles.AddROIm,'Value',0)
        end
        if (yy - ExclSub)>1
            for iy1 = 1:(Vn-1)
                for ix3 = 1:(yy - ExclSub)
                    eval(sprintf('STDPos_%d(%d) = WinAvSavePos.suj_%d(%d);',iy1,ix3,ix3,iy1));
                    eval(sprintf('STDNeg_%d(%d) = WinAvSaveNeg.suj_%d(%d);',iy1,ix3,ix3,iy1));
                end
                StdFinalPos(iy1) = std(eval(sprintf('STDPos_%d',iy1)));
                StdFinalNeg(iy1) = std(eval(sprintf('STDNeg_%d',iy1)));
            end

            StdFinalPos = StdFinalPos./sqrt((yy - ExclSub));
            StdFinalNeg = StdFinalNeg./sqrt((yy - ExclSub));
        end

        graphfinalPos = WinAvSavePos.suj_1;
        graphfinalNeg = WinAvSaveNeg.suj_1;
        All_series_Pos(1,:) = WinAvSavePos.suj_1;
        All_series_Neg(1,:) = WinAvSaveNeg.suj_1;

        if (yy - ExclSub)>1
            for ix2 = 2:(yy - ExclSub)
                eval(sprintf('graphfinalPos = graphfinalPos + WinAvSavePos.suj_%d;',ix2));
                eval(sprintf('graphfinalNeg = graphfinalNeg + WinAvSaveNeg.suj_%d;',ix2));
                eval(sprintf('All_series_Pos(%d,:) = WinAvSavePos.suj_%d;',ix2,ix2));
                eval(sprintf('All_series_Neg(%d,:) = WinAvSaveNeg.suj_%d;',ix2,ix2));
            end

            graphfinalPos = graphfinalPos./(yy - ExclSub);
            graphfinalNeg = graphfinalNeg./(yy - ExclSub);

            save([pathFunc,filesep,foldername,filesep,'Pos_Average_Correlation_Serie'],'graphfinalPos')
            save([pathFunc,filesep,foldername,filesep,'Neg_Average_Correlation_Serie'],'graphfinalNeg')

            save([pathFunc,filesep,foldername,filesep,'All_Pos_Correlation_Series'],'All_series_Pos')
            save([pathFunc,filesep,foldername,filesep,'All_Neg_Correlation_Series'],'All_series_Neg')

        end
        try
            if ~isequal(WS,Dt)
                fig2 = figure;
                set(fig2,'Name','Total Moving Window Average',...
                    'Position', round([ScreSize(2)*.1 ScreSize(2)*.1 ScreSize(2).*1 ScreSize(2).*0.8]),...
                                'Color',[1 0.94 0.86]);

                subplot1 = subplot(1,2,1);
                plot(graphfinalPos,'Parent',...
                                subplot1,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.','LineWidth',1);
                xlabel('Window Start point' ,'FontSize',12);
                ylabel('Correlation value','FontSize',12);
                title('Total Positive Moving Window Average Corrrelation value');

                subplot2 = subplot(1,2,2);
                plot(graphfinalNeg,'Parent',...
                                subplot2,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.','LineWidth',1);
                xlabel('Window Start point','FontSize',12);
                ylabel('Correlation value','FontSize',12);
                title('Total Negative Moving Window Average Corrrelation value');            

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                Y1 = graphfinalPos;
                Y2 = graphfinalNeg;

                box(subplot1,'on');
                hold(subplot1,'all');

                plot1 = errorbar(Y1,StdFinalPos/2,'Parent',subplot1,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.','LineWidth',2,'Color',[0 0 1],'DisplayName','data 1');

                xdata1 = get(plot1, 'xdata');
                ydata1 = get(plot1, 'ydata');
                xdata1 = xdata1(:);
                ydata1 = ydata1(:);
                nanMask1 = isnan(xdata1(:)) | isnan(ydata1(:));
                if any(nanMask1)
                    warning('GenerateMFile:IgnoringNaNs', ...
                        'Data points with NaN coordinates will be ignored.');
                    xdata1(nanMask1) = [];
                    ydata1(nanMask1) = [];
                end
                axesLimits1 = xlim(subplot1);
                xplot1 = linspace(axesLimits1(1), axesLimits1(2));
                fitResults1 = polyfit(xdata1, ydata1, 2);
                yplot1 = polyval(fitResults1, xplot1);
                fitLine1 = plot(xplot1,yplot1,'DisplayName','   quadratic',...
                    'Parent',subplot1,...
                    'Tag','quadratic',...
                    'Color',[0 0.75 0.75]);
                box(subplot2,'on');
                hold(subplot2,'all');

                plot2 = errorbar(Y2,StdFinalNeg/2,'Parent',subplot2,'MarkerEdgeColor',[1 0 0],'MarkerSize',8,...
                    'Marker','.','LineWidth',2,'Color',[0 0 1],'DisplayName','data 1');

                xlabel('Window Start point','FontSize',12);
                ylabel('Correlation value','FontSize',12);
                title('Total Negative Moving Window Average Corrrelation value');
                xdata2 = get(plot2, 'xdata');
                ydata2 = get(plot2, 'ydata');
                xdata2 = xdata2(:);
                ydata2 = ydata2(:);
                nanMask2 = isnan(xdata2(:)) | isnan(ydata2(:));
                if any(nanMask1)
                    warning('GenerateMFile:IgnoringNaNs', ...
                        'Data points with NaN coordinates will be ignored.');
                    xdata2(nanMask2) = [];
                    ydata2(nanMask2) = [];
                end
                axesLimits2 = xlim(subplot2);
                xplot2 = linspace(axesLimits2(1), axesLimits2(2));
                fitResults2 = polyfit(xdata2, ydata2, 2);
                yplot2 = polyval(fitResults2, xplot2);
                fitLine2 = plot(xplot2,yplot2,'DisplayName','   quadratic',...
                    'Parent',subplot2,...
                    'Tag','quadratic',...
                    'Color',[0 0.75 0.75]);
                drawnow
                imgRR = getframe(fig2);
                imwrite(imgRR.cdata, [pathFunc,filesep,foldername,filesep,'Totals_Windows_Graph.tif']);
                close(fig2)
            end
        catch
        end

    catch
        set(handles.status,'String','Error...')
        warndlg('An error occured during overall results saving.','Process Aborted')
        fclose('all');
        return
    end
    
    if isequal(get(handles.FazPrep,'Value'),0)
        if license('test','Distrib_Computing_Toolbox')
            ps.Pool.AutoCreate = PsOri;
        end
    end
    
    try
        fclose(fideG); %close the writable txt file
        multiWaitbar('CloseAll'); %close the progressbar window
        fclose('all');
        set(handles.status,'String','Done!!!')
        fprintf('All Done! ========== %s\n',spm('time'));
        fprintf('==========================================\r\n');
    catch
        set(handles.status,'String','Error...')
        warndlg('An error occured during overall results saving.','Process Aborted')
        fclose('all');
        return
    end
    
function addreg_Callback(hObject, eventdata, handles)
global regVets

    try
        clear(regVets)
    end

    set(handles.refreshb,'ForegroundColor',[1 0 0])
    uf2c_Addreg

function checkReg_Callback(hObject, eventdata, handles)

    if isequal(get(handles.checkReg,'Value'),1)
        set(handles.addreg,'Enable','on')
        set(handles.refreshb,'Enable','on')
    else
        set(handles.addreg,'Enable','off')
        set(handles.refreshb,'Enable','off')
        set(handles.txtregress,'String','0 added')
    end

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
    set(handles.refreshb,'ForegroundColor',[0 0 0])

function FazFilt_Callback(hObject, eventdata, handles)
    if isequal(get(handles.FazFilt,'Value'),1)
        set(handles.LPF,'Enable','on')
        set(handles.HPF,'Enable','on')
        set(handles.stba,'Enable','on')
    else
        set(handles.LPF,'Enable','off')
        set(handles.HPF,'Enable','off')
        set(handles.stba,'Enable','off')
    end

function FazPrep_Callback(hObject, eventdata, handles)
    if get(handles.FazPrep,'Value')
        set(handles.addStru,'Enable','off')
        set(handles.FazFilt,'Enable','off')
        set(handles.LPF,'Enable','off')
        set(handles.HPF,'Enable','off')
        set(handles.stba,'Enable','off')
        set(handles.checkMOV,'Enable','off')
        set(handles.checkOsc,'Enable','off')
        set(handles.checkReg,'Enable','off')
        set(handles.text14,'Enable','off')
        set(handles.text15,'Enable','off')
        set(handles.LPFtxt,'Enable','off')
        set(handles.HPFtxt,'Enable','off')
        set(handles.text21,'Enable','off')
        set(handles.addFunc,'String','Add FiltRegrSW Files')
        set(handles.FDcheck,'Enable','off')
        set(handles.extGM,'Enable','off')
        set(handles.extWM,'Enable','off')
        set(handles.extCSF,'Enable','off')
        set(handles.STCo,'Enable','off')
        set(handles.TM_FD,'Enable','off')
        set(handles.TM_DVARs,'Enable','off')
        set(handles.text28,'Enable','off')
        set(handles.text27,'Enable','off')
        set(handles.FDthres,'Enable','off')
        set(handles.DVARthres,'Enable','off')
        set(handles.DVAR_TS,'Enable','off')
    else
        set(handles.addStru,'Enable','on')
        set(handles.FazFilt,'Enable','on')
        set(handles.LPF,'Enable','on')
        set(handles.HPF,'Enable','on')
        set(handles.stba,'Enable','on')
        set(handles.checkMOV,'Enable','on')
        set(handles.checkOsc,'Enable','on')
        set(handles.checkReg,'Enable','on')
        set(handles.text14,'Enable','on')
        set(handles.text15,'Enable','on')
        set(handles.LPFtxt,'Enable','on')
        set(handles.HPFtxt,'Enable','on')
        set(handles.text21,'Enable','on')
        set(handles.addFunc,'String','Add Functional Files')
        set(handles.FDcheck,'Enable','on')
        set(handles.extGM,'Enable','on')
        set(handles.extWM,'Enable','on')
        set(handles.extCSF,'Enable','on')
        set(handles.STCo,'Enable','on')
        set(handles.TM_FD,'Enable','on')
        set(handles.TM_DVARs,'Enable','on')
        set(handles.text28,'Enable','on')
        set(handles.text27,'Enable','on')
        set(handles.FDthres,'Enable','on')
        set(handles.DVARthres,'Enable','on')
        set(handles.DVAR_TS,'Enable','on')
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

    fclose(fideSL);
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

    fclose(fideSL);
    open([tmpDIR 'Subject_List_Stru.txt'])

function edit10_Callback(hObject, eventdata, handles)
function edit9_Callback(hObject, eventdata, handles)
function numDyna_Callback(hObject, eventdata, handles)
function SizeVoxFunc_Callback(hObject, eventdata, handles)
function SizeMatFunc_Callback(hObject, eventdata, handles)
function wsIn_Callback(hObject, eventdata, handles)
function ROIinp_Callback(hObject, eventdata, handles)
function TRInp_Callback(hObject, eventdata, handles)
function SSInp_Callback(hObject, eventdata, handles)
function LPF_Callback(hObject, eventdata, handles)
function HPF_Callback(hObject, eventdata, handles)
function stba_Callback(hObject, eventdata, handles)
function checkMOV_Callback(hObject, eventdata, handles)
function checkOsc_Callback(hObject, eventdata, handles)
function OutputFil_Callback(hObject, eventdata, handles)
function STCo_Callback(hObject, eventdata, handles)
function DVARthres_Callback(hObject, eventdata, handles)
function FDthres_Callback(hObject, eventdata, handles)
function DVAR_TS_Callback(hObject, eventdata, handles)
function EPCo_Callback(hObject, eventdata, handles)

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

function TM_FD_Callback(hObject, eventdata, handles)
if get(handles.TM_FD,'Value')
    set(handles.text28,'Enable','on')
    set(handles.FDthres,'Enable','on')
else
    set(handles.text28,'Enable','off')
    set(handles.FDthres,'Enable','off')
end

function TM_DVARs_Callback(hObject, eventdata, handles)
if get(handles.TM_DVARs,'Value')
    set(handles.text27,'Enable','on')
    set(handles.DVARthres,'Enable','on')
else
    set(handles.text27,'Enable','off')
    set(handles.DVARthres,'Enable','off')
end

function figure1_CloseRequestFcn(hObject, eventdata, handles)
global PsOri ps
if license('test','Distrib_Computing_Toolbox')
    ps.Pool.AutoCreate = PsOri;
end
delete(hObject);

function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function numDyna_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SizeVoxFunc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SizeMatFunc_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function wsIn_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function ROIinp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function TRInp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function SSInp_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function LPF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function HPF_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function stba_CreateFcn(hObject, eventdata, handles)
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

