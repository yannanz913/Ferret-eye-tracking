function [E,err] = find_selfEyeModel(E_in, L, C)
% eyet.test.find_selfEyeModel - use a full model of cameras, lights, eye, to simulate and re-fit the eye model
%
% [E,err] = eyet.find_selfEyeModel(Ein, L, C)
%
% Given an EyeModel Ein, light model L, and CameraModel C, calculate the view through the system and
% use the calculated views to fit a new EyeModel E. The error between the views through the initial model
% and the final model is returned in err.
%
% Example:
%    model = eyet.test.simpleshift(); % generate basic model
%    [newE, err] = eyet.test.find_selfEyeModel(model.E,model.L,model.C);
%    model_fit = eyet.compute_model(model.C,newE,model.L,0); % without plotting
%    eyet.compare_models(model,model_fit);
%    disp(['Sum of squared error is ' num2str(err) '.']);
%    

 % Step 1: calculate the view through the model input system to get its views

modelcomp = eyet.compute_model(C,E_in,L,0); % compute model without plotting

 % Step 2: fit the eye model given the views through the simulated model

[E,E_guess,err] = eyet.fit.find_eyemodel(modelcomp.camera_landmarks,C,L);

