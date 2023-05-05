function [Go,States]=project(G,Euo)
% PROJECT  Find a deterministic automaton to represent the projection of 
%          a language.  
%
% SYNTAX:   Go=project(G,Euo)
%           [Go,States]=project(G,Euo)
% 
% INPUTS:   G      Input automaton (deterministic or nondeterministic)
%           Euo    Events to be erased (vector)
%                 
% OUTPUTS:  Go        Output automaton (deterministic)
%           States    State set of output automaton (cell array)
%
% DESCRIPTION 
%       Let E be the event set of the input automaton G, Euo the events to be 
%       erased (unobservable events) and P:E ->(E-Euo) the natural projection 
%       onto E-Euo. Furthermore, let Lm() and L() denote marked behavior
%       (marked language) and closed behavior (generated language). 
%
%       Go=project(G,Euo) returns a deterministic automaton Go which marks
%       P(Lm(G)) and generates P(L(G)): Lm(Go)=P(Lm(G)) and L(Go)=P(L(G)).
%       Go may be regarded as an observer automaton.
%
%       [Go,States]=project(G,Euo) returns a cell array States containing 
%       information about the states of Go. The i-the cell of States,
%       States{i}, is a row vector containing the state estimate for the input
%       automaton G when the observer Go is in state i.
%       

%
% Shahin Hashtrudi Zad, Farzam Boroomand, August 21, 2013
% Discrete Event Control Kit (DECK 1.2013.11)   
%
% Copyright (C) 2013 Shahin Hashtrudi Zad, Shauheen Zahirazami, Farzam 
% Boroomand 
%       
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License version 2 as
% published by the Free Software Foundation.
%             
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of   
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the 
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License along
% with this program; if not, write to the Free Software Foundation, Inc.,
% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
% The full text of the GNU General Public License version 2 is
% available at http://www.ece.concordia.ca/~shz/deck/GNU-GPL-v2.txt
%
% Please send inquiries about DECK to: shz@ece.concordia.ca
%

error(nargchk(2,2,nargin))
%
% Special cases
%
if G.N==0
  Go=automaton(0,[],[]);
  States={};
  return;
end
%
if (G.N~=0) && isempty(G.TL)
   if ismember(1,G.Xm)
     Go=automaton(1,[],[1]);
   else
     Go=automaton(1,[],[]);
   end
   States={[1]};
   return;
end
%
% Adjust Euo if necessary
%
if ~isempty(Euo)
  Euo=unique(Euo);
  if ~isrow(Euo)
    Euo=Euo';
  end
else
  Euo=[];
end
%
% Separate the unobservable and observable transitions
%
if isempty(Euo)
  TLuo=[];
  TLo=G.TL;
else
  Induo=false(size(G.TL,1),1);
  for i=1:length(Euo)
    Induo= (Induo | (G.TL(:,2)==Euo(i)));
  end
  TLuo=G.TL(Induo,:);
  TLo=G.TL(~Induo,:);
end
%
% One more special case
%
if isempty(TLo)
  Xr=reach(TLuo,1);
  if any(ismember(Xr,G.Xm))
    Go=automaton(1,[],[1]);
  else
    Go=automaton(1,[],[]);
  end
  States={Xr};
  return;
end

%
% Preparations for the main loop
%

%
% Is the input automaton small?
%
if G.N <= 1000
  Gsmall=true;
else 
  Gsmall=false;
end
%
% In case of small automata, for each state, find in advance the states 
% reachable through unobservable transitions
if Gsmall
  ureach=cell(G.N,1);
  for i=1:G.N
    ureach{i}=reach(TLuo,i);
  end
end

%
% Start by sorting observable transition lists
%
% For each state, identify the corresponding outgoing observable transitions
%
TLo=sortrows(TLo,[1,2,3]);  
Xind=zeros(G.N,2);
for i=1:G.N
   Ind=find(TLo(:,1)==i);
   if ~isempty(Ind)
     Xind(i,:)=[min(Ind) max(Ind)];
   end
