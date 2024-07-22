-- Cleaning Data in SQL Queries
SELECT *
FROM mydb.Nashville_Housing_Data nhd
-- - - - - -  - - - - - - - - - - - -  - - - - - - - - -  - - - - - - - -
-- Standardize Data Format

SELECT nhd.SaleDate, DATE_FORMAT(STR_TO_DATE(nhd.SaleDate, '%M %d, %Y'), '%Y-%m-%d') 
FROM mydb.Nashville_Housing_Data nhd


UPDATE mydb.Nashville_Housing_Data
SET SaleDate = DATE_FORMAT(STR_TO_DATE(SaleDate, '%M %d, %Y'), '%Y-%m-%d')

ALTER TABLE mydb.Nashville_Housing_Data
ADD SaleDateConverted Date;

UPDATE mydb.Nashville_Housing_Data
SET SaleDateConverted = STR_TO_DATE(TRIM(SaleDate), '%Y-%m-%d')
-- - - - - -  - - - - - - - - - - - -  - - - - - - - - -  - - - - - - - -
-- Populate Property Address Data
SELECT *
FROM mydb.Nashville_Housing_Data nhd
-- WHERE PropertyAddress is NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID , b.PropertyAddress ,
COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM mydb.Nashville_Housing_Data a
JOIN mydb.Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress is NULL

UPDATE mydb.Nashville_Housing_Data a
JOIN mydb.Nashville_Housing_Data b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID <> b.UniqueID
SET a.PropertyAddress = COALESCE(a.PropertyAddress, b.PropertyAddress)
WHERE a.PropertyAddress is NULL;
-- - - - - -  - - - - - - - - - - - -  - - - - - - - - -  - - - - - - - -
-- Breaking Out Adress into Individual Columns(Address, City, States)
SELECT PropertyAddress
FROM mydb.Nashville_Housing_Data nhd

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1 ) as Address
,SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress)) as Address
FROM mydb.Nashville_Housing_Data nhd

ALTER TABLE mydb.Nashville_Housing_Data
ADD PropertySplitAddress Nvarchar(255);

UPDATE mydb.Nashville_Housing_Data
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) - 1 )

ALTER TABLE mydb.Nashville_Housing_Data
ADD PropertySplitCity Nvarchar(255);

UPDATE mydb.Nashville_Housing_Data
SET PropertySplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) + 1 , LENGTH(PropertyAddress))

SELECT *
FROM mydb.Nashville_Housing_Data nhd

SELECT OwnerAddress
FROM mydb.Nashville_Housing_Data nhd

SELECT
   SUBSTRING_INDEX(OwnerAddress, ',', 1),
   TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1)),
   TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1))
FROM mydb.Nashville_Housing_Data;

ALTER TABLE mydb.Nashville_Housing_Data
ADD OwnerSplitAddress Nvarchar(255);

UPDATE mydb.Nashville_Housing_Data
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1)

ALTER TABLE mydb.Nashville_Housing_Data
ADD OwnerSplitCity Nvarchar(255);

UPDATE mydb.Nashville_Housing_Data
SET OwnerSplitCity = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1))

ALTER TABLE mydb.Nashville_Housing_Data
ADD OwnerSplitState Nvarchar(255);

UPDATE mydb.Nashville_Housing_Data
SET OwnerSplitState = TRIM(SUBSTRING_INDEX(OwnerAddress, ',', -1))

SELECT *
FROM mydb.Nashville_Housing_Data nhd
-- - - - - -  - - - - - - - - - - - -  - - - - - - - - -  - - - - - - - -
-- Change Y and N to Yes and No in "Sold as Vacant" field
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From mydb.Nashville_Housing_Data nhd
Group By SoldAsVacant
Order By 2

SELECT SoldAsVacant
, CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
 		WHEN SoldAsVacant = 'N' THEN 'No'
 		ELSE SoldAsVacant
 		END
From mydb.Nashville_Housing_Data nhd

UPDATE mydb.Nashville_Housing_Data
SET SoldAsVacant = CASE	WHEN SoldAsVacant = 'Y' THEN 'Yes'
 		WHEN SoldAsVacant = 'N' THEN 'No'
 		ELSE SoldAsVacant
 		END
-- - - - - -  - - - - - - - - - - - -  - - - - - - - - -  - - - - - - - -
-- Remove duplicates
WITH RowNumCTE AS (
    SELECT *,
        ROW_NUMBER() OVER (
           PARTITION BY ParcelID, 
            			PropertyAddress, 
            			SalePrice, 
            			SaleDate, 
            			LegalReference
			            ORDER BY 
			            	UniqueID
			        ) Row_Num
    FROM mydb.Nashville_Housing_Data
)

-- Check rows marked as duplicates
SELECT * FROM RowNumCTE WHERE Row_Num > 1;
 		
 -- - - - - -  - - - - - - - - - - - -  - - - - - - - - -  - - - - - - - -
-- Delete Unused Columns
SELECT *
FROM mydb.Nashville_Housing_Data nhd 

ALTER TABLE mydb.Nashville_Housing_Data 
DROP COLUMN OwnerAddress,
DROP COLUMN TaxDistrict,
DROP COLUMN PropertyAddress;

ALTER TABLE mydb.Nashville_Housing_Data 
DROP COLUMN SaleDate;		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
 		
