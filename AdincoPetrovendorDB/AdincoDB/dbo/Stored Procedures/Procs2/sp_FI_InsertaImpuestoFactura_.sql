-- =============================================
-- Author:		Miguel
-- Create date: 
-- Description:	
-- =============================================
create PROCEDURE sp_FI_InsertaImpuestoFactura_
	-- Add the parameters for the stored procedure here

@IdFactura	int ,
@IdTipoImpuesto	int ,
@Impuesto	nvarchar(MAX) ,
@Tasa	float ,
@Importe	money 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here


INSERT INTO [dbo].[FI_CFDIImpuesto]
           ([IdFactura]
           ,[IdTipoImpuesto]
           ,[Impuesto]
           ,[Tasa]
           ,[Importe])
     VALUES
           (@IdFactura,
@IdTipoImpuesto,
@Impuesto,
@Tasa,
@Importe)
SELECT CAST( @@IDENTITY  as nvarchar)  AS INSERTADO , 'El impuesto se ha registrado correctamente con el id ' + CAST( @@IDENTITY  as nvarchar)  as MSG


END