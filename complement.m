function Gco=complement(G,Ea)
% COMPLEMENT  Complement of a deterministic automaton.
%
% SYNTAX:   Gco=complement(G)
%           Gco=complement(G,Ea)
%            
% INPUTS:   G     Input deterministic automaton
%           Ea    List of events (vector)
%                 
% OUTPUTS:  Gco   Output deterministic automaton
%
% DESCRIPTION 
%       Let E denote the event set of the input automaton G.
%
%       Gco=complement(G) returns an automaton Gco with
%           
%             Lm(Gco)= E^* - Lm(G),  L(Gco) = E^*
%
%       where Lm() and L() denote marked behavior (marked language) 
%       and closed behavior (generated language), and E^* is the
%       Kleene closure of E.
%
%       Gco=complement(G,Ea) returns an automaton Gco with
%            
%             Lm(Gco)= Ee^* - Lm(G),  L(Gco) = Ee^*
%            
%       where Ee=union(E,Ea). The event set of the input automaton, E,  
%       and Ea must be disjoint. 
%

%
% Shahin Hashtrudi Zad, Shauheen Zahirazami, Farzam Boroomand, May 11, 2012
% Discrete Event Control Kit (DECK 1.2013.11) 
%
% Copyright (C) 2012 Shahin Hashtrudi Zad, Shauheen Zahirazami, Farzam 
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

error(nargchk(1,2,nargin))
%
if nargin==1
   Ea=[];
end
%
if nargin==2
  if ~isempty(Ea)
    Ea=unique(Ea);
  else
    Ea=[];
  end
end
%
if (~isempty(Ea)) && (~isrow(Ea))
  Ea=Ea';
end
%
%
%
if (G.N==0) && (isempty(Ea))
  Gco=automaton(1,[],[1]);
  return;
end
%
%
if (G.N==0) && (~isempty(Ea))
  Nco=1;
  TLco=[ones(length(Ea),1) Ea' ones(length(Ea),1)];
  Xmco=1;
  Gco=automaton(Nco,TLco,Xmco);
  return;
end
%
% The event set of the input automaton and Ea must be disjoint.
%
if ~isempty(G.TL)
   E=unique(G.TL(:,2));
else
   E=[];
end
if nargin==2 && ~isempty(intersect(E',Ea))
 error('The event set of the input automaton and Ea in COMPLEMENT must be disjoint.');
end
%
%
%
Ee=[E;Ea'];
%
% Preallocate TLco
TLco=zeros((G.N + 1)*size(Ee,1),3);
if ~isempty(G.TL)
  j=size(G.TL,1);
  TLco(1:j,:)=G.TL;
else
  j=0;
end
adddump=false;
%
for i=1:G.N
  if ~isempty(G.TL)
     Indi= (G.TL(:,1)==i);
     Ei=unique(G.TL(Indi,2));
     EemEi=setdiff(Ee,Ei);
  else
     EemEi=Ee;
  end
  if ~isempty(EemEi)
     v1=zeros(length(EemEi),1);
     v2=zeros(length(EemEi),1);
     v1(:)=i;
     v2(:)=G.N+1;
     TLco(j+1:j+length(EemEi),:)=[v1 EemEi v2];
     j=j+length(EemEi);
     adddump=true;
  end
end
%
if adddump
  Nco=G.N+1;
  v1=zeros(length(Ee),1);
  v1(:)=Nco;
  TLco(j+1:j+length(Ee),:)=[v1 Ee v1];
  j=j+length(Ee); 
else
  Nco=G.N;
end
if j~=0
  TLco=TLco(1:j,:);
else
  TLco=[];
end
Xmco=setdiff(1:Nco,G.Xm);
%
Gco=automaton(Nco,TLco,Xmco);
%
%
% End of code

