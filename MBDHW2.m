R = input('Number of Reaction forces: ');
V = input('How many of the above Rxn forces are vertical?: ');
L = input('Length of Beam: ');
S = input('Number of applied loads on the beam (not including Rxn Forces): ');
CM = input('Number of concentrated moments on the beam: ');

fprintf('\n');

p_list = zeros(S,8);
Rp_list = zeros(R,4);
Cm_list = zeros(CM,2);
cmMag = 0;
cmDir = 0;

if CM ~= 0
    for i = 1:CM
        cmMag = input('Input the magnitude of the concentrated moment: ');
        cmPrompt = input('Input "cw" for clockwise or "cc" for counterclockwise: ', 's');
        Cm_list(i,1) = cmMag;
        if cmPrompt == 'cw'
            cmDir = 1;
        elseif cmPrompt == 'cc'
            cmDir = 0;
        end
        Cm_list(i,2) = cmDir;
        fprintf('\n');
    end
end

for i = 1:R
    if i == 1
        fprintf('For the first vertical Rxn Force...\n');
    elseif i < V || i == V
        fprintf('For the next vertical Rxn Force...\n');
    else
        fprintf('For the horizontal Rxn Force...\n');
    end
    d = input('Is the force in the x or y direction (type either "x" or "y"): ', 's');
    if d == 'x'
        y1 = input('Input the distance along the y-axis that the force starts: ');
        y2 = input('Input the length across which the force is acting (if point force, input "-1"): ');
        x1 = 0;
        x2 = 0;
    elseif d == 'y'
        x1 = input('Input the distance along the x-axis that the force is located: ');
        x2 = input('Input the length across which the force is acting (if point force input "-1"): ');
        y1 = 0;
        y2 = 0;
    end
    Rp_list(i,1) = x1;
    Rp_list(i,2) = x2;
    Rp_list(i,3) = y1;
    Rp_list(i,4) = y2;
    fprintf('\n');  
end

for i = 1:S
    x1 = -1;
    y1 = -1;
    x2 = -1;
    y2 = -1;
    xSign = 1;
    ySign = 1;
    angle = 0;
    if i == 1
        fprintf('For the first Load...\n');
    else
        fprintf('For the next Load...\n');
    end
    Mag = input('What is the magnitude of the load (if distributed input the load/distance): ');
    D = input('How many directions does the Load act in (1 or 2)?: ');
    if D == 1
        d = input('Is the Load in the x or y direction (type either "x" or "y"): ', 's');
        signCheck = input('Is the load in the positive direction? (input "y" or "n"): ', 's');
        if d == 'x'
            if signCheck == 'y'
                xSign = 1;
            elseif signCheck == 'n'
                xSign = 0;
            end
            y1 = input('Input the distance along the y-axis that the load starts: ');
            y2 = input('Input the length along the y-axis that the load acts (if point force input "-1"): ');
        elseif d=='y'
            if signCheck == 'y'
                ySign = 1;
            elseif signCheck == 'n'
                ySign = 0;
            end
            x1 = input('Input the distance along the x-axis that the load starts: ');
            x2 = input('Input the length along the x-axis that the loads acts (if point force input "-1"): ');
        end
    elseif D == 2
        xSignCheck = input('Is the load in the positive x-direction? (input "y" or "n"): ', 's');
        ySignCheck = input('Is the load in the positive y-direction? (input "y" or "n"): ', 's');
        angle = input('At what angle from the horizontal is the load applied (in degrees): ');
        if xSignCheck == 'y'
            xSign = 1;
        elseif xSignCheck == 'n'
            xSign = 0;
        end
        if ySignCheck == 'y'
            ySign = 1;
        elseif ySignCheck == 'n'
            ySign = 0;
        end
        x1 = input('Input the distance along the x-axis that the load starts: ');
        x2 = input('Input the length along the x-axis that the load acts (if point force input "-1"): ');
        y1 = input('Input the distance along the y-axis that the load starts: ');
        y2 = input('Input the length along the y-axis that the load acts (if point force input "-1"): ');
    end
    p_list(i,1) = Mag;
    p_list(i,2) = x1;
    p_list(i,3) = x2;
    p_list(i,4) = y1;
    p_list(i,5) = y2;
    p_list(i,6) = xSign;
    p_list(i,7) = ySign;
    p_list(i,8) = angle;
    fprintf('\n');
end

netLoadX = 0;
netLoadY = 0;
for i = 1:S
    if p_list(i,8) ~= 0
        magX = p_list(i,1) * cos(p_list(i,8));
        magY = p_list(i,1) * sin(p_list(i,8));
        if p_list(i,6) == 1
            magX = magX * 1;
        elseif p_list(i,6) == 0
            magX = magX * -1;
        end
        if p_list(i,7) == 1
            magY = magY * 1;
        elseif p_list(i,7) == 0
            magY = magY * -1;
        end
        if p_list(i,3) ~= -1
            netLoadY = netLoadY + (magY * p_list(i,3));
        elseif p_list(i,3) == -1
            netLoadY = netLoadY + magY;
        end
        if p_list(i,5) ~= -1
            netLoadX = netLoadX + (magX * p_list(i,5));
        elseif p_list(i,5) == -1
            netLoadX = netLoadX + magX;
        end
    elseif p_list(i,8) == 0
        if p_list(i,2) ~= -1
            if p_list(i,3) == -1
                if p_list(i,7) == 1
                    netLoadY = netLoadY + p_list(i,1);
                elseif p_list(i,7) == 0
                    netLoadY = netLoadY - p_list(i,1);
                end
            elseif p_list(i,3) ~= -1
                if p_list(i,7) == 1
                    netLoadY = netLoadY + (p_list(i,1) * p_list(i,3));
                elseif p_list(i,7) == 0
                    netLoadY = netLoadY - (p_list(i,1) * p_list(i,3));
                end
            end
        elseif p_list(i,4) ~= -1
            if p_list(i,5) == -1
                if p_list(i,6) == 1
                    netLoadX = netLoadX + p_list(i,1);
                elseif p_list(i,6) == 0
                    netLoadX = netloadX - p_list(i,1);
                end
            elseif p_list(i,5) ~= -1
                if p_list(i,6) == 1
                    netLoadX = netLoadX + (p_list(i,1) * p_list(i,5));
                elseif p_list(i,6) == 0
                    netLoadX = netLoadX - (p_list(i,1) * p_list(i,5));
                end
            end
        end
    end   
