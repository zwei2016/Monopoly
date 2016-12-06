%%project 2, Monopoly game considering the double dices 
% use normalization to normalize the P distribustion 
clear;

square = {
    'GO';               %1
    'Mediterranean';
    'Community Chest';  %3
    'Baltic';
    'Income Tax';       %5
    'Reading Railroad';
    'Oreintal';
    'Chance';           %8
    'Vermont';
    'Connecticut';
    'Jail';             %11
    'St. Charles';
    'Electric Co';
    'States';
    'Virginia';         %15
    'Pennsylvania Railroad';
    'St. James';
    'Communtity Chest';
    'Tennessee';
    'New York';
    'Free Parking';     %21
    'Kentucky';
    'Chance';           %23
    'Indiana';
    'Illinois';         %25
    'B&O Railroad';     %26
    'Atlantic';         %27
    'Venture';          %28
    'Water Works';      %29
    'Marvin Gardens';
    'Go To Jail';       %31
    'Pacific';
    'North Carolina';
    'Community Chest';  %34
    'Pennsylvania';     %35
    'Short Line Railroad'; 
    'Chance';           %37
    'Park Place';
    'Luxury Tax';
    'Boardwalk'         %40
};

Dice1 = double([1,5,1,1,1,1]/10); 
% Pr for the first dice: fair by default
% double([1,1,1,1,1,1]/6)
% [1,1,1,1,1,5]/10 for big 6

Dice2 = double([1,5,1,1,1,1]/10); % Pr for the second dice: fair by default

% The join probability distribution for two dices : the sum of value is J
DicesJ2 = Dice1(1)*Dice2(1);
DicesJ3 = Dice1(1)*Dice2(2) + Dice1(2)*Dice2(1);
DicesJ4 = Dice1(1)*Dice2(3) + Dice1(2)*Dice2(2) + Dice1(3)*Dice2(1);
DicesJ5 = Dice1(1)*Dice2(4) + Dice1(2)*Dice2(3) + Dice1(3)*Dice2(2) + Dice1(4)*Dice2(1);
DicesJ6 = Dice1(1)*Dice2(5) + Dice1(2)*Dice2(4) + Dice1(3)*Dice2(3) + Dice1(4)*Dice2(2) + Dice1(5)*Dice2(1);
DicesJ7 = Dice1(1)*Dice2(6) + Dice1(2)*Dice2(5) + Dice1(3)*Dice2(4) + Dice1(4)*Dice2(3) + Dice1(5)*Dice2(2) + Dice1(6)*Dice2(1);
DicesJ8 = Dice1(2)*Dice2(6) + Dice1(3)*Dice2(5) + Dice1(4)*Dice2(4) + Dice1(5)*Dice2(3) + Dice1(6)*Dice2(2);
DicesJ9 = Dice1(3)*Dice2(6) + Dice1(4)*Dice2(5) + Dice1(5)*Dice2(4) + Dice1(6)*Dice2(3);
DicesJ10 = Dice1(4)*Dice2(6) + Dice1(5)*Dice2(5) + Dice1(6)*Dice2(4);
DicesJ11 = Dice1(5)*Dice2(6) + Dice1(6)*Dice2(5);
DicesJ12 = Dice1(6)*Dice2(6);

% The joint Pr for one throw with the consideration of double rule: 
% at most two doubles are allowed (third one birngs the player to jail) 
DicesJointBasic = double([DicesJ2,DicesJ3,DicesJ4,DicesJ5,DicesJ6,DicesJ7,DicesJ8,DicesJ9,DicesJ10,DicesJ11,DicesJ12]); 

% But if the Pr rule must to into acount, the Pr of each double must be developped only in the next layer 
DicesJointBasicR = double([DicesJ2-Dice1(1)*Dice2(1),DicesJ3,DicesJ4-Dice1(2)*Dice2(2),DicesJ5,DicesJ6-Dice1(3)*Dice2(3),DicesJ7,DicesJ8-Dice1(4)*Dice2(4),DicesJ9,DicesJ10-Dice1(5)*Dice2(5),DicesJ11,DicesJ12-Dice1(6)*Dice2(6)]);

%For two fair dices, basic should be double([0,2,2,4,4,6,4,4,2,2,0]/36);
Basic = DicesJointBasicR;
Throw = zeros(43,40); % 3 throws matrix row: 1+6+6*6

% normal 1st throw P distribution row: 1
Throw(1,3:13)= Basic;

% 2nd throw after one double P(:|double) row:2:7
for i=5:2:15
  Throw((i-1)/2,i:i+10) = Basic/36;
end

% 3rd throw after two doubles P(:|double,double) row 8:43 = 6*6 
BasicWithoutD_Normal = normalization(Basic);
for j=1:6
  % 6*6  
  for i=2*j+5:2:2*j+15
     Throw((j-1)*5+(i+9)/2,i:i+10) = (BasicWithoutD_Normal/36)/36;
  end
end
% The sum(Throw(:)) = 1

Trans = zeros(40); % state transition matrix 40x40 

for i=1:1:43
    for j=1:1:40
        Trans(1,j)= Trans(1,j)+ Throw(i,j);
    end
end
% Vector 1 dimension 

for i = 2:40,
    Trans(i,:) = circshift(Trans(i-1,:),[0 1]);
end

% Adjust the Matrix by commands in square 

% Go To Jail Square 
Ad_T = eye(40);
Jail_number = find(ismember(square,'Jail'));
Go_to_jail_number = find(ismember(square,'Go To Jail'));
Ad_T(Go_to_jail_number,:) = 0;
Ad_T(Go_to_jail_number,Jail_number) = 1;

% Community Chest cards: 16 cards
Chest_number = find(ismember(square,'Community Chest'));
% Adjustment for one card "Go To Jail", we do not care about money here
Ad_T(Chest_number,:) = Ad_T(Chest_number,:)*15/16;
% Go to Jail card
Ad_T(Chest_number,Jail_number) = Ad_T(Chest_number,Jail_number)+1/16;

% Chance cards: 16 cards
Chance_number= find(ismember(square,'Chance'));
Ad_T(Chance_number,:) = Ad_T(Chance_number,:)*6/16;
% Advance to GO
% Take a trip to Reading Railroad
% Go directly to Jail
% Advance to St. Charles Place
% Advance to Illinois
% Take a walk on the Boardwalk
chance_move = find(ismember(square,{
    'GO','Reading Railroad','Jail','St. Charles','Illinois','Boardwalk'}));
Ad_T(Chance_number,chance_move) = Ad_T(Chance_number,chance_move) + 1/16;
% Go back 3 steps
Ad_T(Chance_number,Chance_number -3)= Ad_T(Chance_number,Chance_number -3) + 1/16;
% Advance to nearest utility 1
Ad_T(8,13) = Ad_T(8,13) + 1/16;    %'Electric Co'
Ad_T(23,29) = Ad_T(23,29) + 1/16;  %'Water Works'
Ad_T(37,29) = Ad_T(37,29) + 1/16;  %'Water Works'

% Advance to nearest railroad 2
Ad_T(8,6) = Ad_T(8,6) + 2/16;      %'Reading Railroad'
Ad_T(23,26) = Ad_T(23,26) + 2/16;  %'B&O Railroad'
Ad_T(37,36) = Ad_T(37,36) + 2/16;  %'Short Line Railroad'

% The MDP transition matrix 
Trans = Trans*Ad_T;

for i=1:40
    if sum(Trans(i,:))~=1
        Trans(i,:)= normalization(Trans(i,:));
    end
end
% 

throws = 500;
% MDP 
row = size(Trans,1);
x_states = zeros(row,throws);
x = eye(1,row);
x_states(:,1) = x;

% for each throw the sum of pobability in 40 squares should be always 1 
for t = 1:throws %col
    x = double(x*Trans);
    %x_states(:,t+1) = normalization(x);
    x_states(:,t+1) = x; 
end

figure(1)
%plot(1:40,x_states(:,end),'b-.*');
plot(1:40,x_states(:,end),'-b','linewidth',4);

hold on
stem(1:40,x_states(:,end));
grid
xlabel('40 Squares in Monopoly Game: from GO to Boardwalk');
ylabel('Probability Distribution');
title('Probability in Monopoly (*Marker)');
set(gca,'fontsize',18)
axis tight

%% steady state
[V, l] = eigs(Trans',1,'lm');
%the columns of V are the eigenvectors
steady_state_value = normalization(V);
figure(2)
plot(1:40,steady_state_value,'-r','linewidth',3);
grid
xlabel('40 Squares in Monopoly Game: from GO to Boardwalk');
ylabel('Eigenvectors of Markov Transition Matrix');
title('Steady State Values in Monopoly Game');
set(gca,'fontsize',18)
axis tight
