function flag=isnondet(G)
% ISNONDET   Determine whether automaton is nondeterministic.
%
% SYNTAX:   flag=isnondet(G)
%            
% INPUTS:   G       Input automaton
%                 
% OUTPUTS:  flag    logical 1 (true) or 0 (false)
%
% DESCRIPTION 
%       Returns logical 1 (true) if the input automaton G is nondeteterminstic.
%       Otherwise it returns logical 0 (false). 
%

%
% Shahin Hashtrudi Zad, Farzam Boroomand, June 28, 2013
% Discrete Event Control Kit (DECK 1.2013.11)   
%
% Copyright (C) 2013 Shahin Hashtrudi Zad, Farzam Boroomand 
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
if G.N==0
  flag=false;
  return;
end
%
if isempty(G.TL)
  flag=false;
  return;
end
%
%
% First remove repeated rows, if any.
TLtmp=unique(G.TL,'rows');
%
ntran=size(TLtmp,1);
if size(unique(TLtmp(:,1:2),'rows'),1) < ntran
  flag=true;
else
  flag=false;
end
%
%
% End of code


