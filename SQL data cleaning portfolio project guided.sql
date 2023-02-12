/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [portfolioproject].[dbo].[Nashville]

  Select *
  from portfolioproject..Nashville
  
  --standardise date format
  
  Select SaleDate, CONVERT(date, SaleDate) Sale_Date
  from Nashville

  ALTER TABLE Nashville
  ADD Saledateconverted Date;
  
  update Nashville
  set Saledateconverted = CONVERT(date, SaleDate)

  select Saledateconverted
  from portfolioproject..Nashville

  --populate property address data

  Select PropertyAddress
  from Nashville
  

  select *
  from portfolioproject..Nashville
  order by ParcelID

  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
  from Nashville a
  JOIN Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
  where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 from portfolioproject..Nashville a
  JOIN portfolioproject..Nashville b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]

--breaking address into individual columns

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From Nashville

select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
From Nashville

 ALTER TABLE Nashville
  ADD PropertySplitAddress NVARCHAR(200);
 
 update Nashville
  set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  ALTER TABLE Nashville
  ADD PropertySplitCity NVARCHAR(200);
 
 update Nashville
  set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

  select *
  from Nashville

---owner address cleaning, parsename

select 
PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
from Nashville

ALTER TABLE Nashville
  ADD OwnerSplitAddress NVARCHAR(200);
 
 update Nashville
  set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

  ALTER TABLE Nashville
  ADD OwnerSplitCity NVARCHAR(200);
 
 update Nashville
  set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

 ALTER TABLE Nashville
  ADD OwnerSplitState NVARCHAR(100);
 
 update Nashville
  set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)

  select *
  from Nashville

select SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
From Nashville

update Nashville
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END

--Remove Duplicates

  WITH RowNumCTE AS(
  select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
				 ) row_num
  from Nashville
  )
  DELETE 
  from RowNumCTE
  where row_num >1
  --order by PropertyAddress

--delete unused column

select *
from Nashville

ALTER TABLE Nashville
DROP COLUMN OwnerAddress, TaxDistrict,PropertyAddress

ALTER TABLE Nashville
DROP COLUMN SaleDate