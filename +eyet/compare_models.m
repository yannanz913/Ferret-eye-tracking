function compare_models(model_target, model_fit);
% eyet.compare_models - compare a model system with its fit
%
% eyet.compare_models(MODEL_TARGET, MODEL_FIT)
%
% Given a target model returned from eyet.compute_model or eyet.empirical_model and a
% fit of a model, plot a side-by-side comparison of the camera views.
%
% Example:
%    model_target = eyet.test.simpleshift(); % generate basic model
%    [newE, err] = eyet.test.find_selfEyeModel(model_target.E,model_target.L,model_target.C);
%    
%    

 % Step 1: calculate the view through the model input system to get its views

figure;
subplot(2,2,1);
eyet.plot.image(model_target.cameraimages.image{1},model_target.cameraimages.cmap); 
ax1 = gca;
title(['Camera 1: View through the actual system']);

subplot(2,2,2);
eyet.plot.image(model_fit.cameraimages.image{1},model_fit.cameraimages.cmap);
ax2 = gca;
title(['Camera 1: View through the found system']);

subplot(2,2,3);
eyet.plot.image(model_target.cameraimages.image{2},model_target.cameraimages.cmap);
ax3 = gca;
title(['Camera 2: View through the actual system']);

subplot(2,2,4);
eyet.plot.image(model_fit.cameraimages.image{2},model_fit.cameraimages.cmap);
ax4 = gca;
title(['Camera 2: View through the found system']);

linkaxes([ax1 ax2]);
linkaxes([ax3 ax4]);


