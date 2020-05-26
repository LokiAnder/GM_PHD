%% 控制变量

VERBOSE = 0;%Set to 1 for much more text output. This can be used to give more information about the state of the filter, but slows execution and makes the code less neat by requiring disp() statements everywhere.
KNOWN_TARGET = 0;%Set to 1 to have the first two targets already known to the filter on initialisation. Otherwise tracks for them will need to be instantiated.
PLOT_ALL_MEASUREMENTS = 0;%Set to 1 to maintain the plot of the full measurement history, including clutter and error ellipses. Set to 0 to just plot the most recent measurement.
OUTPUT_MULTIPLE_HIGH_WEIGHT_TARGETS = 0;%Set to 1 to implement Vo & Ma's state extraction where targets with rounded weight greater than 1 are output multiple times. This does NOT change filter processing as extracted targets are not fed back into the filter, it is merely for display. VERBOSE must be set to 1 to see the effects of this. Personally I think this is a bit redundant but I've included it to match the Vo & Ma algorithm.
CALCULATE_OSPA_METRIC = 1; %Set to 1 to calculate the OSPA performance metric for each step. This is not essential for the GM-PHD filter but provides a rough indication of how well the filter is performing at any given timestep.
USE_EKF = 0;%Set to 1 to use extended Kalman filter. Set to 0 to use linear KF.
DRAW_VELOCITIES = 0;%Set to 1 to draw velocity arrows on the output plot.

addVelocityForNewTargets = 0;
addStaticNewTargets = 1;

weightDataRange = 1:2;
temp = [];

MAX_V = 100;


calculateDataRange2 = @(j) (2*j-1):(2*j);%Used to calculate the indices of two-dimensional target j in a long list of two-dimensional targets
calculateDataRange4 = @(j) (4*(j-1)+1):(4*j);%Used to calculate the indices of four-dimensional target j in a long list of four-dimensional targets

k = 0; %Time step

numBirthedTargets = 0;
numSpawnedTargets = 0;
m_birth_before_prediction = [];%We store the birth/spawn position from before the prediction. This is used in augmenting the measurement vector to calculate velocity, for the update. 

mk_k_minus_1_before_prediction = [];%Used in augmenting measurement vector to calculate velocity, for update.
numTargets_Jk_k_minus_1 = 0;%Number of targets given previous. J_k|k-1. Set at end of Step 2 (prediction of existing targets)
prob_survival = 0.99; %Probability of target survival. Used in GM_PHD_Predict_Existing for weight calculation

wk_k_minus_1 = [];%Weights of gaussians, previous, predicted. w_k|k-1.
mk_k_minus_1 = []; %Means of gaussians, previous, predicted. m_k|k-1
Pk_k_minus_1 = []; %Covariances of gaussians, previous, predicted. P_k|k-1

w_k = [];%Weights of gaussians, updated. w_k|k
m_k = [];%Means of gaussians, updated. m_k|k
P_k = [];%covariances of gaussians, updated. P_k|k
numTargets_Jk = 0;%Number of targets after update. J_k. Set at end of step 4 (update)


numTargets_J_pruned = 0;%Number of targets after pruning
numTargets_Jk_minus_1 = 0; %Number of targets, previous. J_k-1. Set in end of GM_PHD_Prune

T = 10^-5;%Weight threshold. Value the weight needs to be above to be considered a target rather than be deleted immediately.
mergeThresholdU = 4; %Merge threshold. Points with Mahalanobis distance of less than this between them will be merged.
weightThresholdToBeExtracted = 0.5;%Value the weight needs to be above to be considered a 'real' target.
maxGaussiansJ = 100;%Maximum number of Gaussians after pruning. NOT USED in this implementation.

wk_minus_1 = []; %Weights from previous iteration
mk_minus_1 = []; %Means from previous iteration
Pk_minus_1 = []; %Covariances from previous iteration

X_k_history = [];

w_birth = [];%New births' weights
m_birth = [];%New births' means
P_birth = [];%New births' covariances
w_spawn = [];%New spawns' weights
m_spawn = [];%New spawns' means
P_spawn = [];%New spawns' covariances

xrange = [-1000 1000];%X range of measurements
yrange = [-1000 1000];%Y range of measurements
V = 4 * 10^6; %Volume of surveillance region
lambda_c = 12.5 * 10^-6; %average clutter returns per unit volume (50 clutter returns over the region)
clutter_intensity = @(z_cartesian) lambda_c * V * unifpdf_2d(xrange, yrange, z_cartesian);%Generate clutter function. There are caveats to its use for clutter outside of xrange or yrange - see the comments in unifpdf_2d.m

order_p = 1;%The order determines how punishing the metric calculation is to larger errors; as p increases, outliers are more heavily penailsed
cutoff_c = 200;%Cutoff determines the maximum error for a point.
metric_history = [];%History of the OSPA performance metric

I2 = eye(2);%2x2 identify matrix, used to construct matrices
Z2 = zeros(2);%2x2 zero matrix, used to construct matrices
dt = 1; %One-second sampling period
F = [ [I2, dt*I2]; [Z2 I2] ];%State transition matrix (motion model)
sigma_v = 5; %Standard deviation of process noise is 5 m/(s^2)
Q = sigma_v^2 * [ [1/4*dt^4*I2, 1/2*dt^3*I2]; [1/2*dt^3* I2, dt^2*I2] ]; %Process noise covariance, given in Vo&Ma.

birth_mean1 = [250, 250, 0, 0]';%Used in birth_intensity function
birth_mean2 = [-250, -250, 0, 0]';%Used in birth_intensity function
covariance_birth = diag([100, 100, 25, 25]');%Used in birth_intensity function
covariance_spawn = diag([100, 100, 400,400]');%Used in spawn_intensity function
covariance_spawn = max(covariance_spawn, 10^-6);%Used in spawn_intensity function
birth_intensity = @(x) (0.1 * mvnpdf(x(1:2)', birth_mean1(1:2)', covariance_birth(1:2,1:2)) + 0.1 * mvnpdf(x(1:2)', birth_mean2(1:2)', covariance_birth(1:2,1:2)));%Generate birth weight. This only takes into account the position, not the velocity, as Vo&Ma don't say if they use velocity and I assume that they don't. Taken from page 8 of their paper.
spawn_intensity = @(x, targetState) 0.05 * mvnpdf(x, targetState, covariance_spawn);%Spawn weight, from page 8 of Vo&Ma. 

prob_detection = 0.98; %Probability of target detection. Used in recalculating weights in GM_PHD_Update

if(USE_EKF == 0)
    H = [I2, Z2];%Observation matrix for position. Not used, but if you wanted to cut back to just tracking position, might be useful.
    H2 = eye(4);%Observation matrix for position and velocity. This is the one we actually use, in GM_PHD_Construct_Update_Components
    sigma_r = 10; %Standard deviation of measurement noise is 10m. Used in creating R matrix (below)
    R = sigma_r^2 * I2;%Sensor noise covariance. used in R2 (below)
    R2 = [ [R, Z2]; [Z2, R] ];%Measurement covariance, expanded to both position & velocity. Used in GM_PHD_Construct_Update_Components. NOTE: This assumes that speed measurements have the same covariance as position measurements. I have no mathematical justification for this.
end

fake_x=[];
fake_y=[];