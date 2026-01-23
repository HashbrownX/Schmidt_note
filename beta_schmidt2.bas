Attribute VB_Name = "模块1"

' 定义一个子程序，用于执行斯特林引擎的施密特理论分析
Sub beta_stirling_analysis()
    ' 声明变量，用于存储工作表对象和各种计算参数
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets(1) ' 获取当前工作簿的第一个工作表
    
    Dim i As Integer ' 循环索引
    Dim theta As Double, Ve As Double, Vc As Double, Vtotal As Double, p As Double ' 角度、容积、压力等物理量
    Dim de As Double, Se As Double, dc As Double, Sc As Double ' 活塞直径和冲程
    Dim Ved As Double, Vcd As Double, Vh As Double, Vr As Double, Vk As Double ' 死容积、热交换器容积
    Dim Te As Double, Tr As Double, Tc As Double, tau As Double ' 温度和温比
    Dim delta As Double, phi As Double, Pmean As Double ' 压力波动参数、相位角、平均压力
    Dim N As Double, Xv As Double, DeltaTheta As Double ' 转速、容积比、相位角
    Dim V_e0 As Double, V_c0 As Double ' 行程容积
    Dim W_h As Double, W_c As Double, W_i As Double ' 膨胀功、压缩功、指示功
    Dim L_i As Double, eta As Double ' 功率和效率

    ' --- 从工作表单元格读取用户输入的参数 ---
    de = ws.Range("D5").Value / 100 ' 膨胀侧活塞径
    Se = ws.Range("D6").Value / 100 ' 膨胀侧冲程
    dc = ws.Range("D9").Value / 100 ' 压缩侧活塞径
    Sc = ws.Range("D10").Value / 100  ' 压缩侧冲程
    Vh = ws.Range("D13").Value / 1000000 ' 加热器容积
    Vr = ws.Range("D14").Value / 1000000 ' 再生器容积
    Vk = ws.Range("D15").Value / 1000000 ' 冷却器容积
    Ved = ws.Range("D17").Value / 1000000 ' 高温侧死容积
    Vcd = ws.Range("D18").Value / 1000000 ' 压缩侧死容积
    Te = ws.Range("D21").Value + 273.15 ' 膨胀侧温度 (转为K)
    Tc = ws.Range("D23").Value + 273.15 ' 压缩侧温度 (转为K)
    alpha_d = ws.Range("D26").Value ' 相位角 (deg)
    alpha = alpha_d * Application.WorksheetFunction.Pi() / 180 ' 相位角 (转为弧度)
    N = ws.Range("D27").Value ' 转速 (rpm)
    Pmean = ws.Range("D28").Value * 1000 ' 平均压力 (转为Pa)

    ' --- 计算行程容积 ---
    V_e0 = Application.WorksheetFunction.Pi() / 4 * de ^ 2 * Se ' 膨胀侧行程容积
    V_c0 = Application.WorksheetFunction.Pi() / 4 * dc ^ 2 * Sc ' 压缩侧行程容积
    V_b = (V_e0 + V_c0) / 2 - Sqr((V_e0 ^ 2 + V_c0 ^ 2) / 4 - V_e0 * V_c0 * Cos(alpha) / 2)
    Pi = Application.WorksheetFunction.Pi()

    ' --- 计算温度比 ---
    tau = Tc / Te ' 温比
    kappa = V_c0 / V_e0    '% 容积比
    chi_B = V_b / V_e0     ' 重叠容积比
    chi = Vr / V_e0        '% 回热器死区比
    phi = Atn((kappa * Sin(alpha)) / (1 - tau - kappa * Cos(alpha)))  '相位偏移角
    S = tau + (4 * tau * chi) / (1 + tau) + kappa + 1 - 2 * chi_B    '平均容积因子
    B = Sqr(tau * tau + 2 * kappa * (tau - 1) * Cos(alpha) + kappa * kappa - 2 * tau + 1) '振幅因子
    delta = B / S
    
    ws.Range("D36:D42").ClearContents  ' --- 清空之前的数据区域 ---
    ws.Range("D36").Value = alpha      ' 相位角 (转为弧度)
    ws.Range("D37").Value = chi_B      ' 重叠容积比
    ws.Range("D38").Value = chi        '% 回热器死区比
    ws.Range("D39").Value = phi        '相位偏移角
    ws.Range("D40").Value = S          '平均容积因子
    ws.Range("D41").Value = B          '振幅因子
    ws.Range("D42").Value = delta

    ' --- 清空之前的数据区域 ---
    ws.Range("F5:J1000").ClearContents

    ' --- 开始循环，计算每个曲柄角 (0 to 359 degrees) 下的参数 ---
    For i = 0 To 720
        theta = i * Application.WorksheetFunction.Pi() / 180 ' 当前角度 (转为弧度)

        ' --- 计算各部分容积 ---
        Ve = V_e0 * (1 - Cos(theta)) / 2   ' 膨胀侧容积 (β型公式)
        Vc = V_c0 * (1 + Cos(theta)) / 2 + V_c0 * (1 - Cos(theta - alpha)) / 2 - V_b  ' 压缩侧容积 (β型公式)
        Vtotal = Vcd + Ved + Ve + Vc + Vr + Vh + Vk ' 总容积

        ' --- 计算瞬时压力 ---
        p = Pmean * Sqr(1 - delta * delta) / (1 - delta * Cos(theta - phi)) ' 瞬时压力 (施密特理论)

        ' --- 将计算结果写入工作表 ---
        ws.Cells(i + 5, 6).Value = i ' 角度
        ws.Cells(i + 5, 7).Value = Ve ' 膨胀容积
        ws.Cells(i + 5, 8).Value = Vc ' 压缩容积
        ws.Cells(i + 5, 9).Value = Vtotal ' 总容积
        ws.Cells(i + 5, 10).Value = p ' 压力
    Next i
    
    W_h = (Pmean * V_e0 * Pi * delta * Sin(phi)) / (1 + Sqr(1 - delta * delta))
    W_c = (Pmean * V_e0 * Pi * delta * tau * Sin(phi)) / (1 + Sqr(1 - delta * delta))

    ' --- 计算总指示功、功率和效率 ---
    W_i = W_h + W_c ' 总指示功 (膨胀功 + 压缩功)
    L_i = W_i * N / 60 ' 指示功率 (Watts)
    eta = 1 - tau ' 热效率

    ' --- 将结果写入指定的单元格 ---
    ws.Range("D30:D34").ClearContents
    ws.Range("D30").Value = W_h ' 输出膨胀功
    ws.Range("D31").Value = W_c ' 输出压缩功
    ws.Range("D32").Value = W_i ' 输出总指示功
    ws.Range("D34").Value = L_i ' 输出指示功率 (W)

    ' --- 调用创建图表的子程序 ---
    Call Create_Charts

