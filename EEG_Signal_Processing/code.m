%% Katılımcıların EEG sinyallerinin dosyadan çekilmesi
dizi=["K1","K2","K3","K4","K5","K6","K7","K8","K9","K10","K11","K12","K13","K14","K15","K16","K17","K18","K19","K20","K21","K22","K23","K24","K25","K26",...
    "K27","K28","K29","K30","K31","K32","K33","K34"];
dizi2=["r1","r2","r3","r4","r5","r6","r7","r8","r9","r10","r11","r12","r13","r14","r15","r16","r17","r18","r19","r20","r21","r22","r23","r24" ...
    "r25","r26","r27","r28","r29","r30","r31","r32","r33","r34","r35","r36","r37","r38","r39","r40","r41","r42","r43","r44","r45","r46","r47","r48"];
fs = 500;k=0;
for i=1:length(dizi)
    for j=1:length(dizi2)
path="D:\matlab\dataset\dataset2\"+dizi(i)+"\"+dizi2(j)+".xlsx";
f=(xlsread(path));
f2=f;   
k=k+1;
C{i,j}=f2';
    end
end

%% welch
r=0;
%kanal=1;

for kisi=1:34
for durum=1:48
%for kanal=1:31

x=C{kisi,durum}(:,kanal);
r=r+1;
k=1;
window = round(length(x)/7);
noverlap = window/10;
freq = 1:1:49;
fs = 500;
[pxx,freq] = pwelch(x,window,noverlap,freq,fs);
feata(r,:)=pxx;
%end
end
end
%% Veri Çoğaltma
featb=feata*0.99999;
featc=feata*1.00001;
feat=[featb; featc; feata];

%% Labellar
for i=1:816
    
    if  mod(i,2)== 1
        Label(i)="LC";
    else
        Label(i)="MK";
    end
end
Label=categorical(Label);
Label=Label';
%%

cv = cvpartition(1632,'HoldOut',0.20);
idx = cv.test;
datax=num2cell(feat,2);
datay=categorical(Label);
x_train=datax(~idx,:);
y_train=categorical(datay(~idx,:));
x_test=datax(idx,:);
y_test=categorical(datay(idx,:));
%%
layers = [ ...
    sequenceInputLayer(1)
    bilstmLayer(80,'OutputMode','last')
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer
    ];
options = trainingOptions('adam', ...
    'MaxEpochs',1000, ...
    'MiniBatchSize', 256, ...
    'InitialLearnRate', 0.005, ...
    'SequenceLength', 1000, ...
    'GradientThreshold', 1, ...
    'ExecutionEnvironment',"auto",...
    'plots','training-progress', ...
    'Verbose',false);
 %  XValidation=num2cell(XValidation,2);
% XTrain=dataTrain;
% YValidation=categorical(YValidation);
net = trainNetwork(x_train,y_train,layers,options);
%% metrikler
trainPred = classify(net,x_train,'SequenceLength',1000);
LSTMAccuracy = sum(trainPred == y_train)/numel(y_train)*100;
%%
testPred = classify(net,x_test,'SequenceLength',1000);
LSTMAccuracy2 = sum(testPred == y_test)/numel(y_test)*100;
figure
ccLSTM = confusionchart(y_test,testPred);
ccLSTM.Title = 'Confusion Chart for LSTM';
ccLSTM.ColumnSummary = 'column-normalized';
ccLSTM.RowSummary = 'row-normalized';
%%
clc
for i=8:16
testPred = classify(net,x_test(i,:),'SequenceLength',1000)
end
