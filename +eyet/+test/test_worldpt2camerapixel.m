function test_worldpt2camerapixel()
% eyet.test.test_worldpt2camerapixel - test the new method worldpt2camerapixel in eyet.CameraModel
% 

output = eyet.test.simpleshift();

pupil_center = output.E.pupil.e.center; % this is where the pupil is
top_mark = output.E.top.e.center; % this is where the top mark is
left_mark = output.E.left.e.center; % this is where the left mark is

correct{1,1} = [58 58];
correct{1,2} = [52 35];
correct{1,3} = [78 41];
correct{2,1} = [33 58];
correct{2,2} = [39 35];
correct{2,3} = [62 38];

for i=1:2,
	disp(['Testing camera ' int2str(i)]);

	disp(['Should be about ' mat2str(correct{i,1}) ]);
	pupil_pix = output.C(i).worldpt2camera(pupil_center) 

	disp(['Should be about ' mat2str(correct{i,2}) ]);
	top_pix = output.C(i).worldpt2camera(top_mark) 

	disp(['Should be about ' mat2str(correct{i,3}) ]);
	left_pix = output.C(i).worldpt2camera(left_mark) 

end;
