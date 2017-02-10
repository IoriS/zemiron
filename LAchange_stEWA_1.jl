function LAchange_stEWA_1(payoff_matrix,alpha,beta,lambda=0.2775)
    p_U = 0
    q_L = 0
    phiof1 = zeros(200,4)
    phiof2 = zeros(200,4)
    Nof1 = zeros(200,4)
    Nof2 = zeros(200,4)
    s_jof1 = zeros(200,4)
    s_jof2 = zeros(200,4)
    foregone_payoff1 = zeros(200,4)
    foregone_payoff2 = zeros(200,4)
    deltaof1 = zeros(200,4)
    deltaof2 = zeros(200,4)
    ind_1of1 = zeros(200,4)
    ind_2of1 = zeros(200,4)
    ind_1of2 = zeros(200,4)
    ind_2of2 = zeros(200,4)
    pay_1of1 = zeros(200,4)
    pay_2of1 = zeros(200,4)
    pay_1of2 = zeros(200,4)
    pay_2of2 = zeros(200,4)
    A_1of1 = zeros(200,4)
    A_2of1 = zeros(200,4)
    A_1of2 = zeros(200,4)
    A_2of2 = zeros(200,4)
    for ph in 1:4
        phiof1[1,ph] = 0.5
        phiof2[1,ph] = 0.5
    end
    p1_move = zeros(Int,200,4)
    p2_move = zeros(Int,200,4)
    p1_op_move = zeros(Int,200,4)
    p2_op_move = zeros(Int,200,4)
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
                newp1[j] = ((LA_param[200-i+1]-1)*(payoff_matrix[j][1]+s1))/LA_param[200-i+1]
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
                newp2[area2] = (LA_param[200-i+1]-1)*(payoff_matrix[area2][2]+s2)/LA_param[200-i+1]
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
            if i == 1
                pr1of1[mat[1,m]] = 0.5
                pr1of2[mat[2,m]] = 0.5
            else
                pr1of1[mat[1,m]] = exp((A_1of1[i-1,[mat[1,m]]][1])*lambda)/(exp((A_1of1[i-1,[mat[1,m]]][1])*(lambda))+exp((A_2of1[i-1,[mat[1,m]]][1])*lambda))
                pr1of2[mat[2,m]] = exp((A_1of2[i-1,[mat[2,m]]][1])*lambda)/(exp((A_1of2[i-1,[mat[2,m]]][1])*(lambda))+exp((A_2of2[i-1,[mat[2,m]]][1])*lambda))
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

            #フィードバック部分
            p1_move[i,mat[1,m]] = p1_act[mat[1,m]]
            p2_move[i,mat[2,m]] = p2_act[mat[2,m]]
            p1_op_move[i,mat[1,m]] = p2_act[mat[2,m]]
            p2_op_move[i,mat[2,m]] = p1_act[mat[1,m]]

            if i >= 2
                if p1_op_move[i-1,mat[1,m]] == p1_op_move[i,mat[1,m]]
                    phiof1[i,mat[1,m]] = 1
                else
                    phiof1[i,mat[1,m]] = 0.5
                end
                if p2_op_move[i-1,mat[2,m]] == p2_op_move[i,mat[2,m]]
                    phiof2[i,mat[2,m]] = 1
                else
                    phiof2[i,mat[2,m]] = 0.5
                end
            end

            if i == 1
                Nof1[1,mat[1,m]] = phiof1[1,mat[1,m]] +1 
                Nof2[1,mat[2,m]] = phiof2[1,mat[2,m]] +1
            else
                Nof1[i,mat[1,m]] = ((Nof1[i-1,mat[1,m]])*(phiof1[i,mat[1,m]])) +1
                Nof2[i,mat[2,m]] = ((Nof2[i-1,mat[2,m]])*(phiof2[i,mat[2,m]])) +1
            end

            if p1_act[mat[1,m]] == 1
                s_jof1[i,mat[1,m]] = 2
            else
                s_jof1[i,mat[1,m]] = 1
            end
            if p2_act[mat[2,m]] == 1
                s_jof2[i,mat[2,m]] = 2
            else
                s_jof2[i,mat[2,m]] =1
            end

            if s_jof1[i,mat[1,m]] == 1 && p1_op_move[i,mat[1,m]] == 1
                foregone_payoff1[i,mat[1,m]] = newpayoff_matrix[1][1]
            elseif s_jof1[i,mat[1,m]] == 1 && p1_op_move[i,mat[1,m]] == 2
                foregone_payoff1[i,mat[1,m]] = newpayoff_matrix[3][1]
            elseif s_jof1[i,mat[1,m]] == 2 && p1_op_move[i,mat[1,m]] == 1
                foregone_payoff1[i,mat[1,m]] = newpayoff_matrix[2][1]
            elseif s_jof1[i,mat[1,m]] == 2 && p1_op_move[i,mat[1,m]] == 2
                foregone_payoff1[i,mat[1,m]] = newpayoff_matrix[4][1]
            end
            if foregone_payoff1[i,mat[1,m]] >= p1_payoff[mat[1,m]]
                deltaof1[i,mat[1,m]] = 0.5
            else
                deltaof1[i,mat[1,m]] = 0
            end

            if p2_op_move[i,mat[2,m]] == 1 && s_jof2[i,mat[2,m]] == 1
                foregone_payoff2[i,mat[2,m]] = newpayoff_matrix[1][2]
            elseif p2_op_move[i,mat[2,m]] == 1 && s_jof2[i,mat[2,m]] == 2
                foregone_payoff2[i,mat[2,m]] = newpayoff_matrix[3][2]
            elseif p2_op_move[i,mat[2,m]] == 2 && s_jof2[i,mat[2,m]] == 1
                foregone_payoff2[i,mat[2,m]] = newpayoff_matrix[2][2]
            elseif p2_op_move[i,mat[2,m]] == 2 && s_jof2[i,mat[2,m]] == 2
                foregone_payoff2[i,mat[2,m]] = newpayoff_matrix[4][2]
            end
            if foregone_payoff2[i,mat[2,m]] >= p2_payoff[mat[2,m]]
                deltaof2[i,mat[2,m]] = 0.5
            else
                deltaof2[i,mat[2,m]] = 0
            end

            if p1_move[i,mat[1,m]] ==1
                ind_1of1[i,mat[1,m]] = 1
                ind_2of1[i,mat[1,m]] = 0
            else
                ind_1of1[i,mat[1,m]] = 0
                ind_2of1[i,mat[1,m]] = 1
            end
            if p2_move[i,mat[2,m]] ==1
                ind_1of2[i,mat[2,m]] = 1
                ind_2of2[i,mat[2,m]] = 0
            else
                ind_1of2[i,mat[2,m]] = 0
                ind_2of2[i,mat[2,m]] = 1
            end

            if p1_op_move[i,mat[1,m]] == 1
                pay_1of1[i,mat[1,m]] = newpayoff_matrix[1][1]
                pay_2of1[i,mat[1,m]] = newpayoff_matrix[2][1]
            else
                pay_1of1[i,mat[1,m]] = newpayoff_matrix[3][1]
                pay_2of1[i,mat[1,m]] = newpayoff_matrix[4][1]
            end
            if p2_op_move[i,mat[2,m]] == 1
                pay_1of2[i,mat[2,m]] = newpayoff_matrix[1][2]
                pay_2of2[i,mat[2,m]] = newpayoff_matrix[3][2]
            else
                pay_1of2[i,mat[2,m]] = newpayoff_matrix[2][2]
                pay_2of2[i,mat[2,m]] = newpayoff_matrix[4][2]
            end

            if i == 1 #A(0) =1とする。
                A_1of1[1,mat[1,m]] = ((deltaof1[1,mat[1,m]])+(1-deltaof1[1,mat[1,m]])*(ind_1of1[1,mat[1,m]])*(pay_1of1[1,mat[1,m]]))/Nof1[1,mat[1,m]]
                A_2of1[1,mat[1,m]] = ((deltaof1[1,mat[1,m]])+(1-deltaof1[1,mat[1,m]])*(ind_2of1[1,mat[1,m]])*(pay_2of1[1,mat[1,m]]))/Nof1[1,mat[1,m]]
                A_1of2[1,mat[2,m]] = ((deltaof2[1,mat[2,m]])+(1-deltaof2[1,mat[2,m]])*(ind_1of2[1,mat[2,m]])*(pay_1of2[1,mat[2,m]]))/Nof2[1,mat[2,m]]
                A_2of2[1,mat[2,m]] = ((deltaof2[1,mat[2,m]])+(1-deltaof2[1,mat[2,m]])*(ind_2of2[1,mat[2,m]])*(pay_2of2[1,mat[2,m]]))/Nof2[1,mat[2,m]]
            else
                A_1of1[i,mat[1,m]] = ((phiof1[i,mat[1,m]])*(Nof1[i-1,mat[1,m]])*(A_1of1[i-1,mat[1,m]])+(deltaof1[i,mat[1,m]]+(1-deltaof1[i,mat[1,m]])*(ind_1of1[i,mat[1,m]]))*(pay_1of1[i,mat[1,m]]))/Nof1[i,mat[1,m]]
                A_2of1[i,mat[1,m]] = ((phiof1[i,mat[1,m]])*(Nof1[i-1,mat[1,m]])*(A_2of1[i-1,mat[1,m]])+(deltaof1[i,mat[1,m]]+(1-deltaof1[i,mat[1,m]])*(ind_2of1[i,mat[1,m]]))*(pay_2of1[i,mat[1,m]]))/Nof1[i,mat[1,m]]
                A_1of2[i,mat[2,m]] = ((phiof2[i,mat[2,m]])*(Nof2[i-1,mat[2,m]])*(A_1of2[i-1,mat[2,m]])+(deltaof2[i,mat[2,m]]+(1-deltaof2[i,mat[2,m]])*(ind_1of2[i,mat[2,m]]))*(pay_1of2[i,mat[2,m]]))/Nof2[i,mat[2,m]]
                A_2of2[i,mat[2,m]] = ((phiof2[i,mat[2,m]])*(Nof2[i-1,mat[2,m]])*(A_2of2[i-1,mat[2,m]])+(deltaof2[i,mat[2,m]]+(1-deltaof2[i,mat[2,m]])*(ind_2of2[i,mat[2,m]]))*(pay_2of2[i,mat[2,m]]))/Nof2[i,mat[2,m]]
            end
        end
    end
    num_of_1of1 = zeros(4)
    num_of_2of1 = zeros(4)
    num_of_1of2 = zeros(4)
    num_of_2of2 = zeros(4)
    for num in 1:4
        for t in 1:200
            if p2_op_move[t,num] ==1
                num_of_1of1[num] +=1
            else
                num_of_2of1[num] +=1
            end
            if p1_op_move[t,num] ==1
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