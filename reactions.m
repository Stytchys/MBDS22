function reactionCalc = reactions(R, V, S, CM, p_list, Rp_list, Cm_list)
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
        rxn1 = -1 * netLoadY;
        rxn2 = -1 * netLoadX;
        rxnMoment = -1 * momentSum;
    else
        bMatrix(2,1) = momentSum/(Rp_list(2,1) - Rp_list(1,1));
        irxnMatrix = inv(rxnMatrix);
        a = irxnMatrix * bMatrix;
        rxn1 = a(1,1);
        rxn2 = a(2,1);
        rxnMoment = 0;
        rxn3 = -1 * netLoadX;
    end
    reactionCalc = [rxn1, rxn2, rxn3, rxnMoment];
end