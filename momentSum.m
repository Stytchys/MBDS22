%Function to calculate the moment as summed about a specific x-value along
%the beam
function momentCalc = momentSum(x, ADL, APM, AppliedForce, BeamType, EndADL, PositionAF, PositionAPM, PositionRF, SolvedReactionArray, StartADL)
    %Making an array with the reaction forces and their positions
    reactionArray = zeros(3,2);
    %making an array to hold the distributed loads and their positions
    distributedLoadArray = zeros(5,3);
    %making an array to hold the point loads and their positions
    pointLoadArray = zeros(5,2);
    %making an array to hold the point moments and their positions
    pointMomentArray = zeros(5,2);
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
    %Initializing a running sum of moment about position x
    momentSum = 0;
    for i = 1:3
        %sets r as the distance between the reaction and x (negative if
        %reaction is left of the position x)
        r = reactionArray(i,2) - x;
        %determining the moment caused by that reaction force (positive
        %indicates clockwise)
        m = r * reactionArray(i,1);
        %add the moment to the running total
        momentSum = momentSum + m
    end
    %fill an array with all of the information pertaining to distributed
    %loads
    for i = 1:5
        distributedLoadArray(i,1) = ADL(i,1);
        distributedLoadArray(i,2) = StartADL(i,1);
        distributedLoadArray(i,3) = EndADL(i,1);
    end
    %adding the moments applied by distributed loads to the list running
    %sum about position x
    for i = 1:5
        %Calculate moment about x when the distributed load is entirely
        %after the position x
        if x < distributedLoadArray(i,2)
            l = distributedLoadArray(i,3) - distributedLoadArray(i,2);
            c = (l/2) + distributedLoadArray(i,2);
            r = c - x;
            m = r * distributedLoadArray(i,1) * l;
            momentSum = momentSum + m
        %calculate moment about x when the position x is within the length
        %of the distributed load
        elseif x > distributedLoadArray(i,2) && x < distributedLoadArray(i,3)
            l1 = x - distributedLoadArray(i,2);
            c1 = (l1/2) + distributedLoadArray(i,2);
            r1 = c1 - x;
            m = r1 * distributedLoadArray(i,1) * l1;
            momentSum = momentSum + m;
            l2 = distributedLoadArray(i,3) - x;
            c2 = (l2/2) + x;
            r2 = c2 - x;
            m = r2 * distributedLoadArray(i,1) * l2;
            momentSum = momentSum + m
        %calculate moment about x when the distributed load is entirely
        %before the position x
        elseif x < distributedLoadArray(i,3)
            l = distributedLoadArray(i,3) - distributedLoadArray(i,2);
            c = l/2 + distributedLoadArray(i,2);
            r = c - x;
            m = r * distributedLoadArray(i,1) * l;
            momentSum = momentSum + m
        end
    end
    %populate the point load data array
    for i = 1:5
        pointLoadArray(i,1) = AppliedForce(i,1);
        pointLoadArray(i,2) = PositionAF(i,1);
    end
    %Calculate moment about x due to applied point loads
    for i = 1:5
        r = pointLoadArray(i,2) - x;
        m = r * pointLoadArray(i,1);
        momentSum = momentSum + m
    end
    for i = 1:5
        pointMomentArray(i,1) = APM(i,1);
        pointMomentArray(i,2) = PositionAPM(i,1);
    end
    for i = 1:5
        %Only adding concentrated moments to the moment sum if the
        %concentrated moment is located before the position x
        if x > pointMomentArray(i,2)
            momentSum = momentSum - pointMomentArray(i,1)
        end
    end
    momentCalc = momentSum;
end