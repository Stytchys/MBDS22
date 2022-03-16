%-------------------------------------------------------------------------
%
% Code and functions created by Ray Chen and David Corrente collaboratively
%
%-------------------------------------------------------------------------

%Part 1: produce reaction forces/moments

%reads input Excel file for numerical data on solving for beam
opts = detectImportOptions('MBD Problem Solver Input.xlsx');
%optimize code speed by specifying sheet to pull data from
opts.Sheet = 'Sheet1';
%keep variable name in tabular data preview
opts.VariableNamingRule = 'preserve';
%defines range of data (size of data array) to pull for each column
opts.DataRange = '2:6';
%fill 0's in for missing data entry in defined range
opts = setvaropts(opts,{'PositionOfRF_RM','AppliedForce', ...
    'PositionOfAF','AppliedDistributedLoad','StartOfADL', ...
    'EndOfADL','AppliedPointMoment','PositionOfAPM', ...
    'C_SDimensions','BendingVariables', ...
    'ShearVariables','AxialTorques','PositionOfAT','TorsionVariables', ...
    'Moduli'},'TreatAsMissing','');
opts.MissingRule = 'fill';
opts = setvaropts(opts,{'PositionOfRF_RM','AppliedForce', ...
    'PositionOfAF','AppliedDistributedLoad','StartOfADL', ...
    'EndOfADL','AppliedPointMoment','PositionOfAPM', ...
    'C_SDimensions','BendingVariables', ...
    'ShearVariables','AxialTorques','PositionOfAT','TorsionVariables', ...
    'Moduli'},'FillValue',0);

%display table of values used
preview('MBD Problem Solver Input.xlsx',opts)

%assign variable vector names to data columns
[BeamType,ReactionType, PositionRF, AppliedForce, PositionAF, ADL, ...
    StartADL, EndADL, APM, PositionAPM, XSecTypeArray, XSecDim, ...
    BendingVars, ShearVars, AxialTorque, PositionAT, TorsionVars, ...
    Moduli] = readvars('MBD Problem Solver Input.xlsx',opts);

%defining type of beam to determine function for calculation
BeamType = string(BeamType(1));
%if type decision for calculating reactions/moments
if BeamType == ('Simply Supported Beam')
    %if SSB, following array is created, where first row is net forces in 
    %y-direction and second row is net moment, in augmented matrix form
    ReactionArray = [1,1,(-1*(sum(AppliedForce, 'all')+...
            sum((ADL.*(EndADL-StartADL)))));...
            PositionRF(1), PositionRF(2), (-1*((sum(APM,'all')+...
            sum(AppliedForce.*PositionAF)+sum(ADL.*(EndADL-StartADL).*...
            (StartADL+(EndADL-StartADL)/2)))))];
    %REF found for above matrix, representing solutions for reactions
    SolvedReactionArray = rref(ReactionArray);
    fprintf('Rxn force R1 = %.2f where positive indicates upwards \n', SolvedReactionArray(1,3));
    fprintf('Rxn force R2 = %.2f where positive indicates upwards \n', SolvedReactionArray(2,3));
elseif BeamType == ('Cantilever')
    %if Cantilever, following array is created, where first row is net 
    %forces in y-direction and second row is net moment, in augmented 
    %matrix form
    ReactionArray = [1,0,(-1*(sum(AppliedForce, 'all')+...
            sum((ADL.*(EndADL-StartADL)))));...
            PositionRF(1),1,(-1*((sum(APM,'all')+...
            sum(AppliedForce.*PositionAF)+sum(ADL.*(EndADL-StartADL).*...
            (StartADL+(EndADL-StartADL)/2)))))];
    %REF found for above matrix, representing solutions for reactions
    SolvedReactionArray = rref(ReactionArray);
    fprintf('Rxn force R1 = %.2f where positive indicates upwards \n', SolvedReactionArray(1,3));
    fprintf('Rxn moment M1 = %.2f where positive indicates counterclockwise \n', SolvedReactionArray(2,3));
end
XSecType = string(XSecTypeArray(1));

