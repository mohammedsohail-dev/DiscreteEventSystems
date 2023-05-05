function [Gdet,States]=deterministic(G)
% DETERMINISTIC  Convert nondeterministic automaton to deterministic automaton. 
%
% SYNTAX:   Gdet=deterministic(G)
%           [Gdet,States]=deterministic(G)
% 
% INPUTS:   G      Input automaton (deterministic or nondeterministic)
%                 
% OUTPUTS:  Gdet      Output automaton (deterministic)
%           States    State set of output automaton (cell array)
%
% DESCRIPTION 
%       Gdet=deterministic(G) returns a deterministic automaton Gdet that has
%       the same marked and closed behavior as G:
%
%             Lm(Gdet) = Lm(G),    L(Gdet) = L(G).
%
%       Here Lm() and L() denote marked behavior (marked language) and closed 
%       behavior (generated language). If G is deterministic, then Gdet=G.
%
%       DETERMINISTIC uses the subset construction to build Gdet.
%       [Gdet,States]=deterministic(G) returns a cell array States containing 
%       information about the states of Gdet. The i-the cell of States,
%       States{i}, is a row vector containing the subset of states of the input 
%       automaton G associated with state i of Gdet.
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

error(nargchk(1,1,nargin))
%
% Case 1: G is deterministic
%
if ~isnondet(G)
  Gdet=G;
  if nargout>=2
    if G.N==0
      States={};
    else
      States=num2cell((1:G.N)');
    end 
  end
  return;
end
%
% Case 2: G is nondeterministic
%
if nargout<=1
  Gdet=project(G,[]);
else 
  [Gdet,States]=project(G,[]);
end
%
%
% End of code



    
