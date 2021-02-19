-- =============================================
-- Author:	Alexander Gomez
-- Create date: 15-06-17
-- Description:	
-- =============================================
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 18-02-21
-- Description:	adecuacion para carta CN para DEA
-- =============================================
CREATE procedure [dbo].[SP_MPY_MM_CartaValidarProveedor] 
	-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT,
@IdProveedor NVARCHAR(20) 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here 

	DECLARE @RFCPROVEEDOR NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor)

	DECLARE @PROVEEDOR_DEA INT = (SELECT COUNT(1)
									FROM dbo.DEA_Proveedor AS PRDEA
										JOIN dbo.S_Proveedor AS PR ON PRDEA.RFC = PR.RFC
									WHERE PR.IdProveedor = @IdProveedor)

	IF @PROVEEDOR_DEA > 0
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
