function [G,States]=product(G1,G2,varargin)
% PRODUCT  Product of automata.
%
% SYNTAX:   G=product(G1,...,Gn)
%           [G,States]=product(G1,...,Gn)
%
%           G=product(Ga)            
%           [G,States]=product(Ga)
%
%
% INPUTS:   Gi    Input automaton i (i=1, ..., n)
%                 
%           Ga    Cell array containing input automata
%
%
% OUTPUTS:  G        Output automaton
%           States   State set of output automaton
%
%
% DESCRIPTION 
%       G=product(G1,...,Gn) returns the product of G1, ..., Gn (n>=2).
%       If Lm() and L() denote marked behavior (marked language) 
%       and closed behavior (generated language), then
%
%           Lm(G) = intersection of Lm(G1), ..., Lm(Gn)
%           L(G)  = intersection of L(G1), ..., L(Gn).
% 
%       [G,States]=product(G1,...,Gn) returns an Nxn matrix States where N is
%       the number of states of G. Let [xi1 ... xin] be the i-th row of States.
%       Then xi1, ..., xin are the states of G1, ..., Gn when G is in state i. 
%
%       PRODUCT can be used with arrays of automata. Let Ga denote a cell array 
%       containing automata Ga{1}, ..., Ga{n} (n>=2). product(Ga) returns the 
%       product of Ga{1}, ..., Ga{n}.
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
%
if nargin == 1
%
% The input (G1) is a cell array containing input automata
  if (isempty(G1)) || (length(G1)<=1)
    error('Not enough input automata.')
  end
%
  if nargout <= 1
    G=product(G1{1},G1{2});
    for i=3:length(G1)
      G=product(G,G1{i});
    end
  else
    [G,States]=product(G1{1},G1{2});
    for i=3:length(G1)
      [G,Stmp]=product(G,G1{i});
      if ~isempty(States) && ~isempty(Stmp)
         States=[States(Stmp(:,1),:)  Stmp(:,2)];
      else
         States=[];
      end %if
    end %for
  end %if
return
%
end

%
%
if nargin >= 3
%%%%%%%%%%%
% CASE: n>2
%
  if nargout <= 1
    G=product(G1,G2);
    for i=1:length(varargin)
      G=product(G,varargin{i});
    end
  else
    [G,States]=product(G1,G2);
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
% End of CASE n>2
%%%%%%%%%%%%%%%%%
%
% nargin == 2
%
else
%%%%%%%%%%%
% CASE: n=2 
%

%
% Special cases
%
if (G1.N==0 || G2.N==0)
  G=automaton(0,[],[]);
  States=[];
  return;
end 
%
if (isempty(G1.TL) || isempty(G2.TL))
  if (ismember(1,G1.Xm) && ismember(1,G2.Xm)) 
    G=automaton(1,[],[1]);
  else
    G=automaton(1,[],[]);
  end
  States=[1 1];
  return;
end
%
% Main part
%
% Start by sorting transition lists.
%
G1.TL=sortrows(G1.TL,[1,2,3]);
G2.TL=sortrows(G2.TL,[1,2,3]);
%
% For each state, identify the corresponding outgoing transitions.
%
Xind1=zeros(G1.N,2);
for i=1:G1.N
   Ind=find(G1.TL(:,1)==i);
   if ~isempty(Ind)
     Xind1(i,:)=[min(Ind) max(Ind)];
   end
end
%
Xind2=zeros(G2.N,2);
for i=1:G2.N
   Ind=find(G2.TL(:,1)==i);
   if ~isempty(Ind)
     Xind2(i,:)=[min(Ind) max(Ind)];
   end
end
%
% Initialization
%
N=0;
States=[];
%
% Preallocate TL
% 
maxPreTL=1000;
nTL=min(size(G1.TL,1)*size(G2.TL,1),maxPreTL);
TL=-ones(nTL,3);
jTL=0;
%
%
% States discovered, but not investigated.
gray=[1 1];
%
while ~isempty(gray)
  x=gray(1,:);
  if (Xind1(x(1),2)~=0 && Xind2(x(2),2)~=0)
%
% Common events out of x(1) and x(2)    
    rx1=Xind1(x(1),1):Xind1(x(1),2);
    rx2=Xind2(x(2),1):Xind2(x(2),2);
    Ev=intersect(G1.TL(rx1,2), G2.TL(rx2,2));
    if ~isempty(Ev)
%
% Find the destinations of transitions out of (x1,x2)
       for i=1:length(Ev)
          Ind= (G1.TL(rx1,2)==Ev(i));
          dsnx1=G1.TL(rx1,3);
          dsnx1=dsnx1(Ind);
          Ind= (G2.TL(rx2,2)==Ev(i));
          dsnx2=G2.TL(rx2,3);
          dsnx2=dsnx2(Ind);
          dsnx=zeros(length(dsnx1)*length(dsnx2),2);
          indl=1;
          indh=length(dsnx2);
          for j=1:length(dsnx1)
             tmpx1=ones(size(dsnx2));
             tmpx1(:)=dsnx1(j);
             dsnx(indl:indh,:)=[tmpx1 dsnx2];
             indl=indl+length(dsnx2);
             indh=indh+length(dsnx2);
          end  %for
%
% Examine the destination states and update the transition list of G 
% accordingly.
          jnew=true(length(dsnx1)*length(dsnx2),1);
          for j=1:length(dsnx1)*length(dsnx2)
%
% Destination states previously discovered but not investigated
             Indg=find(gray(:,1)==dsnx(j,1) & gray(:,2)==dsnx(j,2));
             if ~isempty(Indg)
                jTL=jTL+1;
                if jTL>size(TL,1)
                   TL=[TL; -ones(maxPreTL,3)];   %increase TL allocation
                end
                TL(jTL,:)=[N+1 Ev(i) N+Indg];
                jnew(j)=false;
             else 
%
% Destination states previously discovered and investigated
                if ~isempty(States)
                  Inds=find(States(:,1)==dsnx(j,1) & States(:,2)==dsnx(j,2));               
                  if ~isempty(Inds)
                    jTL=jTL+1;
                    if jTL>size(TL,1)
                      TL=[TL; -ones(maxPreTL,3)];   %increase TL allocation
                    end
                    TL(jTL,:)=[N+1 Ev(i) Inds];
                    jnew(j)=false;
                  end  %if
                end  %if
             end  %if
          end  %for
%
% The rest of destination states are newly discovered states.
          if any(jnew)
            newx=dsnx(jnew,:); 
            for j=1:size(newx,1)
              jTL=jTL+1;
              if jTL>size(TL,1)
                TL=[TL; -ones(maxPreTL,3)];   %increase TL allocation
              end
              TL(jTL,:)=[N+1 Ev(i) N+size(gray,1)+j];
            end  %for
            gray=[gray; newx];
          end  %if  
      end  %for
    end  %if
  end  %if
%  
  States=[States; x];
  N=N+1;
  if size(gray,1)==1
     gray=[];
  else
     gray=gray(2:size(gray,1),:);
  end  %if
end  %while
%
if jTL==0
  TL=[];
else
  TL=TL(1:jTL,:);
end
%
% Find the marked states.
if (isempty(G1.Xm) || isempty(G2.Xm))
 Xm=[];
else
 Xm=find(ismember(States(:,1),G1.Xm) & ismember(States(:,2),G2.Xm))';
end 
%
G=automaton(N,TL,Xm); 
%
% End of CASE n=2
%%%%%%%%%%%%%%%%%
%
end
%
%
% End of code

