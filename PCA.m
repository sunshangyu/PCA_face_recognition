function PCA
all_stuff = []; 
for i = 1 : 15
    for j = 1 : 7
        if(i < 10)
            a = imread(strcat('C:\Users\sun\Desktop\PCA\face_store\00',...
                num2str(i),'\\0',num2str(j),'.jpg'));
        else
            a = imread(strcat('C:\Users\sun\Desktop\PCA\face_store\0',...
                num2str(i),'\\0',num2str(j),'.jpg'));
        end
        b = a(1 : 137 * 147);b = double(b);
        all_stuff = [all_stuff; b];
    end
end
%mean()
%函数功能
%求数组的平均数或者均值
%使用方法M = mean(A)
%返回沿数组中不同维的元素的平均值。
%如果A是一个向量，mean(A)返回A中元素的平均值。
%如果A是一个矩阵，mean(A)将其中的各列视为向量，把矩阵中的每列看成一个向量，返回一个包含每一列所有元素的平均值的行向量。
%如果A是一个多元数组，mean(A)将数组中第一个非单一维的值看成一个向量，返回每个向量的平均值。
average_sample = mean(all_stuff);%平均图片
%reshape把指定的矩阵改变形状，但是元素个数不变
% mat2gray功能：将矩阵转化为灰度图像。
%用法：I = mat2gray(A,[amin amax])
%把一个double类的任意数组转换成取值范围为[0 1]的亮度图像。
%其中图像I的取值范围也在0（黑色）到1（白色）之间。
figure('Name', '平均脸');
temp_average_sample = mat2gray(reshape(average_sample,147,137));
imshow(temp_average_sample);
imwrite(temp_average_sample, strcat('C:\Users\sun',...
        '\Desktop\PCA\平均脸.jpg'));
%计算每张图片和平均图之间的差值
for i = 1 : 105
    xmean(i, :) = all_stuff(i, :) - average_sample;
end;
%xmean的协方差矩阵
sigma = xmean * xmean';
%求矩阵sigma的全部特征值，构成对角阵D，并求sigma的特征向量构成V的列向量。
[v, d] = eig(sigma);
%将d转为一维矩阵
d1 = diag(d);
%以升序排序
[d2, index] = sort(d1);
%特征向量矩阵的列数
cols = size(v, 2);
%根据特征值完成的降序排列
for i = 1 : cols
    % vsort 是一个105 * col阶矩阵，保存的是按降序排列的特征向量，每一列构成一个特征向量      
    vsort(:, i) = v(:, index(cols - i + 1));
    % dsort 保存的是按降序排列的特征值，是一维行向量
    dsort(i) = d1(index(cols - i + 1));
end
%特征值的和
dsum = sum(dsort);
dsum_extract = 0;
p = 0;
%选取前p个特征值，这p个特征值的和占总特征值的99%
while( dsum_extract / dsum < 0.99)
    p = p + 1;
    dsum_extract = sum(dsort(1 : p));
end

% (训练阶段)计算特征脸形成的坐标系
i = 1;
while(i <= p && dsort(i) > 0)
    % base是N×p阶矩阵，除以dsort(i)^(1/2)是对人脸图像的标准化，特征脸
    base(:, i) = dsort(i)^(-1/2) * xmean' * vsort(:, i);
    i = i + 1;
end
for i = 1 : p
    %figure('Name', strcat('特征脸', num2str(i)));
    imwrite((reshape(xmean' * vsort(:, i),147, 137)), strcat('C:\Users\sun',...
        '\Desktop\PCA\Chara_face\',num2str(i),'.jpg'));
end
% 测试过程
allcoor = all_stuff * base;
accu = 0;
for i = 1 : 15
    for j = 8 : 11  
        if(i < 10)
            if(j < 10)
                a = imread(strcat('C:\Users\sun\Desktop\PCA\face_store\00',...
                num2str(i),'\\0',num2str(j),'.jpg'));
            else
                a = imread(strcat('C:\Users\sun\Desktop\PCA\face_store\00',...
                num2str(i),'\\',num2str(j),'.jpg'));
            end
        else
            if(j < 10)
                a = imread(strcat('C:\Users\sun\Desktop\PCA\face_store\0',...
                num2str(i),'\\0',num2str(j),'.jpg'));
            else
                a = imread(strcat('C:\Users\sun\Desktop\PCA\face_store\0',...
                num2str(i),'\\',num2str(j),'.jpg'));
            end
        end
        b = a(1 : 137 * 147);b = double(b);
        tcoor= b * base; %计算坐标，是1×p阶矩阵      
        for k = 1 : 105
            mdist(k) = norm(tcoor - allcoor(k, :));
        end;          %三阶近邻
        [dist,index2] = sort(mdist);
        class1 = floor(index2(1) / 5) + 1;
        class2 = floor(index2(2) / 5) + 1;
        class3 = floor(index2(3) / 5) + 1;
        if class1 ~= class2 && class2 ~= class3
            class = class1;
        elseif class1 == class2
            class = class1;
        elseif class2 == class3
            class = class2;
        end;
        if class == i
            accu = accu + 1;
        end;
    end;
end;
accuracy = accu / 105;
fprintf('准确率 %.2f\n',accuracy * 100);