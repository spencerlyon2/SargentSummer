function [k,s] = kfilter(A,C,V1,V2,V12)
%function [k,s] = kfilter(A,C,V1,V2,V12)
%KFILTER can have arguments: (A,C,V1,V2) if there are no cross
% products, V12=0.
%     KFILTER calculates the kalman gain, k, and the stationary
%     covariance matrix, s, using the Kalman filter for:
%  
%		x[t+1] = Ax[t] + Bu[t] + w1[t+1]
%               y[t] = Cx[t] + Du[t] + w2[t]
%
%               E [w1(t+1)] [w1(t+1)]' =  [V1   V12;
%                 [ w2(t) ] [ w2(t) ]      V12' V2 ]
%
%  where x is the mx1 vector of states, u is the nx1 vector of controls, y is
%  the px1 vector of observables, A is mxm, B is mxn, C is pxm, V1 is mxm,
%  V2 is pxp, V12 is mxp.
%
m=max(size(A));
[rc,cc]=size(C);
if nargin==4; V12=zeros(m,rc); end;
if (rank(V2)==rc);
  A=A-(V12/V2)*C;
  V1=V1-V12*(V2\V12');
  [k,s]=doubleo(A,C,V1,V2);
  k=k+(V12/V2);
else;
  s0=.01*eye(m);
  dd=1;
  it=1;
  maxit=1000;
  while (dd>1e-8 & it<=maxit);
    k0= (A*s0*C'+V12)/(V2+C*s0*C');
    s1= A*s0*A' + V1 -(A*s0*C'+V12)*k0';
    k1= (A*s1*C'+V12)/(V2+C*s1*C');
    dd=max(max(abs(k1-k0)));
    it=it+1;
    s0=s1;
  end;
  k=k1;s=s0;
  if it>=maxit; 
    disp('WARNING: Iteration limit of 1000 reached in KFILTER.M'); 
  end;
end;
