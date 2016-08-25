genetic_util = {}
genetic_util.__index = genetic_util

function genetic_util.crossover_mutate_proportional(swarmbots, total_energy, mutation_rate)
	--Create the new network as a clone of the previous network
	child_network = swarmbots[1].neural_net:clone()

	for i=1, table.getn(child_network.modules) do
		if (child_network.modules[i].weight ~= nil) then
			size = child_network.modules[i].weight:size()

			for j=1, size[1] do
				for k=1, size[2] do
					--For each element of given set of weights
					random_variable = torch.uniform()
					accumulated_probability = 0
					for l=1, table.getn(swarmbots) do

						if total_energy ~= 0 then
							gene_pool_proportion = swarmbots[l].energy / total_energy
						else 
							gene_pool_proportion = 1 / table.getn(swarmbots)
						end

						accumulated_probability = accumulated_probability + gene_pool_proportion
						if random_variable < accumulated_probability then
							--Gene from lth swarmbot
							chosen_gene = swarmbots[l].neural_net.modules[i].weight[j][k]
							break
						end

					end

					if torch.uniform() < mutation_rate then
						--Gene mutates
						chosen_gene = torch.uniform()
					end
					--Assign gene to child
					child_network.modules[i].weight[j][k] = chosen_gene

				end
			end
		end

	end
	return child_network
end

--Takes two sequential neural networks and returns a crossover
function genetic_util.crossover_mutate(nn1, nn2, favour_first, mutation_rate)
--Pre: nn1 and nn2 have same dimensions
	--Create the new network as a clone of the previous network
	child_network = nn1:clone()
	for i=1, table.getn(nn1.modules) do
		if (nn1.modules[i].weight ~= nil) then
			size = nn1.modules[i].weight:size()
			for j=1, size[1] do
				for k=1, size[2] do
					random_variable = torch.uniform()
					if random_variable < mutation_rate then
						--Gene mutates
						chosen_gene = torch.uniform()
					elseif random_variable < favour_first then
						--Gene from parent 1
						chosen_gene = nn1.modules[i].weight[j][k]
					else
						--Gene from parent 2
						chosen_gene = nn2.modules[i].weight[j][k]
					end
					--Assign gene to child
					child_network.modules[i].weight[j][k] = chosen_gene
				end
			end
		end
	end
	return child_network

end
