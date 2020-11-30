
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description: Consulta los datos de la evaluacion por usuario
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_ConsultarReferencia] 
	-- Add the parameters for the stored procedure here
		@IdReferenciaComercial int

AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ReseniaF int

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
	 SELECT Empresa, Telefono,Correo, ImporteLineaCredito
	 FROM PV_ReferenciasComerciales
	 WHERE IdReferenciaComercial = @IdReferenciaComercial

END



