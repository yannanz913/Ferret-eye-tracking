function output = compare_led_2cameraarray()
% eyet.test.compare_led_2cameraarray - compare two methods of building a camera array
%
% OUTPUT = eyet.test.compare_led_2cameraarray()
%
%

eye_center = [40;-30;10];

mag = 250;
P = [10;0;0]+eye_center;

[L,C]=eyet.systems.led_2camera_arrayB(P,[0 0 0],mag,1);
[La,Ca]=eyet.systems.led_2camera_arrayBalt(P,mag,1);

figure;
subplot(2,2,1);
C(1).plot();
hold on
C(2).plot();
xlabel('x'); ylabel('y'); zlabel('z'); axis equal;
subplot(2,2,2);
Ca(1).plot();
Ca(2).plot();
hold on;

xlabel('x'); ylabel('y'); zlabel('z'); axis equal;

output = vlt.data.workspace2struct();


