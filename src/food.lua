food = {}
food.__index = food

function food.create(id, nodehandle, odom_spec, model_state_spec, x, y, z, value)
	--Spawn food in gazebo
	os.execute('rosrun gazebo_ros spawn_model -x ' .. x .. ' -y ' .. y .. ' -z ' .. z .. ' -file `rospack find swarm_simulator`/sdf/food.sdf' .. 
						 ' -sdf -model food' .. id .. ' -robot_namespace food' .. id)	
	-- .. ' > /dev/null 2>&1'
  local fd = {}
  setmetatable(fd,food)
	fd.id = id
	fd.nodehandle = nodehandle
	fd.value = value
	fd.position = torch.Tensor(3)
	fd.position[1] = x
	fd.position[2] = y
	fd.position[3] = z
	fd.relocation_message = ros.Message(model_state_spec)

	--Connect subscribers to topics that food publishes to
  fd.odom_subscriber = fd.nodehandle:subscribe("/food" .. id .. "/base_pose", odom_spec, 100, { 'udp', 'tcp' }, { tcp_nodelay = true })
	--Connect publishers to topics that food subscribes to
	fd.relocation_publisher = fd.nodehandle:advertise("/gazebo/set_model_state", model_state_spec, 100, false, connect_cb, disconnect_cb)

  fd.odom_subscriber:registerCallback(function(msg, header)
		--position published by robot
		fd.position[1] = msg.pose.pose.position.x
		fd.position[2] = msg.pose.pose.position.y
		fd.position[3] = msg.pose.pose.position.z
  end)

  return fd
end

function food.random_relocate(self, distance)
	new_position = distance * (torch.rand(3) - 0.5)
	new_position[3] = 1
	self:relocate(new_position)
end

function food.relocate(self, new_position)
	--os.execute('rosservice call /gazebo/delete_model "model_name: \'food' .. self.id .. '\'" ')	
	m = self.relocation_message
	m.model_name = 'food' .. self.id
	m.pose.position.x = new_position[1]
	m.pose.position.y = new_position[2]
	m.pose.position.z = new_position[3]
	self.relocation_publisher:publish(m)
	--rostopic pub -r 20 /gazebo/set_modestate gazebo_msgs/ModelState '{model_name: food1, pose: { position: { x: 1, y: 0, z: 2 }, orientation: {x: 0, y: 0.491983115673, z: 0, w: 0.870604813099 } }, twist: { linear: { x: 0, y: 0, z: 0 }, angular: { x: 0, y: 0, z: 0}  }, reference_frame: world }'
	self.position = new_position
end
