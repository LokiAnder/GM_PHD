

GM_EKF_PHD_Initialise_Jacobians;%Initialise observation model h
%Initialise sensor position
xS = 0;%X position in m. X is positive right
yS = 0;%Y position in m. Y is positive up
hS = 0;%Heading in radians. 0 is to the right, positive is left.
%Initialise landmark position. Ideally, don't put this as the exact same
%position as the sensor
xL = 1.5;%X position in m
yL = 2.8;%Y position in m
vxL = 0;%X velocity in m/s
vyL = 0;%Y velocity in m/s

x_sensor = [xS, yS, hS];
x_landmark = [xL, yL, vxL, vyL];

%Anonymous function
calculate_Jacobian_H = @(xR,yR,xL,yL)[ [(xL - xR) / hypot(xL - xR,yL - yR) , (yL - yR) / hypot(xL - xR,yL - yR), 0, 0]; [ (yR - yL)/((xL - xR)^2 + (yL - yR)^2),  (xL - xR)/((xL - xR)^2 + (yL - yR)^2), 0, 0]; [0 0 1 0]; [0 0 0 1] ];

J1 = Calculate_Jacobian_H(xS, yS, xL, yL);%Analytical function
J2 = calculate_Jacobian_H(xS,yS,xL,yL);%Anonymous analytical function
J3 = GM_EKF_PHD_Numerical_Jacobian(h, x_sensor, x_landmark);%Numerical function
J1
J2
J3



