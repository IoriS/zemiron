function LAchange_reinforcement_2(payoff_matrix,alpha,beta)
    p_U = 0
    q_L = 0
    B_1of1 = zeros(4)
    B_1of2 = zeros(4)
    B_2of1 = zeros(4)
    B_2of2 = zeros(4)
    p1_move = zeros(Int,200,4)
    p2_move = zeros(Int,200,4)
    for i in 1:200
        #利得変形というか新しく作成
        p1payoff_firstrow = [payoff_matrix[1][1],payoff_matrix[3][1]]
        p1payoff_secondrow = [payoff_matrix[2][1],payoff_matrix[4][1]]
        s1 = max(minimum(p1payoff_firstrow),minimum(p1payoff_secondrow))
        newp1 = zeros(4)
        LA_param = collect(linspace(alpha,beta,200))
        for j in 1:4
            if payoff_matrix[j][1] <= s1
                newp1[j] = payoff_matrix[j][1]
            else
                newp1[j] = (LA_param[i]-1)*(payoff_matrix[j][1]+s1)/LA_param[i]
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
                newp2[area2] = (LA_param[i]-1)*(payoff_matrix[area2][2]+s2)/LA_param[i]
            end
        end
        AA = (newp1[1],newp2[1])
        AB = (newp1[3],newp2[3])
        BA = (newp1[2],newp2[2])
        BB = (newp1[4],newp2[4])
        karimatrix = [AA,AB,BA,BB]
        newpayoff_matrix =transpose(reshape(karimatrix,2,2))

        #マッチング部分
        mat = zeros(Int,2,4)
        p1_rand = randn(4)
        p2_rand = randn(4)
        p1_ind = sortperm(p1_rand)
        p2_ind = sortperm(p2_rand)
        for p in 1:4
            mat[1,p] = p1_ind[p]
            mat[2,p] = p2_ind[p]
        end

        #確率決定部分
        pr1of1 = zeros(4)
        pr1of2 = zeros(4)
        p1_act = zeros(4)
        p2_act = zeros(4)
        p1_payoff = zeros(4)
        p2_payoff = zeros(4)
        for m in 1:4

            if B_1of1[mat[1,m]] == 0 || B_2of1[mat[1,m]]== 0
                pr1of1[mat[1,m]] =0.5
            else
                pr1of1[mat[1,m]] = (B_1of1[mat[1,m]])/(B_1of1[mat[1,m]] + B_2of1[mat[1,m]])
            end
            if B_1of2[mat[2,m]] == 0 || B_2of2[mat[2,m]]==0
                pr1of2[mat[2,m]] =0.5
            else
                pr1of2[mat[2,m]] = (B_1of2[mat[2,m]])/(B_1of2[mat[2,m]] + B_2of2[mat[2,m]])
            end

            #行動決定部分
            x = rand()
            y = rand()
            if x <= pr1of1[mat[1,m]]
                p1_act[mat[1,m]] = 1
            else
                p1_act[mat[1,m]] = 2
            end
            if y <= pr1of2[mat[2,m]]
                p2_act[mat[2,m]] = 1
            else
                p2_act[mat[2,m]] = 2
            end

            #利得確定部分
            if p1_act[mat[1,m]] == 1 && p2_act[mat[2,m]] == 1
                p1_payoff[mat[1,m]] = newpayoff_matrix[1][1]
                p2_payoff[mat[2,m]] = newpayoff_matrix[1][2]
            elseif p1_act[mat[1,m]] == 1 && p2_act[mat[2,m]] == 2
                p1_payoff[mat[1,m]] = newpayoff_matrix[3][1]
                p2_payoff[mat[2,m]] = newpayoff_matrix[3][2]
            elseif p1_act[mat[1,m]] == 2 && p2_act[mat[2,m]] == 1
                p1_payoff[mat[1,m]] = newpayoff_matrix[2][1]
                p2_payoff[mat[2,m]] = newpayoff_matrix[2][2]
            elseif p1_act[mat[1,m]] == 2 && p2_act[mat[2,m]] == 2
                p1_payoff[mat[1,m]] = newpayoff_matrix[4][1]
                p2_payoff[mat[2,m]] = newpayoff_matrix[4][2]
            end

            ##フィードバック部分
            p1_move[i,[mat[1,m]]] = p1_act[mat[1,m]]
            p2_move[i,[mat[2,m]]] = p2_act[mat[2,m]]
            if p1_act[mat[1,m]] ==1
                B_1of1[mat[1,m]] += p1_payoff[mat[1,m]]
            else
                B_2of1[mat[1,m]] += p1_payoff[mat[1,m]]
            end
            if p2_act[mat[2,m]] == 1
                B_1of2[mat[2,m]] += p2_payoff[mat[2,m]]
            else
                B_2of2[mat[2,m]] += p2_payoff[mat[2,m]]
            end
        end
    end
    num_of_1of1 = zeros(Int,4)
    num_of_2of1 = zeros(Int,4)
    num_of_1of2 = zeros(Int,4)
    num_of_2of2 = zeros(Int,4)
    for num in 1:4
        for t in 1:200
            if p1_move[t,num] ==1
                num_of_1of1[num] +=1
            else
                num_of_2of1[num] +=1
            end
            if p2_move[t,num] ==1
                num_of_1of2[num] +=1
            else
                num_of_2of2[num] +=1
            end
        end
    end
    for prob in 1:4
        p_U += (num_of_1of1[prob]/(num_of_1of1[prob]+num_of_2of1[prob]))/4
        q_L += (num_of_1of2[prob]/(num_of_1of2[prob]+num_of_2of2[prob]))/4
    end
    return p_U,q_L
end