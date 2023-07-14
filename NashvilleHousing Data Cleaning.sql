--- Cleaning data in SQL Queries 
SELECT * 
FROM PortfolioProjects..NashvilleHousing


--- Standardize date format 
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProjects..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)
--- After selecting the SaleDate column, we see that this UPDATE did not get rid of the time like we wanted, so we'll add another column to the table

ALTER TABLE NashvilleHousing
ADD SaleDateConverted DATE

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)
 --- After selecting the new column we made, we see that this does get rid of the time like we wanted

 -------------------------------------------------------------------------------------------------------------------------------------------------------

 --- Populate Property Address data
 SELECT *
 FROM PortfolioProjects..NashvilleHousing
 --WHERE PropertyAddress IS NULL
 ORDER BY ParcelID
 --- When looking at the PropertyAddress column, we see that there are some NULL values. When we order the table by ParcelID though, we see ParcelID's that are the same. 
 --- This means we can write a query to find ParcelID's that are the same, and if one is has a PropertyAddress, we can replace the NULL's for that same ParcelID 
 --- with the correct PropertyAddress

 SELECT NH1.ParcelID, NH1.PropertyAddress, NH2.ParcelID,NH2.PropertyAddress, ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
 FROM PortfolioProjects..NashvilleHousing NH1
 JOIN PortfolioProjects..NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL

UPDATE NH1
SET PropertyAddress = ISNULL(NH1.PropertyAddress,NH2.PropertyAddress)
 FROM PortfolioProjects..NashvilleHousing NH1
 JOIN PortfolioProjects..NashvilleHousing NH2
	ON NH1.ParcelID = NH2.ParcelID
	AND NH1.[UniqueID ] <> NH2.[UniqueID ]
WHERE NH1.PropertyAddress IS NULL


----------------------------------------------------------------------------------------------------------------------------------------
---Breaking address into individual columns
--- Right now the address is all contained in one column, but we want each piece in individual columns (Address, City, State) 
SELECT PropertyAddress
FROM PortfolioProjects..NashvilleHousing

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS Address
FROM PortfolioProjects..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT OwnerAddress
FROM PortfolioProjects..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM PortfolioProjects..NashvilleHousing


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


---------------------------------------------------------------------------------------------------------------------------------------------
--- Change Y and N to Yes and No in SoldasVacant Column
SELECT  DISTINCT SoldAsVacant, COUNT(SoldAsVacant)
FROM PortfolioProjects..NashvilleHousing  
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END
FROM PortfolioProjects..NashvilleHousing


UPDATE PortfolioProjects..NashvilleHousing
SET SoldAsVacant = 
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------

--- Remove Duplicates
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num

FROM PortfolioProjects..NashvilleHousing
--ORDER BY ParcelID
)

DELETE
FROM RowNumCTE
WHERE row_num > 1

------------------------------------------------------------------------------------------------------------------------------

--- Delete unused columns
SELECT PropertyAddress, PropertySplitAddress,PropertySplitCity,OwnerAddress,OwnerSplitAddress,OwnerSplitCity,OwnerSplitState
FROM PortfolioProjects..NashvilleHousing

--- Since we split the addresses to get them in a more useful format, we will delete the columns that have the originally formatted addresses, as these are no longer useful

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress

--- We can also get rid of columns that are just taking up space and are unusable, like our TaxDistrict column
ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN TaxDistrict

--- We also made a new date column without that time, which means we can get rid of our SaleDate column as it isnt useful anymore

ALTER TABLE PortfolioProjects..NashvilleHousing
DROP COLUMN SaleDate