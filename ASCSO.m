%___________________________________________________________________%
%  Adaptive Sand Cat Swarm Optimizer (ASCSO) source code            %
%                                                                   %                               
%                                                                   %
%  Author and programmer: Avaya Aggarwal                            %
%                                                                   %
%  e-Mail: aggarwal.avaya27@gmail.com                               %
%                                                                   %
%                                                                   %
%                                                                   %
%___________________________________________________________________%


function [Best_Score, BestFit, Convergence_curve] = ASCSO(SearchAgents_no, Max_iter, lb, ub, dim, fobj, k)
    % Initialization
    BestFit = zeros(1, dim);
    Best_Score = inf;
    Positions = initialization(SearchAgents_no, dim, ub, lb);  % Assuming `initialization` function exists
    Convergence_curve = zeros(1, Max_iter);
    % Hyperparameters for exploration control (adjust as needed)
    alpha = 1.1;  % Initial large step size
    beta = 0.35;   %
    % Rate of step size decrease
    threshold = 1e-3; 
    % Threshold for minimal fitness change (stuck solution)
    hunter_rate_init = 0.3;  % Proportion of agents to become hunters (adjust as needed)
    % Pre-allocate memory for efficiency
    prev_fitness = zeros(SearchAgents_no, 1);  % Store previous fitness values
    for t = 1:Max_iter
        % Fitness evaluation

        for i = 1:size(Positions, 1)
 
            fitness(i)=fobj(Positions(i, :));

            if fitness(i) < Best_Score
                Best_Score = fitness(i);
                BestFit = Positions(i, :);
            end
        end
        % Selection (modified roulette wheel with top k cats)
        [sorted_fitness, sorted_indices] = sort(fitness, 'descend');  % Sort in descending order
        % Top k cats for roulette wheel selection
        p = ones(1, k);  % Allocate probabilities to top k cats
        % Fitness-based probability weighting for top k
        for i = 1:k
            p(i) = sorted_fitness(i) / sum(sorted_fitness(1:k));
        end
        % Leader selection using roulette wheel with top k probabilities
        leader_indices = TournamentSelection(fitness, k);
        
        % Hunter selection
        midpoint = Max_iter *0.55;
        hunter_rate_decay=0.9;
        hunter_rate = hunter_rate_init / (1 + exp(hunter_rate_decay * (t - midpoint)));
        hunter_indices = randperm(SearchAgents_no, floor(SearchAgents_no * hunter_rate));
        
        % Update positions
        for i = 1:size(Positions, 1)
            % Adaptive step size control
            step_size = alpha * exp(-beta * t / Max_iter);
            if ismember(i, hunter_indices)  % Hunter behavior
                % Run away from the best leader in a random direction
                random_leader_index = randi(length(leader_indices));  % Select a random leader index
                random_leader = leader_indices(random_leader_index);  % Get the corresponding leader's position
                proposed_position = Positions(i, :) + step_size * sign(Positions(i, :) - Positions(random_leader, :)) .* (2*rand(1, dim) - 1);
                
                for j = 1:dim
                    Positions(i, j) = min(max(proposed_position(j), lb), ub);
                    %Positions(i, j) = min(max(Positions(i, j), lb(j)), ub(j));
                end               
               else  %Follower behavior
                % Update based on leading solution (exploitation)
                for j = 1:dim
                    R = rand * 2 - 1;  % Random value between -1 and 1                                                 
                    Positions(i, j) = Positions(i, j) + step_size * (BestFit(j) - Positions(i, j)) * cos(RouletteWheelSelection(p));
                    % Targeted random walk for stuck solutions (exploration)
                    fitness_change = abs(fitness(i) - prev_fitness(i));
                    if fitness_change < threshold  % Potentially stuck solution
                  
                        if R < 0.5 
                            Rand_position = abs(rand * BestFit(j) - Positions(i, j));
                            Positions(i, j) = BestFit(j) - step_size * Rand_position * cos(RouletteWheelSelection(p));
                        else  
                            cp = floor(SearchAgents_no * rand + 1);  % Randomly select another solution
                            CandidatePosition = Positions(cp, :);
                            Positions(i, j) = step_size * (CandidatePosition(j) - rand * Positions(i, j));
                        end
                    end
                    Positions(i, j) = min(max(Positions(i, j), lb), ub);
                    %Positions(i, j) = min(max(Positions(i, j), lb(j)), ub(j));
                end
            end
            
            % Handle boundary

            prev_fitness(i) = fitness(i);  % Update previous fitness
               
        end
        Convergence_curve(t) = Best_Score;
    end
end


