USE [Petrovendor]
GO

/****** Object:  UserDefinedTableType [dbo].[WDEA_Layout_T_V2]    Script Date: 03/09/2021 11:02:47 a. m. ******/
CREATE TYPE [dbo].[WDEA_Layout_T_V2] AS TABLE(
	[Item] [nvarchar](100) NULL,
	[Purch_Organization] [nvarchar](1000) NULL,
	[Cost_Center] [nvarchar](1000) NULL,
	[WBS_Element] [nvarchar](1000) NULL,
	[Short_Text] [nvarchar](max) NULL,
	[Outline_Agreegement] [nvarchar](100) NULL,
	[Validity_Per_Start] [nvarchar](100) NULL,
	[Validity_Period_End] [nvarchar](100) NULL,
	[Deletion_Indicador] [nvarchar](100) NULL,
	[Plant] [nvarchar](100) NULL,
	[Order_Quantity] [nvarchar](100) NULL,
	[Order_Unit] [nvarchar](100) NULL,
	[Net_Price] [nvarchar](100) NULL,
	[Currency] [nvarchar](100) NULL,
	[Vendor_Supplying_Plant] [nvarchar](100) NULL,
	[Purchasing_Document] [nvarchar](100) NULL,
	[Release_State] [nvarchar](100) NULL,
	[Name_of_Vendor] [nvarchar](100) NULL,
	[Order_Price_Unit] [nvarchar](100) NULL,
	[Net_Order_Value] [nvarchar](100) NULL,
	[Requisitioner] [nvarchar](100) NULL,
	[Terminos_Pago] [nvarchar](100) NULL,
	[Justificacion] [nvarchar](max) NULL,
	[RowN] [nvarchar](100) NULL
)
GO


