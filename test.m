function [scores,f_scores,errors]=test(path,filePrefixes)

%ensure that the path is valid
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

errors=0;

%create target and output arrays for all module data
%also create index variables to track position in arrays
v_targets=zeros(3000*length(filePrefixes),1);
v_outputs=zeros(3000*length(filePrefixes),1);
v_index=0;

glottal_targets=zeros(3000*length(filePrefixes),1);
glottal_outputs=zeros(3000*length(filePrefixes),1);
glottal_index=0;

nasal_targets=zeros(3000*length(filePrefixes),1);
nasal_outputs=zeros(3000*length(filePrefixes),1);
nasal_index=0;

n_targets=zeros(200*length(filePrefixes),1);
n_outputs=zeros(200*length(filePrefixes),1);
n_index=0;

g_targets=zeros(3000*length(filePrefixes),1);
g_outputs=zeros(3000*length(filePrefixes),1);
g_index=0;

stop_targets=zeros(3000*length(filePrefixes),1);
stop_outputs=zeros(3000*length(filePrefixes),1);
stop_index=0;

fricative_targets=zeros(3000*length(filePrefixes),1);
fricative_outputs=zeros(3000*length(filePrefixes),1);
fricative_index=0;

sb_targets=zeros(3000*length(filePrefixes),1);
sb_outputs=zeros(3000*length(filePrefixes),1);
sb_index=0;

ftc_targets=zeros(3000*length(filePrefixes),1);
ftc_outputs=zeros(3000*length(filePrefixes),1);
ftc_index=0;

ftr_targets=zeros(3000*length(filePrefixes),1);
ftr_outputs=zeros(3000*length(filePrefixes),1);
ftr_index=0;

vgplace_targets=zeros(20*length(filePrefixes),5);
vgplace_outputs=zeros(20*length(filePrefixes),5);
vgplace_index=0;

sbplace_targets=zeros(50*length(filePrefixes),5);
sbplace_outputs=zeros(50*length(filePrefixes),5);
sbplace_index=0;

ftcplace_targets=zeros(50*length(filePrefixes),5);
ftcplace_outputs=zeros(50*length(filePrefixes),5);
ftcplace_index=0;

ftrplace_targets=zeros(50*length(filePrefixes),5);
ftrplace_outputs=zeros(50*length(filePrefixes),5);
ftrplace_index=0;

cvoicing_targets=zeros(50*length(filePrefixes),5);
cvoicing_outputs=zeros(50*length(filePrefixes),5);
cvoicing_index=0;

