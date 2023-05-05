function Xr=reach(TL,S)
% REACH    Find the reachable states of transition graph.
%
% SYNTAX:   Xr=reach(TL,S)
%
% INPUTS:   TL    Transition list
%           S     Source states (vector)
%
% OUTPUTS:  Xr    States reachable from S (row vector)
%
% DESCRIPTION
%       Xr=reach(TL,S) returns the states of the (automaton) transition 
%       graph that are reachable from the set of source states S using the 
%       breadth-first-search algorithm. The reachable states appear in
%       Xr in the order they are discovered in the breadth-first search.
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
if isempty(S)
  Xr=[];
  return;
end
%       
% If there are repeated elements in S, remove them and sort S.
% Otherwise do not change S.
%
Stmp=unique(S);
if length(S)~=length(Stmp)
   S=Stmp;
end
%
if ~isrow(S)
  S=S';
end 
%
%
if isempty(TL)
  Xr=S;
  return;
end
%
%
Xr=[];
%
% States and transitions to be investigated
%
gray=S;
TLr=TL;
%
% All transitions to already discovered states are removed.
%
for i=1:length(gray)
  Indi = (TLr(:,3)==gray(i));
  if all(Indi)
    Xr=gray;
    return;
  end 
  TLr=TLr(~Indi,:);
end
%
%
while ~isempty(gray)
  if isempty(TLr)
    Xr=[Xr gray];
    return;
  end
% 
% Transitions from gray(1)
%
  Ind = (TLr(:,1)==gray(1));
%
  if any(Ind)
    new_states=unique(TLr(Ind,3))';
%
% All transitions to newly discovered states are removed.
%
    for i=1:length(new_states)
      Indi = (TLr(:,3)~=new_states(i));
      TLr=TLr(Indi,:);
    end
%
    gray=[gray new_states];
    Xr=[Xr gray(1)];
    gray=gray(2:length(gray));
  else
    Xr=[Xr gray(1)];
    if length(gray)==1
      gray=[];
    else
      gray=gray(2:length(gray));
    end
  end
%
end
%
%
% End of code



