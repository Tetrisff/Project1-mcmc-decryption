%define some global variable since we may use them in function
global logfrec;
global LtransB;
global alpha;

%open files and save the context as a whole string
fid = fopen('ciphertext.txt','rb');
c_text = fread(fid,[1 inf],'*char');
fclose(fid);

fid2 = fopen('proj-1.txt','rb');
wp_text = fread(fid2,[1 inf],'*char');
fclose(fid2);

alpha = ['A','B','C','D','E','F','G','H','I','J','K','L','M','N',...
    'O','P','Q','R','S','T','U','V','W','X','Y','Z',' '];

%find matrix B
B=zeros(27);
for i=1:27
    for j=1:27
        B(i,j)=B_element(wp_text,alpha(i),alpha(j));
    end
end

% to find the five most frequent transitions
B_s=sort(B(:),'descend'); 
for i= 1:5
    [m,n]=find(B==B_s(i));
    disp([alpha(m) alpha(n)]);
end



%find logTransB
LtransB=zeros(27);
for i=1:27
    for j=1:27
        LtransB(i,j)=log(B(i,j)/count(wp_text,alpha(i)));
    end
end

 %improve convergence
for i =1:27
    for j =1:27         
        if (LtransB(i,j)==-Inf)
            LtransB(i,j) = -12;
        end
    end
end

%find logfrec(i) since we need this as first term of plausibility
l_wp=length(wp_text);
logfrec=zeros(27,1);
for i=1:27
    logfrec(i)= log(count(wp_text,alpha(i))/l_wp);
end

   
%displace table and sort with number
Rownames={'A';'B';'C';'D';'E';'F';'G';'H';'I';'J';'K';'L';'M';'N';...
      'O';'P';'Q';'R';'S';'T';'U';'V';'W';'X';'Y';'Z';'Space'};
  
nums=[count(wp_text,'A');count(wp_text,'B');count(wp_text,'C');...
    count(wp_text,'D');count(wp_text,'E');count(wp_text,'F');...
    count(wp_text,'G');count(wp_text,'H');count(wp_text,'I');...
    count(wp_text,'J');count(wp_text,'K');count(wp_text,'L');...
    count(wp_text,'M');count(wp_text,'N');count(wp_text,'O');...
    count(wp_text,'P');count(wp_text,'Q');count(wp_text,'R');...
    count(wp_text,'S');count(wp_text,'T');count(wp_text,'U');...
    count(wp_text,'V');count(wp_text,'W');count(wp_text,'X');...
    count(wp_text,'Y');count(wp_text,'Z');count(wp_text,' ')];
T=table(nums,'RowNames',Rownames);
disp(sortrows(T));

%iterations
j= randi([0,30]);
cJ=c_text(9*j+1:end);

MaxIt=6000;
key='123456789';
for i      = 1:MaxIt/2
    cJstar = swap(cJ,key);
    A      = exp(min([0,P(cJstar(10:end))-P(cJ)]));
    u=rand(1);
    if u<=A
       cJ=cJstar(10:end);
       key=cJstar(1:9);
    end
end

for i       = 1:MaxIt/2
    cJstar2 = slide(cJ,key);
    A       = exp(min([0,P(cJstar2(10:end))-P(cJ)]));
    u       = rand(1);
    if u<=A
         cJ =cJstar2(10:end);
         key =cJstar2(1:9);
    end
end


text = read_key(c_text,key);
disp(text);
disp(P(text));
disp(key);


%functions

%swap
function [store] = swap(string,key)
    a = randi(9);
    b = randi(9);
    while a==b 
        b=randi(9); 
    end
    vector  = string;
    new_key = key;
    for i = 1:length(string)/9     
        vector(a+9*(i-1))=string(b+9*(i-1));
        vector(b+9*(i-1))=string(a+9*(i-1));
    end
    new_key(a)=key(b);
    new_key(b)=key(a);
    [store]=[new_key,vector];
end

%slide
function [store] = slide(string,key)
    b      = randi(7);
    k1     = randi(10-b);
    k2     = randi([0,9-b]);
    vector ='';
    new_key='';
     for i     = 1:length(string)/9 
        temp   = string(k1+9*(i-1):k1+b-1+9*(i-1));
        s_temp = [string(1+9*(i-1):k1-1+9*(i-1)) string(k1+b+9*(i-1):9+9*(i-1))];
        vector = [vector insertAfter(s_temp,k2,temp)];
     end
    temp_key=key(k1:k1+b-1);
    k_temp  = [key(1:k1-1) key(k1+b:9)]; 
    new_key =[new_key insertAfter(k_temp,k2,temp_key)];
    [store] =[new_key,vector];  
end
    

%compute plausibility
function num = P(string)
    global logfrec;
    global LtransB;
    global alpha;
    l=length(string);
    f1=logfrec(strfind(alpha,string(1)));
    total=0;
    for i =1:l-1
        total=LtransB(strfind(alpha,string(i)),strfind(alpha,string(i+1)))+total;
    end
    num=f1+total;        
end

%count number
function num = count(string,char)
   num = length(strfind(string,char));
end


%compute each element of B
function num = B_element(string,charA,charB)
    l= length(string);
    j=0;
    for i =1:l-1
        if string(i)==charA && string(i+1)==charB
            j=j+1;
        end
    end
    num=j;
end

%Decrypt the text from the key
function text = read_key(string,key)
    text='';
     for i  = 1:length(string)/9 
         for j = 1:9
             text(j+9*(i-1))=string(str2double(key(j))+9*(i-1));
         end
     end      
end
