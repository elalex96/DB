
-- =============================================
-- Author:		DANIEL AC 
-- Create date: 17/08/2017
-- Description:	Agrega un concepto de una factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_InsertaConceptoFactura_Petrovendor] 
	-- Add the parameters for the stored procedure here

@IdFactura	int ,
@Descripcion	nvarchar(MAX) ,
@Cantidad	float ,
@Unidad	nvarchar(MAX) ,
@ValorUnitario	money ,
@Importe	money ,
@NoIdentificacion	nvarchar(MAX) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;


INSERT INTO [dbo].[FI_CFDIConcepto]
           ([IdFactura]
           ,[Descripcion]
           ,[Cantidad]
           ,[Unidad]
           ,[ValorUnitario]
           ,[Importe]
           ,[NoIdentificacion])
     VALUES
           (@IdFactura,
			@Descripcion,
			@Cantidad,
			@Unidad,
			@ValorUnitario,
			@Importe,
			@NoIdentificacion)

			SELECT CAST( @@IDENTITY  as nvarchar)  AS INSERTADO , 'El concepto se ha registrado correctamente con el id ' + CAST( @@IDENTITY  as nvarchar)  as MSG
    -- Insert statements for procedure here
	
END

