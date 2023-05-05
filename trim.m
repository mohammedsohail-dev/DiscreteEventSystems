function [Gt,Xrc]=trim(G)
% TRIM  Find the reachable and coreachable subautomaton.
%
% SYNTAX:   Gt=trim(G)
%           [Gt,Xrc]=trim(G)
%            
% INPUT:    G    Input automaton
%                 
% OUTPUTS:  Gt    Trim subautomaton
%           Xrc   States of G that are reachable and coreachable (row
%                 vector)
%
% DESCRIPTION
%       Gt=trim(G) returns the trim subautomaton of G (containing only those 
%       states of G that are both reachable and coreachable). The states of Gt 
%       are renamed in the order they are discovered in a breadth-first search. 
%           
%       [Gt,Xrc]=trim(G) returns the states of G that are reachable and
%       coreachable in Xrc.
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
% Special cases
%
if isempty(G.Xm)
  Gt=automaton(0,[],[]);
  Xrc=[];
  return;
end
%
if isempty(G.TL)
  if ismember(1,G.Xm)
     Gt=automaton(1,[],[1]);
     Xrc=1;
  else
     Gt=automaton(0,[],[]);
     Xrc=[];
  end
  return;
end
%
%
% Find the states that are coreachable
%
TL_rev=[G.TL(:,3) G.TL(:,2) G.TL(:,1)];
Xcr=reach(TL_rev,G.Xm);
%
% Remove transitions to and from states that are not coreachable
% (This makes them unreachable too)
% 
% Xren is the state set with states that are not coreachable renamed to -1
Xren=-ones(1,G.N);
Xren(Xcr)=Xcr;
%
Xrent=Xren'; 
G.TL=[Xrent(G.TL(:,1)) G.TL(:,2) Xrent(G.TL(:,3))];
%
Indi= (G.TL(:,1)~=-1 & G.TL(:,3)~=-1);
G.TL=G.TL(Indi,:);
%
% Find the trim subautomaton
[Gt,Xrc]=reachable(G);
%
%
% End of code


