import sys

def main( n):
    for i in range(1,n+1):
  	print """<sensor name="colour_sensor_1" type="camera">
						   <camera>
						     <horizontal_fov>0.15</horizontal_fov>
						     <image>
						       <width>1</width>
						       <height>1</height>
						     </image>
						     <clip>
						       <near>0.1</near>
									 <!-- Sensor range -->
						       <far>3</far>
						     </clip>
						   </camera>
							 <pose> .15 0 .05 0 0 1.0427</pose>
						   <plugin name="camera_controller" filename="libgazebo_ros_camera.so">
						     <alwaysOn>true</alwaysOn>
						     <cameraName>front_colour_sensor1</cameraName>
						     <imageTopicName>image_raw</imageTopicName>
						     <cameraInfoTopicName>camera_info</cameraInfoTopicName>
						     <frameName>camera_link</frameName>
						     <hackBaseline>0.07</hackBaseline>
						     <distortionK1>0.0</distortionK1>
						     <distortionK2>0.0</distortionK2>
						     <distortionK3>0.0</distortionK3>
						     <distortionT1>0.0</distortionT1>
						     <distortionT2>0.0</distortionT2>
						   </plugin>
						   <always_on>1</always_on>
						   <update_rate>10</update_rate>
							 <visualize>false</visualize>
						 </sensor>"""

if __name__ == '__main__':
	main(int(sys.argv[1]))
