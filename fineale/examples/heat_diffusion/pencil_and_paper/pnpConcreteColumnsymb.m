% Finite Element Modeling with Abaqus and Matlab for  Thermal and 
% Stress Analysis
% (C)  2015, Petr Krysl
%
% Concrete column with hydration heat and zero temperature on the boundary.
function pnpConcreteColumnsymb

%% 
% Most of the  steps are carried out symbolically..
syms k dx dy Q Dz real % the variables in the problem, k is kappa
gradNpar= [-1,-1;1,0;0,1];%Gradients of the basis fncs wrt the param. coords
xall= [0,0; dx,-dy; dx,dy; 2*dx,-2*dy; 2*dx,2*dy];%Coordinates of the nodes
dof=[3    1    2    5    4];% Numbers of the degrees of freedom
%% 
% Global conductivity matrix and heat load vector.
K=sym(zeros(5));
L=sym(zeros(5,1));
%% 
% 
%First element
conn= [1,2,3];% The definition of the element, listing its nodes
x=xall(conn,:);% The coordinates  of the three nodes
J=x'*gradNpar % Compute the Jacobian matrix
Se=det(J )/2 % The area of the triangle
gradN=gradNpar/J
(Se*gradN(1,:)*gradN(1,:)'*k*Dz)
(Se*gradN(1,:)*gradN(2,:)'*k*Dz)
Ke1= (Se*gradN*gradN'*k*Dz)
edof=dof(conn)
K(edof,edof)=K(edof,edof)+Ke1;
LeQ1=Se*Q*Dz/3*ones(3,1);
L(edof)=L(edof)+LeQ1;

%% 
% 
%Second element
conn= [2,4,5];
x=xall(conn,:);
J=x'*gradNpar
Se=det(J )/2
gradN=gradNpar/J
Ke2= (Se*gradN*gradN'*k*Dz)
edof=dof(conn)
K(edof,edof)=K(edof,edof)+Ke2;
LeQ2=Se*Q*Dz/3*ones(3,1);
L(edof)=L(edof)+LeQ2;

%% 
% 
%Third element
conn= [2,5,3];
x=xall(conn,:);
J=x'*gradNpar
Se=det(J )/2
gradN=gradNpar/J
edof=dof(conn)
Ke3= (Se*gradN*gradN'*k*Dz)
K(edof,edof)=K(edof,edof)+Ke3;
LeQ3=Se*Q*Dz/3*ones(3,1);
L(edof)=L(edof)+LeQ3;


%% 
% Solution:
K=K(1:3,1:3)
L=L(1:3)
T=K\L

%% 
% Evaluate for a given data
a=2.5; dy=a/2*sin(15/180*pi); dx=a/2*cos(15/180*pi); Q=4.5; k=1.8; Dz=1.0;
m=vpa(eval(T))

