-- =============================================
-- Author:		DANIEL CRUZ
-- Create date: 21/12/2017
-- Description:	 Consutar las monedas activas 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarMoneda_MV1_5] 
	-- Add the parameters for the stored procedure here
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME  
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
   
 
	SELECT IdMoneda, TipoMonedaCorto  
	FROM PV_TipoMoneda (NOLOCK)
	WHERE Eliminado = 1 
	Order By TipoMoneda   ASC
	

END


