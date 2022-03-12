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
    R1 = SolvedReactionArray(1,3)
    disp('upwards')
    R2 = SolvedReactionArray(2,3)
    disp('upwards')
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
    R1 = SolvedReactionArray(1,3)
    disp('upwards')
    M1 = SolvedReactionArray(2,3)
    disp('counterclockwise')
end


%Calculating bending stress at a point
if crossSection == 'rectangle'
    area = b * h;
    inertia = 1/12 * b * (h^3);
    polarInertia = -1;
    edge = h/2;
elseif crossSection == 'circle'
    area = 3.1415926 * (r^2);
    inertia = 3.1415926/4 * (r^4);
    polarInertia = 3.1415926/2 * (r^4);
    edge = r;
end
Moment = momentSum(x, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray);
bendingStress = -1 * Moment * y / inertia;
fprintf('The bending stress at the specified point is: %.2f \n (If no value was specified this is the bending stress at x = 0, y = 0)', bendingStress);

%Calculating shear stress at a point
Shear = shearSum(x, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray);

if crossSection == 'rectangle'
    shearStress = 3/2 * Shear / area;
elseif crossSection == 'circle'
    shearStress = 4/3 * Shear / area;
end
fprintf('The shear stres at the specified point is: %.2f \n (If no value was specified this is the shear stress at x = 0', shearStress);

%Calculating the maximum bending Stress
range = linspace(0,L,L*100);
allMoments = zeros(1,L*100);
for i = 1:(L*100)
    position = range(1,i);
    m = momentSum(position, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray);
    allMoments(1,i) = m;
end
maxMoment = max(allMoments);
maxBendingStress = -1 * maxMoment * edge / inertia;
fprintf('The maximum bending stress in the beam is %.2f \n', maxBendingStress);

%Calculating the maximum shear stress
allShears = zeros(1,L*100);
for i = 1:(L*100)
    position = range(1,i);
    s = shearSum(position, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray);
    allShears(1,i) = s;
end
maxShear = max(allShears);
if crossSection == 'rectangle'
    maxShearStress = 3/2 * maxShear / area;
elseif crossSection == 'circle'
    maxShearStress = 4/3 * maxShear / area;
end
fprintf('The maximum shear stress in the beam is %.2f \n', maxShearStress);

%HW4 Code: torsion

XSecType = string(XSecTypeArray(1));
if XSecType == 'Circular'
    %R is the constant, set radius of circular cross section
    R = XSecDim(1);
    %J is polar moment calculated from R
    J = pi()*(R^4)/2;
    %Calculating torsional shear stress
    ShearStressTorsion = sum(AxialTorque)*TorsionVars(1)/J
    %Calculating angle of twist, in radians
    AngleTwist = sum(AxialTorque)*TorsionVars(2)/Moduli(2)/J
end