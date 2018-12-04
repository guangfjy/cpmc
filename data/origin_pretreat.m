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

%��ȡԭͼ����ģ
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

%��ȡROI
hi = imshow(src);
position = [1, 1, 500, 500];
hr = imrect(hi.Parent, position);
pos = wait(hr);%�õ����ε���ʼ��ͳ���

%��ͼԭͼ����ģ
crop_src = src(pos(2):pos(2)+499, pos(1):pos(1)+499 , :);
crop_msk = msk(pos(2):pos(2)+499, pos(1):pos(1)+499);

%save origin as jpg, save segment as png
if(save)
    % color antenna area
    load('./colormap256.mat');
    
    %ȥ��С����
    %Determine the connected components.
    L = bwlabeln(crop_msk);
	%Compute the area of each component.
    S = regionprops(L, 'Area');
	%Remove small objects.
    bw2 = ismember(L, find([S.Area] >= 50));

    %��ע��ͨ����
    [segmentation, ~] = bwlabel(bw2);
    %��ȡ�߽磬��255
    se = strel('disk', 2);
    bw3 = imdilate(bw2,se);
    segmentation(xor(bw3, bw2)) = 255;

    %������
    imwrite(crop_src, [path_src pic_name '_small.jpg']); %��ͼ��ͼ
    imwrite(crop_msk, [path_msk pic_name '_small.bmp']); %��ģ��ͼ
    imwrite(crop_src, [path_dst_src pic_name '.jpg']); %��ͼ��ͼ
    imwrite(uint8(segmentation), map256, [path_dst_msk pic_name '.png']); %���ͼ
end

%draw mask on origin & show
if(disp)
    msk = segmentation;
    msk(msk==255) = 0;
    lesionCoutour = bwboundaries(msk);
    
    %��ԭͼ�ϸ�����ʾ��ģ�߽�ͱ��
    imshow(msk)
    hold on
    for k = 1:length(lesionCoutour)
        plot(lesionCoutour{k}(:,2), lesionCoutour{k}(:,1), 'r', 'LineWidth', 1)
        
        x = lesionCoutour{k}(1,2);
        y = lesionCoutour{k}(1,1);
        text(x, y, num2str(msk(y,x)), 'Color', 'green', 'FontSize', 10);
    end
    
%     %��ԭͼ�ϸ�����ʾ��ģ��
%     %������ģ
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
%     res = immerge(crop_src, bg, .3); %�ϳɸ���ͼ
%     imshow(res); %��ʾͼ��
%     %��ʾ���
%     hold on
%     for k = 1:length(lesionCoutour)
%         x = lesionCoutour{k}(1,2);
%         y = lesionCoutour{k}(1,1);
%         text(x, y, num2str(msk(y,x)), 'Color', 'green', 'FontSize', 10);
%     end
end

end