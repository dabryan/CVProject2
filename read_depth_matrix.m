function [disparity_data, depth_data] = read_depth_matrix(fname)

fd = fopen(fname,'rb');
disparity_data = zeros([480 640]);
for ii=1:480,
  disparity_data(ii,:) = fscanf(fd,'%f',[1 640]);
end

fclose(fd);
depth_data = 34800./(1091.5-disparity_data);
depth_neg = (depth_data>=0);
depth_data = depth_data .* depth_neg + (1-depth_neg)*-1;
return;
