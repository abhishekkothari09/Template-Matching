clc;
close all;
clear all;

i=imread('plate3.jpg');      % read the image.
tic;
i=imresize(i,[400 NaN]);     % resize the image.
% imshow(i);                   % show original image.
g=rgb2gray(i);               % convert color image to grayscale.
g=medfilt2(g,[3 3]);         % apply median/average filtering.
se=strel('disk',1);          % use a disk structuring element with radius 1.
dilate=imdilate(g,se);       % dilate the image.
erode=imerode(g,se);         % erode the image.
gdiff=imsubtract(dilate,erode);           % sutract both.
gdiff=mat2gray(gdiff);                    % convert to grayscale.
gdiff=conv2(gdiff,[1 1;1 1]);             % perform 2D convolution.
gdiff=imadjust(gdiff,[0.5 0.7],[0 1],.1); % adjust the intensity values.
B=logical(gdiff);                         % convert to logical type.
[a1,b1]=size(B);
%figure(2)
%imshow(B)
er=imerode(B,strel('line',101,0));        % erosion with line structuring element.
% figure(3)
% imshow(er)
out1=imsubtract(B,er);                    % subtract processed image with eroded image.
F=imfill(out1,'holes');                   % filling the object.
H=bwmorph(F,'thin',1);                    % thinning on binary image.
H=imerode(H,strel('line',3,90));          % erosion again using line.
% figure(4)
% imshow(H)

final=bwareaopen(H,floor((a1/15)*(b1/15)));  % remove small objects from image.
final(1:floor(.9*a1),1:2)=1;
final(a1:-1:(a1-20),b1:-1:(b1-2))=1;
yyy=template(2);
% figure(5)
% imshow(final)
Iprops=regionprops(final,'BoundingBox','Image'); % use the proerties of regions from image.

%--uncomment the following 5 lines to see the bounding boxes
% hold on            
% for n=1:size(Iprops,1)
%     rectangle('Position',Iprops(n).BoundingBox,'EdgeColor','g','LineWidth',2); % create boxes of geen color around blobs.
% end
% hold off

NR=cat(1,Iprops.BoundingBox);  % Store the coordinates of the bounding boxes in a matrix format.
[r,ttb]=connn(NR);

if ~isempty(r)
    xlow=floor(min(reshape(ttb(:,1),1,[])));
    xhigh=ceil(max(reshape(ttb(:,1),1,[])));
    xadd=ceil(ttb(size(ttb,1),3));
    ylow=floor(min(reshape(ttb(:,2),1,[])));          % area selection.
    yadd=ceil(max(reshape(ttb(:,4),1,[])));
    final1=H(ylow:(ylow+yadd+(floor(max(reshape(ttb(:,2),1,[])))-ylow)),xlow:(xhigh+xadd));
    [a2,b2]=size(final1);
    final1=bwareaopen(final1,floor((a2/20)*(b2/20))); % remove unwanted areas above and below.
%     figure(6)
%     imshow(final1)
    
   
    Iprops1=regionprops(final1,'BoundingBox','Image');
    NR3=cat(1,Iprops1.BoundingBox);
    I1={Iprops1.Image};
    
    carnum=[];
    if (size(NR3,1)>size(ttb,1))
        [r2,to]=connn2(NR3);
        
        for i=1:size(Iprops1,1)
           
            
            ff=find(i==r2);
            if ~isempty(ff)
                N1=I1{1,i};
                letter=readLetter(N1,2);
            else
                N1=I1{1,i};
                letter=readLetter(N1,1);
            end
            if ~isempty(letter)
                carnum=[carnum letter];
            end
        end
    else
        for i=1:size(Iprops1,1)
            N1=I1{1,i};
            letter=readLetter(N1,1);
            carnum=[carnum letter];
        end
    end
    
    fid1 = fopen('template_matching_output.txt', 'wt'); %create file with write permission
    fprintf(fid1,'%s',carnum);                          % write the stored value of variable carnum.
    fclose(fid1);
    winopen('template_matching_output.txt')             % open the text file.
   
    else
    fprintf('license plate recognition failure\n');
    fprintf('Characters are not clear \n');
end
elapsed_time=toc;                  % stores the time taken for execution