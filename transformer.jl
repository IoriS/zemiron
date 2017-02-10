function transformer(payoff_matrix)
    LA_param = 2
    p1payoff_firstrow = [payoff_matrix[1][1],payoff_matrix[3][1]]
    p1payoff_secondrow = [payoff_matrix[2][1],payoff_matrix[4][1]]
    s1 = max(minimum(p1payoff_firstrow),minimum(p1payoff_secondrow))
    newp1 = zeros(4)
    for j in 1:4
        if payoff_matrix[j][1] <= s1
            newp1[j] = payoff_matrix[j][1]
        else
            newp1[j] = (payoff_matrix[j][1]+s1)/LA_param
        end
    end
    p2payoff_firstcolumn = [payoff_matrix[1][2],payoff_matrix[2][2]]
    p2payoff_secondcolumn = [payoff_matrix[3][2],payoff_matrix[4][2]]
    s2 = max(minimum(p2payoff_firstcolumn),minimum(p2payoff_secondcolumn))
    newp2 = zeros(4)
    for area2 in 1:4
        if payoff_matrix[area2][2] <= s2
            newp2[area2] = payoff_matrix[area2][2]
        else
            newp2[area2] = (payoff_matrix[area2][2]+s2)/LA_param
        end
    end
    AA = (newp1[1],newp2[1])
    AB = (newp1[3],newp2[3])
    BA = (newp1[2],newp2[2])
    BB = (newp1[4],newp2[4])
    karimatrix = [AA,AB,BA,BB]
    newpayoff_matrix =transpose(reshape(karimatrix,2,2))
    return newpayoff_matrix
end