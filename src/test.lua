os.execute('rosrun gazebo_ros spawn_model -x ' .. 0 .. ' -y ' .. 0 .. ' -z ' .. 1 .. ' -file `rospack find 		      		          swarm_simulator`/sdf/swarm_robot_v2.sdf' .. ' -sdf -model swarmbot' .. 2 .. ' -robot_namespace swarmbot' .. 2)

--os.execute('rosrun gazebo_ros spawn_model -x ' .. 0 .. ' -y ' .. 0 .. ' -z ' .. 1 .. ' -file `rospack find 		      		          swarm_simulator`/sdf/food.sdf' .. ' -sdf -model food' .. 1 .. ' -robot_namespace food' .. 1)
