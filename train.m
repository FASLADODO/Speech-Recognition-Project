%train is a program that simultaneously trains all of the modules we will
%be using. More modules can easily be added, and you can stop modules from
%being trained by commenting out certain sections. For now, there is no
%output, but the new GMMs will be saved directly to the 'models.mat'
%file, where they can then be used by the main program.
%Currently, one can change the destintation file manually, but the program
%could easliy be modified to accept a file destination as an input. Keep in
%mind that a complete path input is required, even if the files are in the
%same folder as this program.
%
% Inputs: path - a path address to the folder or directory where the WAV
%                and TextGrid files are held together (corresponding files
%                must have the same name). This cannot just be an empty
%                string, or the program will not work. The path must be a
%                valid address of a folder, i.e. 'C:\Users\name\Documents'
%         filePrefixes - all of the names of the files that should be used
%                        for training. They should be in a cell, seperated 
%                        by commas between curly brackets, i.e. {'wordsjump',
%                        'wordsrun', 'wordssit'}
%
% Written by Collin Potts, MIT RLE Speech Communication Group
%
% Last updated June 15th, 2017
%
% Known bugs: It expects certain tier names, but it does not expect them in
% a particular order. Also, it does not examine LMmods or comments

function train(path, filePrefixes)

%try to make sure that path is valid
if ~isempty(path)
    if strcmp(path(end),'\')
        PATH=path;
    else
        PATH=[path '\'];
    end
else
    disp('You must have a valid path for this program to run properly');
    return
end

%create measurement arrays
%first, location detection
glottalM = zeros(numel(filePrefixes)*200,12);
nonglottalM = zeros(numel(filePrefixes)*1000,12);
nasalM = zeros(numel(filePrefixes)*200,6);
nonnasalM = zeros(numel(filePrefixes)*1000,6);
glideM = zeros(numel(filePrefixes)*200,12);
nonglideM = zeros(numel(filePrefixes)*1000,12);
burstM = zeros(numel(filePrefixes)*200,12);
nonburstM = zeros(numel(filePrefixes)*1000,12);
ftcM = zeros(numel(filePrefixes)*200,12);
ftrM = zeros(numel(filePrefixes)*200,12);
nonftM = zeros(numel(filePrefixes)*1000,12);
ippM = zeros(numel(filePrefixes)*200,6);
nonippM = zeros(numel(filePrefixes)*1000,6);
%set index variables for measurement arrays
glottali = 0;
nonglottali = 0;
nasali = 0;
nonnasali = 0;
glidei = 0;
nonglidei = 0;
bursti = 0;
nonbursti = 0;
ftci = 0;
ftri = 0;
nonfti = 0;
ippi = 0;
nonippi = 0;
%second, place of articulation
ftc_labM = zeros(numel(filePrefixes)*200,12);
ftc_denM = zeros(numel(filePrefixes)*200,12);
ftc_alvM = zeros(numel(filePrefixes)*200,12);
ftc_palM = zeros(numel(filePrefixes)*200,12);
ftc_velM = zeros(numel(filePrefixes)*200,12);
ftr_labM = zeros(numel(filePrefixes)*200,12);
ftr_denM = zeros(numel(filePrefixes)*200,12);
ftr_alvM = zeros(numel(filePrefixes)*200,12);
ftr_palM = zeros(numel(filePrefixes)*200,12);
ftr_velM = zeros(numel(filePrefixes)*200,12);
sb_labM = zeros(numel(filePrefixes)*200,12);
sb_denM = zeros(numel(filePrefixes)*200,12);
sb_alvM = zeros(numel(filePrefixes)*200,12);
sb_palM = zeros(numel(filePrefixes)*200,12);
sb_velM = zeros(numel(filePrefixes)*200,12);
rM = zeros(numel(filePrefixes)*200,12);
lM = zeros(numel(filePrefixes)*200,12);
wM = zeros(numel(filePrefixes)*200,12);
hM = zeros(numel(filePrefixes)*200,12);
yM = zeros(numel(filePrefixes)*200,12);
%set index variables for measurement arrays
ftc_labi = 0;
ftc_deni = 0;
ftc_alvi = 0;
ftc_pali = 0;
ftc_veli = 0;
ftr_labi = 0;
ftr_deni = 0;
ftr_alvi = 0;
ftr_pali = 0;
ftr_veli = 0;
sb_labi = 0;
sb_deni = 0;
sb_alvi = 0;
sb_pali = 0;
sb_veli = 0;
ri = 0;
li = 0;
wi = 0;
hi = 0;
yi = 0;
%third, consonant voicing
vscM = zeros(numel(filePrefixes)*200,6);
vsrM = zeros(numel(filePrefixes)*200,6);
vsrvotM = zeros(numel(filePrefixes)*200,6);
vfcM = zeros(numel(filePrefixes)*200,6);
vfrM = zeros(numel(filePrefixes)*200,6);
uvscM = zeros(numel(filePrefixes)*200,6);
uvsrM = zeros(numel(filePrefixes)*200,6);
uvsrvotM = zeros(numel(filePrefixes)*200,6);
uvfcM = zeros(numel(filePrefixes)*200,6);
uvfrM = zeros(numel(filePrefixes)*200,6);
%set index variables for measurement arrays
vsci = 0;
vsri = 0;
vsrvoti = 0;
vfci = 0;
vfri = 0;
uvsci = 0;
uvsri = 0;
uvsrvoti = 0;
uvfci = 0;
uvfri = 0;

%vgplace works differently
vgplace = struct('back', false, 'high', false, 'low', false, 'atr', false, 'ctr', false, 'f1', 0, 'f2',0);

for i = 1:length(filePrefixes)
    try
    disp(['Training with file ' filePrefixes{i}]);
    wav_file = [PATH filePrefixes{i} '.WAV'];
    textgrid_file = [PATH filePrefixes{i} '.TextGrid'];

    %calculate formants and energy levels
    [T,V,Fs]=vectorize(wav_file);
    [F1,F2,F3,~,B1,B2,B3,B4]=func_PraatFormants(wav_file,0.01,80/Fs,1,floor(T(end)*Fs/80));
    [F0, ~, ~] = func_SnackPitch_IM(wav_file, 0.01, 80/Fs, 500, 75);
    original=cd;
    cd('..\..\wordsbyword Data');
    load([filePrefixes{i} '.mat'],'H1','H2','H4');
    cd(original);
    if length(F1)>length(V)
        F1=F1(1:length(V));
        F2=F2(1:length(V));
        F3=F3(1:length(V));
        B1=B1(1:length(V));
        B2=B2(1:length(V));
        B3=B3(1:length(V));
        B4=B4(1:length(V));
    elseif length(V)>length(F1)
        V=V(1:length(F1),:);
    end
    H1=resize(H1,length(F1));
    H2=resize(H2,length(F1));
    H4=resize(H4,length(F1));
    F0=resize(F0,length(F1));
    F1_real=find(~isnan(F1));
    F1_first=F1_real(1);
    F1_last=F1_real(end);
    F1(1:F1_first)=F1(F1_first);
    F1(F1_last:end)=F1(F1_last);
    F2_real=find(~isnan(F2));
    F2_first=F2_real(1);
    F2_last=F2_real(end);
    F2(1:F2_first)=F2(F2_first);
    F2(F2_last:end)=F2(F2_last);
    F3_real=find(~isnan(F3));
    F3_first=F3_real(1);
    F3_last=F3_real(end);
    F3(1:F3_first)=F3(F3_first);
    F3(F3_last:end)=F3(F3_last);
    B1_real=find(~isnan(B1));
    B1_first=B1_real(1);
    B1_last=B1_real(end);
    B1(1:B1_first)=B1(B1_first);
    B1(B1_last:end)=B1(B1_last);
    B2_real=find(~isnan(B2));
    B2_first=B2_real(1);
    B2_last=B2_real(end);
    B2(1:B2_first)=B2(B2_first);
    B2(B2_last:end)=B2(B2_last);
    B3_real=find(~isnan(B3));
    B3_first=B3_real(1);
    B3_last=B3_real(end);
    B3(1:B3_first)=B3(B3_first);
    B3(B3_last:end)=B3(B3_last);
    normalV=zeros(length(V),6);
    ratioV=zeros(length(V),6);
    sumV=zeros(length(V),1);
    for j=1:length(V)
        sumV(j)=sum(V(j,:));
        normalV(j,:)=V(j,:)./sum(V(j,:));
        for k=1:6
            ratioV(j,k)=normalV(j,k)/(1-normalV(j,k));
        end
    end

    %create an array
    [array,tiers]=textgrid_to_array(textgrid_file);

    %find tier locations
    LM_index='Unfound';
    vg_index='Unfound';
    c_index='Unfound';
    n_index='Unfound';
    g_index='Unfound';
    for j=1:length(tiers)
        tier=char(tiers(j));
        if strfind(tier,'"LM"')
            LM_index=j;
        elseif strfind(tier,'"vgplace"')
            vg_index=j;
        elseif strfind(tier,'"cplace"')
            c_index=j;
        elseif strfind(tier,'"nasal"')
            n_index=j;
        elseif strfind(tier,'"glottal"')
            g_index=j;
        end
    end
    
    %take LM related measurements
    if isa(LM_index,'double')
        %isolate LM tier
        LM_tier = array(LM_index,:);
        LM_indices = find(LM_tier ~= '');
        LM_labels = LM_tier(LM_indices);
        
        %find all glide labels
        r_starts = zeros(20,1);
        r_index = 0;
        l_starts = zeros(20,1);
        l_index = 0;
        w_starts = zeros(20,1);
        w_index = 0;
        h_starts = zeros(20,1);
        h_index = 0;
        y_starts = zeros(20,1);
        y_index = 0;
        glide_starts = zeros(20,1);
        glide_index = 0;
        % and find vowel times for vgplace
        v_times = zeros(20,1);
        v_index = 0;
        % and find consonant times for consonant voicing
        vsc_times = zeros(20,1);
        vsr_times = zeros(20,1);
        vsrvot_times = zeros(20,1);
        vfc_times = zeros(20,1);
        vfr_times = zeros(20,1);
        uvsc_times = zeros(20,1);
        uvsr_times = zeros(20,1);
        uvsrvot_times = zeros(20,1);
        uvfc_times = zeros(20,1);
        uvfr_times = zeros(20,1);
        vsc_index = 0;
        vsr_index = 0;
        vsrvot_index = 0;
        vfc_index = 0;
        vfr_index = 0;
        uvsc_index = 0;
        uvsr_index = 0;
        uvsrvot_index = 0;
        uvfc_index = 0;
        uvfr_index = 0;
        voiced = {'b','d','g','v','dh','z','zh','jh','dj'};
        unvoiced = {'p','t','k','f','th','s','sh','ch'};
        for g=1:length(LM_labels)
            if strfind(LM_labels(g),'"r"')
                glide_index = glide_index+1;
                r_index = r_index+1;
                glide_starts(glide_index) = (LM_indices(g)-15)/1000;
                r_starts(r_index) = (LM_indices(g)-15)/1000;
                v_index = v_index+1;
                v_times(v_index) = LM_indices(g);
            elseif strfind(LM_labels(g),'"l"')
                glide_index = glide_index+1;
                l_index = l_index+1;
                glide_starts(glide_index) = (LM_indices(g)-15)/1000;
                l_starts(l_index) = (LM_indices(g)-15)/1000;
                v_index = v_index+1;
                v_times(v_index) = LM_indices(g);
            elseif strfind(LM_labels(g),'"w"')
                glide_index = glide_index+1;
                w_index = w_index+1;
                glide_starts(glide_index) = (LM_indices(g)-15)/1000;
                w_starts(w_index) = (LM_indices(g)-15)/1000;
                v_index = v_index+1;
                v_times(v_index) = LM_indices(g);
            elseif strfind(LM_labels(g),'"h"')
                glide_index = glide_index+1;
                h_index = h_index+1;
                glide_starts(glide_index) = (LM_indices(g)-15)/1000;
                h_starts(h_index) = (LM_indices(g)-15)/1000;
                v_index = v_index+1;
                v_times(v_index) = LM_indices(g);
            elseif strfind(LM_labels(g),'"y"')
                glide_index = glide_index+1;
                y_index = y_index+1;
                glide_starts(glide_index) = (LM_indices(g)-15)/1000;
                y_starts(y_index) = (LM_indices(g)-15)/1000;
                v_index = v_index+1;
                v_times(v_index) = LM_indices(g);
            elseif strfind(LM_labels(g),'"V"')
                v_index = v_index+1;
                v_times(v_index) = LM_indices(g);
            elseif ~isempty(cell2mat(regexp(LM_labels(g),voiced)))
                if strfind(char(LM_labels(g)),'cl')
                    if ~isempty(cell2mat(regexp(LM_labels(g),{'v','dh','z','zh'})))
                        vfc_index = vfc_index+1;
                        vfc_times(vfc_index) = LM_indices(g);
                    else
                        vsc_index = vsc_index+1;
                        vsc_times(vsc_index) = LM_indices(g);
                    end
                else
                   if ~isempty(cell2mat(regexp(LM_labels(g),{'v','dh','z','zh'})))
                       vfr_index = vfr_index+1;
                       vfr_times(vfr_index) = LM_indices(g);
                   elseif ~isempty(cell2mat(regexp(LM_labels(g),{'jh','dj'})))
                       if strfind(char(LM_labels(g)),'1')
                           vsr_index = vsr_index+1;
                           vfc_index = vfc_index+1;
                           vsr_times(vsr_index) = LM_indices(g);
                           vfc_times(vfc_index) = LM_indices(g);
                       else
                           vfr_index = vfr_index+1;
                           vfr_times(vfr_index) = LM_indices(g);
                       end
                   else
                       if g ~= length(LM_labels)
                           if ~isempty(cell2mat(regexp(LM_labels(g+1),{'"V"','"l"','"r"','"y"','"w"'})))
                               vsrvot_index = vsrvot_index+1;
                               vsrvot_times(vsrvot_index) = LM_indices(g);
                           else
                               vsr_index = vsr_index+1;
                               vsr_times(vsr_index) = LM_indices(g);
                           end
                       else
                           vsr_index = vsr_index+1;
                           vsr_times(vsr_index) = LM_indices(g);
                       end
                   end
                end
            elseif ~isempty(cell2mat(regexp(LM_labels(g),unvoiced)))
                if strfind(char(LM_labels(g)),'cl')
                    if ~isempty(cell2mat(regexp(LM_labels(g),{'f','th','s','sh'})))
                        uvfc_index = uvfc_index+1;
                        uvfc_times(uvfc_index) = LM_indices(g);
                    else
                        uvsc_index = uvsc_index+1;
                        uvsc_times(uvsc_index) = LM_indices(g);
                    end
                else
                   if ~isempty(cell2mat(regexp(LM_labels(g),{'f','th','s','sh'})))
                       uvfr_index = uvfr_index+1;
                       uvfr_times(uvfr_index) = LM_indices(g);
                   elseif ~isempty(cell2mat(regexp(LM_labels(g),{'ch'})))
                       if strfind(char(LM_labels(g)),'1')
                           uvsr_index = uvsr_index+1;
                           uvfc_index = uvfc_index+1;
                           uvsr_times(uvsr_index) = LM_indices(g);
                           uvfc_times(uvfc_index) = LM_indices(g);
                       else
                           uvfr_index = uvfr_index+1;
                           uvfr_times(uvfr_index) = LM_indices(g);
                       end
                   else
                       if g ~= length(LM_labels)
                           if ~isempty(cell2mat(regexp(LM_labels(g+1),{'"V"','"l"','"r"','"y"','"w"'})))
                               uvsrvot_index = uvsrvot_index+1;
                               uvsrvot_times(uvsrvot_index) = LM_indices(g);
                           else
                               uvsr_index = uvsr_index+1;
                               uvsr_times(uvsr_index) = LM_indices(g);
                           end
                       else
                           uvsr_index = uvsr_index+1;
                           uvsr_times(uvsr_index) = LM_indices(g);
                       end
                   end
                end
            end
        end
        %remove extra space
        r_starts(r_index+1:end) = [];
        l_starts(l_index+1:end) = [];
        w_starts(w_index+1:end) = [];
        h_starts(h_index+1:end) = [];
        y_starts(y_index+1:end) = [];
        glide_starts(glide_index+1:end) = [];
        v_times(v_index+1:end) = [];
        vsc_times(vsc_index+1:end) = [];
        vsr_times(vsr_index+1:end) = [];
        vsrvot_times(vsrvot_index+1:end) = [];
        vfc_times(vfc_index+1:end) = [];
        vfr_times(vfr_index+1:end) = [];
        uvsc_times(uvsc_index+1:end) = [];
        uvsr_times(uvsr_index+1:end) = [];
        uvsrvot_times(uvsrvot_index+1:end) = [];
        uvfc_times(uvfc_index+1:end) = [];
        uvfr_times(uvfr_index+1:end) = [];
        %find indices within glide regions
        r_indices = isininterval(T,r_starts,r_starts+0.3);
        l_indices = isininterval(T,l_starts,l_starts+0.3);
        w_indices = isininterval(T,w_starts,w_starts+0.3);
        h_indices = isininterval(T,h_starts,h_starts+0.3);
        y_indices = isininterval(T,y_starts,y_starts+0.3);
        glide_indices = isininterval(T,glide_starts,glide_starts+0.3);
        %find indices within closure and release regions
        vsc_indices = isininterval(1:length(T),vsc_times-15,vsc_times+15);
        vsr_indices = isininterval(1:length(T),vsr_times-15,vsr_times+15);
        vsrvot_indices = isininterval(1:length(T),vsrvot_times-15,vsrvot_times+15);
        vfc_indices = isininterval(1:length(T),vfc_times-15,vfc_times+15);
        vfr_indices = isininterval(1:length(T),vfr_times-15,vfr_times+15);
        uvsc_indices = isininterval(1:length(T),uvsc_times-15,uvsc_times+15);
        uvsr_indices = isininterval(1:length(T),uvsr_times-15,uvsr_times+15);
        uvsrvot_indices = isininterval(1:length(T),uvsrvot_times-15,uvsrvot_times+15);
        uvfc_indices = isininterval(1:length(T),uvfc_times-15,uvfc_times+15);
        uvfr_indices = isininterval(1:length(T),uvfr_times-15,uvfr_times+15);
        %calculate number of glide indices
        r_count = sum(r_indices);
        l_count = sum(l_indices);
        w_count = sum(w_indices);
        h_count = sum(h_indices);
        y_count = sum(y_indices);
        glide_count = sum(glide_indices);
        nonglide_count = numel(glide_indices)-glide_count;
        %calculate number of closure and release indices
        vsc_count = sum(vsc_indices);
        vsr_count = sum(vsr_indices);
        vsrvot_count = sum(vsrvot_indices);
        vfc_count = sum(vfc_indices);
        vfr_count = sum(vfr_indices);
        uvsc_count = sum(uvsc_indices);
        uvsr_count = sum(uvsr_indices);
        uvsrvot_count = sum(uvsrvot_indices);
        uvfc_count = sum(uvfc_indices);
        uvfr_count = sum(uvfr_indices);
        %create specific data arrays
        %gV_1=[smooth(diff(V(:,1)),30) smooth(diff(V(:,2)),30) smooth(diff(V(:,3)),30) ...
        %smooth(diff(V(:,4)),30) smooth(diff(V(:,5)),30) smooth(diff(V(:,6)),30)];
        %gV_1=[gV_1; gV_1(end,:)];
        %gV = [gV_1 F1 F2 F3 B1 B2 B3];
        gV = [normalV sumV sumV/max(sumV) F1 F2-F1 F3-F2 F3-F1];
        F0_minus5 = F0;
        F0_plus5 = F0;
        F1_minus5 = F1;
        F1_plus5 = F1;
        H1_minus5 = H1;
        H1_plus5 = H1;
        H2_minus5 = H2;
        H2_plus5 = H2;
        H4_minus5 = H4;
        H4_plus5 = H4;
        H1_minus15 = H1;
        H1_plus15 = H1;
        F0_minus5(1:5) = repmat(F0(1),5,1);
        F0_plus5(end-4:end) = repmat(F0(end),5,1);
        F1_minus5(1:5) = repmat(F1(1),5,1);
        F1_plus5(end-4:end) = repmat(F1(end),5,1);
        H1_minus5(1:5) = repmat(H1(1),5,1);
        H1_plus5(end-4:end) = repmat(H1(end),5,1);
        H2_minus5(1:5) = repmat(H2(1),5,1);
        H2_plus5(end-4:end) = repmat(H2(end),5,1);
        H4_minus5(1:5) = repmat(H4(1),5,1);
        H4_plus5(end-4:end) = repmat(H4(end),5,1);
        H1_minus15(1:15) = repmat(H1(1),15,1);
        H1_plus15(end-14:end) = repmat(H1(end),15,1);
        VOT = zeros(length(F1),1);
        glottal_tier = array(g_index);
        plus_g = find(strtrim(glottal_tier)=='"+g"');
        for b = 1:length(VOT)
            bigger = plus_g(plus_g>b);
            if ~isempty(bigger)
                VOT(b) = bigger(1)-b;
            else
                VOT(b) = -1;
            end
        end
        vcV = [F0_minus5 F1_minus5 H1_minus5-H2_minus5 H1_minus5-H4_minus5 ...
            H1_plus15 zeros(length(F0),1)];
        vrV = [F0_plus5 F1_plus5 H1_plus5-H2_plus5 H1_plus5-H4_plus5 ...
            H1_minus15 zeros(length(F0),1)];
        vrvotV = [F0_plus5 F1_plus5 H1_plus5-H2_plus5 H1_plus5-H4_plus5 ...
            H1_minus15 VOT];
        %add to measurement arrays
        rM(ri+1:ri+r_count,:) = gV(r_indices,:);
        lM(li+1:li+l_count,:) = gV(l_indices,:);
        wM(wi+1:wi+w_count,:) = gV(w_indices,:);
        hM(hi+1:hi+h_count,:) = gV(h_indices,:);
        yM(yi+1:yi+y_count,:) = gV(y_indices,:);
        glideM(glidei+1:glidei+glide_count,:) = gV(glide_indices,:);
        nonglideM(nonglidei+1:nonglidei+nonglide_count,:) = gV(~glide_indices,:);
        vscM(vsci+1:vsci+vsc_count,:) = vcV(vsc_indices,:);
        vsrM(vsri+1:vsri+vsr_count,:) = vrV(vsr_indices,:);
        vsrvotM(vsrvoti+1:vsrvoti+vsrvot_count,:) = vrvotV(vsrvot_indices,:);
        vfcM(vfci+1:vfci+vfc_count,:) = vcV(vfc_indices,:);
        vfrM(vfri+1:vfri+vfr_count,:) = vrV(vfr_indices,:);
        uvscM(uvsci+1:uvsci+uvsc_count,:) = vcV(uvsc_indices,:);
        uvsrM(uvsri+1:uvsri+uvsr_count,:) = vrV(uvsr_indices,:);
        uvsrvotM(uvsrvoti+1:uvsrvoti+uvsrvot_count,:) = vrvotV(uvsrvot_indices,:);
        uvfcM(uvfci+1:uvfci+uvfc_count,:) = vcV(uvfc_indices,:);
        uvfrM(uvfri+1:uvfri+uvfr_count,:) = vrV(uvfr_indices,:);
        %update index variables
        ri = ri+r_count;
        li = li+l_count;
        wi = wi+w_count;
        hi = hi+h_count;
        yi = yi+y_count;
        glidei = glidei+glide_count;
        nonglidei = nonglidei+nonglide_count;
        vsci = vsci+vsc_count;
        vsri = vsri+vsr_count;
        vsrvoti = vsrvoti+vsrvot_count;
        vfci = vfci+vfc_count;
        vfri = vfri+vfr_count;
        uvsci = uvsci+uvsc_count;
        uvsri = uvsri+uvsr_count;
        uvsrvoti = uvsrvoti+uvsrvot_count;
        uvfci = uvfci+uvfc_count;
        uvfri = uvfri+uvfr_count;
        %if vgplace tier is found, use vowel times to get vgplace data
        if isa(vg_index,'double')
            vg_tier = array(vg_index,:);
            for v=1:length(v_times)
                v_time = v_times(v);
                back = false;
                low = false;
                high = false;
                atr = false;
                ctr = false;
                for k=correct(v_time-12,length(vg_tier)):correct(v_time+12,length(vg_tier))
                    if strfind(vg_tier(k),'"<high>"')
                        high = true;
                    elseif strfind(vg_tier(k),'"<low>"')
                        low = true;
                    elseif strfind(vg_tier(k),'"<back>"')
                        back = true;
                    elseif strfind(vg_tier(k),'"<atr>"')
                        atr = true;
                    elseif strfind(vg_tier(k),'"<ctr>"')
                        ctr = true;
                    end
                end
                f1 = F1(floor(length(F1)*v_time/length(vg_tier)));
                f2 = F2(floor(length(F2)*v_time/length(vg_tier)));
                vg_data = struct('back', back, 'high', high, 'low', low,...
                    'atr', atr, 'ctr', ctr, 'f1', f1, 'f2', f2);
                vgplace = [vgplace vg_data];
            end
        end
    end
    %if there is no LM tier, take no measurements
    
    %%take vgplace related measurements
    %if isa(vg_index,'double')
    %    currently no measurements are taken from the vgplace tier except 
    %    except within the LM tier section 
    %end
    %%if there is no vgplace tier, take no measurements
    
    
    %take cplace related measurements
    if isa(c_index,'double')
        %isolate cplace tier
        cplace_tier = array(c_index,:);
        
        %find all burst and formant transition labels
        %first, allocate formant transition closures
        ftc_lab_starts = zeros(20,1);
        ftc_den_starts = zeros(20,1);
        ftc_alv_starts = zeros(20,1);
        ftc_pal_starts = zeros(20,1);
        ftc_vel_starts = zeros(20,1);
        ftc_starts = zeros(20,1);
        %add index variables
        ftc_lab_index = 0;
        ftc_den_index = 0;
        ftc_alv_index = 0;
        ftc_pal_index = 0;
        ftc_vel_index = 0;
        ftc_index = 0;
        %second, allocate formant transition releases
        ftr_lab_starts = zeros(20,1);
        ftr_den_starts = zeros(20,1);
        ftr_alv_starts = zeros(20,1);
        ftr_pal_starts = zeros(20,1);
        ftr_vel_starts = zeros(20,1);
        ftr_starts = zeros(20,1);
        %add index variables
        ftr_lab_index = 0;
        ftr_den_index = 0;
        ftr_alv_index = 0;
        ftr_pal_index = 0;
        ftr_vel_index = 0;
        ftr_index = 0;
        %third, allocate spectral bursts
        sb_lab_starts = zeros(20,1);
        sb_den_starts = zeros(20,1);
        sb_alv_starts = zeros(20,1);
        sb_pal_starts = zeros(20,1);
        sb_vel_starts = zeros(20,1);
        sb_starts = zeros(20,1);
        %add index variables
        sb_lab_index = 0;
        sb_den_index = 0;
        sb_alv_index = 0;
        sb_pal_index = 0;
        sb_vel_index = 0;
        sb_index = 0;
        
        %search tier
        for c=1:length(cplace_tier)
            if strfind(cplace_tier(c),'FTc')
                ftc_index = ftc_index+1;
                ftc_starts(ftc_index) = (c-15)/1000;
                if strfind(cplace_tier(c),'lab')
                    ftc_lab_index = ftc_lab_index+1;
                    ftc_lab_starts(ftc_lab_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'den')
                    ftc_den_index = ftc_den_index+1;
                    ftc_den_starts(ftc_den_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'alv')
                    ftc_alv_index = ftc_alv_index+1;
                    ftc_alv_starts(ftc_alv_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'pal')
                    ftc_pal_index = ftc_pal_index+1;
                    ftc_pal_starts(ftc_pal_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'vel')
                    ftc_vel_index = ftc_vel_index+1;
                    ftc_vel_starts(ftc_vel_index) = (c-15)/1000;
                end
            elseif strfind(cplace_tier(c),'FTr')
                ftr_index = ftr_index+1;
                ftr_starts(ftr_index) = (c-15)/1000;
                if strfind(cplace_tier(c),'lab')
                    ftr_lab_index = ftr_lab_index+1;
                    ftr_lab_starts(ftr_lab_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'den')
                    ftr_den_index = ftr_den_index+1;
                    ftr_den_starts(ftr_den_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'alv')
                    ftr_alv_index = ftr_alv_index+1;
                    ftr_alv_starts(ftr_alv_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'pal')
                    ftr_pal_index = ftr_pal_index+1;
                    ftr_pal_starts(ftr_pal_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'vel')
                    ftr_vel_index = ftr_vel_index+1;
                    ftr_vel_starts(ftr_vel_index) = (c-15)/1000;
                end
            elseif strfind(cplace_tier(c),'SB')
                sb_index = sb_index+1;
                sb_starts(sb_index) = (c-15)/1000;
                if strfind(cplace_tier(c),'lab')
                    sb_lab_index = sb_lab_index+1;
                    sb_lab_starts(sb_lab_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'den')
                    sb_den_index = sb_den_index+1;
                    sb_den_starts(sb_den_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'alv')
                    sb_alv_index = sb_alv_index+1;
                    sb_alv_starts(sb_alv_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'pal')
                    sb_pal_index = sb_pal_index+1;
                    sb_pal_starts(sb_pal_index) = (c-15)/1000;
                elseif strfind(cplace_tier(c),'vel')
                    sb_vel_index = sb_vel_index+1;
                    sb_vel_starts(sb_vel_index) = (c-15)/1000;
                end
            end
        end
        %remove extra space
        ftc_lab_starts(ftc_lab_index+1:end) = [];
        ftc_den_starts(ftc_den_index+1:end) = [];
        ftc_alv_starts(ftc_alv_index+1:end) = [];
        ftc_pal_starts(ftc_pal_index+1:end) = [];
        ftc_vel_starts(ftc_vel_index+1:end) = [];
        ftc_starts(ftc_index+1:end) = [];
        ftr_lab_starts(ftr_lab_index+1:end) = [];
        ftr_den_starts(ftr_den_index+1:end) = [];
        ftr_alv_starts(ftr_alv_index+1:end) = [];
        ftr_pal_starts(ftr_pal_index+1:end) = [];
        ftr_vel_starts(ftr_vel_index+1:end) = [];
        ftr_starts(ftr_index+1:end) = [];
        sb_lab_starts(sb_lab_index+1:end) = [];
        sb_den_starts(sb_den_index+1:end) = [];
        sb_alv_starts(sb_alv_index+1:end) = [];
        sb_pal_starts(sb_pal_index+1:end) = [];
        sb_vel_starts(sb_vel_index+1:end) = [];
        sb_starts(sb_index+1:end) = [];
        
        %find indices within estimated ft and sb periods
        ftc_lab_indices = isininterval(T,ftc_lab_starts,ftc_lab_starts+0.03);
        ftc_den_indices = isininterval(T,ftc_den_starts,ftc_den_starts+0.03);
        ftc_alv_indices = isininterval(T,ftc_alv_starts,ftc_alv_starts+0.03);
        ftc_pal_indices = isininterval(T,ftc_pal_starts,ftc_pal_starts+0.03);
        ftc_vel_indices = isininterval(T,ftc_vel_starts,ftc_vel_starts+0.03);
        ftc_indices = isininterval(T,ftc_starts,ftc_starts+0.03);
        ftr_lab_indices = isininterval(T,ftr_lab_starts,ftr_lab_starts+0.03);
        ftr_den_indices = isininterval(T,ftr_den_starts,ftr_den_starts+0.03);
        ftr_alv_indices = isininterval(T,ftr_alv_starts,ftr_alv_starts+0.03);
        ftr_pal_indices = isininterval(T,ftr_pal_starts,ftr_pal_starts+0.03);
        ftr_vel_indices = isininterval(T,ftr_vel_starts,ftr_vel_starts+0.03);
        ftr_indices = isininterval(T,ftr_starts,ftr_starts+0.03);
        sb_lab_indices = isininterval(T,sb_lab_starts,sb_lab_starts+0.03);
        sb_den_indices = isininterval(T,sb_den_starts,sb_den_starts+0.03);
        sb_alv_indices = isininterval(T,sb_alv_starts,sb_alv_starts+0.03);
        sb_pal_indices = isininterval(T,sb_pal_starts,sb_pal_starts+0.03);
        sb_vel_indices = isininterval(T,sb_vel_starts,sb_vel_starts+0.03);
        sb_indices = isininterval(T,sb_starts,sb_starts+0.03);
        
        %calculate number of sb and ft indices
        ftc_lab_count = sum(ftc_lab_indices);
        ftc_den_count = sum(ftc_den_indices);
        ftc_alv_count = sum(ftc_alv_indices);
        ftc_pal_count = sum(ftc_pal_indices);
        ftc_vel_count = sum(ftc_vel_indices);
        ftc_count = sum(ftc_indices);
        %nonftc_count = numel(ftc_indices)-ftc_count;
        ftr_lab_count = sum(ftr_lab_indices);
        ftr_den_count = sum(ftr_den_indices);
        ftr_alv_count = sum(ftr_alv_indices);
        ftr_pal_count = sum(ftr_pal_indices);
        ftr_vel_count = sum(ftr_vel_indices);
        ftr_count = sum(ftr_indices);
        %nonftr_count = numel(ftr_indices)-ftr_count;
        %nonft_count = numel(ftr_indices)-ftr_count-ftc_count;
        sb_lab_count = sum(sb_lab_indices);
        sb_den_count = sum(sb_den_indices);
        sb_alv_count = sum(sb_alv_indices);
        sb_pal_count = sum(sb_pal_indices);
        sb_vel_count = sum(sb_vel_indices);
        sb_count = sum(sb_indices);
        nonsb_count = numel(sb_indices)-sb_count;
        
        %create specific data arrays
        %spectral burst data (1 is for detection, 2 is for place of
        %articulation)
        sbV_1 = [V F1 F2 B1 B2 B3 B4];
        V_norm = V(:,:);
        for v=1:length(V_norm)
            V_norm(v,:)=V_norm(v,:)/mean(V_norm(v,:));
        end
        sbV_2 = [V_norm F1 F2 F3 B1 B2 B3];
        %formant transition data (1 is for detection, 2 is for place of
        %articulation)
        V_diff = [abs(smooth(diff(F1))) abs(smooth(diff(F2))) ...
            abs(smooth(diff(F3))) abs(smooth(diff(B1)))];
        V_diff = [V_diff; V_diff(end,:)];
        ftV_1 = [V(:,1:2) V_diff];
        ftV_1_before = ftV_1(:,:);
        ftV_1_after = ftV_1(:,:);
        for v=11:length(ftV_1_before)
           ftV_1_before(v,:) = ftV_1(v-10,:); 
        end
        for v=1:length(ftV_1_after)-10
            ftV_1_after(v,:) = ftV_1(v+10,:);
        end
        ftV_1=[ftV_1_before(:,1:2) ftV_1_after(:,1:2) ...
            ftV_1_before(:,3:end) ftV_1_after(:,3:end)];
        ftV_2 = [V(:,1:4) F1 F2];
        ftV_2_before = ftV_2(:,:);
        ftV_2_after = ftV_2(:,:);
        for v=11:length(ftV_2_before)
           ftV_2_before(v,:) = ftV_2(v-10,:); 
        end
        for v=1:length(ftV_2_after)-10
            ftV_2_after(v,:) = ftV_2(v+10,:);
        end
        ftV_2=[ftV_2_before(:,1:4) ftV_2_after(:,1:4) ...
            ftV_2_before(:,5:end) ftV_2_after(:,5:end)];
        
        %add to measurement arrays
        ftc_labM(ftc_labi+1:ftc_labi+ftc_lab_count,:) = ftV_2(ftc_lab_indices,:);
        ftc_denM(ftc_deni+1:ftc_deni+ftc_den_count,:) = ftV_2(ftc_den_indices,:);
        ftc_alvM(ftc_alvi+1:ftc_alvi+ftc_alv_count,:) = ftV_2(ftc_alv_indices,:);
        ftc_palM(ftc_pali+1:ftc_pali+ftc_pal_count,:) = ftV_2(ftc_pal_indices,:);
        ftc_velM(ftc_veli+1:ftc_veli+ftc_vel_count,:) = ftV_2(ftc_vel_indices,:);
        ftcM(ftci+1:ftci+ftc_count,:) = ftV_1(ftc_indices,:);
        ftr_labM(ftr_labi+1:ftr_labi+ftr_lab_count,:) = ftV_2(ftr_lab_indices,:);
        ftr_denM(ftr_deni+1:ftr_deni+ftr_den_count,:) = ftV_2(ftr_den_indices,:);
        ftr_alvM(ftr_alvi+1:ftr_alvi+ftr_alv_count,:) = ftV_2(ftr_alv_indices,:);
        ftr_palM(ftr_pali+1:ftr_pali+ftr_pal_count,:) = ftV_2(ftr_pal_indices,:);
        ftr_velM(ftr_veli+1:ftr_veli+ftr_vel_count,:) = ftV_2(ftr_vel_indices,:);
        ftrM(ftri+1:ftri+ftr_count,:) = ftV_1(ftr_indices,:);
        sb_labM(sb_labi+1:sb_labi+sb_lab_count,:) = sbV_2(sb_lab_indices,:);
        sb_denM(sb_deni+1:sb_deni+sb_den_count,:) = sbV_2(sb_den_indices,:);
        sb_alvM(sb_alvi+1:sb_alvi+sb_alv_count,:) = sbV_2(sb_alv_indices,:);
        sb_palM(sb_pali+1:sb_pali+sb_pal_count,:) = sbV_2(sb_pal_indices,:);
        sb_velM(sb_veli+1:sb_veli+sb_vel_count,:) = sbV_2(sb_vel_indices,:);
        burstM(bursti+1:bursti+sb_count,:) = sbV_1(sb_indices,:);
        nonftM(nonfti+1:nonfti+sum(~(ftr_indices+ftc_indices)),:) = ftV_1(~(ftr_indices+ftc_indices),:);
        nonburstM(nonbursti+1:nonbursti+nonsb_count,:) = sbV_1(~sb_indices,:);
        
        %update index variables
        ftc_labi = ftc_labi+ftc_lab_count;
        ftc_deni = ftc_deni+ftc_den_count;
        ftc_alvi = ftc_alvi+ftc_alv_count;
        ftc_pali = ftc_pali+ftc_pal_count;
        ftc_veli = ftc_veli+ftc_vel_count;
        ftci = ftci+ftc_count;
        ftr_labi = ftr_labi+ftr_lab_count;
        ftr_deni = ftr_deni+ftr_den_count;
        ftr_alvi = ftr_alvi+ftr_alv_count;
        ftr_pali = ftr_pali+ftr_pal_count;
        ftr_veli = ftr_veli+ftr_vel_count;
        ftri = ftri+ftr_count;
        sb_labi = sb_labi+sb_lab_count;
        sb_deni = sb_deni+sb_den_count;
        sb_alvi = sb_alvi+sb_alv_count;
        sb_pali = sb_pali+sb_pal_count;
        sb_veli = sb_veli+sb_vel_count;
        bursti = bursti+sb_count;
        nonbursti = nonbursti+nonsb_count;
        nonfti = nonfti+sum(~(ftr_indices+ftc_indices));
    end
    %if there is no cplace tier, take no measurements
    
    %take nasal related measurements
    if isa(n_index,'double')
        %isolate nasal tier
        nasal_tier=array(n_index,:);
        
        %find +n and -n labels
        n_starts = zeros(20,1);
        n_stops = zeros(20,1);
        n_start_index = 0;
        n_stop_index = 0;
        for n=1:length(nasal_tier)
            if strfind(nasal_tier(n),'"+n"')
                n_start_index=n_start_index+1;
                n_starts(n_start_index)=n/1000;
            elseif strfind(nasal_tier(n),'"-n"')
                n_stop_index=n_stop_index+1;
                n_stops(n_stop_index)=n/1000;
            end
        end
        %remove extra space
        n_starts(n_start_index+1:end)=[];
        n_stops(n_stop_index+1:end)=[];
        
        %find indices within nasal periods
        n_indices = isininterval(T,n_starts,n_stops);
        n_count = sum(n_indices);
        nonn_count = numel(n_indices)-n_count;
        
        %add to the measurement arrays
        nasalM(nasali+1:nasali+n_count,:)=V(n_indices,:);
        nasali=nasali+n_count;
        nonnasalM(nonnasali+1:nonnasali+nonn_count,:)=V(~n_indices,:);
        nonnasali=nonnasali+nonn_count;
    end
    %if there is no nasal tier, take no measurements
    
    %take glottal related measurements
    if isa(g_index,'double')
        %isolate glottal tier
        glottal_tier = array(g_index,:);
        
        %find +g, -g, <ipp, and ipp> labels
        g_starts = zeros(20,1);
        g_stops = zeros(20,1);
        ipp_starts = zeros(20,1);
        ipp_stops = zeros(20,1);
        g_start_index = 0;
        g_stop_index = 0;
        ipp_start_index = 0;
        ipp_stop_index = 0;
        for g=1:length(glottal_tier)
            if strfind(glottal_tier(g),'"+g"')
                g_start_index = g_start_index+1;
                g_starts(g_start_index) = g/1000;
            elseif strfind(glottal_tier(g),'"-g"')
                g_stop_index = g_stop_index+1;
                g_stops(g_stop_index) = g/1000;
            elseif strfind(glottal_tier(g),'"<ipp"')
                ipp_start_index = ipp_start_index+1;
                ipp_starts(ipp_start_index) = g/1000;
            elseif strfind(glottal_tier(g),'"ipp>"')
                ipp_stop_index = ipp_stop_index+1;
                ipp_stops(ipp_stop_index) = g/1000;
            end
        end
        %remove extra space
        g_starts(g_start_index+1:end) = [];
        g_stops(g_stop_index+1:end) = [];
        ipp_starts(ipp_start_index+1:end) = [];
        ipp_stops(ipp_stop_index+1:end) = [];
        
        %find indices within glottal and irregular pitch periods
        g_indices = isininterval(T,g_starts,g_stops);
        g_count = sum(g_indices);
        nong_count = numel(g_indices)-g_count;
        ipp_indices = isininterval(T,ipp_starts,ipp_stops);
        ipp_count = sum(ipp_indices);
        nonipp_count = numel(ipp_indices)-ipp_count;
        
        %create specific data array
        sumV = V(:,1);
        for k = 1:length(V)
            sumV(k) = sum(V(k,:));
        end
        gV = [V sumV F1 F2 F3 B1 B2];
        
        %add to measurement arrays
        glottalM(glottali+1:glottali+g_count,:) = gV(g_indices,:);
        glottali = glottali+g_count;
        nonglottalM(nonglottali+1:nonglottali+nong_count,:) = gV(~g_indices,:);
        nonglottali = nonglottali+nong_count;
        ippM(ippi+1:ippi+ipp_count,:) = V(ipp_indices,:);
        ippi = ippi+ipp_count;
        nonippM(nonippi+1:nonippi+nonipp_count,:) = V(~ipp_indices,:);
        nonippi = nonippi+nonipp_count;
    end
    %if there is no glottal tier, take no measurements
    catch
        disp('error with word, skipping');
    end
end

%create GMMs

%first, glides
rM(ri+1:end,:) = [];
lM(li+1:end,:) = [];
wM(wi+1:end,:) = [];
hM(hi+1:end,:) = [];
yM(yi+1:end,:) = [];
glideM(glidei+1:end,:) = [];
nonglideM(nonglidei+1:end,:) = [];
rDist = fitgmdist(rM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
lDist = fitgmdist(lM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
wDist = fitgmdist(wM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
hDist = fitgmdist(hM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
yDist = fitgmdist(yM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
glideDist = fitgmdist(glideM, 6, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonglideDist = fitgmdist(nonglideM, 6, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
save('models.mat','rDist','lDist','wDist','hDist','yDist',...
    'glideDist','nonglideDist','-append');

%second, cplace
%formant transition closures
ftc_labM(ftc_labi+1:end,:) = [];
ftc_denM(ftc_deni+1:end,:) = [];
ftc_alvM(ftc_alvi+1:end,:) = [];
ftc_palM(ftc_pali+1:end,:) = [];
ftc_velM(ftc_veli+1:end,:) = [];
ftcM(ftci+1:end,:) = [];
ftc_labDist = fitgmdist(ftc_labM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftc_denDist = fitgmdist(ftc_denM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftc_alvDist = fitgmdist(ftc_alvM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftc_palDist = fitgmdist(ftc_palM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftc_velDist = fitgmdist(ftc_velM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftcDist = fitgmdist(ftcM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
save('models.mat','ftc_labDist','ftc_denDist','ftc_alvDist',...
    'ftc_palDist','ftc_velDist','ftcDist','-append');

%formant transition releases (and non-formant transition)
ftr_labM(ftr_labi+1:end,:) = [];
ftr_denM(ftr_deni+1:end,:) = [];
ftr_alvM(ftr_alvi+1:end,:) = [];
ftr_palM(ftr_pali+1:end,:) = [];
ftr_velM(ftr_veli+1:end,:) = [];
ftrM(ftri+1:end,:) = [];
nonftM(nonfti+1:end,:) = [];
ftr_labDist = fitgmdist(ftr_labM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftr_denDist = fitgmdist(ftr_denM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftr_alvDist = fitgmdist(ftr_alvM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftr_palDist = fitgmdist(ftr_palM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftr_velDist = fitgmdist(ftr_velM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ftrDist = fitgmdist(ftrM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonftDist = fitgmdist(nonftM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
save('models.mat','ftr_labDist','ftr_denDist','ftr_alvDist',...
    'ftr_palDist','ftr_velDist','ftrDist','nonftDist','-append');

%spectral bursts (and non-spectral burst)
sb_labM(sb_labi+1:end,:) = [];
sb_denM(sb_deni+1:end,:) = [];
sb_alvM(sb_alvi+1:end,:) = [];
sb_palM(sb_pali+1:end,:) = [];
sb_velM(sb_veli+1:end,:) = [];
burstM(bursti+1:end,:) = [];
nonburstM(nonbursti+1:end,:) = [];
sb_labDist = fitgmdist(sb_labM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
sb_denDist = fitgmdist(sb_denM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
sb_alvDist = fitgmdist(sb_alvM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
sb_palDist = fitgmdist(sb_palM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
sb_velDist = fitgmdist(sb_velM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
burstDist = fitgmdist(burstM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonburstDist = fitgmdist(nonburstM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
save('models.mat','sb_labDist','sb_denDist','sb_alvDist',...
    'sb_palDist','sb_velDist','burstDist','nonburstDist','-append');

%third, nasal
nasalM(nasali+1:end,:) = [];
nonnasalM(nonnasali+1:end,:) = [];
nasalDist = fitgmdist(nasalM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonnasalDist = fitgmdist(nonnasalM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
save('models.mat','nasalDist','nonnasalDist','-append');

%fourth, glottal and ipp
glottalM(glottali+1:end,:) = [];
nonglottalM(nonglottali+1:end,:) = [];
ippM(ippi+1:end,:) = [];
nonippM(nonippi+1:end,:) = [];
glottalDist = fitgmdist(glottalM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonglottalDist = fitgmdist(nonglottalM, 6, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
ippDist = fitgmdist(ippM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
nonippDist = fitgmdist(nonippM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
save('models.mat','glottalDist','nonglottalDist','ippDist','nonippDist','-append');

%fifth, vgplace (works differently)
extCategories = struct('back', {0, 1});
heightCategories = struct('high', {1, 0, 0}, 'low', {0, 0, 1});
atrHighCategories = struct('high', {1, 1}, 'atr', {1, 0}, 'ctr', {0, 0});
atrMidCategories = struct('high', {0, 0}, 'low', {0, 0}, 'atr', {1, 0}, 'ctr', {0, 0});
ctrCategories = struct('low', {1, 1}, 'atr', {0, 0}, 'ctr', {1, 0});
extTraining = trainCategories(vgplace,extCategories,true);
heightTraining = trainCategories(vgplace,heightCategories,true);
atrHighTraining = trainCategories(vgplace,atrHighCategories,true);
atrMidTraining = trainCategories(vgplace,atrMidCategories,true);
ctrTraining = trainCategories(vgplace,ctrCategories,true);
save('models.mat','extTraining','heightTraining','atrHighTraining',...
    'atrMidTraining','ctrTraining','-append');

%sixth, consonant voicing
vscM(vsci+1:end,:) = [];
vsrM(vsri+1:end,:) = [];
vsrvotM(vsrvoti+1:end,:) = [];
vfcM(vfci+1:end,:) = [];
vfrM(vfri+1:end,:) = [];
uvscM(uvsci+1:end,:) = [];
uvsrM(uvsri+1:end,:) = [];
uvsrvotM(uvsrvoti+1:end,:) = [];
uvfcM(uvfci+1:end,:) = [];
uvfrM(uvfri+1:end,:) = [];
vscDist = fitgmdist(vscM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
vsrDist = fitgmdist(vsrM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
vsrvotDist = fitgmdist(vsrvotM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
vfcDist = fitgmdist(vfcM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
vfrDist = fitgmdist(vfrM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
uvscDist = fitgmdist(uvscM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
uvsrDist = fitgmdist(uvsrM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
uvsrvotDist = fitgmdist(uvsrvotM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
uvfcDist = fitgmdist(uvfcM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
uvfrDist = fitgmdist(uvfrM, 4, 'RegularizationValue', 1e-4, ...
    'Options', statset('Display', 'final'));
save('models.mat','vscDist','vsrDist','vsrvotDist','vfcDist','vfrDist',...
    'uvscDist','uvsrDist','uvsrvotDist','uvfcDist','uvfrDist','-append');
end

function new_t = correct(t,length)
if t<1
    new_t = 1;
elseif t>length
    new_t = length;
else
    new_t = t;
end
end
    