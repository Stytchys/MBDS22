%Function to calculate the shear as summed before a specific x-value along
%the beam
function shearCalc = shearSum(x, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL)
    %Making an array with the reaction forces and their positions
    reactionArray = zeros(3,2);
    %making an array to hold the distributed loads and their positions
    distributedLoadArray = zeros(5,3);
    %making an array to hold the point loads and their positions
    pointLoadArray = zeros(5,2);
    %making an array to hold the point moments and their positions
    pointMomentArray = zeros(5,2);
    %rounding out the input value
    x = round(x,2);
    %populating the reaction force array
    if BeamType == ("Simply Supported Beam")
        reactionArray(1,1) = SolvedReactionArray(1,3);
        reactionArray(2,1) = SolvedReactionArray(2,3);
        reactionArray(1,2) = PositionRF(1,1);
        reactionArray(2,2) = PositionRF(2,1);
    elseif BeamType == ("Cantilever")
        reactionArray(1,1) = SolvedReactionArray(1,3);
        reactionArray(1,2) = PositionRF(1,1);
        reactionArray(3,1) = SolvedReactionArray(2,3);
        reactionArray(3,2) = PositionRF(1,1);
    end
    %populating the distributed load array
    for i = 1:5
        distributedLoadArray(i,1) = ADL(i,1);
        distributedLoadArray(i,2) = StartADL(i,1);
        distributedLoadArray(i,3) = EndADL(i,1);
    end
    %populating the point load array
    for i = 1:5
        pointLoadArray(i,1) = AppliedForce(i,1);
        pointLoadArray(i,2) = PositionAF(i,1);
    end
    %Initialize the shear as 0
    shearSum = 0;
    %Sum the shear of the reaction forces if they are before the position x
    for i = 1:2
        if x > reactionArray(i,2)
            shearSum = shearSum + reactionArray(i,1);
        end
    end
    %Sum the shear of the distributed loads if they are before x
    for i = 1:5
        if x > distributedLoadArray(i,2)
            l = round(x,1) - distributedLoadArray(i,2);
            load = l * distributedLoadArray(i,1);
            shearSum = shearSum + load;
        end
    end
    %Sum the shear of the point loads before x
    for i = 1:5
        if x > pointLoadArray(i,2)
            shearSum = shearSum + pointLoadArray(i,1);
        end
    end
    shearCalc = shearSum;
end