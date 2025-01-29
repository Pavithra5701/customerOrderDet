
ALTER PROCEDURE [dbo].[GetLatestOrderDetails]
    @CustomerEmail NVARCHAR(255),
    @CustomerId NVARCHAR(50)
AS
BEGIN

	IF EXISTS (select * from Customers WHERE CustomerId = @CustomerId AND Email = @CustomerEmail)
	BEGIN
		SET NOCOUNT ON;
		DECLARE 
			@FirstName NVARCHAR(100), 
			@LastName NVARCHAR(100),
			@HouseNo NVARCHAR(50), 
			@Street NVARCHAR(100), 
			@Town NVARCHAR(100), 
			@PostCode NVARCHAR(20),

			@OrderId INT, 
			@OrderDate DATE, 
			@DeliveryExpected DATE;
		
	-- -- To Get the Customer Details By Mail Id and Customer ID -- --
		SELECT 
			@FirstName = Firstname, 
			@LastName = Lastname,
			@HouseNo = HouseNo, 
			@Street = Street, 
			@Town = Town, 
			@PostCode = PostCode
			FROM Customers
			WHERE CustomerId = @CustomerId AND Email = @CustomerEmail;


	-- -- To Get the Most Recent Order , Based on CustId -- --
		SELECT TOP 1 
			@OrderId = OrderId, 
			@OrderDate = OrderDate, 
			@DeliveryExpected = DeliveryExpected
			FROM Orders
			WHERE CustomerId = @CustomerId
			ORDER BY OrderDate DESC;

	-- -- Select The Customer Details And Order Details -- --

		If @OrderId is Not Null
		Begin
			SELECT 
				@FirstName AS FirstName, 
				@LastName AS LastName,
				@OrderId AS OrderNumber, 
				FORMAT(@OrderDate, 'dd-MMM-yyyy') AS OrderDate, 
				CONCAT(@HouseNo, ' ', @Street, ', ', @Town, ', ', @PostCode) AS DeliveryAddress, 
				FORMAT(@DeliveryExpected, 'dd-MMM-yyyy') AS DeliveryExpected;

		-- -- To get the Product Details Based on OrderItems -- --
			SELECT 
				P.productname AS Product, 
				OI.Quantity, 
				OI.Price AS PriceEach
				FROM OrderItems OI
				JOIN Products P ON OI.ProductId = P.ProductId
				WHERE OI.OrderId = @OrderId;
		END

		Else 
		Begin
						SELECT 
						@FirstName AS FirstName, 
						@LastName AS LastName,
						NULL AS DeliveryAddress, 
						NULL AS OrderNumber,
						NULL AS OrderDate,
						NULL AS DeliveryAddress,
						NULL AS DeliveryExpected;
            
					   SELECT NULL AS Product, NULL AS Quantity, NULL AS PriceEach;
		End
	End
End


-- exec  GetLatestOrderDetails 'ken@aol.com','X45001'