function leader_indices = TournamentSelection(fitness, k)
    [~, sorted_indices] = sort(fitness, 'descend');  % Sort in descending order
    
    % Initialize empty array to store leader indices
    leader_indices = zeros(1, k);
    for i = 1:k
        % Randomly select a subset of size 'k' from the sorted indices
        tournament_indices = sorted_indices(randperm(length(sorted_indices), k));
        % Select the index with the highest fitness value within the tournament
        [~, winner_index] = max(fitness(tournament_indices));
        leader_indices(i) = tournament_indices(winner_index);
    end
end
