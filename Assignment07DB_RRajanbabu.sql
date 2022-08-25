--*************************************************************************--
-- Title: Assignment07
-- Author: RRajanbabu
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2022-08-18, RRajanbabu, Created File & Completed Questions 1-4
-- 2022-08-22, RRajanbabu, Completed Questions 5-6
-- 2022-08-23, RRajanbabu, Completed Questions 7-8
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_RRajanbabu')
	 Begin 
	  Alter Database [Assignment07DB_RRajanbabu] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_RRajanbabu;
	 End
	Create Database Assignment07DB_RRajanbabu;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_RRajanbabu;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine -- Ignore!
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts): COMPLETE
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT * FROM vProducts AS P;
-- GO
-- <Attempt 2>
-- SELECT
-- 	P.ProductName,
-- 	P.UnitPrice
-- FROM vProducts AS P
-- ORDER BY 1;
-- GO
-- <Final Answer>
SELECT
	P.ProductName,
	FORMAT(P.UnitPrice, 'C') AS UnitPrice
FROM vProducts AS P
ORDER BY 1;
GO

-- Question 2 (10% of pts): COMPLETE
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT * FROM vCategories AS C;
-- GO
-- SELECT * FROM vProducts AS P;
-- GO
-- <Attempt 2>
-- SELECT
-- 	C.CategoryName,
-- 	P.ProductName,
-- 	P.UnitPrice
-- FROM vCategories AS C
-- INNER JOIN vProducts AS P
-- ON C.CategoryID = P.CategoryID
-- ORDER BY 1, 2;
-- <Final Answer>
SELECT
	C.CategoryName,
	P.ProductName,
	FORMAT(P.UnitPrice, 'C') AS UnitPrice
FROM vCategories AS C
INNER JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
ORDER BY 1, 2;

-- Question 3 (10% of pts): COMPLETE
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT * FROM vProducts AS P;
-- GO
-- SELECT * FROM vInventories AS I;
-- GO
-- <Attempt 2>
-- SELECT
-- 	P.ProductName,
-- 	I.InventoryDate,
-- 	I.[Count] AS InventoryCount
-- FROM vProducts AS P
-- INNER JOIN vInventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY 1, 2;
-- GO
-- <Final Answer>
SELECT
	P.ProductName,
	InventoryDate = DateName(MONTH, I.InventoryDate) + ', ' + DateName(YEAR, I.InventoryDate),
	I.[Count] AS InventoryCount
FROM vProducts AS P
INNER JOIN vInventories AS I
ON P.ProductID = I.ProductID
ORDER BY 1, MONTH(InventoryDate);
GO

-- Question 4 (10% of pts): COMPLETE
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT
-- 	P.ProductName,
-- 	InventoryDate = DateName(MONTH, I.InventoryDate) + ', ' + DateName(YEAR, I.InventoryDate),
-- 	I.[Count] AS InventoryCount
-- FROM vProducts AS P
-- INNER JOIN vInventories AS I
-- ON P.ProductID = I.ProductID
-- ORDER BY 1, MONTH(InventoryDate);
-- GO
-- <Final Answer>
CREATE VIEW vProductInventories
AS
SELECT TOP 100
	P.ProductName,
	InventoryDate = DateName(MONTH, I.InventoryDate) + ', ' + DateName(YEAR, I.InventoryDate),
	I.[Count] AS InventoryCount
FROM vProducts AS P
INNER JOIN vInventories AS I
ON P.ProductID = I.ProductID
ORDER BY 1, MONTH(InventoryDate);
GO
-- Check that it works: Select * From vProductInventories;
GO

