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
     A1PSUF1.TL=[A1PSUF1.TL;i A1H  i];  
   else
     A1PSUF1.TL=[A1PSUF1.TL; i A1L i];
   end
end

[Systemautomata,states1]=sync(V2,V1,V3,A1,F2,F1,local,master,PSU,F1V1,F2V2V3,A1PSUF1);