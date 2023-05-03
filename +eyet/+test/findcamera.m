function findcamera()
% eyet.test.findcamera - test the new function eyet.fit.findcamera

output = eyet.test.simpleshift();

pupil_center = output.E.pupil.e.center; % this is where the pupil is
top_mark = output.E.top.e.center; % this is where the top mark is
left_mark = output.E.left.e.center; % this is where the left mark is
right_mark = output.E.right.e.center; % this is where the right mark is
bottom_mark = output.E.bottom.e.center;

correct{1}(:,1) = [58 58]';
correct{1}(:,2) = [52 35]';
correct{1}(:,3) = [78 41]';
correct{1}(:,4) = [36 67]';
correct{1}(:,5) = [58 67]';
correct{2}(:,1) = [33 58]';
correct{2}(:,2) = [39 35]';
correct{2}(:,3) = [62 38]';
correct{2}(:,4) = [26 65]';
correct{2}(:,5) = [53.5 68]';

worldmarks = [ pupil_center top_mark left_mark right_mark bottom_mark];

initial_position_guess = [ [ 50; -40; 10]  [ 50; -20; 10] ];
initial_angle_guess = [ vlt.math.deg2rad([-45 0 180])' vlt.math.deg2rad([45 0 180])' ];
mag = 250;

pixelsX = 100;
pixelsY = 100;

for i=1:2,
	disp(['Fitting camera ' int2str(i)]);

    C(i) = eyet.fit.find_camera(worldmarks,correct{i},initial_position_guess(:,i),initial_angle_guess(:,i),250, ...
        'pixelsX',pixelsX,'pixelsY',pixelsY,'search_Magnification',0);

    disp(['comparison'])

    figure;
    eyet.plot.system(output.C(i),output.E,output.L);
    hold on;
    C(i).plot;
end;

