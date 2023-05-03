function [err,model,model_fit] = run_selfEyeModel()
% eyet.test.run_selfEyeModel - use a full model of cameras, lights, eye, to simulate and re-fit the eye model
%
% [err] = eyet.run_selfEyeModel()
%
% Creates an EyeModel E, light model L, and CameraModel C, and calculates the view through the system and
% use the calculated views to fit a new EyeModel E. The error between the views through the initial model
% and the final model is returned in err. This function tests and demonstrates eyet.find_selfEyeModel().
%

eye_rotation = [10*randn;10*randn;0];
eye_center = [40;-30;10];
pupil_azimuth_angle = randn*25;
pupil_elevation_angle = randn*25;

E = eyet.EyeModel('eye_rotation',eye_rotation,'eye_center',eye_center,'pupil_azimuth_angle',pupil_azimuth_angle,...
	'pupil_elevation_angle',pupil_elevation_angle); 

[L,C] = eyet.systems.led_2camera_arrayB([10;0;0]+eye_center,[0 0 0],250,1);

model = eyet.compute_model(C,E,L,0);
[newE, err] = eyet.test.find_selfEyeModel(model.E,model.L,model.C);
model_fit = eyet.compute_model(model.C,newE,model.L,0); % without plotting
eyet.compare_models(model,model_fit);

disp(['Sum of squared error is ' num2str(err) '.']);
disp(['Eye rotations (actual, fit):' mat2str(E.eye.rotation) ' -- ' mat2str(newE.eye.rotation) ]);
disp(['Eye center (actual, fit):' mat2str(E.eye.center) ' -- ' mat2str(newE.eye.center) ]);
disp(['Eye radii (actual, fit):' mat2str(E.eye.radii) ' -- ' mat2str(newE.eye.radii) ]);
disp(['Pupil elevation (actual, fit): ' num2str(E.pupil.elevation) ' -- ' num2str(newE.pupil.elevation) ]);
disp(['Pupil azimuth (actual, fit): ' num2str(E.pupil.azimuth) ' -- ' num2str(newE.pupil.azimuth) ]);

