%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 1到4维插值
% 用指定的方法内插，若不指定则默认是线性插值，表外的用线性插值外插
% 按照矩阵维数顺序使用 row*col*page...
% 主要使用 interp1 和 interpn
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function Vi = interpolate(varargin)
%%%function Vi = interpnskin(varargin)
% 具有线性外插功能的插值函数，支持1～4维插值，interpnskin的使用索引顺序按照矩阵维
% 数顺序。interpnskin使用interpne作为主要插值函数。
% 使用方法：
% interpnskin(index1,index2 ...,V,X1i,X2i,...)
% 其中index1 index2 ... 为索引列向量，V为多维矩阵V(index1,index2,index3,index4)
% X1i为插值向量或者标量，在不同的维数上的插值点
% 
% See also: interp1, interp2, interpn
% by masonghui 2006.7.5
% e-mail: masonghui@263.net
% Version: 1.0
% 修改说明：2006.11.29 王睿加上可选插值方法的功能，插值函数名改为'interpolate.m'

% 判断是否定义了插值方法，若无则取默认值'linear'
method = 'linear';
IPNUM = nargin; %输入参数的个数
if ischar( varargin{IPNUM} )    %判断最后一个参数是不是指定插值方法的字符
    'ischar!!!';
    method  = varargin{IPNUM};
    IPNUM = IPNUM-1;
end

if IPNUM==3       % 1维插值
% varargin{1}-x varargin{2}-y varargin{3}-xi
    Vi = interp1(varargin{1},varargin{2},varargin{3},method,'extrap');
elseif IPNUM==5   % 2维插值
% varargin{1}-X1 varargin{2}-X2 varargin{3}-V varargin{4}-X1i varargin{5}-X2i 
    nodelist = {varargin{1},varargin{2}};
    Xi = getInterpPoint(varargin{4},varargin{5});
    Vi = interpne(varargin{3},Xi,nodelist,method);
    Vi = Vector2Matrix(Vi,length(varargin{4}),length(varargin{5}));
elseif IPNUM==7   % 3维插值
% varargin{1}-X1 varargin{2}-X2 varargin{3}-X3 varargin{4}-V varargin{5}-X1i varargin{6}-X2i varargin{7}-X3i     
    nodelist = {varargin{1},varargin{2},varargin{3}};
    Xi = getInterpPoint(varargin{5},varargin{6},varargin{7});
    Vi = interpne(varargin{4},Xi,nodelist,method);
    Vi = Vector2Matrix(Vi,length(varargin{5}),length(varargin{6}),length(varargin{7}));
elseif IPNUM==9   % 4维插值
% varargin{1}-X1 varargin{2}-X2 varargin{3}-X3 varargin{4}-X4 varargin{5}-V varargin{6}-X1i varargin{7}-X2i varargin{9}-X3i varargin{9}-X4i     
    nodelist = {varargin{1},varargin{2},varargin{3},varargin{4}};
    Xi = getInterpPoint(varargin{6},varargin{7},varargin{8},varargin{9});
    Vi = interpne(varargin{5},Xi,nodelist,method);
    Vi = Vector2Matrix(Vi,length(varargin{6}),length(varargin{7}),length(varargin{8}),length(varargin{9}));
else
    error('interplate: wrong input arguments number.');
end


