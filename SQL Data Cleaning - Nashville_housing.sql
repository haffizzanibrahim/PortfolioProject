-- A quick look into the table


Select *
From PortfolioProject..Nashville_housing


/*________________________________________NUMBER ONE (1)________________________________________*/

-- The SaleDate column has both date and time (00:00:00), we gonna get rid off the time.


Select SaleDateonly --, CAST(SaleDate as date) AS SaleDate2
From PortfolioProject..Nashville_housing


Update Nashville_housing
SET SaleDate = CAST(SaleDate as date)



-- The above method does not work, so we insert a new column instead of converting an existing one.



ALTER TABLE Nashville_housing
Add SaleDateonly Date;

Update Nashville_housing
SET SaleDateonly = CONVERT(Date,SaleDate)


/*________________________________________NUMBER TWO (2)________________________________________*/

-- Working with PropertyAddress column; null values

Select *
FROM PortfolioProject..Nashville_housing
--WHERE PropertyAddress is null
Order by ParcelID  /*look at no44&45, 61&62, 75&76, same parcelid and same propertyaddress*/


-- using join of the same table.


SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM PortfolioProject..Nashville_housing AS A
JOIN PortfolioProject..Nashville_housing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]
WHERE A.PropertyAddress is null
ORDER BY A.ParcelID


-- Replacing NULL value of the property address with address from the same ParcelID, using IS NULL() function.

UPDATE A
SET PropertyAddress = ISNULL (A.PropertyAddress, B.PropertyAddress)
FROM PortfolioProject..Nashville_housing AS A
JOIN PortfolioProject..Nashville_housing AS B
	ON A.ParcelID = B.ParcelID
	AND A.[UniqueID ] <> B.[UniqueID ]


-- Checking up

SELECT *
FROM PortfolioProject..Nashville_housing
WHERE PropertyAddress is null
ORDER BY ParcelID


/*________________________________________NUMBER THREE (3)________________________________________*/

-- Working with PropertyAddress column; split into individual column; address, city.

Select PropertyAddress
From PortfolioProject..Nashville_housing /*2005  SADIE LN (address), GOODLETTSVILLE(city). Separated by coma*/


-- Note: Substring () has three argument. (column name, position number to start, end with what or length of the wanted substring)

SELECT
SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM PortfolioProject..Nashville_housing

ALTER TABLE Nashville_housing
ADD Address nvarchar(255), City nvarchar(255);

UPDATE Nashville_housing
SET Address = SUBSTRING (PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

UPDATE Nashville_housing
SET City = SUBSTRING (PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


--Checking up

SELECT Address, City
FROM PortfolioProject..Nashville_housing



/*________________________________________NUMBER FOUR (4)________________________________________*/
--Working with OwnerAddress column to extract the state.

SELECT OwnerAddress
FROM PortfolioProject..Nashville_housing /*The last two letters is the state*/

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
--PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
FROM PortfolioProject..Nashville_housing

ALTER TABLE Nashville_housing
ADD State nvarchar(255);

UPDATE Nashville_housing
SET State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


--Checking up

SELECT *
FROM PortfolioProject..Nashville_housing


/*________________________________________NUMBER FIVE (5)________________________________________*/
-- checking out SoldAsVacant column


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject..Nashville_housing
Group by SoldAsVacant
order by 2

SELECT SoldAsVacant,
CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortfolioProject..Nashville_housing


UPDATE Nashville_housing
SET SoldAsVacant = CASE 
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



/*________________________________________NUMBER SIX (6)________________________________________*/
-- Removing Duplicates


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

From PortfolioProject..Nashville_housing

-- using cte

WITH RowNumCTE AS (
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
From PortfolioProject..Nashville_housing
)
SELECT * --Use DELETE 
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject..Nashville_housing




/*________________________________________NUMBER SEVEN (7)________________________________________*/
-- Delete Unused Columns



Select *
From PortfolioProject..Nashville_housing


ALTER TABLE PortfolioProject..Nashville_housing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
