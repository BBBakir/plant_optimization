sets
i indice of months /June,July,August,September,October/
j indice of coal type /Coal_Stockpile, Coal_Columbian, Coal_Russian, Coal_Scottish, Wood_chips/
k indice of periods /Weekday_Peak, Weekday_Offpeak, Weekend_Peak, Weekend_Offpeak/
m indice of Day type/Weekday,Weekend/
k1(k) /Weekday_Peak, Weekday_Offpeak/
k2(k) /Weekend_Peak, Weekend_Offpeak/
j1(j)/Coal_Columbian, Coal_Russian, Coal_Scottish/
;

scalar
N Pound-Euro Exchange Rate /1.5/
G MWh energy per calorie / 0.278 /
L Stockpile Stock Left/600000/
T Transmission rate/0.65/
B Leftsulphure bubble/9000/
R Supplement /45/
U Plant capacity/12000/
D CO2 Emmision Rate/0.8/
O CO2 Emission Price/15/
;

parameters
W(j) Cost of fuel
/Coal_Stockpile 42.56
 Coal_Columbian 43.93
 Coal_Russian 43.80
 Coal_Scottish 42.00
 Wood_chips 73.77/
 
C(j) `
/Coal_Stockpile 25.81
 Coal_Columbian 25.12
 Coal_Russian 24.50
 Coal_Scottish 26.20
 Wood_chips 18.00/
 
S(j) Sulfur percentage of fuel
/Coal_Stockpile 0.0138
 Coal_Columbian 0.007
 Coal_Russian 0.0035
 Coal_Scottish 0.0172
 Wood_chips 0.0001/

H(j) efficiency of fuels
/Coal_Stockpile 0.35
 Coal_Columbian 0.35
 Coal_Russian 0.35
 Coal_Scottish 0.35
 Wood_chips 0.035/
 ;
 
table P(k,i) Price at Month i and Period k
                  June         July          August       September       October 
Weekday_Peak       36.00        36.35         37.65          38.35          43.70     
Weekday_Offpeak    27.00        27.00         28.20          28.50          31.70    
Weekend_Peak       33.50        34.30         35.65          35.80          38.70   
Weekend_Offpeak    26.20        26.30         27.50          27.65          30.10
;

table E(k,i) weekdays or weekends in month k
                    June         July          August       September       October
Weekday_Peak        22           21              23         22              21
Weekday_Offpeak     22           21              23         22              21
Weekend_Peak        8            10              8          8               10
Weekend_Offpeak     8            10              8          8               10
;

nonnegative variables
x(i,j,k) amount of fuel burned in month i type j in all periods k

variables
z total profit
F1 Co2
F2 Electricity
F3 costfuel
F4 transmission
F5 rocsupp
;

equations
Obj define objective function
Co2
Electricity
costfuel
transmission
rocsupp 
SulphurBubble define constraint for sulfur bubble
Stockpile  define constraint for stockpile
firstmonths1
Plantcapacity plant capacity constraintsasas
;

Co2.. F1=e= sum((i,j,k),x(i,j,k)*H(j)*C(j)*G*D*O/N);
Electricity.. F2=e= sum((i,j,k),x(i,j,k)*H(j)*C(j)*G*P(k,i));
costfuel.. F3=e= sum((i,j,k),x(i,j,k)*W(j));
transmission.. F4=e= sum((i,j,k),x(i,j,k)*C(j)*H(j)*G*T);
rocsupp.. F5=e= sum((i,k),x(i,'Wood_chips',k)*H('Wood_chips')*C('Wood_chips')*G*R); 
Obj.. Z=e=F2+F5-F4-F3-F1;
*F2= electric satisi geliri F3=komur fiyati cost - co2 emissionu cezasi -transmission rate parasi + roc destegi


SulphurBubble.. sum((i,j,k),X(i,j,k)*S(j)) =l= 9000;
Stockpile.. sum((i,k),X(i,'Coal_Stockpile',k)) =l= 600000;
firstmonths1(i,j1,k)$((ord(i))<=3).. X(i,j1,k)=e= 0;
Plantcapacity(i,k).. sum(j,x(i,j,k)*H(j)*C(j)*G)=l=(U)*E(k,i);


model profitfunction/all/;
solve profitfunction using lp maximizing Z;
display X.l, z.l;
