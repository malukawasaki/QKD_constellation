clear all
close all

startTime = datetime(2020,9,19,02,55,0);              % 19 August 2020 8:55 PM UTC
stopTime = startTime + days(1);                       % 20 August 2020 8:55 PM UTC
sampleTime = 60;                                      % seconds
sc = satelliteScenario(startTime,stopTime,sampleTime,"AutoSimulate",false);

Sat_altitude = 8000e3; % meters


%sat_constellation = walkerDelta(sc,6.37814e+06+Sat_altitude,55,30,3,1);

%% Add GS

%%% GS in Europe

Tenerife_gs = groundStation(sc,lat = 28.2916, long = -16.6291,MinElevationAngle=10,Name="Tenerife");
Graz_gs = groundStation(sc, lat = 47.0766, long = 15.4213, MinElevationAngle=10,Name="Graz");
Oberpfaffenhofen_gs = groundStation(sc, lat = 48.0744, long = 11.2622, MinElevationAngle=10,Name="Oberpfaffenhofen");
Almeria_gs = groundStation(sc, lat = 36.8381, long = -2.4597, MinElevationAngle=10,Name="Almeria");
Nemea_gs = groundStation(sc, lat = 37.8206, long = 22.6610, MinElevationAngle=10,Name="Nemea");
Crete_gs = groundStation(sc, lat = 35.1558, long = 24.8950, MinElevationAngle=10,Name="Crete");
TheHague_gs = groundStation(sc, lat = 52.0706, long = 4.3129, MinElevationAngle=10,Name="TheHague");

GS_list = [Tenerife_gs,Graz_gs,Oberpfaffenhofen_gs,Almeria_gs,Nemea_gs,Crete_gs,TheHague_gs];
%%% GS in US

Hawaii_gs = groundStation(sc,lat = 18.9, long = -155.681, MinElevationAngle = 10, Name = "Hawaii");
WhiteSands_gs = groundStation(sc, lat = 32.7797, long = -106.1716, MinElevationAngle=10,Name="WhiteSands");
Wrightwood_gs = groundStation(sc, lat = 34.3534, long = -117.6241, MinElevationAngle=10,Name="Wrightwood");