function Vpred = interpne(V,Xi,nodelist,method)
% interpne: Interpolates and extrapolates using n-linear interpolation (tensor product linear)
% usage: Vpred = interpne(V,Xi)
% usage: Vpred = interpne(V,Xi,nodelist)
% usage: Vpred = interpne(V,Xi,nodelist,method)
%
% Note: Extrapolating long distances outside the support of V is rarely advisable.
%
% arguments: (input)
%  V - p-dimensional array to be interpolated/extrapolated at the list
%      of points in the array Xi.
%
%      Note: interpne will work in any number of dimensions >= 1
%
%  Xi - (n by p) array of n points to interpolate/extrapolate. Each
%      point is one row of the array Xi.
%
%  nodelist - (OPTIONAL) cell array of nodes in each dimension.
%      If nodelist is not provided, then by default I will assume:
%
%      nodelist{i} = 1:size(V,i)
%
%      The nodes in nodelist need not be uniformly spaced.
%
%  method - (OPTIONAL) chacter string, denotes the interpolation
%      method used. 
%      
%      DEFAULT: method = 'linear'
% 
%      'linear' --> n-d linear tensor product interpolation/extrapolation
%      'nearest' --> n-d nearest neighbor interpolation/extrapolation
%
%      Note: in 2-d, 'linear' is equivalent to a bilinear interpolant
%      in 3-d, it is commonly known as trilinear interpolation.
%
%
% arguments: (output)
%  Vpred - n by 1 array of interpolated/extrapolated values
%
%
% Example 1: 2d (bilinear) case
%  [x1,x2] = meshgrid(0:.2:1);
%  z = exp(x1+x2);
%  Xi = rand(100,2)*2-.5;
%  Zi = interpne(z,Xi,{0:.2:1, 0:.2:1},'linear');
%  surf(0:.2:1,0:.2:1,z)
%  hold on
%  plot3(Xi(:,1),Xi(:,2),Zi,'ro')
%
%
% My apology: this interface is not fully compatible with that of
% interpn. But in higher dimensions, the interpn interface is both
% a mess to use and to write.
%
%
% See also: interp1, interp2, interpn
%
% Author: John D'Errico
% e-mail address: woodchips@rochester.rr.com
% Release: 1.01
% Release date: 3/27/06

% get some sizes
vsize = size(V);
ndims = length(vsize);
[n,p] = size(Xi);
if ndims~=p
  error 'Xi is not compatible in size with the array V for interpolation.'
end

% default for nodelist
if (nargin<2) || isempty(nodelist)
  nodelist = cell(1,ndims);
  for i=1:ndims
    nodelist{i} = (1:vsize(i))';
  end
end
if length(nodelist)~=ndims
  error 'nodelist is incompatible with the size of V.'
end
nll = cellfun('length',nodelist);
if any(nll~=vsize)
  error 'nodelist is incompatible with the size of V.'
end

% get deltax for the node spacing
dx = nodelist;
for i=1:ndims
  nodelist{i} = nodelist{i}(:);
  dx{i} = diff(nodelist{i});
  if any(dx{i}<=0)
    error 'The nodes in nodelist must be monotone increasing.'
  end
end

% check for method
if (nargin<4) || isempty(method)
  method = 'linear';
end
if ~ischar(method)
  error 'method must be a character string if supplied.'
end
validmethod = {'linear' 'nearest'};
k = find(strncmp(method,validmethod,length(method)));
if isempty(k)
  error(['No match found for method = ',method])
end
method = validmethod{k};

% Which cell of the array does each point lie in?
% This includes extrapolated points, which are also taken
% to fall in a cell. histc will do all the real work.
ind = zeros(n,ndims);
for i = 1:ndims
  [junk,bin] = histc(Xi(:,i),nodelist{i});
  
  % catch any point along the very top edge.
  bin(bin==vsize(i)) = vsize(i) - 1;
  ind(:,i) = bin;
  k = find(bin==0);
  
  % look for any points external to the nodes
  if ~isempty(k)
    % bottom end
    ind(k(Xi(k,i)<nodelist{i}(1)),i) = 1;
    
    % top end
    ind(k(Xi(k,i)>nodelist{i}(end)),i) = vsize(i) - 1;
  end
end  % for i = 1:ndims

% where in each cell does each point fall?
t = zeros(n,ndims);
for i = 1:ndims
  t(:,i) = (Xi(:,i) - nodelist{i}(ind(:,i)))./dx{i}(ind(:,i));
end

sub = cumprod([1,vsize(1:(end-1))])';
base = 1+(ind-1)*sub;

% which interpolation method do we use?
switch method
  case 'nearest'
    % nearest neighbor is really simple to do.
    t = round(t);
    t(t>1) = 1;
    t(t<0) = 0;
    
    Vpred = V(base + t*sub);
    
  case 'linear'
    % tensor product linear is not too nasty.
    Vpred = zeros(n,1);
    % define the 2^ndims corners of a hypercube
    corners = (dec2bin(0:(2^ndims-1))== '1');
    nc = size(corners,1);
    for i = 1:nc
      s = V(base + corners(i,:)*sub);
      for j = 1:ndims
        % this will work for extrapolation too
        if corners(i,j) == 0
          s = s.*(1-t(:,j));
        else
          s = s.*t(:,j);
        end
      end
      Vpred = Vpred + s;
    end
    
end  % switch method

