function Gs=selfloop(G,Es)
% SELFLOOP   Add selfloops to automaton.
%
% SYNTAX:   Gs=selfloop(G,Es)
%            
% INPUTS:   G     Input automaton
%           Es    List of events (vector)
%                 
% OUTPUTS:  Gs    Output automaton
%
% DESCRIPTION 
%       Adds selfloop transitions (x,e,x) to the transition list
%       of the input automaton G, for all states x of G and all 
%       events e in the event list Es.
%
%       The event set of G and Es must be disjoint. 
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

error(nargchk(2,2,nargin))
%
% Empty input automaton
%
if G.N==0
  Gs=automaton(0,[],[]);
  return;
end
%
% Es empty
%
if isempty(Es)
  Gs=G;
  return;
end
%
%
%
Es=unique(Es);
if ~isrow(Es)
  Es=Es';
end
%
% The event set of the input automaton and Es must be disjoint.
%
if ~isempty(G.TL)
  E=unique(G.TL(:,2))';
else
  E=[];
end
if ~isempty(intersect(E,Es))
  error('The event set of G and Es in SELFLOOP must be disjoint.');
end
%
%
%
if ~isempty(G.TL)
  TLs=[G.TL; zeros(G.N*length(Es),3)];
  j=size(G.TL,1);
else
  TLs=zeros(G.N*length(Es),3);
  j=0;
end
%
vi=zeros(length(Es),1);
for i=1:G.N
  vi(:)=i;
  TLs(j+1:j+length(Es),:)=[vi,Es',vi];
  j=j+length(Es);
end
%
Gs=automaton(G.N,TLs,G.Xm);
%
%
% End of code


