
clc
clear all;
SearchAgents_no = 200;
Max_iteration = 300;
num_runs = 100;  % Number of runs for each function
a = 1;
b = 20;

for i = a:b

    if i==17
        continue;
    end    

    Function_name = i;
    [lb, ub, dim, fobj] = Get_Functions_details(Function_name);
    k = max(1, floor(0.25 * SearchAgents_no));

    [Best_Score, BestFit, Convergence_curve] = ASCSO(SearchAgents_no, Max_iteration, lb, ub, dim, fobj,k);


    disp( [num2str(Best_Score),"For Function",num2str(i)]);

end


 
