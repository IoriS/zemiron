function actionsampling(payoff_matrix,sample_param=12)
    p_U = 0
    q_L = 0
    p1_op_move = zeros(Int,200,4)
    p2_op_move = zeros(Int,200,4)
    for i in 1:200
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

        ##確率決定部分
        P_1of1 = zeros(4)
        P_1of2 = zeros(4)
        P_2of1 = zeros(4)
        P_2of2 = zeros(4)
        count1_1 = zeros(Int,4)
        count2_1 = zeros(Int,4)
        count1_2 = zeros(Int,4)
        count2_2 = zeros(Int,4)
        pr1of1 = zeros(4)
        pr1of2 = zeros(4)
        p1_act = zeros(Int,4)
        p2_act = zeros(Int,4)
        p1_payoff = zeros(4)
        p2_payoff = zeros(4)

        for m in 1:4
            #pr1of1部分
            if i != 1
                hantei1 = p1_op_move[1:i-1,mat[1,m]]
                for han1_ind in 1:length(hantei1)
                    if hantei1[han1_ind] == 1
                        count1_1[mat[1,m]] = 1
                    else
                        count2_1[mat[1,m]] = 1
                    end
                end
            end
            if i == 1 || (count1_1[mat[1,m]]  == 0 || count2_1[mat[1,m]]  ==0)
                pr1of1[mat[1,m]] =0.5
            else
                if i <= sample_param
                    AS1 = p1_op_move[1:i-1,mat[1,m]]
                else
                    kariAS1 = p1_op_move[1:i-1,mat[1,m]]
                    ranz1 = randn(length(kariAS1))
                    z1 = sortperm(ranz1)
                    AS1 = zeros(Int,sample_param)
                    for as1_ind in 1:sample_param
                        AS1[as1_ind] = kariAS1[z1[as1_ind]]
                    end
                end
                for as1_len in 1:length(AS1)
                    if AS1[as1_len] == 1
                        P_1of1[mat[1,m]] += payoff_matrix[1][1]
                        P_2of1[mat[1,m]] += payoff_matrix[2][1]
                    else
                        P_1of1[mat[1,m]] += payoff_matrix[3][1]
                        P_2of1[mat[1,m]] += payoff_matrix[4][1]
                    end
                end
                if P_1of1[mat[1,m]] > P_2of1[mat[1,m]]
                    pr1of1[mat[1,m]] = 1
                elseif P_1of1[mat[1,m]] == P_2of1[mat[1,m]]
                    pr1of1[mat[1,m]] = 0.5
                elseif P_1of1[mat[1,m]] < P_2of1[mat[1,m]]
                    pr1of1[mat[1,m]] = 0
                end
            end

            #pr1of2部分
            if i != 1
                hantei2 = p2_op_move[1:i-1,mat[2,m]]
                for han2_ind in 1:length(hantei2)
                    if hantei2[han2_ind] == 1
                        count1_2[mat[2,m]] =1
                    else
                        count2_2[mat[2,m]] = 1
                    end
                end
            end
            if i == 1 || (count1_2[mat[2,m]] == 0 || count2_2[mat[2,m]] ==0)
                pr1of2[mat[2,m]] =0.5
            else
                if i <= sample_param
                    AS2 = p2_op_move[1:i-1,mat[2,m]]
                else
                    kariAS2 = p2_op_move[1:i-1,mat[2,m]]
                    ranz2 = randn(length(kariAS2))
                    z2 = sortperm(ranz2)
                    AS2 = zeros(Int,sample_param)
                    for as2_ind in 1:sample_param
                        AS2[as2_ind] = kariAS2[z2[as2_ind]]
                    end
                end
                for as2_len in 1:length(AS2)
                    if AS2[as2_len] == 1
                        P_1of2[mat[2,m]] += payoff_matrix[1][2]
                        P_2of2[mat[2,m]] += payoff_matrix[3][2]
                    else
                        P_1of2[mat[2,m]] += payoff_matrix[2][2]
                        P_2of2[mat[2,m]] += payoff_matrix[4][2]
                    end
                end
                if P_1of2[mat[2,m]] > P_2of2[mat[2,m]]
                    pr1of2[mat[2,m]] = 1
                elseif P_1of2[mat[2,m]] == P_2of2[mat[2,m]]
                    pr1of2[mat[2,m]] = 0.5
                elseif P_1of2[mat[2,m]] < P_2of2[mat[2,m]]
                    pr1of2[mat[2,m]] = 0
                end
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

            #フィードバック部分
            p1_op_move[i,mat[1,m]] = p2_act[mat[2,m]]
            p2_op_move[i,mat[2,m]] = p1_act[mat[1,m]]
        end
    end
    num_of_1of1 = zeros(Int,4)
    num_of_2of1 = zeros(Int,4)
    num_of_1of2 = zeros(Int,4)
    num_of_2of2 = zeros(Int,4)
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