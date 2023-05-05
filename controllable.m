function [isctrb,States,Events]=controllable(K,G,Euc)
% CONTROLLABLE  Determine if a language is controllable. 
%
% SYNTAX:   isctrb=controllable(K,G,Euc)
%           [isctrb,States]=controllable(K,G,Euc)           
%           [isctrb,States,Events]=controllable(K,G,Euc)
%
% INPUTS:   K     Automaton representing the test language 
%           G     Plant Automaton
%           Euc   Uncontrollable events (vector) 
%                 
% OUTPUTS:  isctrb    Test result
%           States    List of states where disablement of uncontrollable events 
%                     occurs
%           Events    List of disabled uncontrollable events (cell array)
%
%
% DESCRIPTION 
%       Let Lm() and L() denote marked behavior (marked language) and 
%       closed behavior (generated language). isctrb=controllable(K,G,Euc)
%       returns isctrb=1 if and only if L(K) is controllable with respect to L(G) 
%       and Euc. Otherwise, it returns isctrb=0. When K is trim, 
%       controllable(K,G,Euc) returns 1 if and only if Lm(K) is controllable with 
%       respect to L(G) and Euc.
%        
%       [isctrb,States]=controllable(K,G,Euc) returns a two-column matrix States.
%       Each row of States, [xK,xG], is a state of product(K,G) where disablement 
%       of uncontrollable events (if any) occurs, i.e., the test fails. If L(K)
%       is controllable (isctrb=1), then States=[]. 
%
%       [isctrb,States,Events]=controllable(K,G,Euc) returns the list of disabled
%       uncontrollable events (if any) in the cell array Events. The i-th cell of
%       Events, Events{i}, is a row vector containing the uncontrollable events 
%       disabled in [xKi,xGi] (the i-th row of States). 
%

%
% Shahin Hashtrudi Zad, Shauheen Zahirazami, Farzam Boroomand, May 16, 2012
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

error(nargchk(3,3,nargin))
%
if (~isempty(Euc)) && (~isrow(Euc))
  Euc=Euc';
end
%
% Special cases
%
if (K.N==0 || G.N==0 || isempty(Euc))
  isctrb=1;
  States=[];
  Events={};
  return;
end 
%
if isempty(G.TL)
  isctrb=1;
  States=[];
  Events={};
  return;
end 
%
if isempty(K.TL)
  Ind= (G.TL(:,1)==1);
  Ev=intersect(G.TL(Ind,2)',Euc);
  if isempty(Ev)
    isctrb=1;
    States=[];
    Events={};
  else
    isctrb=0;
    States=[1 1];
    Events={ Ev };
  end
  return;
end
%
% Main part
%
% Start by sorting transition lists.
%
K.TL=sortrows(K.TL,[1,2,3]);
G.TL=sortrows(G.TL,[1,2,3]);
%
% For each state, identify the corresponding outgoing transitions.
%
Xind1=zeros(K.N,2);
for i=1:K.N
   Ind=find(K.TL(:,1)==i);
   if ~isempty(Ind)
     Xind1(i,:)=[min(Ind) max(Ind)];
   end
end
%
Xind2=zeros(G.N,2);
for i=1:G.N
   Ind=find(G.TL(:,1)==i);
   if ~isempty(Ind)
     Xind2(i,:)=[min(Ind) max(Ind)];
   end
end
%
% Initialization
%
isctrb=1;
States=[];
Events={};
%
N=0;
KGStates=[];
%
% States discovered, but not investigated.
gray=[1 1];
%
while ~isempty(gray)
%
% x=[x1,x2]=[xK,xG]
  x=gray(1,:);
%
% No transition out of xK, some transitions out of xG
  if (Xind1(x(1),2)==0 && Xind2(x(2),2)~=0)
    rx2=Xind2(x(2),1):Xind2(x(2),2);
    Ev=intersect(G.TL(rx2,2)',Euc);
    if ~isempty(Ev)
      isctrb=0;
      switch nargout
        case 1
          return;
        case 2
          States=[States; x];
        case 3
          States=[States; x];
          Events{size(States,1)}=Ev;
      end  %switch
    end  %if
%
% Transitions out of xK and xG
  elseif (Xind1(x(1),2)~=0 && Xind2(x(2),2)~=0)
%
% Common events out of x1=xK and x2=xG    
    rx1=Xind1(x(1),1):Xind1(x(1),2);
    rx2=Xind2(x(2),1):Xind2(x(2),2);
    Edis=setdiff(G.TL(rx2,2),K.TL(rx1,2));
    if ~isempty(intersect(Edis',Euc))
       isctrb=0;
       switch nargout
         case 1
            return;
         case 2
            States=[States; x];
         case 3
            States=[States; x];
            Events{size(States,1)}=intersect(Edis',Euc);
       end  %switch
    end  %if
    Ev=intersect(G.TL(rx2,2), K.TL(rx1,2));
    if ~isempty(Ev)
%
% Find the destinations of transitions out of x=[x1,x2]=[xK,xG]
       for i=1:length(Ev)
          Ind= (K.TL(rx1,2)==Ev(i));
          dsnx1=K.TL(rx1,3);
          dsnx1=dsnx1(Ind);
          Ind= (G.TL(rx2,2)==Ev(i));
          dsnx2=G.TL(rx2,3);
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
% Find the newly discovered states.
          jnew=true(size(dsnx,1),1);
          OldStates=[KGStates; gray];
          for j=1:size(dsnx,1)
            Ind= (OldStates(:,1)==dsnx(j,1) & OldStates(:,2)==dsnx(j,2));
            jnew(j)= ~any(Ind);
          end
          newx=dsnx(jnew,:); 
          gray=[gray; newx];  
       end  %for
    end  %if
  end  %if
%  
  KGStates=[KGStates; x];
  N=N+1;
  if size(gray,1)==1
     gray=[];
  else
     gray=gray(2:size(gray,1),:);
  end  %if
end  %while
%
%
% End of code