%iterate through all files to collect data
for i = 1:length(filePrefixes)
    try
    disp(['Testing with file ' filePrefixes{i}]);
    %assemble the names of the WAV and TextGrid files
    wav_file = [PATH filePrefixes{i} '.WAV'];
    textgrid_file = [PATH filePrefixes{i} '.TextGrid'];
    
    %create arrays for the labeled and generated textgrids
    [test_array,test_tiers]=textgrid_to_array(textgrid_file);
    [pred_array,pred_tiers]=predict(wav_file);
    %[pred_array,pred_tiers]=textgrid_to_array([PATH 'output.TextGrid']);
    
    %isolate tiers for both arrays
    for j=1:length(test_tiers)
        tier=char(test_tiers(j));
        if strfind(tier,'"LM"')
            test_LMtier=test_array(j,:);
            test_LMtier_indices=find(test_LMtier~='');
            test_LMtier_labels=test_LMtier(test_LMtier_indices);
        elseif strfind(tier,'"vgplace"')
            test_vgtier=test_array(j,:);
            test_vgtier_indices=find(test_vgtier~='');
            test_vgtier_labels=test_vgtier(test_vgtier_indices);
        elseif strfind(tier,'"cplace"')
            test_ctier=test_array(j,:);
            test_ctier_indices=find(test_ctier~='');
            test_ctier_labels=test_ctier(test_ctier_indices);
        elseif strfind(tier,'"nasal"')
            test_ntier=test_array(j,:);
            test_ntier_indices=find(test_ntier~='');
            test_ntier_labels=test_ntier(test_ntier_indices);
        elseif strfind(tier,'"glottal"')
            test_gtier=test_array(j,:);
            test_gtier_indices=find(test_gtier~='');
            test_gtier_labels=test_gtier(test_gtier_indices);
        end
    end
    for j=1:length(pred_tiers)
        tier=char(pred_tiers(j));
        if strfind(tier,'"LM"')
            pred_LMtier=pred_array(j,:);
            pred_LMtier_indices=find(pred_LMtier~='');
            pred_LMtier_labels=pred_LMtier(pred_LMtier_indices);
        elseif strfind(tier,'"vgplace"')
            pred_vgtier=pred_array(j,:);
            pred_vgtier_indices=find(pred_vgtier~='');
            pred_vgtier_labels=pred_vgtier(pred_vgtier_indices);
        elseif strfind(tier,'"cplace"')
            pred_ctier=pred_array(j,:);
            pred_ctier_indices=find(pred_ctier~='');
            pred_ctier_labels=pred_ctier(pred_ctier_indices);
        elseif strfind(tier,'"nasal"')
            pred_ntier=pred_array(j,:);
            pred_ntier_indices=find(pred_ntier~='');
            pred_ntier_labels=pred_ntier(pred_ntier_indices);
        elseif strfind(tier,'"glottal"')
            pred_gtier=pred_array(j,:);
            pred_gtier_indices=find(pred_gtier~='');
            pred_gtier_labels=pred_gtier(pred_gtier_indices);
        elseif strfind(tier,'"cvoicing"') 
            pred_cvtier=pred_array(j,:);
        end
    end
    
    %find regions surrounding vowel landmarks
    test_v_indices=zeros(floor(length(test_LMtier)/100),1);
    test_v_index=0;
    for j=1:length(test_LMtier_labels)
        if strfind(char(test_LMtier_labels(j)),'"V"')
            test_v_index=test_v_index+1;
            test_v_indices(test_v_index)=test_LMtier_indices(j);
        end
    end
    pred_v_indices=zeros(floor(length(pred_LMtier)/100),1);
    pred_v_index=0;
    for j=1:length(pred_LMtier_labels)
        if strfind(char(pred_LMtier_labels(j)),'"V"')
            pred_v_index=pred_v_index+1;
            pred_v_indices(pred_v_index)=pred_LMtier_indices(j);
        end
    end
    test_v_indices(test_v_index+1:end)=[];
    pred_v_indices(pred_v_index+1:end)=[];
    test_v_intervals=isininterval(1:length(test_LMtier),test_v_indices-15,test_v_indices+15);
    pred_v_intervals=isininterval(1:length(test_LMtier),pred_v_indices-15,pred_v_indices+15);
    v_targets(v_index+1:v_index+length(test_LMtier))=test_v_intervals(1:end);
    v_outputs(v_index+1:v_index+length(test_LMtier))=pred_v_intervals(1:end);
    v_index=v_index+length(test_LMtier);
    
    %find regions surrounding glottal periods
    test_glottal_starts=zeros(floor(length(test_gtier)/100),1);
    test_glottal_stops=zeros(floor(length(test_gtier)/100),1);
    test_glottal_start_index=0;
    test_glottal_stop_index=0;
    for j=1:length(test_gtier_labels)
        if strfind(char(test_gtier_labels(j)),'"+g"')
            test_glottal_start_index=test_glottal_start_index+1;
            test_glottal_starts(test_glottal_start_index)=test_gtier_indices(j);
        elseif strfind(char(test_gtier_labels(j)),'"-g"')
            test_glottal_stop_index=test_glottal_stop_index+1;
            test_glottal_stops(test_glottal_stop_index)=test_gtier_indices(j);
        end
    end
    test_glottal_starts(test_glottal_start_index+1:end)=[];
    test_glottal_stops(test_glottal_stop_index+1:end)=[];
    pred_glottal_starts=zeros(floor(length(pred_gtier)/100),1);
    pred_glottal_stops=zeros(floor(length(pred_gtier)/100),1);
    pred_glottal_start_index=0;
    pred_glottal_stop_index=0;
    for j=1:length(pred_gtier_labels)
        if strfind(char(pred_gtier_labels(j)),'"+g"')
            pred_glottal_start_index=pred_glottal_start_index+1;
            pred_glottal_starts(pred_glottal_start_index)=pred_gtier_indices(j);
        elseif strfind(char(pred_gtier_labels(j)),'"-g"')
            pred_glottal_stop_index=pred_glottal_stop_index+1;
            pred_glottal_stops(pred_glottal_stop_index)=pred_gtier_indices(j);
        end
    end
    pred_glottal_starts(pred_glottal_start_index+1:end)=[];
    pred_glottal_stops(pred_glottal_stop_index+1:end)=[];
    test_glottal_intervals=isininterval(1:length(test_gtier),test_glottal_starts,test_glottal_stops);
    pred_glottal_intervals=isininterval(1:length(test_gtier),pred_glottal_starts,pred_glottal_stops);
    glottal_targets(glottal_index+1:glottal_index+length(test_gtier))=...
        test_glottal_intervals(1:end);
    glottal_outputs(glottal_index+1:glottal_index+length(test_gtier))=...
        pred_glottal_intervals(1:end);
    glottal_index=glottal_index+length(test_gtier);
    
    %find intervals surrounding nasal regions
    test_nasal_starts=zeros(floor(length(test_ntier)/100),1);
    test_nasal_stops=zeros(floor(length(test_ntier)/100),1);
    test_nasal_start_index=0;
    test_nasal_stop_index=0;
    for j=1:length(test_ntier_labels)
        if strfind(char(test_ntier_labels(j)),'"+n"')
            test_nasal_start_index=test_nasal_start_index+1;
            test_nasal_starts(test_nasal_start_index)=test_ntier_indices(j);
        elseif strfind(char(test_ntier_labels(j)),'"-n"')
            test_nasal_stop_index=test_nasal_stop_index+1;
            test_nasal_stops(test_nasal_stop_index)=test_ntier_indices(j);
        end
    end
    test_nasal_starts(test_nasal_start_index+1:end)=[];
    test_nasal_stops(test_nasal_stop_index+1:end)=[];
    pred_nasal_starts=zeros(floor(length(pred_ntier)/100),1);
    pred_nasal_stops=zeros(floor(length(pred_ntier)/100),1);
    pred_nasal_start_index=0;
    pred_nasal_stop_index=0;
    for j=1:length(pred_ntier_labels)
        if strfind(char(pred_ntier_labels(j)),'"+n"')
            pred_nasal_start_index=pred_nasal_start_index+1;
            pred_nasal_starts(pred_nasal_start_index)=pred_ntier_indices(j);
        elseif strfind(char(pred_ntier_labels(j)),'"-n"')
            pred_nasal_stop_index=pred_nasal_stop_index+1;
            pred_nasal_stops(pred_nasal_stop_index)=pred_ntier_indices(j);
        end
    end
    pred_nasal_starts(pred_nasal_start_index+1:end)=[];
    pred_nasal_stops(pred_nasal_stop_index+1:end)=[];
    test_nasal_intervals=isininterval(1:length(test_ntier),test_nasal_starts,test_nasal_stops);
    pred_nasal_intervals=isininterval(1:length(test_ntier),pred_nasal_starts,pred_nasal_stops);
    nasal_targets(nasal_index+1:nasal_index+length(test_ntier))=test_nasal_intervals(1:end);
    nasal_outputs(nasal_index+1:nasal_index+length(test_ntier))=pred_nasal_intervals(1:end);
    nasal_index=nasal_index+length(test_ntier);
    
    %find intervals of nasal consonants
    test_n_starts=zeros(floor(length(test_LMtier)/100),1);
    test_n_stops=zeros(floor(length(test_LMtier)/100),1);
    test_n_start_index=0;
    test_n_stop_index=0;
    for j=1:length(test_LMtier_labels)
        if ~isempty(cell2mat(regexp(char(test_LMtier_labels(j)),{'n-cl','m-cl','ng-cl'})))
            test_n_start_index=test_n_start_index+1;
            test_n_starts(test_n_start_index)=test_LMtier_indices(j);
        elseif ~isempty(cell2mat(regexp(char(test_LMtier_labels(j)),{'"n"','"m"','"ng"'})))
            test_n_stop_index=test_n_stop_index+1;
            test_n_stops(test_n_stop_index)=test_LMtier_indices(j);
        end
    end
    test_n_starts(test_n_start_index+1:end)=[];
    test_n_stops(test_n_stop_index+1:end)=[];
    pred_n_starts=zeros(floor(length(pred_LMtier)/100),1);
    pred_n_stops=zeros(floor(length(pred_LMtier)/100),1);
    pred_n_start_index=0;
    pred_n_stop_index=0;
    for j=1:length(pred_LMtier_labels)
        if strfind(char(pred_LMtier_labels(j)),'"Nc"')
            pred_n_start_index=pred_n_start_index+1;
            pred_n_starts(pred_n_start_index)=pred_LMtier_indices(j);
        elseif strfind(char(pred_LMtier_labels(j)),'"Nr"')
            pred_n_stop_index=pred_n_stop_index+1;
            pred_n_stops(pred_n_stop_index)=pred_LMtier_indices(j);
        end
    end
    pred_n_starts(pred_n_start_index+1:end)=[];
    pred_n_stops(pred_n_stop_index+1:end)=[];
    test_n_intervals=isininterval(1:length(test_LMtier),test_n_starts,test_n_stops);
    pred_n_intervals=isininterval(1:length(test_LMtier),pred_n_starts,pred_n_stops);
    n_targets(n_index+1:n_index+length(test_LMtier))=test_n_intervals(1:end);
    n_outputs(n_index+1:n_index+length(test_LMtier))=pred_n_intervals(1:end);
    n_index=n_index+length(test_LMtier);
    
    %find intervals surrounding glides
    test_g_indices=zeros(floor(length(test_LMtier)/100),1);
    test_g_index=0;
    for j=1:length(test_LMtier_labels)
        if strfind(char(test_LMtier_labels(j)),'"r"')
            test_g_index=test_g_index+1;
            test_g_indices(test_g_index)=test_LMtier_indices(j);
        elseif strfind(char(test_LMtier_labels(j)),'"l"')
            test_g_index=test_g_index+1;
            test_g_indices(test_g_index)=test_LMtier_indices(j);
        elseif strfind(char(test_LMtier_labels(j)),'"h"')
            test_g_index=test_g_index+1;
            test_g_indices(test_g_index)=test_LMtier_indices(j);
        elseif strfind(char(test_LMtier_labels(j)),'"w"')
            test_g_index=test_g_index+1;
            test_g_indices(test_g_index)=test_LMtier_indices(j);
        elseif strfind(char(test_LMtier_labels(j)),'"y"')
            test_g_index=test_g_index+1;
            test_g_indices(test_g_index)=test_LMtier_indices(j);
        end
    end
    test_g_indices(test_g_index+1:end)=[];
    pred_g_indices=zeros(floor(length(pred_LMtier)/100),1);
    pred_g_index=0;
    for j=1:length(pred_LMtier_labels)
        if strfind(char(pred_LMtier_labels(j)),'"G"')
            pred_g_index=pred_g_index+1;
            pred_g_indices(pred_g_index)=pred_LMtier_indices(j);
        end
    end
    pred_g_indices(pred_g_index+1:end)=[];
    test_g_intervals=isininterval(1:length(test_LMtier),test_g_indices-15,test_g_indices+15);
    pred_g_intervals=isininterval(1:length(test_LMtier),pred_g_indices-15,pred_g_indices+15);
    g_targets(g_index+1:g_index+length(test_LMtier))=test_g_intervals(1:end);
    g_outputs(g_index+1:g_index+length(test_LMtier))=pred_g_intervals(1:end);
    g_index=g_index+length(test_LMtier);
    
    %find intervals surrounding stop consonants
    test_stop_closures=zeros(floor(length(test_LMtier)/100),1);
    test_stop_releases=zeros(floor(length(test_LMtier)/100),1);
    test_stop_closure_index=0;
    test_stop_release_index=0;
    test_stop_closures_voicing=zeros(length(test_stop_closures),1);
    test_stop_releases_voicing=zeros(length(test_stop_releases),1);
    stop_release_labels={'"p"','"b"','"d"','"t"','"ch"','"ch1"','"ch2"',...
        '"jh"','"jh1"','"jh2"','"g"','"k"','"ch-1"','"ch-2"','"jh-1"','"jh-2"'};
    stop_closure_labels={'"p-cl"','"b-cl"','"d-cl"','"t-cl"','"ch-cl"',...
        '"jh-cl"','"g-cl"','"k-cl"'};
    stop_release_voiced_labels={'"b"','"d"','"g"','"jh1"','"jh-1"'};
    stop_closure_voiced_labels={'"b-cl"','"d-cl"','"g-cl"','"jh-cl"'};
    for j=1:length(test_LMtier_labels)
        if any(ismember(stop_release_labels,strtrim(char(test_LMtier_labels(j)))))
            test_stop_release_index=test_stop_release_index+1;
            test_stop_releases(test_stop_release_index)=test_LMtier_indices(j);
            if any(ismember(stop_release_voiced_labels,strtrim(char(test_LMtier_labels(j)))))
                test_stop_releases_voicing(test_stop_release_index)=1;
            end
        elseif any(ismember(stop_closure_labels,strtrim(char(test_LMtier_labels(j)))))
            test_stop_closure_index=test_stop_closure_index+1;
            test_stop_closures(test_stop_closure_index)=test_LMtier_indices(j);
            if any(ismember(stop_closure_voiced_labels,strtrim(char(test_LMtier_labels(j)))))
                test_stop_closures_voicing(test_stop_closure_index)=1;
            end
        end
    end
    test_stop_closures(test_stop_closure_index+1:end)=[];
    test_stop_releases(test_stop_release_index+1:end)=[];
    test_stop_closures_voicing(test_stop_closure_index+1:end)=[];
    test_stop_releases_voicing(test_stop_release_index+1:end)=[];
    pred_stop_closures=zeros(floor(length(pred_LMtier)/100),1);
    pred_stop_releases=zeros(floor(length(pred_LMtier)/100),1);
    pred_stop_closure_index=0;
    pred_stop_release_index=0;
    pred_stop_closures_voicing=zeros(length(pred_stop_closures),1);
    pred_stop_releases_voicing=zeros(length(pred_stop_releases),1);
    for j=1:length(pred_LMtier_labels)
        if strfind(char(pred_LMtier_labels(j)),'"Sr"')
            pred_stop_release_index=pred_stop_release_index+1;
            pred_stop_releases(pred_stop_release_index)=pred_LMtier_indices(j);
            if strfind(pred_cvtier(pred_LMtier_indices(j)),'slack')
                pred_stop_releases_voicing(pred_stop_release_index)=1;
            end
        elseif strfind(char(pred_LMtier_labels(j)),'"Sc"')
            pred_stop_closure_index=pred_stop_closure_index+1;
            pred_stop_closures(pred_stop_closure_index)=pred_LMtier_indices(j);
            if strfind(pred_cvtier(pred_LMtier_indices(j)),'slack')
                pred_stop_closures_voicing(pred_stop_closure_index)=1;
            end
        end
    end
    pred_stop_closures(pred_stop_closure_index+1:end)=[];
    pred_stop_releases(pred_stop_release_index+1:end)=[];
    pred_stop_closures_voicing(pred_stop_closure_index+1:end)=[];
    pred_stop_releases_voicing(pred_stop_release_index+1:end)=[];
    if ~isempty(test_stop_closures) && ~isempty(test_stop_releases)
    if test_stop_closures(1)>test_stop_releases(1)
        test_stop_closures=[1; test_stop_closures];
    end
    if test_stop_releases(end)<test_stop_closures(end)
        test_stop_releases=[test_stop_releases; length(test_LMtier)];
    end
    test_stop_intervals=isininterval(1:length(test_LMtier),test_stop_closures,test_stop_releases);
    pred_stop_intervals=isininterval(1:length(test_LMtier),pred_stop_closures,pred_stop_releases);
    stop_targets(stop_index+1:stop_index+length(test_LMtier))=test_stop_intervals(1:end);
    stop_outputs(stop_index+1:stop_index+length(test_LMtier))=pred_stop_intervals(1:end);
    stop_index=stop_index+length(test_LMtier);
    end
    
    %find intervals surrounding fricative consonants
    test_fricative_closures=zeros(floor(length(test_LMtier)/100),1);
    test_fricative_releases=zeros(floor(length(test_LMtier)/100),1);
    test_fricative_closure_index=0;
    test_fricative_release_index=0;
    test_fricative_closures_voicing=zeros(length(test_fricative_closures),1);
    test_fricative_releases_voicing=zeros(length(test_fricative_releases),1);
    fricative_release_labels={'"v"','"dh"','"z"','"zh"','f','th','s','sh'};
    fricative_closure_labels={'"v-cl"','"dh-cl"','"z-cl"','"zh-cl"','"f-cl"','"th"','"s"','"sh"'};
    fricative_release_voiced_labels={'"v"','"z"','"zh"','dh'};
    fricative_closure_voiced_labels={'"v-cl"','"dh-cl"','"z-cl"','"zh-cl"'};
    for j=1:length(test_LMtier_labels)
        if any(ismember(fricative_release_labels,strtrim(char(test_LMtier_labels(j)))))
            test_fricative_release_index=test_fricative_release_index+1;
            test_fricative_releases(test_fricative_release_index)=test_LMtier_indices(j);
            if any(ismember(fricative_release_voiced_labels,strtrim(char(test_LMtier_labels(j)))))
                test_fricative_releases_voicing(test_fricative_release_index)=1;
            end
        elseif any(ismember(fricative_closure_labels,strtrim(char(test_LMtier_labels(j)))))
            test_fricative_closure_index=test_fricative_closure_index+1;
            test_fricative_closures(test_fricative_closure_index)=test_LMtier_indices(j);
            if any(ismember(fricative_closure_voiced_labels,strtrim(char(test_LMtier_labels(j)))))
                test_fricative_closures_voicing(test_fricative_closure_index)=1;
            end
        end
    end
    test_fricative_closures(test_fricative_closure_index+1:end)=[];
    test_fricative_releases(test_fricative_release_index+1:end)=[];
    test_fricative_closures_voicing(test_fricative_closure_index+1:end)=[];
    test_fricative_releases_voicing(test_fricative_release_index+1:end)=[];
    pred_fricative_closures=zeros(floor(length(pred_LMtier)/100),1);
    pred_fricative_releases=zeros(floor(length(pred_LMtier)/100),1);
    pred_fricative_closure_index=0;
    pred_fricative_release_index=0;
    pred_fricative_closures_voicing=zeros(length(pred_fricative_closures),1);
    pred_fricative_releases_voicing=zeros(length(pred_fricative_releases),1);
    for j=1:length(pred_LMtier_labels)
        if strfind('"Fr"',char(pred_LMtier_labels(j)))
            pred_fricative_release_index=pred_fricative_release_index+1;
            pred_fricative_releases(pred_fricative_release_index)=pred_LMtier_indices(j);
            if strfind(pred_cvtier(pred_LMtier_indices(j)),'slack')
                pred_fricative_releases_voicing(pred_fricative_release_index)=1;
            end
        elseif strfind('"Fc"',char(pred_LMtier_labels(j)))
            pred_fricative_closure_index=pred_fricative_closure_index+1;
            pred_fricative_closures(pred_fricative_closure_index)=pred_LMtier_indices(j);
            if strfind(pred_cvtier(pred_LMtier_indices(j)),'slack')
                pred_fricative_closures_voicing(pred_fricative_closure_index)=1;
            end
        end
    end
    pred_fricative_closures(pred_fricative_closure_index+1:end)=[];
    pred_fricative_releases(pred_fricative_release_index+1:end)=[];
    pred_fricative_closures_voicing(pred_fricative_closure_index+1:end)=[];
    pred_fricative_releases_voicing(pred_fricative_release_index+1:end)=[];
    if ~isempty(test_fricative_closures) && ~isempty(test_fricative_releases)
    if test_fricative_closures(1)>test_fricative_releases(1)
        test_fricative_closures=[1; test_fricative_closures];
    end
    if test_fricative_releases(end)<test_fricative_closures(end)
        test_fricative_releases=[test_fricative_releases; length(test_LMtier)];
    end
    test_fricative_intervals=isininterval(1:length(test_LMtier),test_fricative_closures,test_fricative_releases);
    pred_fricative_intervals=isininterval(1:length(test_LMtier),pred_fricative_closures,pred_fricative_releases);
    fricative_targets(fricative_index+1:fricative_index+length(test_LMtier))=test_fricative_intervals(1:end);
    fricative_outputs(fricative_index+1:fricative_index+length(test_LMtier))=pred_fricative_intervals(1:end);
    fricative_index=fricative_index+length(test_LMtier);   
    end
    
    %pair together closures and releases
    
    dummy_test_sc=test_stop_closures;
    dummy_pred_sc=pred_stop_closures;
    dummy_test_sc_voicing=test_stop_closures_voicing;
    dummy_pred_sc_voicing=pred_stop_closures_voicing;
    usable_test_sc=zeros(length(dummy_test_sc),1);
    usable_pred_sc=zeros(length(dummy_pred_sc),1);
    usable_test_sc_voicing=zeros(length(dummy_test_sc),1);
    usable_pred_sc_voicing=zeros(length(dummy_pred_sc),1);
    index=1;
    index2=0;
    while index<=length(dummy_test_sc)
        closest=min(abs(dummy_pred_sc-dummy_test_sc(index)));
        if closest<150
            index2=index2+1;
            usable_test_sc(index2)=dummy_test_sc(index);
            usable_test_sc_voicing(index2)=dummy_test_sc_voicing(index);
            pair=dummy_pred_sc(abs(dummy_pred_sc-dummy_test_sc(index))==closest);
            pair=pair(1);
            pair_index=find(dummy_pred_sc==pair);
            usable_pred_sc(index2)=pair;
            usable_pred_sc_voicing(index2)=dummy_pred_sc_voicing(pair_index);
            dummy_test_sc=dummy_test_sc(1:length(dummy_test_sc)~=index);
            dummy_test_sc_voicing=dummy_test_sc_voicing(1:length(dummy_test_sc_voicing)~=index);
            dummy_pred_sc=dummy_pred_sc(dummy_pred_sc~=pair);
            dummy_pred_sc_voicing=dummy_pred_sc_voicing(1:length(dummy_pred_sc_voicing)~=pair_index);
        end
        index=index+1;
    end
    usable_test_sc_voicing(index2+1:end)=[];
    usable_pred_sc_voicing(index2+1:end)=[];
    cvoicing_targets(cvoicing_index+1:cvoicing_index+length(usable_test_sc_voicing))=usable_test_sc_voicing(1:end);
    cvoicing_outputs(cvoicing_index+1:cvoicing_index+length(usable_test_sc_voicing))=usable_pred_sc_voicing(1:end);
    cvoicing_index=cvoicing_index+length(usable_test_sc_voicing);
    dummy_test_sr=test_stop_releases;
    dummy_pred_sr=pred_stop_releases;
    dummy_test_sr_voicing=test_stop_releases_voicing;
    dummy_pred_sr_voicing=pred_stop_releases_voicing;
    usable_test_sr=zeros(length(dummy_test_sr),1);
    usable_pred_sr=zeros(length(dummy_pred_sr),1);
    usable_test_sr_voicing=zeros(length(dummy_test_sr),1);
    usable_pred_sr_voicing=zeros(length(dummy_pred_sr),1);
    index=1;
    index2=0;
    while index<=length(dummy_test_sr)
        closest=min(abs(dummy_pred_sr-dummy_test_sr(index)));
        if closest<150
            index2=index2+1;
            usable_test_sr(index2)=dummy_test_sr(index);
            usable_test_sr_voicing(index2)=dummy_test_sr_voicing(index);
            pair=dummy_pred_sr(abs(dummy_pred_sr-dummy_test_sr(index))==closest);
            pair=pair(1);
            pair_index=find(dummy_pred_sr==pair);
            usable_pred_sr(index2)=pair;
            usable_pred_sr_voicing(index2)=dummy_pred_sr_voicing(pair_index);
            dummy_test_sr=dummy_test_sr(1:length(dummy_test_sr)~=index);
            dummy_test_sr_voicing=dummy_test_sr_voicing(1:length(dummy_test_sr_voicing)~=index);
            dummy_pred_sr=dummy_pred_sr(dummy_pred_sr~=pair);
            dummy_pred_sr_voicing=dummy_pred_sr_voicing(1:length(dummy_pred_sr_voicing)~=pair_index);
        end
        index=index+1;
    end
    usable_test_sr_voicing(index2+1:end)=[];
    usable_pred_sr_voicing(index2+1:end)=[];
    cvoicing_targets(cvoicing_index+1:cvoicing_index+length(usable_test_sr_voicing))=usable_test_sr_voicing(1:end);
    cvoicing_outputs(cvoicing_index+1:cvoicing_index+length(usable_test_sr_voicing))=usable_pred_sr_voicing(1:end);
    cvoicing_index=cvoicing_index+length(usable_test_sr_voicing);
    dummy_test_fc=test_fricative_closures;
    dummy_pred_fc=pred_fricative_closures;
    dummy_test_fc_voicing=test_fricative_closures_voicing;
    dummy_pred_fc_voicing=pred_fricative_closures_voicing;
    usable_test_fc=zeros(length(dummy_test_fc),1);
    usable_pred_fc=zeros(length(dummy_pred_fc),1);
    usable_test_fc_voicing=zeros(length(dummy_test_fc),1);
    usable_pred_fc_voicing=zeros(length(dummy_pred_fc),1);
    index=1;
    index2=0;
    while index<=length(dummy_test_fc)
        closest=min(abs(dummy_pred_fc-dummy_test_fc(index)));
        if closest<150
            index2=index2+1;
            usable_test_fc(index2)=dummy_test_fc(index);
            usable_test_fc_voicing(index2)=dummy_test_fc_voicing(index);
            pair=dummy_pred_fc(abs(dummy_pred_fc-dummy_test_fc(index))==closest);
            pair=pair(1);
            pair_index=find(dummy_pred_fc==pair);
            usable_pred_fc(index2)=pair;
            usable_pred_fc_voicing(index2)=dummy_pred_fc_voicing(pair_index);
            dummy_test_fc=dummy_test_fc(1:length(dummy_test_fc)~=index);
            dummy_test_fc_voicing=dummy_test_fc_voicing(1:length(dummy_test_fc_voicing)~=index);
            dummy_pred_fc=dummy_pred_fc(dummy_pred_fc~=pair);
            dummy_pred_fc_voicing=dummy_pred_fc_voicing(1:length(dummy_pred_fc_voicing)~=pair_index);
        end
        index=index+1;
    end
    usable_test_fc_voicing(index2+1:end)=[];
    usable_pred_fc_voicing(index2+1:end)=[];
    cvoicing_targets(cvoicing_index+1:cvoicing_index+length(usable_test_fc_voicing))=usable_test_fc_voicing(1:end);
    cvoicing_outputs(cvoicing_index+1:cvoicing_index+length(usable_test_fc_voicing))=usable_pred_fc_voicing(1:end);
    cvoicing_index=cvoicing_index+length(usable_test_fc_voicing);
    dummy_test_fr=test_fricative_releases;
    dummy_pred_fr=pred_fricative_releases;
    dummy_test_fr_voicing=test_fricative_releases_voicing;
    dummy_pred_fr_voicing=pred_fricative_releases_voicing;
    usable_test_fr=zeros(length(dummy_test_fr),1);
    usable_pred_fr=zeros(length(dummy_pred_fr),1);
    usable_test_fr_voicing=zeros(length(dummy_test_fr),1);
    usable_pred_fr_voicing=zeros(length(dummy_pred_fr),1);
    index=1;
    index2=0;
    while index<=length(dummy_test_fr)
        closest=min(abs(dummy_pred_fr-dummy_test_fr(index)));
        if closest<150
            index2=index2+1;
            usable_test_fr(index2)=dummy_test_fr(index);
            usable_test_fr_voicing(index2)=dummy_test_fr_voicing(index);
            pair=dummy_pred_fr(abs(dummy_pred_fr-dummy_test_fr(index))==closest);
            pair=pair(1);
            pair_index=find(dummy_pred_fr==pair);
            usable_pred_fr(index2)=pair;
            usable_pred_fr_voicing(index2)=dummy_pred_fr_voicing(pair_index);
            dummy_test_fr=dummy_test_fr(1:length(dummy_test_fr)~=index);
            dummy_test_fr_voicing=dummy_test_fr_voicing(1:length(dummy_test_fr_voicing)~=index);
            dummy_pred_fr=dummy_pred_fr(dummy_pred_fr~=pair);
            dummy_pred_fr_voicing=dummy_pred_fr_voicing(1:length(dummy_pred_fr_voicing)~=pair_index);
        end
        index=index+1;
    end
    usable_test_fr_voicing(index2+1:end)=[];
    usable_pred_fr_voicing(index2+1:end)=[];
    cvoicing_targets(cvoicing_index+1:cvoicing_index+length(usable_test_fr_voicing))=usable_test_fr_voicing(1:end);
    cvoicing_outputs(cvoicing_index+1:cvoicing_index+length(usable_test_fr_voicing))=usable_pred_fr_voicing(1:end);
    cvoicing_index=cvoicing_index+length(usable_test_fr_voicing);
    %find intervals surrounding spectral bursts
    test_sb=zeros(floor(length(test_ctier)/100),1);
    test_sb_index=0;
    for j=1:length(test_ctier_labels)
        if strfind(char(test_ctier_labels(j)),'SB')
            test_sb_index=test_sb_index+1;
            test_sb(test_sb_index)=test_ctier_indices(j);
        end
    end
    test_sb(test_sb_index+1:end)=[];
    pred_sb=zeros(floor(length(pred_ctier)/100),1);
    pred_sb_index=0;
    for j=1:length(pred_ctier_labels)
        if strfind(char(pred_ctier_labels(j)),'SB')
            pred_sb_index=pred_sb_index+1;
            pred_sb(pred_sb_index)=pred_ctier_indices(j);
        end
    end
    pred_sb(pred_sb_index+1:end)=[];
    test_sb_intervals=isininterval(1:length(test_ctier),test_sb-15,test_sb+15);
    pred_sb_intervals=isininterval(1:length(test_ctier),pred_sb-15,pred_sb+15);
    sb_targets(sb_index+1:sb_index+length(test_ctier))=test_sb_intervals(1:end);
    sb_outputs(sb_index+1:sb_index+length(test_ctier))=pred_sb_intervals(1:end);
    sb_index=sb_index+length(test_ctier);
    
    %find intervals surrounding formant transitions
    test_ftc=zeros(floor(length(test_ctier)/100),1);
    test_ftr=zeros(floor(length(test_ctier)/100),1);
    test_ftc_index=0;
    test_ftr_index=0;
    for j=1:length(test_ctier_labels)
        if strfind(char(test_ctier_labels(j)),'FTc')
            test_ftc_index=test_ftc_index+1;
            test_ftc(test_ftc_index)=test_ctier_indices(j);
        elseif strfind(char(test_ctier_labels(j)),'FTr')
            test_ftr_index=test_ftr_index+1;
            test_ftr(test_ftr_index)=test_ctier_indices(j);
        end
    end
    test_ftc(test_ftc_index+1:end)=[];
    test_ftr(test_ftr_index+1:end)=[];
    pred_ftc=zeros(floor(length(pred_ctier)/100),1);
    pred_ftr=zeros(floor(length(pred_ctier)/100),1);
    pred_ftc_index=0;
    pred_ftr_index=0;
    for j=1:length(pred_ctier_labels)
        if strfind(char(pred_ctier_labels(j)),'FTc')
            pred_ftc_index=pred_ftc_index+1;
            pred_ftc(pred_ftc_index)=pred_ctier_indices(j);
        elseif strfind(char(pred_ctier_labels(j)),'FTr')
            pred_ftr_index=pred_ftr_index+1;
            pred_ftr(pred_ftr_index)=pred_ctier_indices(j);
        end
    end
    pred_ftc(pred_ftc_index+1:end)=[];
    pred_ftr(pred_ftr_index+1:end)=[];
    test_ftc_intervals=isininterval(1:length(test_ctier),test_ftc-15,test_ftc+15);
    test_ftr_intervals=isininterval(1:length(test_ctier),test_ftr-15,test_ftr+15);
    pred_ftc_intervals=isininterval(1:length(test_ctier),pred_ftc-15,pred_ftc+15);
    pred_ftr_intervals=isininterval(1:length(test_ctier),pred_ftr-15,pred_ftr+15);
    ftc_targets(ftc_index+1:ftc_index+length(test_ctier))=test_ftc_intervals(1:end);
    ftr_targets(ftr_index+1:ftr_index+length(test_ctier))=test_ftr_intervals(1:end);
    ftc_outputs(ftc_index+1:ftc_index+length(test_ctier))=pred_ftc_intervals(1:end);
    ftr_outputs(ftr_index+1:ftr_index+length(test_ctier))=pred_ftr_intervals(1:end);
    ftc_index=ftc_index+length(test_ctier);
    ftr_index=ftr_index+length(test_ctier);
    
    %find paired vgplace labels
    dummy_test_v_indices=test_v_indices;
    dummy_pred_v_indices=pred_v_indices;
    usable_test_v_indices=zeros(1,length(dummy_test_v_indices));
    usable_pred_v_indices=zeros(1,length(dummy_test_v_indices));
    index=1;
    index2=0;
    while index<=length(dummy_test_v_indices)
        closest=min(abs(dummy_pred_v_indices-dummy_test_v_indices(index)));
        if closest<150
            index2=index2+1;
            usable_test_v_indices(index2)=dummy_test_v_indices(index);
            pair=dummy_pred_v_indices(abs(dummy_pred_v_indices-dummy_test_v_indices)==closest);
            pair=pair(1);
            usable_pred_v_indices(index2)=pair;
            dummy_test_v_indices=dummy_test_v_indices(1:length(dummy_test_v_indices)~=index);
            dummy_pred_v_indices=dummy_pred_v_indices(dummy_pred_v_indices~=pair);
        end
        index=index+1;
    end 
    usable_test_v_indices(index2+1:end)=[];
    usable_pred_v_indices(index2+1:end)=[];
    for p=1:length(usable_test_v_indices)
        test_vowel=usable_test_v_indices(p);
        pred_vowel=usable_pred_v_indices(p);
        [test_back,test_high,test_low,test_atr,test_ctr]=check_vgplace(test_vowel,test_vgtier_indices,test_vgtier_labels,20);
        [pred_back,pred_high,pred_low,pred_atr,pred_ctr]=check_vgplace(pred_vowel,pred_vgtier_indices,pred_vgtier_labels,20);
        vgplace_targets(p+vgplace_index,:)=[test_back test_high test_low test_atr test_ctr];
        vgplace_outputs(p+vgplace_index,:)=[pred_back pred_high pred_low pred_atr pred_ctr];
    end
    vgplace_index=vgplace_index+length(usable_test_v_indices);
    
    %find paired spectral burst labels
    dummy_test_sb=test_sb;
    dummy_pred_sb=pred_sb;
    usable_test_sb=zeros(1,length(test_sb));
    usable_pred_sb=zeros(1,length(test_sb));
    index=1;
    index2=0;
    while index<=length(dummy_test_sb)
        closest=min(abs(dummy_pred_sb-dummy_test_sb(index)));
        if closest<150
            index2=index2+1;
            usable_test_sb(index2)=dummy_test_sb(index);
            pair=dummy_pred_sb(abs(dummy_pred_sb-dummy_test_sb(index))==closest);
            pair=pair(1);
            usable_pred_sb(index2)=pair;
            dummy_test_sb=dummy_test_sb(1:length(dummy_test_sb)~=index);
            dummy_pred_sb=dummy_pred_sb(dummy_pred_sb~=pair);
        end
        index=index+1;
    end
    usable_test_sb(index2+1:end)=[];
    usable_pred_sb(index2+1:end)=[];
    for p=1:length(usable_test_sb)
        test_burst=usable_test_sb(p);
        pred_burst=usable_pred_sb(p);
        test_burst_label=test_ctier_labels(test_ctier_indices==test_burst);
        pred_burst_label=pred_ctier_labels(pred_ctier_indices==pred_burst);
        test_array=zeros(1,5);
        pred_array=zeros(1,5);
        if strfind(char(test_burst_label),'lab')
            test_array(1)=1;
        elseif strfind(char(test_burst_label),'den')
            test_array(2)=1;
        elseif strfind(char(test_burst_label),'alv')
            test_array(3)=1;
        elseif strfind(char(test_burst_label),'pal')
            test_array(4)=1;
        elseif strfind(char(test_burst_label),'vel')
            test_array(5)=1;
        end
        if strfind(char(pred_burst_label),'lab')
            pred_array(1)=1;
        elseif strfind(char(pred_burst_label),'den')
            pred_array(2)=1;
        elseif strfind(char(pred_burst_label),'alv')
            pred_array(3)=1;
        elseif strfind(char(pred_burst_label),'pal')
            pred_array(4)=1;
        elseif strfind(char(pred_burst_label),'vel')
            pred_array(5)=1;
        end
        sbplace_targets(p+sbplace_index,:)=test_array;
        sbplace_outputs(p+sbplace_index,:)=pred_array;
    end
    sbplace_index=sbplace_index+length(usable_test_sb);
    
    %find paired formant transition labels
    dummy_test_ftc=test_ftc;
    dummy_pred_ftc=pred_ftc;
    usable_test_ftc=zeros(1,length(test_ftc));
    usable_pred_ftc=zeros(1,length(test_ftc));
    index=1;
    index2=0;
    while index<=length(dummy_test_ftc)
        closest=min(abs(dummy_pred_ftc-dummy_test_ftc(index)));
        if closest<150
            index2=index2+1;
            usable_test_ftc(index2)=dummy_test_ftc(index);
            pair=dummy_pred_ftc(abs(dummy_pred_ftc-dummy_test_ftc(index))==closest);
            pair=pair(1);
            usable_pred_ftc(index2)=pair;
            dummy_test_ftc=dummy_test_ftc(1:length(dummy_test_ftc)~=index);
            dummy_pred_ftc=dummy_pred_ftc(dummy_pred_ftc~=pair);
        end
        index=index+1;
    end
    usable_test_ftc(index2+1:end)=[];
    usable_pred_ftc(index2+1:end)=[];
    for p=1:length(usable_test_ftc)
        test_ft=usable_test_ftc(p);
        pred_ft=usable_pred_ftc(p);
        test_ft_label=test_ctier_labels(test_ctier_indices==test_ft);
        pred_ft_label=pred_ctier_labels(pred_ctier_indices==pred_ft);
        test_array=zeros(1,5);
        pred_array=zeros(1,5);
        if strfind(char(test_ft_label),'lab')
            test_array(1)=1;
        elseif strfind(char(test_ft_label),'den')
            test_array(2)=1;
        elseif strfind(char(test_ft_label),'alv')
            test_array(3)=1;
        elseif strfind(char(test_ft_label),'pal')
            test_array(4)=1;
        elseif strfind(char(test_ft_label),'vel')
            test_array(5)=1;
        end
        if strfind(char(pred_ft_label),'lab')
            pred_array(1)=1;
        elseif strfind(char(pred_ft_label),'den')
            pred_array(2)=1;
        elseif strfind(char(pred_ft_label),'alv')
            pred_array(3)=1;
        elseif strfind(char(pred_ft_label),'pal')
            pred_array(4)=1;
        elseif strfind(char(pred_ft_label),'vel')
            pred_array(5)=1;
        end
        ftcplace_targets(p+ftcplace_index,:)=test_array;
        ftcplace_outputs(p+ftcplace_index,:)=pred_array;
    end
    ftcplace_index=ftrplace_index+length(usable_test_ftc);
    dummy_test_ftr=test_ftr;
    dummy_pred_ftr=pred_ftr;
    usable_test_ftr=zeros(1,length(test_ftr));
    usable_pred_ftr=zeros(1,length(test_ftr));
    index=1;
    index2=0;
    while index<=length(dummy_test_ftr)
        closest=min(abs(dummy_pred_ftr-dummy_test_ftr(index)));
        if closest<150
            index2=index2+1;
            usable_test_ftr(index2)=dummy_test_ftr(index);
            pair=dummy_pred_ftr(abs(dummy_pred_ftr-dummy_test_ftr(index))==closest);
            pair=pair(1);
            usable_pred_ftr(index2)=pair;
            dummy_test_ftr=dummy_test_ftr(1:length(dummy_test_ftr)~=index);
            dummy_pred_ftr=dummy_pred_ftr(dummy_pred_ftr~=pair);
        end
        index=index+1;
    end
    usable_test_ftr(index2+1:end)=[];
    usable_pred_ftr(index2+1:end)=[];
    for p=1:length(usable_test_ftr)
        test_ft=usable_test_ftr(p);
        pred_ft=usable_pred_ftr(p);
        test_ft_label=test_ctier_labels(test_ctier_indices==test_ft);
        pred_ft_label=pred_ctier_labels(pred_ctier_indices==pred_ft);
        test_array=zeros(1,5);
        pred_array=zeros(1,5);
        if strfind(char(test_ft_label),'lab')
            test_array(1)=1;
        elseif strfind(char(test_ft_label),'den')
            test_array(2)=1;
        elseif strfind(char(test_ft_label),'alv')
            test_array(3)=1;
        elseif strfind(char(test_ft_label),'pal')
            test_array(4)=1;
        elseif strfind(char(test_ft_label),'vel')
            test_array(5)=1;
        end
        if strfind(char(pred_ft_label),'lab')
            pred_array(1)=1;
        elseif strfind(char(pred_ft_label),'den')
            pred_array(2)=1;
        elseif strfind(char(pred_ft_label),'alv')
            pred_array(3)=1;
        elseif strfind(char(pred_ft_label),'pal')
            pred_array(4)=1;
        elseif strfind(char(pred_ft_label),'vel')
            pred_array(5)=1;
        end
        ftrplace_targets(p+ftrplace_index,:)=test_array;
        ftrplace_outputs(p+ftrplace_index,:)=pred_array;
    end
    ftrplace_index=ftrplace_index+length(usable_test_ftr);
    
    catch
        disp('error, skipping word');
        errors=errors+1;
    end