%Calculating bending stress at a point
if XSecType == 'Rectangular'
    area = XSecDim(1,1) * XSecDim(2,1);
    inertia = 1/12 * XSecDim(1,1) * ((XSecDim(2,1))^3);
    polarInertia = -1;
    edge = XSecDim(2,1)/2;
elseif XSecType == 'Circular'
    area = 3.1415926 * ((XSecDim(1,1))^2);
    inertia = 3.1415926/4 * ((XSecDim(1,1))^4);
    polarInertia = 3.1415926/2 * ((XSecDim(1,1))^4);
    edge = XSecDim(1,1);
end
Moment = momentSumNew(BendingVars(1,1), ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL);
bendingStress = -1 * Moment * BendingVars(2,1) / inertia;
fprintf('The bending stress at the specified point is: %.2f\n(If no value was specified this is the bending stress at x = 0, y = 0)\n', bendingStress);

%Calculating shear stress at a point
Shear = shearSum(ShearVars(1,1), ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL);

if XSecType == 'Rectangular'
    shearStress = 3/2 * Shear / area;
elseif XSecType == 'Circular'
    shearStress = 4/3 * Shear / area;
end
fprintf('The shear stres at the specified point is: %.2f\n(If no value was specified this is the shear stress at x = 0)\n', shearStress);

%Calculating the maximum bending Stress
L = TorsionVars(2,1);
range = linspace(0,L,L*100);
allMoments = zeros(1,L*100);
for i = 1:(L*100)
    position = round(range(1,i),1);
    m = momentSumNew(position, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL);
    allMoments(1,i) = m;
end
maxM = max(allMoments);
minM = min(allMoments);
if abs(minM)>abs(maxM)
    maxMoment = minM;
else
    maxMoment = maxM;
end
maxBendingStress = -1 * maxMoment * edge / inertia;
fprintf('The maximum bending stress in the beam is %.2f \n', maxBendingStress);

%Calculating the maximum shear stress
allShears = zeros(1,L*100);
for i = 1:(L*100)
    position = range(1,i);
    s = shearSum(position, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL);
    allShears(1,i) = s;
end
maxShear = max(allShears);
if XSecType == 'Rectangular'
    maxShearStress = -3/2 * maxShear / area;
elseif XSecType == 'Circular'
    maxShearStress = -4/3 * maxShear / area;
end
fprintf('The maximum shear stress in the beam is %.2f \n', maxShearStress);
plot(range,allShears)
hold on
plot(range,allMoments)
plot(range,zeros(1,L*100))
hold off

%HW4 Code addition: torsion calculations

if XSecType == 'Circular'
    %R is the constant radius of circular cross section
    R = XSecDim(1);
    %J is polar moment calculated from radius, R
    J = pi()*(R^4)/2;

%creation of empty torsion array to set up for torsion calculations
    torsionArray = zeros(5,1);
    for i = 1:5
        if TorsionVars(1,1) >= PositionAT(i,1)
            torsionArray(i,1) = AxialTorque(i,1);
        end
    end
%^Need to change this so that it takes multiple torques and their positions
%into calculations, also think about multiple radii at different parts of
%the beam
    %Calculating torsional shear stress
    ShearStressTorsion = sum(torsionArray)*TorsionVars(1)/J;
    %Calculating angle of twist, in radians
    AngleTwist = sum(torsionArray)*TorsionVars(2)/Moduli(2)/J;
    %display torsional shear stress to 2 decimal places
    fprintf('The torsional shear stress at the specified point is: %.2f\n', ShearStressTorsion);
    %display angle of twist in radians to 4 decimal places
    fprintf('The angle of twist (in radians) of the beam at the specified point is: %.4f\n', AngleTwist);
end

%Work In Progress:
%Torsion calculations (shear, angle of twist) work currently only on one
%torque, and position is not taken into account yet in angle of twist
%calculations

%Next Steps:
%1. work on getting torsion calculations (shear, angle of twist) to work 
%for multiple torques at multiple placements along the beam

%2. move length of beam to somewhere earlier in spreadsheet (used in plots)
%and make necessary adjustments in referencing/naming of respective array