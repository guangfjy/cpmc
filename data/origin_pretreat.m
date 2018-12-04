function pre(pic_name, save, disp)

pic_name = '136-019';
save = true;
disp = true;

img_name = pic_name;
path_src = './origin_src/';
path_msk = './origin_msk/';
path_dst_src = './JPEGImages/';
path_dst_msk = './SegmentationObject/';

if(~isdir(path_dst_msk))
    mkdir(path_dst_msk);
end

%读取原图和掩模
try
    src = imread([path_src img_name '.jpg']);
catch
    disp([path_src img_name '.jpg does not exist.']);
    return;
end
try
    msk = imread([path_msk img_name '.tiff']);
catch
    disp([path_msk img_name '.tiff does not exist.']);
    return;
end

%获取ROI
hi = imshow(src);
position = [1, 1, 500, 500];
hr = imrect(hi.Parent, position);
pos = wait(hr);%得到矩形的起始点和长宽

%截图原图和掩模
crop_src = src(pos(2):pos(2)+499, pos(1):pos(1)+499 , :);
crop_msk = msk(pos(2):pos(2)+499, pos(1):pos(1)+499);

%save origin as jpg, save segment as png
if(save)
    % color antenna area
    load('./colormap256.mat');
    
    %去除小区域
    %Determine the connected components.
    L = bwlabeln(crop_msk);
	%Compute the area of each component.
    S = regionprops(L, 'Area');
	%Remove small objects.
    bw2 = ismember(L, find([S.Area] >= 50));

    %标注连通区域
    [segmentation, ~] = bwlabel(bw2);
    %获取边界，置255
    se = strel('disk', 2);
    bw3 = imdilate(bw2,se);
    segmentation(xor(bw3, bw2)) = 255;

    %保存结果
    imwrite(crop_src, [path_src pic_name '_small.jpg']); %大图截图
    imwrite(crop_msk, [path_msk pic_name '_small.bmp']); %掩模截图
    imwrite(crop_src, [path_dst_src pic_name '.jpg']); %大图截图
    imwrite(uint8(segmentation), map256, [path_dst_msk pic_name '.png']); %标记图
end

%draw mask on origin & show
if(disp)
    msk = segmentation;
    msk(msk==255) = 0;
    lesionCoutour = bwboundaries(msk);
    
    %在原图上覆盖显示掩模边界和标号
    imshow(msk)
    hold on
    for k = 1:length(lesionCoutour)
        plot(lesionCoutour{k}(:,2), lesionCoutour{k}(:,1), 'r', 'LineWidth', 1)
        
        x = lesionCoutour{k}(1,2);
        y = lesionCoutour{k}(1,1);
        text(x, y, num2str(msk(y,x)), 'Color', 'green', 'FontSize', 10);
    end
    
%     %在原图上覆盖显示掩模块
%     %设置掩模
%     bg = zeros(size(crop_msk,1), size(crop_msk,2), 3);
%     [I, J] = find(msk);
%     for i = 1: length(I)
%         y = I(i); 
%         x = J(i);
%         idx = msk(y, x) + 1;
%         bg(y, x, 1) = map256(idx, 1);
%         bg(y, x, 2) = map256(idx, 2);
%         bg(y, x, 3) = map256(idx, 3);
%         bg = uint8(255*bg);
%     end
%     res = immerge(crop_src, bg, .3); %合成覆盖图
%     imshow(res); %显示图像
%     %显示标号
%     hold on
%     for k = 1:length(lesionCoutour)
%         x = lesionCoutour{k}(1,2);
%         y = lesionCoutour{k}(1,1);
%         text(x, y, num2str(msk(y,x)), 'Color', 'green', 'FontSize', 10);
%     end
end

end