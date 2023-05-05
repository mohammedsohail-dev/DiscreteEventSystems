function [flag1,flag2]=automatonchk(G)
% AUTOMATONCHK   Verify the validity of an automaton object.
%
% SYNTAX:   flag1=automatonchk(G)
%           [flag1,flag2]=automatonchk(G)            
%
% INPUTS:   G     Input automaton
%                 
% OUTPUTS:  flag1     Automaton validity flag (part 1)
%           flag2     Automaton validity flag (part 2)
%
% DESCRIPTION
%       [flag1,flag2]=automatonchk(G) verifies the validity of the automaton 
%       object G and returns the result in flag1. In cases where the automaton 
%       is not valid, the invalid property is identified in flag2. The 
%       various cases are explained in the following table.
%
%        flag1   flag2     Description
%         -3       1       G.N has wrong size (is not a scalar) 
%         -3       2       G.TL has wrong size 
%         -3       3       G.Xm has wrong size
%
%         -2       1       G.N is not an integer 
%         -2       2       G.TL contains entry that is not an integer
%         -2       3       G.Xm contains entry that is not an integer
%
%         -1       1       G.N is negative 
%         -1       2       G.TL has out-of-range entry
%         -1       3       G.Xm has out-of-range entry
%                          (The valid range for states is 1,...,G.N, and for
%                           events, nonnegative integers.)
%
%          0       2       G.TL has repeated rows
%          0       3       G.Xm has repeated entries
%       
%          1       0       Automaton is valid       
%
%       Automatonchk examines the above list of cases from the top. Once a case 
%       is identified, the function returns with the corresponding flags.
% 
    
%
% Shahin Hashtrudi Zad, Farzam Boroomand, Apr. 24, 2012
% Discrete Event Control Kit (DECK 1.2013.11)
% 
% Copyright (C) 2012 Shahin Hashtrudi Zad, Farzam Boroomand
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
% Check array sizes
%
if ~isscalar(G.N)
   flag1=-3;
   flag2=1;
   return;
end
% 
if ~isempty(G.TL) && (size(G.TL,2)~=3)
   flag1=-3;
   flag2=2; 
   return;
end
%
if ~isempty(G.Xm) && ~isrow(G.Xm)
   flag1=-3;
   flag2=3;
   return;
end
%
% Check for entries that are not integer
%
if floor(G.N)~=G.N
   flag1=-2;
   flag2=1;
   return;
end
%
if ~isempty(G.TL) && any(any(floor(G.TL)~=G.TL))
   flag1=-2;
   flag2=2;
   return;
end
%
if ~isempty(G.Xm) && any(floor(G.Xm)~=G.Xm)
   flag1=-2;
   flag2=3;
   return;
end
%
% Check for out-of-range entries
%
if G.N<0
   flag1=-1;
   flag2=1;
   return;
end
%
if ~isempty(G.TL) 
   if any(any(G.TL(:,[1 3])>G.N)) || any(any(G.TL(:,[1 3])<1))  
      flag1=-1;
      flag2=2;
      return;
   end
end 
%
if ~isempty(G.TL) && any(G.TL(:,2)<0)
   flag1=-1;
   flag2=2;
   return;
end
%
if ~isempty(G.Xm) && (any(G.Xm>G.N) || any(G.Xm<1))  
   flag1=-1;
   flag2=3;
   return;
end
%
% Check for repeated rows in G.TL and repeated entries in G.Xm 
%
if ~isempty(G.TL) && (size(unique(G.TL,'rows'),1)~=size(G.TL,1))
   flag1=0;
   flag2=2;
   return;
end
%
if ~isempty(G.Xm) && (size(unique(G.Xm),2)~=size(G.Xm,2))
   flag1=0;
   flag2=3;
   return;
end
%
% Automaton is valid.
%
flag1=1;
flag2=0;
%
%
% End of code