end
v_targets(v_index+1:end)=[];
v_outputs(v_index+1:end)=[];
v_f_score=f_score(v_targets,v_outputs,70);
v_score_list=score_list(v_targets,v_outputs,70);

glottal_targets(glottal_index+1:end)=[];
glottal_outputs(glottal_index+1:end)=[];
glottal_f_score=f_score(glottal_targets,glottal_outputs,70);
glottal_score_list=score_list(glottal_targets,glottal_outputs,70);

nasal_targets(nasal_index+1:end)=[];
nasal_outputs(nasal_index+1:end)=[];
nasal_f_score=f_score(nasal_targets,nasal_outputs,70);
nasal_score_list=score_list(nasal_targets,nasal_outputs,70);

n_targets(n_index+1:end)=[];
n_outputs(n_index+1:end)=[];
n_f_score=f_score(n_targets,n_outputs,70);
n_score_list=score_list(n_targets,n_outputs,70);

g_targets(g_index+1:end)=[];
g_outputs(g_index+1:end)=[];
g_f_score=f_score(g_targets,g_outputs,70);
g_score_list=score_list(g_targets,g_outputs,70);

stop_targets(stop_index+1:end)=[];
stop_outputs(stop_index+1:end)=[];
stop_f_score=f_score(stop_targets,stop_outputs,70);
stop_score_list=score_list(stop_targets,stop_outputs,70);

