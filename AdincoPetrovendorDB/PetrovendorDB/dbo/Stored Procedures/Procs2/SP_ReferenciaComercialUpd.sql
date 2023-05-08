
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description: Consulta los datos de la evaluacion por usuario
				
-- =============================================
	CREATE PROCEDURE [dbo].[SP_ReferenciaComercialUpd] 
	-- Add the parameters for the stored procedure here
		@IdReferenciaComercial int,
		@Empresa nvarchar(MAX),
		@Telefono nvarchar(MAX),
		@Correo nvarchar(MAX),
		@ImporteLineaCredito nvarchar(MAX)
		
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
		UPDATE PV_ReferenciasComerciales
		SET
			Empresa = @Empresa,
			Telefono = @Telefono,
			Correo = @Correo,
			ImporteLineaCredito = @ImporteLineaCredito,
			FechaModificacion = GETDATE()
			WHERE	IdReferenciaComercial = @IdReferenciaComercial

			SELECT 'Referencia EDITADA Exitosamente' AS Respose
	 
END


