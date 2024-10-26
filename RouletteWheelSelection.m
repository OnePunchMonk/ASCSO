function j=RouletteWheelSelection(P) 
    r=rand; 
    s=sum(P);
    P=P./s;
    C=cumsum(P); 
    j=find(r<=C,1,'first'); 

    if isempty(j)
        j=randi(length(P));
    end    
end