
function H = Calculate_Jacobian_H(xS, yS, xL, yL, vxL, vyL)


range = hypot(xL - xS, yL - yS);
delta_x = xL - xS;
delta_y = yL - yS;

dfr_dx = delta_x / range;
dfr_dy = delta_y / range;
dfr_dvx = 0;
dfr_dvy = 0;

dftheta_dx = -delta_y / range^2;
dftheta_dy = delta_x / range^2;
dftheta_dvx = 0;
dftheta_dvy = 0;

dfvx_dx = 0;
dfvx_dy = 0;
dfvx_dvx = 1;
dfvx_dvy = 0;

dfvy_dx = 0;
dfvy_dy = 0;
dfvy_dvx = 0;
dfvy_dvy = 1;

H = [ [dfr_dx, dfr_dy, dfr_dvx, dfr_dvy]; [dftheta_dx, dftheta_dy, dftheta_dvx, dftheta_dvy]; [dfvx_dx, dfvx_dy, dfvx_dvx, dfvx_dvy ]; [dfvy_dx, dfvy_dy, dfvy_dvx, dfvy_dvy] ];

end