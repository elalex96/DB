-- =============================================
-- Author:	Alexander Gomez
-- Create date: 15-06-17
-- Description:	
-- =============================================
-- =============================================  
-- Author: Alexander Gomez  
-- Create date: 18-02-21  
-- Description: adecuacion para carta CN para DEA  
-- =============================================  
ALTER procedure [dbo].[SP_MPY_MM_CartaValidarProveedor] 
	-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT,
@IdProveedor NVARCHAR(20) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here 

	DECLARE @RFC_ACTUAL NVARCHAR(200), @EXISTE_RFC INT;

	set @RFC_ACTUAL = (SELECT TOP 1
							P.RFC
						FROM dbo.MM_AceptacionPedido AS AP
						JOIN dbo.S_Proveedor AS P ON AP.IdProveedor = P.IdProveedor
						WHERE AP.IdAceptacionPedido = @IdAceptacionPedido);

	set @EXISTE_RFC = (SELECT COUNT(IdProveedor) 
						FROM DEA_Proveedor 
						WHERE RTRIM(LTRIM(RFC))=RTRIM(LTRIM(@RFC_ACTUAL)) 
						AND Activo = 1)

	IF @EXISTE_RFC > 0
	BEGIN
		
		SELECT 'EXISTE_PROVEEDOR_DEA'

	END
	ELSE
	BEGIN
		
		SELECT CASE WHEN  COUNT(AP.IdAceptacionPedido)  > 0 THEN 'EXISTE' ELSE 'NO_EXISTE' END 
		FROM dbo.MPY_MM_AceptacionPedido AS AP
		WHERE --AP.IdSubcontratista = @RFCPROVEEDOR AND 
		AP.IdAceptacionPedido = @IdAceptacionPedido

	END;

END

