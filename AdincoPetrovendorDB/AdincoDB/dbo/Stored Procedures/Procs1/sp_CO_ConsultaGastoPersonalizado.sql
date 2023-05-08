-- =============================================
-- Author:		DANIEL Cruz
-- Create date: 12-06-17
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_CO_ConsultaGastoPersonalizado]
	-- Add the parameters for the stored procedure here
@IdCoRegistro INT 


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT [IdRegistro],[IdPrograma],[IdFactura],[MontoRegistro],[InicioEjecucion],[FinEjecucion],[Comentarios],ISNULL([IdInstalacion],0) AS IdIstalacion ,ISNULL([IdCatalogoCuentasSH],0) AS CCuenta,[Poliza]
	FROM [dbo].[CO_Registro]
	WHERE [IdRegistro] = @IdCoRegistro  



END
