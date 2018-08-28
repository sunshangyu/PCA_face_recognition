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
%��������
%�������ƽ�������߾�ֵ
%ʹ�÷���M = mean(A)
%�����������в�ͬά��Ԫ�ص�ƽ��ֵ��
%���A��һ��������mean(A)����A��Ԫ�ص�ƽ��ֵ��
%���A��һ������mean(A)�����еĸ�����Ϊ�������Ѿ����е�ÿ�п���һ������������һ������ÿһ������Ԫ�ص�ƽ��ֵ����������
%���A��һ����Ԫ���飬mean(A)�������е�һ���ǵ�һά��ֵ����һ������������ÿ��������ƽ��ֵ��
average_sample = mean(all_stuff);%ƽ��ͼƬ
%reshape��ָ���ľ���ı���״������Ԫ�ظ�������
% mat2gray���ܣ�������ת��Ϊ�Ҷ�ͼ��
%�÷���I = mat2gray(A,[amin amax])
%��һ��double�����������ת����ȡֵ��ΧΪ[0 1]������ͼ��
%����ͼ��I��ȡֵ��ΧҲ��0����ɫ����1����ɫ��֮�䡣
figure('Name', 'ƽ����');
temp_average_sample = mat2gray(reshape(average_sample,147,137));
imshow(temp_average_sample);
imwrite(temp_average_sample, strcat('C:\Users\sun',...
        '\Desktop\PCA\ƽ����.jpg'));
%����ÿ��ͼƬ��ƽ��ͼ֮��Ĳ�ֵ
for i = 1 : 105
    xmean(i, :) = all_stuff(i, :) - average_sample;
end;
%xmean��Э�������
sigma = xmean * xmean';
%�����sigma��ȫ������ֵ�����ɶԽ���D������sigma��������������V����������
[v, d] = eig(sigma);
%��dתΪһά����
d1 = diag(d);
%����������
[d2, index] = sort(d1);
%�����������������
cols = size(v, 2);
%��������ֵ��ɵĽ�������
for i = 1 : cols
    % vsort ��һ��105 * col�׾��󣬱�����ǰ��������е�����������ÿһ�й���һ����������      
    vsort(:, i) = v(:, index(cols - i + 1));
    % dsort ������ǰ��������е�����ֵ����һά������
    dsort(i) = d1(index(cols - i + 1));
end
%����ֵ�ĺ�
dsum = sum(dsort);
dsum_extract = 0;
p = 0;
%ѡȡǰp������ֵ����p������ֵ�ĺ�ռ������ֵ��99%
while( dsum_extract / dsum < 0.99)
    p = p + 1;
    dsum_extract = sum(dsort(1 : p));
end

% (ѵ���׶�)�����������γɵ�����ϵ
i = 1;
while(i <= p && dsort(i) > 0)
    % base��N��p�׾��󣬳���dsort(i)^(1/2)�Ƕ�����ͼ��ı�׼����������
    base(:, i) = dsort(i)^(-1/2) * xmean' * vsort(:, i);
    i = i + 1;
end
for i = 1 : p
    %figure('Name', strcat('������', num2str(i)));
    imwrite((reshape(xmean' * vsort(:, i),147, 137)), strcat('C:\Users\sun',...
        '\Desktop\PCA\Chara_face\',num2str(i),'.jpg'));
end
% ���Թ���
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
        tcoor= b * base; %�������꣬��1��p�׾���      
        for k = 1 : 105
            mdist(k) = norm(tcoor - allcoor(k, :));
        end;          %���׽���
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
fprintf('׼ȷ�� %.2f\n',accuracy * 100);