fricative_targets(fricative_index+1:end)=[];
fricative_outputs(fricative_index+1:end)=[];
fricative_f_score=f_score(fricative_targets,fricative_outputs,70);
fricative_score_list=score_list(fricative_targets,fricative_outputs,70);

sb_targets(sb_index+1:end)=[];
sb_outputs(sb_index+1:end)=[];
sb_f_score=f_score(sb_targets,sb_outputs,70);
sb_score_list=score_list(sb_targets,sb_outputs,70);

ftc_targets(ftc_index+1:end)=[];
ftc_outputs(ftc_index+1:end)=[];
ftc_f_score=f_score(ftc_targets,ftc_outputs,70);
ftc_score_list=score_list(ftc_targets,ftc_outputs,70);

ftr_targets(ftr_index+1:end)=[];
ftr_outputs(ftr_index+1:end)=[];
ftr_f_score=f_score(ftr_targets,ftr_outputs,70);
ftr_score_list=score_list(ftr_targets,ftr_outputs,70);

vgplace_targets(vgplace_index+1:end,:)=[];
vgplace_outputs(vgplace_index+1:end,:)=[];
vgplace_f_scores=zeros(1,5);
for i=1:5
    vgplace_f_scores(i)=f_score(vgplace_targets(:,i),vgplace_outputs(:,i),0);
