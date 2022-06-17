/*

Cleaning Data in SQL Queries

*/

-- Standardize Date Format

SELECT SaleDate, CAST(SaleDate AS Date) AS DateOfSale
FROM NashvileeHousing

UPDATE NashvileeHousing
SET SaleDate = CAST(SaleDate AS Date)


/*

-- The above approach may not work properly sometimes
-- We can alter the table instead

*/


ALTER TABLE NashvileeHousing
ADD DateOfSale Date

UPDATE NashvileeHousing
SET DateofSale = CAST(SaleDate AS Date)

SELECT SaleDate, DateofSale
FROM NashvileeHousing



-- Populate Property Address data (filling missing data)

SELECT * 
FROM NashvileeHousing
WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM NashvileeHousing a JOIN NashvileeHousing b
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvileeHousing a JOIN NashvileeHousing B
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvileeHousing a JOIN NashvileeHousing B
ON a.ParcelID = b.ParcelID AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


SELECT PropertyAddress
FROM NashvileeHousing



-- Breaking out Address into Individual Columns (Address, City, State)

SELECT SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1), 
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))
FROM NashvileeHousing

ALTER TABLE NashvileeHousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvileeHousing
SET PropertySplitAddress  = SUBSTRING( PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvileeHousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvileeHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
FROM NashvileeHousing

SELECT * FROM NashvileeHousing

SELECT OwnerAddress
FROM NashvileeHousing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'), 3),
PARSENAME(REPLACE(OwnerAddress,',','.'), 2),
PARSENAME(REPLACE(OwnerAddress,',','.'), 1)
FROM NashvileeHousing

ALTER TABLE NashvileeHousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvileeHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'), 3)

ALTER TABLE NashvileeHousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvileeHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'), 2)

ALTER TABLE NashvileeHousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvileeHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'), 1)


SELECT * FROM NashvileeHousing



-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant)
FROM NashvileeHousing

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvileeHousing
GROUP BY SoldAsVacant


SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END
FROM NashvileeHousing

UPDATE NashvileeHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
WHEN SoldAsVacant = 'N' THEN 'No'
ELSE SoldAsVacant
END


SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM NashvileeHousing
GROUP BY SoldAsVacant




-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From NashvileeHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvileeHousing
