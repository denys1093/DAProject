/****** Script for SelectTopNRows command from SSMS  ******/

--Data Cleaning FROM dbo.NHousingProject

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
  FROM [SQLProject].[dbo].[NHousingProject]

  ---------------------------------------------------------------------------------------------------------------------d

--Standardize Date Format

SELECT SaleDateConverted, CONVERT (Date, SaleDate)
FROM dbo.NHousingProject

UPDATE NHousingProject
SET SaleDate = CONVERT (Date, SaleDate)

ALTER TABLE NHousingProject
ADD SaleDateConverted Date;

UPDATE NHousingProject
SET SaleDateConverted = CONVERT (Date, SaleDate)

---------------------------------------------------------------------------------------------------------------------d

--Populate Property Adress Data

Select *
FROM dbo.NHousingProject
--where PropertyAdress is NULL
Order by ParcelID

Select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM dbo.NHousingProject A
JOIN dbo.NHousingProject B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

UPDATE A
SET PropertyAddress = ISNULL(A.PropertyAddress, B.PropertyAddress)
FROM dbo.NHousingProject A
JOIN dbo.NHousingProject B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is NULL

---------------------------------------------------------------------------------------------------------------------d

--Breaking out Adress into Individual Columns (Adress, City, State)

Select PropertyAddress
FROM dbo.NHousingProject
--where PropertyAdress is NULL
Order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) as Address

FROM dbo.NHousingProject

ALTER TABLE NHousingProject
ADD PropertySplitAdress Nvarchar(255);

UPDATE NHousingProject
SET PropertySplitAdress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 

ALTER TABLE NHousingProject
ADD PropertySplitCity Nvarchar(255);

UPDATE NHousingProject
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))


SELECT *
FROM dbo.NHousingProject

SELECT OwnerAddress
FROM dbo.NHousingProject

SELECT
PARSENAME(REPLACE (OwnerAddress, ',', '.') ,3)
,PARSENAME(REPLACE (OwnerAddress, ',', '.') ,2)
,PARSENAME(REPLACE (OwnerAddress, ',', '.') ,1)
FROM dbo.NHousingProject



ALTER TABLE NHousingProject
ADD OwnerSplitAdress Nvarchar(255);

UPDATE NHousingProject
SET OwnerSplitAdress = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,3)

ALTER TABLE NHousingProject
ADD OwnerSplitCity Nvarchar(255);

UPDATE NHousingProject
SET OwnerSplitCity = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,2)

ALTER TABLE NHousingProject
ADD OwnerSplitState Nvarchar(255);

UPDATE NHousingProject
SET OwnerSplitState = PARSENAME(REPLACE (OwnerAddress, ',', '.') ,1)

Select *
FROM dbo.NHousingProject

---------------------------------------------------------------------------------------------------------------------d

--Change Y and N Yes and No in "Sold Vacant" Field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM dbo.NHousingProject
GROUP BY SoldAsVacant
Order by 2


SELECT SoldAsVacant
, CASE	When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END
FROM dbo.NHousingProject

UPDATE NHousingProject
SET SoldAsVacant = CASE	When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		Else SoldAsVacant
		END

---------------------------------------------------------------------------------------------------------------------d


-- Remove Duplicates

WITH rownumCTE AS(
SELECT *,
	ROW_NUMBER() Over (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
					ORDER BY
						UniqueID
						) row_num
FROM dbo.NHousingProject
--Order by ParcelID
)
Select *
FROM rownumCTE
where row_num > 1
Order by PropertyAddress


---------------------------------------------------------------------------------------------------------------------d


--Delete Unused Column

Select *
FROM dbo.NHousingProject

ALTER TABLE dbo.NHousingProject
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE dbo.NHousingProject
DROP COLUMN SaleDate

---------------------------------------------------------------------------------------------------------------------d