end
vgplace_f_score=mean(vgplace_f_scores);
vgplace_scores_sum=zeros(1,4);
for i=1:5
    vgplace_scores_sum=vgplace_scores_sum+score_list(vgplace_targets(:,i),vgplace_outputs(:,i),0);
end
vgplace_score_list=vgplace_scores_sum/5;

sbplace_targets(sbplace_index+1:end,:)=[];
sbplace_outputs(sbplace_index+1:end,:)=[];
sbplace_f_scores=zeros(1,5);
for i=1:5
    sbplace_f_scores(i)=f_score(sbplace_targets(:,i),sbplace_outputs(:,i),0);
end
sbplace_f_score=mean(sbplace_f_scores);
sbplace_scores_sum=zeros(1,4);
for i=1:5
    sbplace_scores_sum=sbplace_scores_sum+score_list(sbplace_targets(:,i),sbplace_outputs(:,i),0);
end
sbplace_score_list=sbplace_scores_sum/5;

ftcplace_targets(ftcplace_index+1:end,:)=[];
ftcplace_outputs(ftcplace_index+1:end,:)=[];
ftcplace_f_scores=zeros(1,5);
for i=1:5
    ftcplace_f_scores(i)=f_score(ftcplace_targets(:,i),ftcplace_outputs(:,i),0);
