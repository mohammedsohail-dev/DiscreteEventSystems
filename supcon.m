function K=supcon(H,G,Euc)
% SUPCON  Supremal Controllable Sublanguage. 
%
% SYNTAX:   K=supcon(H,G,Euc)
%            
% INPUTS:   H     Specification (deterministic) automaton
%           G     Plant (deterministic) automaton
%           Euc   Uncontrollable events (vector) 
%                 
% OUTPUTS:  K    Trim (deterministic) automaton marking supremal controllable 
%                sublangage
%
% DESCRIPTION 
%       Let Lm() and L() denote marked behavior (marked language) 
%       and closed behavior (generated language). SUPCON calculates the 
%       supremal sublanguage of the intersection of Lm(H) and Lm(G) that
%       is controllable with respect to L(G) and Euc. The result is returned
%       in the trim automaton K which marks the supremal controllable 
%       sublanguage. The calculations are based on the algorithm introduced in
%       
%        W.M. Wonham and P.J. Ramadge, On the supremal controllable
%        sublanguage of a given language, SIAM J. Control and Optimization,
%        Vol. 25, No. 3, May 1987.
%

%
% Shahin Hashtrudi Zad, Shauheen Zahirazami, Farzam Boroomand, May 16, 2012
% Shahin Hashtrudi Zad, June 5, 2013
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

error(nargchk(3,3,nargin))
%
if (~isempty(Euc)) && (~isrow(Euc))
  Euc=Euc';
end 
%
%
[GH,States]=product(G,H);
[K,Xt]=trim(GH);
%
% Special cases
%
if isempty(G.TL)
   return;
end
%
if K.N==0
  return;
end 
%
if (K.N==1) && isempty(K.TL)
   Ind= (G.TL(:,1)==1);
   ExG=G.TL(Ind,2);
   if ~isempty(intersect(ExG',Euc))
      K=automaton(0,[],[]);
   end
   return;
end
%
if isempty(Euc)
  return;
end
%
% Initialization
%
%
% Sort G.TL. For each state, identify the corresponding outgoing transitions.
%
G.TL=sortrows(G.TL,[1,2,3]);
Xind=zeros(G.N,2);
for i=1:G.N
   Ind=find(G.TL(:,1)==i);
   if ~isempty(Ind)
     Xind(i,:)=[min(Ind) max(Ind)];
   end
end
%
% Remove transitions in GH.TL from and to states that are not reachable and 
% coreachable.
% 
if K.N~=GH.N
  Xren=-ones(1,GH.N);
  Xren(Xt)=Xt;
  Xrent=Xren';
  GH.TL=[Xrent(GH.TL(:,1)) GH.TL(:,2) Xrent(GH.TL(:,3))];
  Indi= (GH.TL(:,1)~=-1 & GH.TL(:,3)~=-1);
  GH.TL=GH.TL(Indi,:);
end
%
% Main part
%
jexit=0;
while jexit==0
%
% Find the subset of Xt where no uncontrollable event is disabled. 
  Xtt=-ones(size(Xt));
  for i=1:length(Xt)
    Indi= (GH.TL(:,1)==Xt(i));
    ExGH=GH.TL(Indi,2);
    xG=States(Xt(i),1);
    if Xind(xG,2)~=0
      rxG=Xind(xG,1):Xind(xG,2);
      ExG=G.TL(rxG,2);
    else
      ExG=[];
    end  %if
    Edis=setdiff(ExG,ExGH);
    if isempty(intersect(Edis',Euc))
      Xtt(i)=Xt(i);
    end  %if   
  end  %for
  Ind= (Xtt~=-1);
  Xtt=Xtt(Ind);
%
%
  if isempty(Xtt)
    K=automaton(0,[],[]);
    return;
  end  %if
%
% If there is no uncontrolllable disablement, then return.
  if size(Xtt,2)==size(Xt,2)
    jexit=1;
%
% If there are states in Xt with uncontrollable disablement, remove transitions
% to and from such states. Then proceed with trimming (without renaming).
  else
    Xren=-ones(1,GH.N);
    Xren(Xtt)=Xtt;
    Xrent=Xren';
    GH.TL=[Xrent(GH.TL(:,1)) GH.TL(:,2) Xrent(GH.TL(:,3))];
    Indi= (GH.TL(:,1)~=-1 & GH.TL(:,3)~=-1);
    GH.TL=GH.TL(Indi,:);
    Xt=Xtt;
%
% Find the reachable and coreachable states of GH. 
    TL_rev=[GH.TL(:,3) GH.TL(:,2) GH.TL(:,1)];
    Xtcr=reach(TL_rev,intersect(GH.Xm,Xt));
    Xtr=reach(GH.TL,1);
    Xtt=intersect(Xtr,Xtcr);
%
    if isempty(Xtt)
      K=automaton(0,[],[]);
      return;
    end  %if
%
% Finish trimming by removing the transitions to and from the states that
% are not reachable or not coreachable. 
    if size(Xtt,2)~=size(Xt,2)
      Xt=Xtt;
      Xren=-ones(1,GH.N);
      Xren(Xtt)=Xtt;
      Xrent=Xren';
      GH.TL=[Xrent(GH.TL(:,1)) GH.TL(:,2) Xrent(GH.TL(:,3))];
      Indi= (GH.TL(:,1)~=-1 & GH.TL(:,3)~=-1);
      GH.TL=GH.TL(Indi,:);
    end  %if
  end  %if
end  %while
%
% Rename GH and return.
%
Xren=-ones(1,GH.N);
for i=1:length(Xt)
   Xren(Xt(i))=i;
end  %for
K.N=length(Xt);
Xrent=Xren';
K.TL=[Xrent(GH.TL(:,1)) GH.TL(:,2) Xrent(GH.TL(:,3))];
Xtm=intersect(Xt,GH.Xm);
K.Xm=Xren(Xtm);
return;
%
%
% End of code