function Xi = getInterpPoint(varargin)
% 输入index1 index2 index3 ...  列向量
% 输出坐标值，按照索引顺序
% by masonghui 2006.7.5
if nargin==2   % 2维插值点
    index1 = varargin{1};
    dim1 = length(index1);
    index2 = varargin{2};
    dim2 = length(index2);
    Xi = zeros(dim1*dim2,2);
    Xi(:,1) = duplicateVector1(index1,dim2);
    Xi(:,2) = duplicateVector2(index2,dim1);
elseif nargin==3   % 3维插值点
    index1 = varargin{1};
    dim1 = length(index1);
    index2 = varargin{2};
    dim2 = length(index2);
    index3 = varargin{3};
    dim3 = length(index3);
    Xi = zeros(dim1*dim2*dim3,3);
    Xi(:,1) = duplicateVector1(index1,dim2*dim3);
    tmp = duplicateVector2(index2,dim1);
    Xi(:,2) = duplicateVector1(tmp,dim3);
    Xi(:,3) = duplicateVector2(index3,dim1*dim2);
elseif nargin==4   % 4维插值点
    index1 = varargin{1};
    dim1 = length(index1);
    index2 = varargin{2};
    dim2 = length(index2);
    index3 = varargin{3};
    dim3 = length(index3);
    index4 = varargin{4};
    dim4 = length(index4);
    Xi = zeros(dim1*dim2*dim3*dim4,4);
    Xi(:,1) = duplicateVector1(index1,dim2*dim3*dim4);
    tmp = duplicateVector2(index2,dim1);
    Xi(:,2) = duplicateVector1(tmp,dim3*dim4);
    tmp = duplicateVector2(index3,dim1*dim2);
    Xi(:,3) = duplicateVector1(tmp,dim4);
    Xi(:,4) = duplicateVector2(index4,dim1*dim2*dim3);    
else
    error('CLdesign>> interpnskin: wrong input arguments number.');
end

function Vext = duplicateVector1(Vec,n)
% Vec    列向量
% n      复制n次
% Vext   由Vec组合n次得到的列向量
% by masonghui 2006.7.5
m = length(Vec);
Vext = zeros(m*n,1);
for i=1:n
    Vext((i-1)*m+1:i*m) = Vec;
end

function Vext = duplicateVector2(Vec,n)
% Vec    列向量
% n      复制n次
% Vext   由Vec的每一项组合n次得到的列向量
% by masonghui 2006.7.5
m = length(Vec);
Vext = zeros(m*n,1);
Vone = ones(n,1);
for i=1:m
    Vext((i-1)*n+1:i*n) = Vone*Vec(i);
end

function Mat = Vector2Matrix(varargin)
% 输入列向量 Vec dim1 dim2 dim3 ... 
% 输出矩阵   Mat[index1][index2][index3] ...
% by masonghui 2006.7.5

if nargin==3   % 2维插值点
    Vec = varargin{1};
    dim1 = varargin{2};
    dim2 = varargin{3};
    Mat = zeros(dim1,dim2);
    for i=1:dim2
        Mat(:,i) = Vec((i-1)*dim1+1:i*dim1);
    end    
elseif nargin==4   % 3维插值点
    Vec = varargin{1};
    dim1 = varargin{2};
    dim2 = varargin{3};
    dim3 = varargin{4};
    Mat = zeros(dim1,dim2,dim3);
    step1 = dim1;
    step2 = dim1*dim2;
    for i=1:dim3
        for j=1:dim2
            Mat(:,j,i) = Vec((i-1)*step2+(j-1)*step1+1:(i-1)*step2+j*step1);
        end
    end
elseif nargin==5   % 4维插值点
    Vec = varargin{1};
    dim1 = varargin{2};
    dim2 = varargin{3};
    dim3 = varargin{4};
    dim4 = varargin{5};
    Mat = zeros(dim1,dim2,dim3,dim4);
    step1 = dim1;
    step2 = dim1*dim2;
    step3 = dim1*dim2*dim3;
    for i=1:dim4
        for j=1:dim3
            for k=1:dim2
                Mat(:,k,j,i) = Vec((i-1)*step3+(j-1)*step2+(k-1)*step1+1:(i-1)*step3+(j-1)*step2+k*step1);
            end
        end
    end
else
    error('CLdesign>> Vector2Matrix: wrong input arguments number.');
end

