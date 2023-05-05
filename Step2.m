
%Step 2

%SPEC2:

NSTSD=4;
STSDTL=[1 SDS 1;1 SUS 2;2 SUS 2;2 SDS 2;2 SUF 3;3 SUS 3;3 SDS 4;4 SDS 4;4 SUS 4;4 SDF 1];
XmSTSD=[1,2,3,4];
STSD=automaton(NSTSD,STSDTL,XmSTSD);

[SPEC2,states]=sync(STSD,A);

for i=1:size(states,1)
    if (states(i,1)==4 && states(i,2) == 2)
        SPEC2.TL=[SPEC2.TL ; i F2H i];
    else
        SPEC2.TL=[SPEC2.TL; i F2L i; i F2H i];
    end
end

SPEC2=selfloop(SPEC2,[PSUON,PSUOFF,V1O,V1C,V2O,V2C,V3O,V3C,F1H,F1L]);
SPEC2.Xm=[1,2,3,4,5,6,7,8];

Supervisor2=supcon(product(SPEC1,SPEC2),plantautomaton,UC)
project2=project(product(Supervisor2,plantautomaton),EUC)