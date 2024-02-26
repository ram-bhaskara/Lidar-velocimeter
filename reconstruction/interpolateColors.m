function interpolated_colors = interpolateColors(data, cmap, min_val, max_val)
    % Normalize data to [0, 1]
    normalized_data = (data - min_val) / (max_val - min_val);
    
    % Clip values to [0, 1]
    normalized_data(normalized_data < 0) = 0;
    normalized_data(normalized_data > 1) = 1;
    
    % Map normalized data to colormap indices
    indices = round(normalized_data * (size(cmap, 1) - 1)) + 1;
    
    % Interpolate colors
    interpolated_colors = cmap(indices, :);
end