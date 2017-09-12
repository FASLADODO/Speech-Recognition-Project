function cvoice = cvoicing(sc,sr,fc,fr,g_starts,T,F0,F1,H1,H2,H4)
load('models.mat','vscDist','vsrDist','vsrvotDist','vfcDist','vfrDist',...
    'uvscDist','uvsrDist','uvsrvotDist','uvfcDist','uvfrDist');
sc_id=zeros(length(sc),1);
sr_id=zeros(length(sr),1);
fc_id=zeros(length(fc),1);
fr_id=zeros(length(fr),1);
for i=1:length(sc)
    [~,closest]=min(abs(T-sc(i)));
    sc(i)=closest(1);
end
for i=1:length(sr)
    [~,closest]=min(abs(T-sr(i)));
    sr(i)=closest(1);
end
for i=1:length(fc)
    [~,closest]=min(abs(T-fc(i)));
    fc(i)=closest(1);
end
for i=1:length(fr)
    [~,closest]=min(abs(T-fr(i)));
    fr(i)=closest(1);
end
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
for b = 1:length(VOT)
    bigger = g_starts(g_starts>b);
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
scale=1.2;
vscPDF = scale*smooth(pdf(vscDist,vcV));
vsrPDF = scale*smooth(pdf(vsrDist,vrV));
vsrvotPDF = scale*smooth(pdf(vsrvotDist,vrvotV));
vfcPDF =scale* smooth(pdf(vfcDist,vcV));
vfrPDF = scale*smooth(pdf(vfrDist,vrV));
uvscPDF = smooth(pdf(uvscDist,vcV));
uvsrPDF = smooth(pdf(uvsrDist,vrV));
uvsrvotPDF = smooth(pdf(uvsrvotDist,vrvotV));
uvfcPDF = smooth(pdf(uvfcDist,vcV));
uvfrPDF = smooth(pdf(uvfrDist,vrV));
for i=1:length(sc)
    if vscPDF(sc(i))>uvscPDF(sc(i))
        sc_id(i)=1;
    end
end
for i=1:length(sr)
    if i==length(sr)
        if VOT(sr(i))<length(sr)-sr(i)
            if vsrvotPDF(sr(i))>uvsrvotPDF(sr(i))
                sr_id(i)=1;
            end
        else
            if vsrPDF(sr(i))>uvsrPDF(sr(i))
                sr_id(i)=1;
            end
        end
    else
        if VOT(sr(i))<sr(i+1)-sr(i)
            if vsrvotPDF(sr(i))>uvsrvotPDF(sr(i))
                sr_id(i)=1;
            end
        else
            if vsrPDF(sr(i))>uvsrPDF(sr(i))
                sr_id(i)=1;
            end
        end
    end
end
for i=1:length(fc)
    if vfcPDF(fc(i))>uvfcPDF(fc(i))
        fc_id(i)=1;
    end
end
for i=1:length(fr)
    if vfrPDF(fr(i))>uvfrPDF(fr(i))
        fr_id(i)=1;
    end
end
cvoice={sc_id,sr_id,fc_id,fr_id};
end