-- Question 5 (10% of pts): COMPLETE
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Category and Date.

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT
-- 	C.CategoryName,
-- 	InventoryDate = DateName(MONTH, I.InventoryDate) + ', ' + DateName(YEAR, I.InventoryDate),
-- 	I.[Count] AS InventoryCount
-- FROM vCategories AS C
-- INNER JOIN vProducts AS P
-- ON C.CategoryID = P.CategoryID
-- INNER JOIN vInventories AS I
-- ON P.ProductID = I.ProductID;
-- GO
-- <Attempt 2>
-- SELECT
-- 	C.CategoryName,
-- 	InventoryDate = DateName(MONTH, I.InventoryDate) + ', ' + DateName(YEAR, I.InventoryDate),
-- 	SUM(I.[Count]) AS InventoryCount
-- FROM vCategories AS C
-- INNER JOIN vProducts AS P
-- ON C.CategoryID = P.CategoryID
-- INNER JOIN vInventories AS I
-- ON P.ProductID = I.ProductID
-- GROUP BY C.CategoryName, InventoryDate;
-- GO
-- <Attempt 3>
-- SELECT
-- 	C.CategoryName,
-- 	InventoryDate = DateName(MONTH, I.InventoryDate) + ', ' + DateName(YEAR, I.InventoryDate),
-- 	SUM(I.[Count]) AS InventoryCount
-- FROM vCategories AS C
-- INNER JOIN vProducts AS P
-- ON C.CategoryID = P.CategoryID
-- INNER JOIN vInventories AS I
-- ON P.ProductID = I.ProductID
-- GROUP BY C.CategoryName, InventoryDate
-- ORDER BY 1, MONTH(InventoryDate);
-- GO
-- <Final Answer>
CREATE VIEW vCategoryInventories
AS
SELECT TOP 100
	C.CategoryName,
	InventoryDate = DateName(MONTH, I.InventoryDate) + ', ' + DateName(YEAR, I.InventoryDate),
	SUM(I.[Count]) AS InventoryCount
FROM vCategories AS C
INNER JOIN vProducts AS P
ON C.CategoryID = P.CategoryID
INNER JOIN vInventories AS I
ON P.ProductID = I.ProductID
GROUP BY C.CategoryName, InventoryDate
ORDER BY 1, MONTH(InventoryDate);
GO
-- Check that it works: Select * From vCategoryInventories;
GO

-- Question 6 (10% of pts): COMPLETE
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT 
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount
-- FROM vProductInventories;
-- GO
-- <Attempt 2>
-- SELECT 
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount,
-- 	PreviousMonthCount = IIF(MONTH(InventoryDate) = 1,  0, InventoryCount) 
-- FROM vProductInventories;
-- GO
-- <Attempt 3>
-- SELECT 
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount,
-- 	PreviousMonthCount = IIF(MONTH(InventoryDate) = 1,  0, (Lag(InventoryCount, 1) OVER(ORDER BY ProductName)))
-- FROM vProductInventories;
-- GO
-- <Attempt 4>
-- SELECT 
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount,
-- 	PreviousMonthCount = IIF(MONTH(InventoryDate) = 1,  0, (Lag(InventoryCount, 1) OVER(ORDER BY ProductName)))
-- FROM vProductInventories
-- ORDER BY 1, MONTH(InventoryDate);
-- GO
-- <Final Answer>
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
AS
SELECT TOP 100
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount =
		IIF(
			MONTH(InventoryDate) = 1,
			0,
			(Lag(InventoryCount, 1) OVER(ORDER BY ProductName))
		)
FROM vProductInventories
ORDER BY 1, MONTH(InventoryDate);
GO
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
GO

-- Question 7 (15% of pts): COMPLETE
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.
-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount,
-- 	PreviousMonthCount
-- FROM vProductInventoriesWithPreviousMonthCounts;
-- GO
-- <Attempt 2>
-- SELECT
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount,
-- 	PreviousMonthCount,
-- 	CountVsPreviousCountKPI =
-- 		CASE
-- 			WHEN InventoryCount = PreviousMonthCount THEN 0
-- 			WHEN InventoryCount > PreviousMonthCount THEN 1
-- 			WHEN InventoryCount < PreviousMonthCount THEN -1
-- 		END
-- FROM vProductInventoriesWithPreviousMonthCounts;
-- GO
-- <Final Answer>
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
AS
SELECT TOP 100
	ProductName,
	InventoryDate,
	InventoryCount,
	PreviousMonthCount,
	CountVsPreviousCountKPI =
		CASE
			WHEN InventoryCount = PreviousMonthCount THEN 0
			WHEN InventoryCount > PreviousMonthCount THEN 1
			WHEN InventoryCount < PreviousMonthCount THEN -1
		END
FROM vProductInventoriesWithPreviousMonthCounts
ORDER BY 1, MONTH(InventoryDate);
GO
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- Question 8 (25% of pts): COMPLETE
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
-- <Attempt 1>
-- SELECT
-- 	ProductName,
-- 	InventoryDate,
-- 	InventoryCount,
-- 	PreviousMonthCount,
-- 	CountVsPreviousCountKPI
-- FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
-- GO
-- <Final Answer>
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs(@Value INT)
RETURNS TABLE AS
RETURN
	SELECT *
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs
	WHERE CountVsPreviousCountKPI = @Value;
GO
/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
GO
/***************************************************************************************/