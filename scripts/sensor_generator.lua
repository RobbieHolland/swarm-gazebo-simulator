n = 15
--[[
print('fov: ' .. 1/100000 * math.floor(100000 * math.pi/n + 0.5))
for i=1, n do
	print('sensor ' .. i .. ' : ' .. 1/100000 * math.floor(100000 * (math.pi/2 - ((2*(i-1) + 1)*math.pi)/(2*n)) + 0.5) )
end
--]]

fov = 1/100000 * math.floor(100000 * math.pi/n + 0.5)
for i=1, n do
	angle = 1/100000 * math.floor(100000 * (math.pi/2 - ((2*(i-1) + 1)*math.pi)/(2*n)) + 0.5)
	print (	'<sensor name="colour_sensor_' .. i .. '" type="camera">\n' ..
					'  <camera>\n'..
					'    <horizontal_fov>' .. fov .. '</horizontal_fov>\n'..
					'    <image>\n'..
					'      <width>1</width>\n'..
					'      <height>1</height>\n'..
					'    </image>\n'..
					'    <clip>\n'..
					'      <near>0.1</near>\n'..
					'      <!-- Sensor range -->\n'..
					'      <far>3</far>\n'..
					'    </clip>\n'..
					'  </camera>\n'..
					' <pose> .15 0 .05 0 0 ' .. angle .. '</pose>\n'..
					'  <plugin name="camera_controller" filename="libgazebo_ros_camera.so">\n'..
					'    <alwaysOn>true</alwaysOn>\n'..
					'    <cameraName>front_colour_sensor_' .. i .. '</cameraName>\n'..
					'    <imageTopicName>image_raw</imageTopicName>\n'..
					'    <cameraInfoTopicName>camera_info</cameraInfoTopicName>\n'..
					'    <frameName>camera_link</frameName>\n'..
					'    <hackBaseline>0.07</hackBaseline>\n'..
					'    <distortionK1>0.0</distortionK1>\n'..
					'    <distortionK2>0.0</distortionK2>\n'..
					'    <distortionK3>0.0</distortionK3>\n'..
					'    <distortionT1>0.0</distortionT1>\n'..
					'    <distortionT2>0.0</distortionT2>\n'..
					'  </plugin>\n'..
					'  <always_on>1</always_on>\n'..
					'  <update_rate>10</update_rate>\n'..
					' <visualize>false</visualize>\n'..
					'</sensor>\n'..
					'\n')
end