End Sub
Sub Create_Charts()
   
    Dim ws As Worksheet                    ' 声明一个工作表对象变量，并让它指向当前工作簿的第一个工作表
    Set ws = ThisWorkbook.Sheets(1)

    ' --- 清空旧图表 ---
    
    On Error Resume Next                   ' 当发生错误时（例如，如果工作表上没有图表），忽略错误并继续执行
   
    Application.DisplayAlerts = False      ' 关闭 Excel 的警告提示（例如删除图表时的确认框）
   
    ws.ChartObjects.Delete                 ' 删除工作表上所有的图表对象
   
    Application.DisplayAlerts = True       ' 重新开启 Excel 的警告提示
    
    On Error GoTo 0                        ' 恢复正常的错误处理模式（遇到错误则停止并报错）

    ' --- 创建 V-θ 图 ---
   
    Dim Chart1 As ChartObject              ' 声明一个图表对象变量，用于创建新的图表
    ' 在工作表上添加一个新的图表对象，并设定其位置和大小
    ' Left: 距离工作表左边界的距离 (像素)
    ' Top: 距离工作表上边界的距离 (像素)
    ' Width: 图表的宽度 (像素)
    ' Height: 图表的高度 (像素)
    Set Chart1 = ws.ChartObjects.Add(Left:=50, Top:=300, Width:=400, Height:=300)
    
    ' 对刚刚创建的 Chart1 对象进行配置
    With Chart1.Chart ' With 语句可以简化对 Chart1.Chart 对象的多次引用
        .ChartType = xlXYScatterSmoothNoMarkers     ' 设置图表类型为“平滑线散点图（无标记）”
                                                    ' .SetSourceData Source:=ws.Range("F5:G364") ' 这行设置了初始数据源，但后面会添加更多系列，所以可以注释掉
        .HasTitle = True ' 让图表显示标题
        .ChartTitle.Text = "V-θ 图" ' 设置图表的标题文本
        ' 设置 X 轴（类别轴）的标题
        .Axes(xlCategory, xlPrimary).HasTitle = True ' 让 X 轴显示标题
        .Axes(xlCategory, xlPrimary).AxisTitle.Text = "曲柄角 (deg)" ' 设置 X 轴标题文本
        ' 设置 Y 轴（数值轴）的标题
        .Axes(xlValue, xlPrimary).HasTitle = True ' 让 Y 轴显示标题
        .Axes(xlValue, xlPrimary).AxisTitle.Text = "容积 (m3)" ' 设置 Y 轴标题文本
        
        ' 添加第一个数据系列（膨胀侧容积 vs 角度）
        .SeriesCollection.NewSeries ' 在图表中创建一个新的数据系列
        .SeriesCollection(1).Name = "膨胀侧容积" ' 给这个系列命名
        .SeriesCollection(1).XValues = ws.Range("F5:F725") ' 设置 X 轴数据来自 F 列（角度）
        .SeriesCollection(1).Values = ws.Range("G5:G725") ' 设置 Y 轴数据来自 G 列（膨胀侧容积）
        
        ' 添加第二个数据系列（压缩侧容积 vs 角度）
        .SeriesCollection.NewSeries ' 再创建一个新系列
        .SeriesCollection(2).Name = "压缩侧容积" ' 给这个系列命名
        .SeriesCollection(2).XValues = ws.Range("F5:F725") ' X 轴数据同样来自 F 列（角度）
        .SeriesCollection(2).Values = ws.Range("H5:H725") ' Y 轴数据来自 H 列（压缩侧容积）
        .Axes(xlValue, xlPrimary).TickLabels.NumberFormat = "0.00E+00"
        
         ' 添加第三个数据系列（总容积 vs 角度）
        .SeriesCollection.NewSeries ' 再创建一个新系列
        .SeriesCollection(3).Name = "总容积" ' 给这个系列命名
        .SeriesCollection(3).XValues = ws.Range("F5:F725") ' X 轴数据同样来自 F 列（角度）
        .SeriesCollection(3).Values = ws.Range("I5:I725") ' Y 轴数据来自 I 列（总容积）
        .Axes(xlValue, xlPrimary).TickLabels.NumberFormat = "0.00E+00"
    End With ' 结束对 Chart1.Chart 的配置

    ' --- 创建 p-V 图 ---
    ' 声明另一个图表对象变量
    Dim Chart2 As ChartObject
    ' 在工作表的不同位置添加第二个图表对象
    Set Chart2 = ws.ChartObjects.Add(Left:=500, Top:=300, Width:=400, Height:=300)
    
    ' 对刚刚创建的 Chart2 对象进行配置
    With Chart2.Chart
        .ChartType = xlXYScatterSmoothNoMarkers ' 同样设置为平滑线散点图
        ' .SetSourceData Source:=ws.Range("G5:J364") ' 这行设置了初始数据源，但后面会添加系列，可以注释掉
        .HasTitle = True ' 显示图表标题
        .ChartTitle.Text = "p-V 图" ' 设置标题文本
        ' 设置 X 轴（类别轴）的标题
        .Axes(xlCategory, xlPrimary).HasTitle = True ' 显示 X 轴标题
        .Axes(xlCategory, xlPrimary).AxisTitle.Text = "容积 (m3)" ' 设置 X 轴标题文本
        ' 设置 Y 轴（数值轴）的标题
        .Axes(xlValue, xlPrimary).HasTitle = True ' 显示 Y 轴标题
        .Axes(xlValue, xlPrimary).AxisTitle.Text = "压力 (Pa)" ' 设置 Y 轴标题文本
        
        ' 添加数据系列（压力 vs 膨胀侧容积）
        .SeriesCollection.NewSeries ' 创建一个新的数据系列
        .SeriesCollection(1).Name = "压力" ' 给这个系列命名
        .SeriesCollection(1).XValues = ws.Range("I5:I364") ' X 轴数据来自 G 列（总容积）
        .SeriesCollection(1).Values = ws.Range("J5:J364") ' Y 轴数据来自 J 列（压力）
        .Axes(xlCategory, xlPrimary).TickLabels.NumberFormat = "0.00E+00"
        .Axes(xlValue, xlPrimary).TickLabels.NumberFormat = "0.00E+00"
    End With ' 结束对 Chart2.Chart 的配置

End Sub ' 结束整个 Create_Charts 子程序