end
ftcplace_f_score=mean(ftcplace_f_scores);
ftcplace_scores_sum=zeros(1,4);
for i=1:5
    ftcplace_scores_sum=ftcplace_scores_sum+score_list(ftcplace_targets(:,i),ftcplace_outputs(:,i),0);
end
ftcplace_score_list=ftcplace_scores_sum/5;

ftrplace_targets(ftrplace_index+1:end,:)=[];
ftrplace_outputs(ftrplace_index+1:end,:)=[];
ftrplace_f_scores=zeros(1,5);
for i=1:5
    ftrplace_f_scores(i)=f_score(ftrplace_targets(:,i),ftrplace_outputs(:,i),0);
end
ftrplace_f_score=mean(ftrplace_f_scores);
ftrplace_scores_sum=zeros(1,4);
for i=1:5
    ftrplace_scores_sum=ftrplace_scores_sum+score_list(ftrplace_targets(:,i),ftrplace_outputs(:,i),0);
end
ftrplace_score_list=ftrplace_scores_sum/5;

cvoicing_targets(cvoicing_index+1:end)=[];
cvoicing_outputs(cvoicing_index+1:end)=[];
cvoicing_f_score=f_score(cvoicing_targets,cvoicing_outputs,0);
cvoicing_score_list=score_list(cvoicing_targets,cvoicing_outputs,0);