end
%
%
% Initialization
%
% Preallocate States and TL
maxPreStates=1000;
nStates=min((2^(G.N)-1),maxPreStates);
States=cell(nStates,1);
N=0;
% 
maxPreTL=1000;
nTL=min(size(TLo,1),maxPreTL);
TL=-ones(nTL,3);
jTL=0;
%
%
% States discovered, but not investigated.
gray=cell(1,1);
if Gsmall
  gray{1,1}=ureach{1};
else
  gray{1,1}=reach(TLuo,1);
end
%
% Main loop
%
while ~isempty(gray)
  z=gray{1,1};
%
% Find the observable transitions out of z
  Ind=[];
  for i=1:length(z)
    if (Xind(z(i),1)~=0 && Xind(z(i),2)~=0)
      Ind=[Ind, Xind(z(i),1):Xind(z(i),2)];
    end  %if
  end  %for
%
  if ~isempty(Ind)
    TLoind=TLo(Ind,1:3);
    Ev=unique(TLoind(:,2));
    for i=1:length(Ev)
       Inde= (TLoind(:,2)==Ev(i));
       dsnz0=unique(TLoind(Inde,3));
       dsnz0=dsnz0';
       if Gsmall
         dsnz=dsnz0;
         for j=1:length(dsnz0)
           dsnz=[dsnz ureach{dsnz0(j)}];
         end
       else
         dsnz=reach(TLuo,dsnz0);
       end
       dsnz=unique(dsnz);
%
% Examine the destination states and update the transition list of Go 
% accordingly
       jfound=false;
%
% Destination state set previously discovered but not investigated
       j=1;
       while ( ~jfound && j<=size(gray,1) )
         if ( length(dsnz)==length(gray{j,1}) && all(dsnz==gray{j,1}) ) 
           jfound=true;
           jTL=jTL+1;
           if jTL>size(TL,1)
             TL=[TL; -ones(maxPreTL,3)];   %increase TL allocation
           end  %if
           TL(jTL,:)=[N+1 Ev(i) N+j];
         end  %if
         j=j+1;
       end   %while 
%
% Destination state set previously discovered and investigated
       j=1;
       while ( ~jfound && N>0 && j<=N )
         if ( length(dsnz)==length(States{j,1}) && all(dsnz==States{j,1}) ) 
           jfound=true;
           jTL=jTL+1;
           if jTL>size(TL,1)
             TL=[TL; -ones(maxPreTL,3)];   %increase TL allocation
           end  %if
           TL(jTL,:)=[N+1 Ev(i) j];
         end  %if
         j=j+1;
       end   %while 
%
% Newly discovered state set
       if ~jfound 
         jfound=true;
         jTL=jTL+1;
           if jTL>size(TL,1)
             TL=[TL; -ones(maxPreTL,3)];   %increase TL allocation
           end  %if
         TL(jTL,:)=[N+1 Ev(i) N+size(gray,1)+1];
         ngray=size(gray,1);
         gray{ngray+1,1}=dsnz; 
       end  %if         
%
    end  %for Ev(i)
  end  %if ~Ind
%
  N=N+1;
  if N>size(States,1)
    States=[States; cell(maxPreStates,1)];  %increase States allocation
  end  %if
  States{N,1}=z;
  if size(gray,1)==1
     gray={};
  else
     gray=gray(2:size(gray,1),1);
  end  %if
end  %while ~gray
%
States=States(1:N,1);
if jTL==0
  TL=[];
else
  TL=TL(1:jTL,:);
end
%
% Find the marked states
Xm=[];
if ~isempty(G.Xm)
  for i=1:N
    if any(ismember(States{i,1},G.Xm))
      Xm=[Xm i];
    end
  end
end 
%
Go=automaton(N,TL,Xm); 
%
%
% End of code



    
