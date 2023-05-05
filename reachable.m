function [Gr,Xr]=reachable(G)
% REACHABLE  Find reachable subautomaton.
%
% SYNTAX:   Gr=reachable(G)
%           [Gr,Xr]=reachable(G)
% 
% INPUTS:   G     Input automaton
%                 
% OUTPUTS:  Gr    Reachable subautomaton
%           Xr    Reachable states of G (row vector)
%
% DESCRIPTION 
%       Gr=reachable(G) returns the subautomaton of G that is reachable
%       (from the initial state of G). The states of Gr are renamed in 
%       the order they are discovered in a breadth-first search. 
%
%       [Gr,Xr]=reachable(G) returns the reachable states of G in Xr.
%

%
% Shahin Hashtrudi Zad, Shauheen Zahirazami, Farzam Boroomand, Apr. 25, 2012
% Shahin Hashtrudi Zad, Farzam Boroomand, May 31, 2013
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

error(nargchk(1,1,nargin))
%
if G.N==0
  Gr=automaton(0,[],[]);
  Xr=[];
  return;
end
%
if (G.N~=0) && isempty(G.TL)
   Xr=1;
   if ismember(1,G.Xm)
      Gr=automaton(1,[],[1]);
   else
      Gr=automaton(1,[],[]);
   end
   return;
end
%
Xr=reach(G.TL,1);
%
% Rename reachable states in the order they appear in Xr and rename
% unreachable states "-1"
%
Xren=-ones(1,G.N);
for i=1:length(Xr)
  Xren(Xr(i))=i;
end
%
% Rename states in transition list
%
Xrent=Xren';
TLren=[Xrent(G.TL(:,1)) G.TL(:,2) Xrent(G.TL(:,3))];
%
% Remove transitions to and from unreachable states
%
Indi= (TLren(:,1)~=-1 & TLren(:,3)~=-1);
TLren=TLren(Indi,:);
%
% Find and rename reachable marked states
% 
Xrm=intersect(Xr,G.Xm);
Xrmren=Xren(Xrm);
%
%
Gr=automaton(length(Xr),TLren,Xrmren);
%
%
% End of code



    