scores=[v_score_list;glottal_score_list;nasal_score_list;g_score_list;n_score_list;...
    stop_score_list;fricative_score_list;sb_score_list;ftc_score_list;...
    ftr_score_list;vgplace_score_list;sbplace_score_list;ftcplace_score_list;...
    ftrplace_score_list;cvoicing_score_list];

f_scores=[v_f_score;glottal_f_score;nasal_f_score;g_f_score;n_f_score;...
    stop_f_score;fricative_f_score;sb_f_score;ftc_f_score;ftr_f_score;...
    vgplace_f_score;sbplace_f_score;ftcplace_f_score;ftrplace_f_score;...
    cvoicing_f_score];
end

function [back,high,low,atr,ctr]=check_vgplace(index,indices,labels,radius)
back=0;
high=0;
low=0;
atr=0;
ctr=0;
valid_labels=labels(abs(indices-index)<=radius);
for i=1:length(valid_labels)
    if strfind(valid_labels(i),'back')
        back=1;
    elseif strfind(valid_labels(i),'high')
        high=1;
    elseif strfind(valid_labels(i),'low')
        low=1;
    elseif strfind(valid_labels(i),'atr')
        atr=1;
    elseif strfind(valid_labels(i),'ctr')
        ctr=1;
    end
end
end

