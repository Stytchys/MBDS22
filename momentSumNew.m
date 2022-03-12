%Function to calculate the moment as summed about a specific x-value along
%the beam
function momentCalc = momentSumNew(x, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL)
    %Making an array with the reaction forces and their positions
    reactionArray = zeros(3,2);
    %making an array to hold the distributed loads and their positions
    distributedLoadArray = zeros(5,3);
    %making an array to hold the point loads and their positions
    pointLoadArray = zeros(5,2);
    %making an array to hold the point moments and their positions
    pointMomentArray = zeros(5,2);
    %making an array to hold the positions of everything
    positionArray = zeros(19,2);
    %populating the reaction force array
    if BeamType == ("Simply Supported Beam")
        if x >= PositionRF(1,1)
            reactionArray(1,1) = SolvedReactionArray(1,3);
            reactionArray(1,2) = PositionRF(1,1);
        end
        if x >= PositionRF(2,1)
            reactionArray(2,1) = SolvedReactionArray(2,3);
            reactionArray(2,2) = PositionRF(2,1);
        end
    elseif BeamType == ("Cantilever")
        if x >= PositionRF(1,1)
            reactionArray(1,1) = SolvedReactionArray(1,3);
            reactionArray(1,2) = PositionRF(1,1);
            reactionArray(3,1) = SolvedReactionArray(2,3);
            reactionArray(3,2) = PositionRF(1,1);
        end
    end 

    %populating the distributed load array
    for i = 1:5
        if x > StartADL(i,1)
            distributedLoadArray(i,1) = ADL(i,1);
            distributedLoadArray(i,2) = StartADL(i,1);
            distributedLoadArray(i,3) = EndADL(i,1);
        end
    end
    %populating the point load array
    for i = 1:5
        if x > PositionAF(i,1)
            pointLoadArray(i,1) = AppliedForce(i,1);
            pointLoadArray(i,2) = PositionAF(i,1);
        end
    end
    %populating the point moment array
    for i = 1:5
        if x > PositionAPM(i,1)
            pointMomentArray(i,1) = APM(i,1);
            pointMomentArray(i,2) = PositionAPM(i,1);
        end
    end
    for i = 1:3
        positionArray(i+1,1) = reactionArray(i,2);
    end
    for i = 1:5
        positionArray(i+4,1) = distributedLoadArray(i,2);
        positionArray(i+4,2) = distributedLoadArray(i,3);
    end
    for i = 1:5
        positionArray(i+9,1) = pointLoadArray(i,2);
    end
    for i = 1:5
        positionArray(i+14,1) = pointMomentArray(i,2);
    end
    uniquePosArray = unique(positionArray);
    
    %Initialize Moment sum
    pos = round(x*100)+1;
    range = linspace(0,x,pos);
    allShears = zeros(1,pos);
    allMoments = zeros(1,pos);
    [posSize,irrel] = size(uniquePosArray);
    for i = 1:pos
        position = range(1,i);
        s = shearSum(position, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL);
        allShears(1,i) = s;
    end
    for i = 1:posSize - 1
        tempPos = uniquePosArray(i+1,1);
        if x < tempPos
            allMoments(1,i) = allShears(1,i) * (x-uniquePosArray(i,1));
        end
    end
    plot(range,allMoments)
    pointMoment = allMoments(1,pos);
    momentCalc = pointMoment;
end