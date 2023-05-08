-- =============================================
-- Author:	Daniel AC
-- Create date: 06-11-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_CartaValidarProveedor] 
	-- Add the parameters for the stored procedure here
@IdAceptacionPedido INT,
@IdProveedor INT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here 
	  

	SELECT CASE WHEN  COUNT(AP.IdAceptacionPedido)  > 0 THEN 'EXISTE' ELSE 'NO_EXISTE' END 
	FROM dbo.MM_AceptacionPedido AP
	INNER JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
	WHERE P.IdSubcontratista = @IdProveedor AND AP.IdAceptacionPedido = @IdAceptacionPedido
	 


END





SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
