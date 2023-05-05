function [G,States,Blocked_events]=sync(G1,G2,varargin)
% SYNC   Synchronous product of automata.
%
% SYNTAX:   G=sync(G1,...,Gn)
%           [G,States]=sync(G1,...,Gn)
%           [G,States,Blocked_events]=sync(G1,...,Gn)
%
%           G=sync(Ga)
%           [G,States]=sync(Ga)
%           [G,States,Blocked_events]=sync(Ga)
%
%            
% INPUTS:   Gi    Input automaton i (i=1, ..., n)
%                 
%           Ga    Cell array containing input automata
%
%
% OUTPUTS:  G        Output automaton
%           States   State set of output automaton
%           Blocked_events    Events blocked (absent) in output automaton 
%                             (row vector)
%
% DESCRIPTION 
%       G=sync(G1,G2) returns the synchronous product of G1 and G2.
%       Let E1 and E2 be the event sets of G1 and G2. If Lm() and L() denote 
%       marked behavior (marked language) and closed behavior (generated 
%       language), then 
%
%                Lm(G)=Lm(G1)||Lm(G2),   L(G)=L(G1)||L(G2)
%
%       Here L1||L2 is the synchronous product of languages L1 and L2 defined
%       according to:
%
%                L1||L2 = intersection of P1^-1(L1) and P2^-1(L2)
%
%       where P1 (resp. P2) is the natural project of (union of E1 and E2)^*
%       onto E1^* (resp. E2^*).
%
%       G=sync(G1,...,Gn) returns the synchronous product of G1, ..., Gn (n>=2).
%
%       [G,States]=sync(G1,...,Gn) returns the Nxn matrix States where N is the
%       number of states of G. Let [xi1 ... xin] be the i-th row of States.
%       Then xi1, ..., xin are the states of G1, ..., Gn when G is in state i.
%
%       [G,States,Blocked_events]=sync(G1,...,Gn) returns the row vector
%       Blocked_events containing the events that are in the transition list of
%       at least one of the input automata (Gi) and absent in the transition
%       list of the output automaton (G).
%
%       SYNC can be used with arrays of automata. Let Ga denote a cell array
%       containing automata Ga{1}, ..., Ga{n} (n>=2). sync(Ga) returns the 
%       synchronous product of Ga{1}, ..., Ga{n}.
%

%
% Shahin Hashtrudi Zad, Shauheen Zahirazami, Farzam Boroomand, May 23, 2012
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

if nargin == 0
  error('Not enough input arguments.')
end

%
% Case 1: Input (G1) is a cell array containing input automata.
%
if nargin == 1
%
  if (isempty(G1)) || (length(G1)<=1)
    error('Not enough input automata.')
  end
%
  E=[];
  for i=1:length(G1)
    if ~isempty(G1{i}.TL)
      E1{i}=unique(G1{i}.TL(:,2));
    else
      E1{i}=[];
    end
    E=union(E,E1{i});
  end
%
  for i=1:length(G1)
    G1{i}=selfloop(G1{i},setdiff(E,E1{i}));
  end
%
%
%
  if nargout <= 1
    G=product(G1);
  else
    [G,States]=product(G1);
  end

%
% Case 2: Input arguments are automaton.
%
else
%
  if ~isempty(G1.TL)
    E1=unique(G1.TL(:,2));
  else
    E1=[];
  end
  if ~isempty(G2.TL)
    E2=unique(G2.TL(:,2));
  else
    E2=[];
  end
  E=union(E1,E2);
  for i=1:length(varargin)
    if ~isempty(varargin{i}.TL)
      Evar{i}=unique(varargin{i}.TL(:,2));
    else
      Evar{i}=[];
    end
    E=union(E,Evar{i});
  end
%
%
%
  G1s=selfloop(G1,setdiff(E,E1));
  G2s=selfloop(G2,setdiff(E,E2));
  for i=1:length(varargin)
    varargin{i}=selfloop(varargin{i},setdiff(E,Evar{i}));
  end
%
%
%
  if nargout <= 1
    G=product(G1s,G2s);
    for i=1:length(varargin)
      G=product(G,varargin{i});
    end
  else
    [G,States]=product(G1s,G2s);
    for i=1:length(varargin)
      [G,Stmp]=product(G,varargin{i});
      if ~isempty(States) && ~isempty(Stmp)
        States=[States(Stmp(:,1),:)  Stmp(:,2)];
      else
        States=[];
      end %if
    end %for
  end %if
%
%
%
end %if
%
% End of case 2
%

if nargout==3
  if ~isempty(G.TL)
    EG=unique(G.TL(:,2));
    Blocked_events=setdiff(E,EG);
  else
    Blocked_events=E;
  end
  if (~isempty(Blocked_events)) && (~isrow(Blocked_events))
    Blocked_events=Blocked_events';
  end
end
%
%
% End of code

