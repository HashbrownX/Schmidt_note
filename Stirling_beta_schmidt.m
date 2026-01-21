clc;clear all;
T_h = 1073; % 热端温度 [K]
T_c = 320;  % 冷端温度 [K]
p_mean = 12e6;    % 平均压力 [Pa]
V_SE = 182.5e-6; % 膨胀空间扫气容积 [m³]
V_SC = 182.5e-6; % 压缩空间扫气容积 [m³]
alpha_deg = 90;   % 相位角 [deg]
n_rpm = 50 * 60;  % 转速 [rpm]
V_R = 100e-6;     % 回热器容积 [m³]
schmidt_stirling_analysis(T_h, T_c, p_mean, V_SE, V_SC, alpha_deg, n_rpm, V_R);
function schmidt_stirling_analysis(T_h, T_c, p_mean, V_SE, V_SC, alpha_deg, n_rpm, V_R)
    % 施密特理论斯特林发动机性能分析
    % 严格遵守 Wi = WE + WC，其中 WC 为负
    % 输入参数:
    %   T_h: 热端温度 [K]
    %   T_c: 冷端温度 [K]
    %   p_mean: 平均压力 [Pa]
    %   V_SE: 膨胀空间扫气容积 [m³]
    %   V_SC: 压缩空间扫气容积 [m³]
    %   alpha_deg: 相位角 [deg]
    %   n_rpm: 转速 [rpm]
    %   V_R: 回热器容积 [m³]

    %% === 1. 设计参数输入 ===
    fprintf('=== 施密特循环斯特林发动机性能分析===\n');  
    tau = T_c / T_h; % 温比
    fprintf('热端温度 T_h = %.1f K\n', T_h);
    fprintf('冷端温度 T_c = %.1f K\n', T_c);
    fprintf('温比 tau = T_c/T_h = %.4f\n\n', tau);
    % --- 几何与操作参数 ---
    alpha = deg2rad(alpha_deg); % 转换为弧度

    fprintf('平均压力 p_mean = %.2f MPa\n', p_mean/1e6);
    fprintf('膨胀腔扫气容积 V_SE = %.2f cm³\n', V_SE*1e6);
    fprintf('压缩腔扫气容积 V_SC = %.2f cm³\n', V_SC*1e6);
    fprintf('相位角 alpha = %.1f deg\n', alpha_deg);
    fprintf('回热器容积 V_R = %.2f cm³\n', V_R*1e6);
    fprintf('转速 n = %.0f rpm (%.1f Hz)\n\n', n_rpm, n_rpm/60);
    %% === 2. 计算中间参数 ===
    kappa = V_SC / V_SE; % 容积比
    chi = V_R / V_SE;    % 回热器死区比
    % 计算 V_B 和 chi_B
    V_B = (V_SE + V_SC)/2 - sqrt( (V_SE^2 + V_SC^2)/4 - (V_SE*V_SC/2) * cos(alpha) );
    chi_B = V_B / V_SE; % 重叠死区比
    % 计算 B, S, delta, phi
    S = tau + (4*tau*chi)/(1+tau) + kappa + 1 - 2*chi_B;
    B = sqrt( tau^2 + 2*kappa*(tau - 1)*cos(alpha) + kappa^2 - 2*tau + 1 );
    delta = B / S;
    phi = atan2(kappa * sin(alpha), 1 - tau - kappa * cos(alpha));
    fprintf('=== 中间计算参数 ===\n');
    fprintf('容积比 kappa = V_SC/V_SE = %.4f\n', kappa);
    fprintf('回热器死区比 chi = V_R/V_SE = %.4f\n', chi);
    fprintf('重叠容积 V_B = %.2f cm³\n', V_B*1e6);
    fprintf('重叠死区比 chi_B = V_B/V_SE = %.4f\n', chi_B);
    fprintf('压力波动参数 delta = %.4f\n', delta);
    fprintf('相位偏移角 phi = %.2f deg\n\n', rad2deg(phi));
    %% === 3. 计算性能指标 ===
    % 角度向量
    theta = linspace(0, 2*pi, 1000);
    % ---图示功---
    % W_E 为正值
    W_E_calc = (p_mean * V_SE * pi * delta * sin(phi)) / (1 + sqrt(1 - delta^2));
    % W_C 给出的是压缩耗功的绝对值，但实际功为负
    W_C_abs = (p_mean * V_SE * pi * delta * tau * sin(phi)) / (1 + sqrt(1 - delta^2));
    W_C_calc = - W_C_abs; % 实际代数值为负
    % 总指示功 Wi = WE + WC (WC 为负)
    W_i_calc = W_E_calc + W_C_calc;
    % --- 输出功率 (公式 3.128) ---
    L_i_W = (W_i_calc * n_rpm) / 60; % 单位 W
    L_i_kW = L_i_W / 1000;      % 单位 kW
    % --- 热效率 (公式 3.129) ---
    % eta= W_i_calc/W_E_calc=1 - tau
    eta= 1 - tau;
    % --- 压力比 ---
    p_min_ratio = sqrt(1 - delta) / sqrt(1 + delta);
    p_max_ratio = sqrt(1 + delta) / sqrt(1 - delta);
    p_min = p_mean * p_min_ratio;
    p_max = p_mean * p_max_ratio;
    
    fprintf('=== 性能计算结果 ===\n');
    fprintf('膨胀功 W_E = %.2f J/cycle\n', W_E_calc);
    fprintf('压缩功 (绝对值) |W_C| = %.2f J/cycle\n', W_C_abs);
    fprintf('压缩功 (代数值) W_C = %.2f J/cycle\n', W_C_calc);
    fprintf('总指示功 W_i = W_E + W_C = %.2f J/cycle\n', W_i_calc);
    fprintf('(验证: W_E * (1 - tau) = %.2f J/cycle)\n', W_E_calc * (1-tau));
    fprintf('指示功率 L_i = %.2f kW\n', L_i_kW);
    fprintf('热效率 eta = %.4f (%.2f%%)\n', eta, eta*100);
    fprintf('最小压力 p_min = %.2f MPa\n', p_min/1e6);
    fprintf('最大压力 p_max = %.2f MPa\n', p_max/1e6);
    fprintf('压力比 p_max/p_min = %.3f\n\n', p_max/p_min);
    %% === 4. 绘制 p-V 图 ===
    % 计算瞬时容积
    V_E_t = V_SE / 2 * (1 - cos(theta));
    V_C_t = V_SE / 2 * (1 + cos(theta)) + V_SC / 2 * (1 - cos(theta - alpha)) - V_B;
    V_total_t = V_E_t + V_C_t + V_R;
    % 计算瞬时压力 (公式 3.101a)
    p_t = (p_mean * sqrt(1 - delta^2)) ./ (1 - delta * cos(theta - phi));  %矩阵点除，逐元素除法（A/B）
    % 绘制膨胀腔的 p-V 图
    figure;
    plot(V_E_t*1e6, p_t/1e6, 'b-', 'LineWidth', 2);
    xlabel('膨胀腔容积 V_E [cm³]');
    ylabel('压力 p [MPa]');
    title(sprintf('膨胀腔 p-V 图 (T_h=%.0fK, T_c=%.0fK, p_{mean}=%.0fMPa)', T_h, T_c, p_mean/1e6));
    grid on;
    axis([min(V_E_t)*1e6, max(V_E_t)*1e6, p_min/1e6, p_max/1e6]);
    % 绘制压缩腔的 p-V 图
    figure;
    plot(V_C_t*1e6, p_t/1e6, 'r-', 'LineWidth', 2);
    xlabel('压缩腔容积 V_C [cm³]');
    ylabel('压力 p [MPa]');
    title(sprintf('压缩腔 p-V 图 (T_h=%.0fK, T_c=%.0fK,  p_{mean}=%.0fMPa)', T_h, T_c, p_mean/1e6));
    grid on;
    axis([min(V_C_t)*1e6, max(V_C_t)*1e6, p_min/1e6, p_max/1e6]);
    % 绘制总容积的 p-V 图
    figure;
    plot(V_total_t*1e6, p_t/1e6, 'k-', 'LineWidth', 2);
    xlabel('总容积 V_{total} [cm³]');
    ylabel('压力 p [MPa]');
    title(sprintf('总容积 p-V 图 (T_h=%.0fK, T_c=%.0fK, p_{mean}=%.0fMPa)', T_h, T_c, p_mean/1e6));
    grid on;
    axis([min(V_total_t)*1e6, max(V_total_t)*1e6, p_min/1e6, p_max/1e6]);
    %% === 5. 绘制效率随温比变化曲线 ===
    figure('Name', '施密特理论效率曲线');
    taus = linspace(0.1, 0.9, 100);
    etas = 1 - taus;
    plot(taus, etas, 'g-', 'LineWidth', 2);
    xlabel('温比 \tau = T_c / T_h');
    ylabel('热效率 \eta');
    title('施密特理论热效率 vs 温比');
    grid on;
    yline(eta, '--k', sprintf('当前 \eta = %.4f', eta));
    xline(tau, '--k', sprintf('当前 \tau = %.4f', tau));

end
% --- End of Function ---