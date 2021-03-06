require 'image'
ros = require 'ros'
require 'nn'
require 'torch'
require 'swarmbot'
require 'food'
require 'genetic_util'
require 'optim'

ros.init('torchros_example_publisher')
local classic = require 'classic'
local main, super = classic.class('main', Env)
local main = {};

--Global variables
number_of_bots = 20;
number_of_food = 6;
camera_size = 1;
eat_distance = 0.4;
generation_time = 80;
arena_width = 20

--Globals required to extract info from message callbacks
resp_ready = false
image = nil

function connect_cb(name, topic)
  print("subscriber connected: " .. name .. " (topic: '" .. topic .. "')")
end


function disconnect_cb(name, topic)
  print("subscriber diconnected: " .. name .. " (topic: '" .. topic .. "')")
end


function main:_init(opts)
	opts = opts or {}

	--Setup ros node and spinner (processes queued send and receive topics)
	self.spinner = ros.AsyncSpinner()
	self.spinner:start()
	self.nodehandle = ros.NodeHandle()
	
	--Message Formats
	self.string_spec = ros.MsgSpec('std_msgs/String')
	self.image_spec = ros.MsgSpec('sensor_msgs/Image')
	self.jointstate_spec = ros.MsgSpec('sensor_msgs/JointState')
	self.log_spec = ros.MsgSpec('rosgraph_msgs/Log')
	self.clock_spec = ros.MsgSpec('rosgraph_msgs/Clock')
	self.float_spec = ros.MsgSpec('std_msgs/Float64')
	self.link_spec = ros.MsgSpec('gazebo_msgs/LinkStates')
	self.twist_spec = ros.MsgSpec('geometry_msgs/Twist')
	self.odom_spec = ros.MsgSpec('nav_msgs/Odometry')
	self.model_state_spec = ros.MsgSpec('gazebo_msgs/ModelState')


	--Create swarmbots
	swarmbots = {}
	swarmbots_new = {}
	for i=1, number_of_bots do
		--Neural net parameters
		HUs = 3;
		--Create new swarmbot
		swarmbots[i] = swarmbot.create(i, self.nodehandle, HUs, self.twist_spec, self.image_spec, self.odom_spec, self.link_spec, self.model_state_spec, i - 5, 0, 0)
		swarmbots[i]:random_relocate(arena_width)
	end

	--Create food
	foods = {}
	for i=1, number_of_food do
		--Create new food
		foods[i] = food.create(i, self.nodehandle, self.odom_spec, self.model_state_spec, 0, 0, 1, 10)
		foods[i]:random_relocate(arena_width)
	end

	--Setup timer for generation timing
	current_time = 0
	self.clock_subscriber = self.nodehandle:subscribe("/clock", self.clock_spec, 100, { 'udp', 'tcp' }, { tcp_nodelay = true })
  self.clock_subscriber:registerCallback(function(msg, header)
		--position published by robot
		current_time = msg.clock:toSec()
  end)

	--Set start time
	ros.spinOnce()
	start_time = current_time
	--Count generations
	generation_count = 0
	total_fitness = 0

	--spin must be called to trigger callbacks for any received messages
	frequency = 10
	print('------------------------------------------------------------')
	print('---------------------------BEGIN----------------------------')
	print('------------------------------------------------------------')

	fitness_logger = optim.Logger('Logs/Swarmbot Fitness Logger 2')
	fitness_logger:setNames({'Average Fitness', 'Best Fitness'})
	fitness_logger:style{'-', '-'}

	while not ros.isShuttingDown() do
		elapsed_generation_time = current_time - start_time	

		if elapsed_generation_time < generation_time then

			--Check if any food is eaten
			for i=1, number_of_bots do
				for j=1, number_of_food do
					if (torch.abs(torch.dist(swarmbots[i].position, foods[j].position)) < eat_distance) then
						swarmbots[i]:consume(foods[j])
						foods[j]:random_relocate(arena_width)
						total_fitness = total_fitness + foods[j].value
					end
				end
			end
			
		else
			--End of tournament, perform genetic crossover and generate next generation
			start_time = current_time
			generation_count = generation_count + 1
			
			--Sort turtles with regard to fitness
			table.sort(swarmbots, swarmbot.fittest)
			best_fitness = swarmbots[1].energy
			average_fitness = total_fitness / number_of_bots

			--Keep old swambots for crossover
			swarmbots_new = table.copy(swarmbots)

			--Update neural networks
			for i=1, number_of_bots do
				swarmbots_new[i]:update_neural_net(genetic_util.crossover_mutate_proportional(swarmbots, total_fitness, 0.05))
				swarmbots_new[i].energy = 0
				swarmbots_new[i]:random_relocate(arena_width)
				swarmbots = swarmbots_new
			end

			fitness_logger:add({average_fitness, best_fitness})

			print('Generation [' .. generation_count .. '], Best [' .. best_fitness .. '], Average [' .. average_fitness .. ']')
			fitness_logger:plot()
			total_fitness = 0

			for j=1, number_of_food do
				foods[j]:random_relocate(arena_width)
			end

		end

	  ros.spinOnce()
	  ros.Duration(1/frequency):sleep()
	end

	resp_ready = false
end

function table.copy(t)
  local u = { }
  for k, v in pairs(t) do u[k] = v end
  return setmetatable(u, getmetatable(t))
end

return main
