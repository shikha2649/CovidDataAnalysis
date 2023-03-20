select * from Housing_data hd;

#Formatting the date format 

#select saledate , str_to_date(SaleDate, '%d-%M-%y')  from Housing_data hd; 
#select STR_TO_DATE('April 9,2013','%M %d,%Y') from dual;
#select saledate from Housing_data hd where SaleDateNew is null;


UPDATE Housing_data set saledatenew = str_to_date(SaleDate,'%M %d,%Y') where SaleDateNew is null;

UPDATE Housing_data set saledatenew = str_to_date(SaleDate,'%d-%M-%Y') where SaleDate like '%-%';



/*Populating Null property address*/

select * from Housing_data hd where PropertyAddress is null;


#Formatting  address by bifercating the address, city , state 

#Formatting PropertyAddress 
select PropertyAddress  from Housing_data hd; 

select SUBSTR(PropertyAddress,1,LOCATE(',',PropertyAddress)-1) as addr1, 
       SUBSTR(PropertyAddress,LOCATE(',',PropertyAddress)+1,LENGTH(PropertyAddress)) as addr2
       from Housing_data hd; 

select LOCATE(',','appl,e');

ALTER table Housing_data 
add PropertyAddress1 varchar(400);

ALTER table Housing_data 
add PropertyAddressCity varchar(400);

update Housing_data 
set PropertyAddress1 = SUBSTR(PropertyAddress,1,LOCATE(',',PropertyAddress)-1);

update Housing_data 
set PropertyAddressCity = SUBSTR(PropertyAddress,LOCATE(',',PropertyAddress)+1,LENGTH(PropertyAddress));

commit;

#Formatting ownerAddress 

select OwnerAddress from Housing_data hd;

/*select SUBSTRING_INDEX(OwnerAddress,',',1) as owneraddr1, 
SUBSTR(SUBSTRING_INDEX(OwnerAddress,',',2),LOCATE(',',SUBSTRING_INDEX(OwnerAddress,',',2))+1,LENGTH(SUBSTRING_INDEX(OwnerAddress,',',2))) as owneraddr2
from Housing_data hd; 

select SUBSTRING_INDEX(OwnerAddress,',',2) , LOCATE(',',SUBSTRING_INDEX(OwnerAddress,',',2))from Housing_data hd; */

select SUBSTRING_INDEX(OwnerAddress,',',2) as owneraddr1, SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1) as ownercity, 
SUBSTRING_INDEX(OwnerAddress,',',-1) as ownerstate from Housing_data hd ; 


ALTER table Housing_data 
add ownerAddress1 varchar(400);

update Housing_data 
set ownerAddress1 = SUBSTRING_INDEX(OwnerAddress,',',2);

ALTER table Housing_data 
add ownercity varchar(400);

update Housing_data 
set ownercity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress,',',2),',',-1);

ALTER table Housing_data 
add ownerstate varchar(400);

update Housing_data 
set ownerstate = SUBSTRING_INDEX(OwnerAddress,',',-1);


# SoldasVacant data replace the values N , Y with Yes and No

select distinct soldasvacant from Housing_data hd ;

UPDATE Housing_data 
set soldasvacant = case when soldasvacant = 'N'
                        then 'No'
                        when soldasvacant = 'Y'
                        then 'Yes'
                        else soldasvacant
                  end;
                 
#removing duplicates 
  with count_tbl as (               
  select COUNT(ParcelID) as count_a , ParcelID, PropertyAddress  from Housing_data hd
  group by ParcelID , PropertyAddress
 )
 select * from count_tbl 
 where count_a >1;

select * from Housing_data hd ;
with housing_temp as (
select ParcelID, PrimaryID, ROW_NUMBER() over ( PARTITION by ParcelID , PropertyAddress , SalePrice , LegalReference , OwnerName 
 #order by ParcelID
 ) as row_num
from Housing_data hd)
select *  
from housing_temp
where 
row_num >1 
#ParcelID = '163 05 0B 203.00'
order by ParcelID
;

ALTER table Housing_data 
add row_num int;

with housing_temp as (
select ParcelID, PrimaryID, ROW_NUMBER() over ( PARTITION by ParcelID , PropertyAddress , SalePrice , LegalReference , OwnerName 
 #order by ParcelID
 ) as row_num
from Housing_data hd)
delete hd1 from Housing_data hd1, housing_temp
#set row_num  = housing_temp.row_num
where 
housing_temp.row_num > 1 and
hd1.PrimaryID = housing_temp.PrimaryID;

create table Housing_data_backup  as select * from Housing_data hd;  

# Removing unused columns 

alter table Housing_data 
drop column owneraddress;