function [f_value]=f_score(targets,outputs,threshold)
correct_positive=0;
positive_outputs=sum(outputs);
positive_targets=sum(targets);
for i=1:length(targets)
    zone_start=i-threshold;
    zone_end=i+threshold;
    if i<threshold+1
        zone_start=1;
    elseif i>length(targets)-threshold
        zone_end=length(targets);
    end
    if sum(targets(zone_start:zone_end))>=1 && outputs(i)==1
        correct_positive=correct_positive+1;
    end
end
precision=correct_positive/positive_outputs;
recall=correct_positive/positive_targets;
f_value=2*(precision*recall)/(precision+recall);
end

function list = score_list(targets,outputs,threshold)
total=length(targets);
true_positives=0;
true_negatives=0;
false_positives=0;
false_negatives=0;
for i=1:length(targets)
    zone_start=i-threshold;
    zone_end=i+threshold;
    if i<threshold+1
        zone_start=1;
    elseif i>length(targets)-threshold
        zone_end=length(targets);
    end
    if sum(targets(zone_start:zone_end))>=1 && outputs(i)==1
        true_positives=true_positives+1;
    elseif sum(targets(zone_start:zone_end))==0 && outputs(i)==1
        false_positives=false_positives+1;
    elseif sum(targets(zone_start:zone_end))==0 && outputs(i)==0
        true_negatives=true_negatives+1;
    else
        false_negatives=false_negatives+1;
    end
end
list=[true_positives true_negatives false_positives false_negatives];
list=list/total;
end