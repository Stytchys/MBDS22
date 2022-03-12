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
    'EndOfADL','AppliedPointMoment','PositionOfAPM'},'TreatAsMissing','');
opts.MissingRule = 'fill';
opts = setvaropts(opts,{'PositionOfRF_RM','AppliedForce', ...
    'PositionOfAF','AppliedDistributedLoad','StartOfADL', ...
    'EndOfADL','AppliedPointMoment','PositionOfAPM'},'FillValue',0);

%display table of values used
preview('MBD Problem Solver Input.xlsx',opts)

%assign variable vector names to data columns
[BeamType,ReactionType, PositionRF, AppliedForce, PositionAF, ADL, ...
    StartADL, EndADL, APM, PositionAPM] = readvars(...
    'MBD Problem Solver Input.xlsx',opts);

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

%part 2: find max bending and shear, probably use singularity equations





%FOR GRAPHING LATER ON IN THE PROJECT:
% %creation of integer array of numbers for length of beam
% array = linspace(0,(endLength))
% %endBC+1 as third term in 
% %q(x) = 
% V = R1*(array>x1)-200(array-4)-100*(x>10)-R2*(x>x2);
% plot (x,V)
% M(x) = R1*x-200*(array-4).*(array>4)-100*(x-10).*(x>10);
% plot (x,M)
    