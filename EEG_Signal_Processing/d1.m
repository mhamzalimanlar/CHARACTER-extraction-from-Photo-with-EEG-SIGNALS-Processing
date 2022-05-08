%% Filing of participants' EEG signals
dizi=["K1","K2","K3","K4","K5","K6","K7","K8","K9","K10","K11","K12","K13","K14","K15","K16","K17","K18","K19","K20","K21","K22","K23","K24","K25","K26","K27","K28","K29","K30","K31","K32","K33","K34"];
dizi2=["r2","r4","r6","r8","r10","r12","r14","r16","r18","r20","r22","r24","r26","r28","r30","r32","r34","r36","r38","r40","r42","r44","r46","r48"];

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
%% Welch Metodu      

r=0;
kanal=31; 

for kisi=1:34 
for durum=1:24 

x=C{kisi,durum}(:,kanal);
r=r+1;
k=1;
window = round(length(x)/5);
noverlap = window/10;
freq = 1:1:49;
fs = 500;
[pxx,f] = pwelch(x,window,noverlap,freq,fs);
feat31(r,:)=pxx; 

end
end

%% Raising number of channels
feata=[feat31];

%% Veri Artırımı
featb=feata*0.9999;
featc=feata*1.0001;
feat=[feata; featb; featc];

    
%% Labels
for i=1:2448
    if mod(i,2)==1
        Label(i)="LC";
    else
        Label(i)="MK";
    end
end
Label=Label';

%% Splitting data into Training and Test

cv = cvpartition(2448,'HoldOut',0.20);
idx = cv.test;
datax=num2cell(feat,2);
datay=categorical(Label);
x_train=datax(~idx,:);
y_train=categorical(datay(~idx,:));
x_test=datax(idx,:);
y_test=categorical(datay(idx,:));
%% Trainin Process
layers = [ ...
    sequenceInputLayer(1)
    bilstmLayer(100,'OutputMode','last')
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer
    ]
options = trainingOptions('adam', ...
    'MaxEpochs',200, ...
    'MiniBatchSize', 256, ...
    'InitialLearnRate', 0.005, ...
    'SequenceLength', 1000, ...
    'GradientThreshold', 1, ...
    'ExecutionEnvironment',"auto",...
    'plots','training-progress', ...
    'Verbose',false);

net = trainNetwork(x_train,y_train,layers,options);
%% Metrics
trainPred = classify(net,x_train,'SequenceLength',1000);
LSTMAccuracy = sum(trainPred == y_train)/numel(y_train)*100;
%% Confusion Matrix
testPred = classify(net,x_test,'SequenceLength',1000);
LSTMAccuracy2 = sum(testPred == y_test)/numel(y_test)*100;
figure
ccLSTM = confusionchart(y_test,testPred);
ccLSTM.Title = 'Confusion Chart for LSTM';
ccLSTM.ColumnSummary = 'column-normalized';
ccLSTM.RowSummary = 'row-normalized';

%% Testing of the training section
clc
clear a
testPred = classify(net,x_test(35,:),'SequenceLength',1000)
a = arduino("COM6","Uno");
if (testPred == "LC")
    writeDigitalPin(a,'D9',1);
else 
    writeDigitalPin(a,'D8',1);

end
