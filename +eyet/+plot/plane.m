function h = plane(P1,P2,P3,varargin)
% eyet.plot.plane - plot a plane from 3 points
%
% H = eye.plot.plane(P1, P2, P3, ...)
%
% Creates a field of points plotted on a plane defined by
% an axis along points P1..P2 and P1..P3. The field is
% centered between P1 and P2.
% 
% This function takes name/value pairs that modify its behavior
% |-------------------------------------------------------------|
% |PARAMETER (DEFAULT)       | DESCRIPTION                      |
% |--------------------------|----------------------------------|
% | center ((P1+P2)/2)       | Center location of plot          |
% | x_width (1)              | "X" half width of plane          |
% | y_width (1)              | "Y" half width of plane          |
% | dx (0.1)                 | Space between "X" points         |
% | dy (0.1)                 | Space between "Y" points         |
% | symbol ('*')             | Symbol to be used for plotting   |
% | color ([1 0 0])          | Color to be used for the symbols |
% |--------------------------|----------------------------------|
%

center = (P1+P2)/2;
x_width = 1;
y_width = 1;
dx = 0.1;
dy = 0.1;
symbol = '*';
color = [1 0 0];

vlt.data.assign(varargin{:});
[X,Y]=meshgrid(-x_width:dx:x_width,-y_width:dy:y_width);
axis1 = P2-P1;
axis2 = P3-P1;

pts = center(:)' + [axis1(:)*X(:)' + axis2(:) * Y(:)']';

h = plot3(pts(:,1),pts(:,2),pts(:,3),'linestyle','none','Marker',symbol,'color',color);


