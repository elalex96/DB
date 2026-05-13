
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description: Consulta los datos de la evaluacion por usuario
				
-- =============================================
	CREATE  PROCEDURE [dbo].[SP_EliminarReferencia] 
	-- Add the parameters for the stored procedure here
		@IdReferenciaComercial int

AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ReseniaF int

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 
	 UPDATE PV_ReferenciasComerciales
		SET
			ReferenciaActiva = 0
			WHERE	IdReferenciaComercial = @IdReferenciaComercial
			SELECT 'Referencia ELIMINADA Exitosamente' AS Respose

END



