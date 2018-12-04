function cpmc_example()  
    addpath('./code/');    
    addpath('./external_code/');
    addpath('./external_code/paraFmex/');
    addpath('./external_code/imrender/vgg/');
    addpath('./external_code/immerge/');
    addpath('./external_code/color_sift/');
    addpath('./external_code/vlfeats/toolbox/kmeans/');
    addpath('./external_code/vlfeats/toolbox/mex/mexa64/');
    addpath('./external_code/globalPb/lib/');
    addpath('./external_code/mpi-chi2-v1_5/');        
    
    % create multiple threads (set how many you have)
    ncores=feature('numCores'); %CPU������
    if ncores < 2
        error('the number of CPU cores is less than 2');
    end
    n = ncores - 1; %��ʵ�ʺ���С1��������ϵͳ��������������
    p = gcp('nocreate'); %��ȡ��ǰ���г���Ϣ
    if isempty(p)
        %���г�δ�򿪣����
        p = parpool(n);
    else
        %���г��Ѵ򿪣��鿴�߳���
        if p.NumWorkers ~= n
            %�߳������ԣ��ر����´�
            delete(p);
            p = parpool(n);
        end
    end
    fprintf(1, 'CPU������Ϊ%d��������%d�������߳�\n', ncores, p.NumWorkers);

    exp_dir = './data/';
    img_name = '2010_000238'; % airplane and people   
    %img_name = '2007_009084'; % dogs, motorbike, chairs, people    
    %img_name = '2010_002868'; % buses   
    %img_name = '2010_003781'; % cat, bottle, potted plants
    %img_name = 'test123';  %test crash 
       
   [masks, scores] = cpmc(exp_dir, img_name);
            
    I = imread([exp_dir '/JPEGImages/' img_name '.jpg']);
    
    %save all for debug
    save;

    % visualization and ground truth score for whole pool
    fprintf(['Best segments from initial pool of ' int2str(size(masks,3))]);
    Q = SvmSegm_segment_quality(img_name, exp_dir, masks, 'overlap');
    save('duh_32.mat', 'Q');
    avg_best_overlap = mean(max([Q.q]))
    SvmSegm_show_best_segments(I,Q,masks);
    
    % visualization and ground truth score for top 200 segments
    top_masks = masks(:, :, 1:min(200, size(masks, 3)));
    figure;
    disp('Best 200 segments after filtering');
    Q = SvmSegm_segment_quality(img_name, exp_dir, top_masks, 'overlap');
    avg_best_overlap = mean(max([Q.q]))
    SvmSegm_show_best_segments(I,Q,top_masks);
    fprintf('Best among top 200 after filtering\n\n');    
end