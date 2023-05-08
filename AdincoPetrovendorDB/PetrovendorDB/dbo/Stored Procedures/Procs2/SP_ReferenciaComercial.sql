
-- =============================================
-- Author:		Alexander G
-- Create date: 29-06-17
-- Description: Consulta los datos de la evaluacion por usuario
				
-- =============================================
	CREATE PROCEDURE [dbo].[SP_ReferenciaComercial] 
	-- Add the parameters for the stored procedure here
		@Proveedor int,
		@Empresa nvarchar(MAX),
		@Telefono nvarchar(MAX),
		@Correo nvarchar(MAX),
		@ImporteLineaCredito nvarchar(MAX)
AS
BEGIN
	 
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	DECLARE @ReferenciaF int

	SET NOCOUNT ON;

    -- Insert statements for procedure here
	 SET @ReferenciaF = (
	 SELECT IdReferenciaComercial FROM PV_ReferenciasComerciales
	 WHERE 
		Proveedor = @Proveedor AND 
		--Empresa = @Empresa AND 
		Correo = @Correo AND
		ReferenciaActiva = 1
	 )

	 IF @ReferenciaF IS NULL
	 BEGIN
		 INSERT INTO PV_ReferenciasComerciales (
		 Empresa,
		 Telefono,
		 Correo,
		 ImporteLineaCredito,
		 Proveedor,
		 ReferenciaActiva,
		 FechaAltaReferencia
		 )
		 VALUES
		 (
		 @Empresa,
		 @Telefono,
		 @Correo,
		 @ImporteLineaCredito,
		 @Proveedor,
		 1,
		 GETDATE()
		 )
		 SELECT 'Referencia Enviada Exitosamente' AS Respose
	 END

	 IF @ReferenciaF > 0
	 BEGIN
		UPDATE PV_ReferenciasComerciales
		SET
			Empresa = @Empresa,
			Telefono = @Telefono,
			Correo = @Correo,
			ImporteLineaCredito = @ImporteLineaCredito,
			Proveedor = @Proveedor,
			FechaModificacion = GETDATE()
			WHERE	IdReferenciaComercial = @ReferenciaF

			SELECT 'Referencia EDITADA Exitosamente' AS Respose
	 END
END



