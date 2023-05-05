clc 
clear all

%Step 1

% V2 Valve
NV2=2;
V2O=10;% V2 Valve Open
V2C=11;% V2 Valve Close
TLV2=[1 V2C 1; 1 V2O 2; 2 V2O 2; 2 V2C 1];
XmV2=[1];
V2= automaton(NV2,TLV2,XmV2);

% V3 Valve
NV3=2;
V3O=12;% V3 Valve Open
V3C=13;% V3 Valve Close
TLV3=[1 V3C 1; 1 V3O 2; 2 V3O 2; 2 V3C 1];
XmV3=[1];
V3= automaton(NV3,TLV3,XmV3);

% V1 Valve
NV1=2;
V1O=14;% V1 Valve Open
V1C=15;% V1 Valve Close
TLV1=[1 V1C 1; 1 V1O 2; 2 V1O 2; 2 V1C 1];
XmV1=[1];
V1= automaton(NV1,TLV1,XmV1);


%A1- Analyser:

NA1=2;
AH=20; %A1 Reads High
AL=21; %A1 Reads Low
TLA1=[1 AH 2;2 AL 1];
XmA1=1;
A=automaton(NA1,TLA1,XmA1);

% F2 Flow Sensor:

NF2=2;
F2H=16; %F2 Reads High
F2L=17; %F2 Reads Low
TLF2=[1 F2H 2;2 F2L 1];
XmF2=1;
F2=automaton(NF2,TLF2,XmF2);

% F1 Flow Sensor:

NF1=2;
F1H=18;%F1 Reads High
F1L=19;%F1 Reads Low
TLF1=[1 F1H 2;2 F1L 1];
XmF1=1;
F1=automaton(NF1,TLF1,XmF1);

% PSU 

NPSU=2;
PSUON=22; % Turn PSU ON
PSUOFF=23; % Turn PSU OFF
TLPSU=[1 PSUOFF 1; 1 PSUON 2; 2 PSUON 2;2 PSUOFF 1];
XmPSU=1;
PSU=automaton(NPSU,TLPSU,XmPSU);

%Local automaton


SDF=31; % Shut down Finish
SUF=33; % Start up Finish

Nlocal=1;
localtl=[1 SUF 1;1 SDF 1];
Xmlocal=1;

local=automaton(Nlocal,localtl,Xmlocal);


%Master Controller
SDS=30; % Shut down Start
SUS=32; % Start up Start

NMaster=1;
mastertl=[1 SUS 1;1 SDS 1];
Xmmaster=1;

master=automaton(NMaster,mastertl,Xmmaster);

%-----------------------------------------------------------------------------
%interactions

NF1V1=2;
TLF1V1=[ TLV1 ; 1 F1L 1; 2 F1H 2];
XmF1V1=[1];
F1V1=automaton(NF1V1,TLF1V1,XmF1V1);

%--------------------------------

[F2V2V3,states]=sync(V2,V3);
for i=1:size(states,1)
   if (states(i,1)==2  && states(i,2)==2) 
     F2V2V3.TL=[F2V2V3.TL;i F2H  i];  
   else
     F2V2V3.TL=[F2V2V3.TL; i F2L i];
   end
end

%---------------------------------

[A1PSUF1,states]=sync(PSU,F1);
for i=1:size(states,1)
   if (states(i,1)==2  && states(i,2)==2) 
     A1PSUF1.TL=[A1PSUF1.TL;i AH  i];  
   else
     A1PSUF1.TL=[A1PSUF1.TL; i AL i];
   end
end

%plantmodel

plantautomaton=sync(V2,V1,V3,A,F2,F1,local,master,PSU,F1V1,F2V2V3,A1PSUF1)




%SPEC1:


SPEC1N=10;
SPEC1TL=[1 SDS 1;1 SUS 2; 2 F1H 3;3 F2H 4;4 PSUON 5;5 SUF 6;6 SUS 6;6 SDS 7;7 PSUOFF 8; 8 F2L 9; 9 F1L 10; 10 SDF 1];
for i=[2,3,4,5,7,8,9,10]
    SPEC1TL=[SPEC1TL; i SUS i; i SDS i ];
end

XmSPEC1=[1,2,3,4,5,6,7,8,9,10];

SPEC1=automaton(SPEC1N,SPEC1TL,XmSPEC1);
SPEC1=selfloop(SPEC1,[AH,AL,V1O,V1C,V2O,V2C,V3O,V3C]);

UC=[AH,AL,F2H,F2L,F1L,F1H,SUS,SDS];
Supervisor1=supcon(SPEC1,plantautomaton,UC)

EUC=[V1C,V1O,V2C,V2O,V3O,V3C,F1H,F1L,SUF,SDF,PSUON,PSUOFF];

project1=project(product(Supervisor1,plantautomaton),EUC)

