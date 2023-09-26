close all
clear all

startTime = datetime(2020,8,19,14,55,0);              % 19 August 2020 8:55 PM UTC
stopTime = startTime + days(1);                       % 20 August 2020 8:55 PM UTC
sampleTime = 60;                                      % seconds
sc = satelliteScenario(startTime,stopTime,sampleTime);

Sat_altitude = 8000e3; % meters


sat_constellation = walkerDelta(sc,Sat_altitude + 6.37814e+06,60,18,3,1);

Vienna_gs = groundStation(sc,lat = 48.2082, long = 16.37,MinElevationAngle=10,Name="Vienna");

names = sat_constellation.Name + " Camera";
cam = conicalSensor(sat_constellation,"Name",names,"MaxViewAngle",90);


fov = fieldOfView(cam);

ac2 = access(cam,Vienna_gs);
intvls2 = accessIntervals(ac2);


satelliteScenarioViewer(sc, ShowDetails=false);


