
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description: Consulta los datos de la evaluacion por usuario
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_ConsultarEvaluacionProveedor] 
	-- Add the parameters for the stored procedure here
		@IdProveedor int
 
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ReseniaF int

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SELECT IdProveedor, RazonSocial, Alias FROM S_Proveedor WHERE IdProveedor = @IdProveedor

END

