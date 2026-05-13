-- =============================================
-- Author:		JG
-- Create date: Hoy
-- Description:	Actualiza la vista de factura de ADINCO
-- =============================================
CREATE PROCEDURE [dbo].[AX_RegistraCuentaPolizaCARSO]
	-- Add the parameters for the stored procedure here
	@UUID VARCHAR (MAX	),
	@CSH VARCHAR(MAX),
	@Poliza INT 


AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
    -- Insert statements for procedure here

	DECLARE	 @IdCSH INT =( SELECT TOP 1 IdCatalogoCuentasSH FROM dbo.CO_CatalogoCuentaSH WHERE Nivel3 = @CSH)
	DECLARE  @IdFactura INT = (SELECT TOP 1  IdFactura FROM dbo.FI_Factura WHERE UUID =	@UUID)

	IF (@IdCSH <> 0 OR @IdCSH IS NOT NULL	)
		BEGIN	
			IF(@IdFactura <> 0 OR @IdFactura IS NOT NULL )
			BEGIN
				UPDATE dbo.CO_Registro SET	
				IdCatalogoCuentasSH = @IdCSH,
				Poliza = @Poliza
				WHERE IdFactura = @IdFactura
			END
			ELSE	
			BEGIN	
			SELECT 'No existe la factura recibida'
			END
		END	
		
	ELSE	 
	BEGIN	
	SELECT 'No existe la cuenta del Catálogo del Sector Hidrocarburos'
	END
	END	;