end

Rx = 0;
Ry = 0;
for i = 1:R
    if Rp_list(i,1) ~= 0
        Rx = Rx + 1;
    end
    if Rp_list(i,3) ~= 0
        Ry = Ry + 1;
    end
end

fprintf('The sum of the loads in the y-direction is: %.2f \n', netLoadY);
fprintf('The sum of the loads in the x-direction is: %.2f \n', netLoadX);
rxnMatrix = [1 , 1 ; 0 , 1];
bMatrix = zeros(2,1);
bMatrix(1,1) = -netLoadY;

load_list = zeros(S,6);
for i = 1:S
    LoadX = 0;
    LoadY = 0;
    if p_list(i,8) ~= 0
        magX = p_list(i,1) * cos(p_list(i,8));
        magY = p_list(i,1) * sin(p_list(i,8));
        if p_list(i,6) == 1
            magX = magX * 1;
        elseif p_list(i,6) == 0
            magX = magX * -1;
        end
        if p_list(i,7) == 1
            magY = magY * 1;
        elseif p_list(i,7) == 0
            magY = magY * -1;
        end
        if p_list(i,3) ~= -1
            LoadY = magY * p_list(i,3);
        elseif p_list(i,3) == -1
            LoadY = magY;
        end
        if p_list(i,5) ~= -1
            LoadX = magX * p_list(i,5);
        elseif p_list(i,5) == -1
            LoadX = magX;
        end
    elseif p_list(i,8) == 0
        if p_list(i,2) ~= -1
            if p_list(i,3) == -1
                if p_list(i,7) == 1
                    LoadY = p_list(i,1);
                elseif p_list(i,7) == 0
                    LoadY = -1 * p_list(i,1);
                end
            elseif p_list(i,3) ~= -1
                if p_list(i,7) == 1
                    LoadY = p_list(i,1) * p_list(i,3);
                elseif p_list(i,7) == 0
                    LoadY = -1 * (p_list(i,1) * p_list(i,3));
                end
            end
        elseif p_list(i,4) ~= -1
            if p_list(i,5) == -1
                if p_list(i,6) == 1
                    LoadX = p_list(i,1);
                elseif p_list(i,6) == 0
                    LoadX = -1 * p_list(i,1);
                end
            elseif p_list(i,5) ~= -1
                if p_list(i,6) == 1
                    LoadX = (p_list(i,1) * p_list(i,5));
                elseif p_list(i,6) == 0
                    LoadX = -1 * (p_list(i,1) * p_list(i,5));
                end
            end
        end
    end
    load_list(i,1) = LoadX;
    load_list(i,2) = LoadY;
    load_list(i,3) = p_list(i,2);
    load_list(i,4) = p_list(i,3);
    load_list(i,5) = p_list(i,4);
    load_list(i,6) = p_list(i,5);
end

momentSum = 0;
for i = 1:S
    xpos = Rp_list(1,1);
    ypos = Rp_list(1,3);
    xload = 0;
    yload = 0;
    xdist = 0;
    ydist = 0;
    if load_list(i,4) == -1 && load_list(i,6) == -1
        xdist = (load_list(i,3) - xpos);
        ydist = (load_list(i,5) - ypos);
        xload = load_list(i,1);
        yload = load_list(i,2);
    elseif load_list(i,4) ~= -1
        center = load_list(i,3) + ((1/2) * load_list(i,4));
        xdist = center - xpos;
        yload = load_list(i,2);
    end
    momentSum = momentSum - (xload * ydist) - (yload * xdist);
end

if CM ~= 0
    for i = 1:CM
        if Cm_list(i,2) == 1
            momentSum = momentSum + Cm_list(i,1);
        elseif Cm_list(i,2) == 0
            momentSum = momentSum - Cm_list(i,1);
        end
    end
end

if V == 1
    fprintf('Rxn Force "Y" is: %.2f \n', (-1 * netLoadY));
    fprintf('The reaction moment is: %.2f \n', -momentSum);
else
    bMatrix(2,1) = momentSum/(Rp_list(2,1) - Rp_list(1,1));
    irxnMatrix = inv(rxnMatrix);
    a = irxnMatrix * bMatrix;
    fprintf('Rxn Force 1 is: %.2f \n', a(1,1));
    fprintf('Rxn Force 2 is: %.2f \n', a(2,1));
    rxn3 = -1 * netLoadX;
    fprintf('Horizontal Rxn Force is: %.2f \n', rxn3);
end