for i_2 = 1:1

    Current_satellites =24;

    sat_constellation = walkerDelta(sc,6.37814e+06+Sat_altitude,55,Current_satellites,4,1);
    
    not_sucess = false;
                        
    advance(sc);


    for i_1 = 1:length(GS_list)

        for i_3 = 1:length(GS_list)-1
        
            if i_1 ~= i_3

                %while not_sucess == false

                    gsSource = GS_list(i_1);
                    gsTarget = Wrightwood_gs;

                    %% Determine elevation angles

                    % Calculate the scenario state corresponding to StartTime.

                    % Retrieve the elevation angle of each satellite with respect to the ground
                    % stations.
                    [~,elSourceToSat] = aer(gsSource,sat_constellation);
                    [~,elTargetToSat] = aer(gsTarget,sat_constellation);

                    % Determine the elevation angles that are greater than or equal to 30
                    % degrees.
                    elSourceToSatGreaterThanOrEqual30 = (elSourceToSat >= 10)';
                    elTargetToSatGreaterThanOrEqual30 = (elTargetToSat >= 10)';

                    %% Find best initial satellites

                    % Find the indices of the elements of elSourceToSatGreaterThanOrEqual30
                    % whose value is true.

                    trueID = find(elSourceToSatGreaterThanOrEqual30 == true);

                    % These indices are essentially the indices of satellites in sat whose
                    % elevation angle with respect to "Source Ground Station" is at least 30
                    % degrees. Determine the range of these satellites to "Target Ground
                    % Station".
                    [~,~,r] = aer(sat_constellation(trueID), gsTarget);

                    % Determine the index of the element in r bearing the minimum value.
                    [~,minRangeID] = min(r);

                    % Determine the element in trueID at the index minRangeID.
                    id = trueID(minRangeID);

                    % This is the index of the best satellite for initial access to the
                    % constellation. This will be the first hop in the path. Initialize a
                    % variable 'node' that stores the first two nodes of the routing - namely,
                    % "Source Ground Station" and the best satellite for initial constellation
                    % access.
                    nodes = {gsSource sat_constellation(id)};

                    %% Determine remanining nodes

                    earthRadius = 6378137;                                                   % meters
                    altitude = Sat_altitude;                                                       % meters
                    horizonElevationAngle = asind(earthRadius/(earthRadius + altitude)) - 90; % degrees

                    % Minimum elevation angle of satellite nodes with respect to the prior
                    % node.
                    minSatElevation = -15; % degrees

                    % Flag to specify if the complete multi-hop path has been found.
                    pathFound = false;


                    % Determine nodes of the path in a loop. Exit the loop once the complete
                    % multi-hop path has been found.

                    ISL_numbers = 0;

                    while (pathFound == false & not_sucess == false)

                        % Index of the satellite in sat corresponding to current node is
                        % updated to the value calculated as index for the next node in the
                        % prior loop iteration. Essentially, the satellite in the next node in
                        % prior iteration becomes the satellite in the current node in this
                        % iteration.

                        idCurrent = id;
                        

                        % This is the index of the element in elTargetToSatGreaterThanOrEqual30
                        % tells if the elevation angle of this satellite is at least 30 degrees
                        % with respect to "Target Ground Station". If this element is true, the
                        % routing is complete, and the next node is the target ground station.
                        if elTargetToSatGreaterThanOrEqual30(idCurrent)
                            nodes = {nodes{:} gsTarget}; %#ok<CCAT>
                            pathFound = true;
                            continue
                        end

                        % If the element is false, the path is not complete yet. The next node
                        % in the path must be determined from the constellation. Determine
                        % which satellites have elevation angle that is greater than or equal
                        % to -15 degrees with respect to the current node. To do this, first
                        % determine the elevation angle of each satellite with respect to the
                        % current node.
                        [~,els] = aer(sat_constellation(idCurrent),sat_constellation);

                        % Overwrite the elevation angle of the satellite with respect to itself
                        % to be -90 degrees to ensure it does not get re-selected as the next
                        % node.
                        els(idCurrent) = -90;

                        % Determine the elevation angles that are greater than or equal to -15
                        % degrees.
                        s = els >= minSatElevation;

                        % Find the indices of the elements in s whose value is true.
                        trueID = find(s == true);

                        % These indices are essentially the indices of satellites in sat whose
                        % elevation angle with respect to the current node is greater than or
                        % equal to -15 degrees. Determine the range of these satellites to
                        % "Target Ground Station".
                        [~,~,r] = aer(sat_constellation(trueID), gsTarget);

                        % Determine the index of the element in r bearing the minimum value.
                        [~,minRangeID] = min(r);

                        % Determine the element in trueID at the index minRangeID.
                        id = trueID(minRangeID);

                        % This is the index of the best satellite among those in sat to be used
                        % for the next node in the path. Append this satellite to the 'nodes'
                        % variable.
                        nodes = {nodes{:} sat_constellation(id)}; %#ok<CCAT>

                        ISL_numbers = ISL_numbers + 1

                        if ISL_numbers > 100
                            not_sucess = true;
                            failure_case = [Current_satellites,gsSource,gsTarget];
                            break
                        end

                    end

                %end
            
            
            end

        end
    
    end

end

%%

sc.AutoSimulate = true;

ac = access(nodes{:});
ac.LineColor = "red";

intvls = accessIntervals(ac);

v = satelliteScenarioViewer(sc,"ShowDetails",false);
sat_constellation.MarkerSize = 6; % Pixels
campos(v,60,5);     % Latitude and longitude in degrees

%play(sc);
