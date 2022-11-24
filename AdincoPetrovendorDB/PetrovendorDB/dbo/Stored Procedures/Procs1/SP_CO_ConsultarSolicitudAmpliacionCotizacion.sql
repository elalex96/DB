-- =============================================
-- Author:		Alexander Gomez
-- Create date: 30/05/2018
-- Description:	Validacion para mostrar los proveedores que solicitaron una ampliacion del plazo de cotizacion
-- =============================================
CREATE PROCEDURE SP_CO_ConsultarSolicitudAmpliacionCotizacion
	-- Add the parameters for the stored procedure here
	@IdSolicitudPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @SOLICITANTES NVARCHAR(MAX) = (
	SELECT STUFF((SELECT ', ' + PR.RazonSocial + PR.RegimenCapital FROM dbo.MM_PeticionOferta AS PO
	LEFT JOIN dbo.S_Proveedor AS PR ON PR.IdProveedor = PO.IdSubcontratista
	WHERE PO.IdSolicitudPedido = @IdSolicitudPedido
	AND PO.AmpliacionPor IS NOT NULL 
	FOR XML PATH ('')),1, 2, '')
	)

	SELECT ISNULL(@SOLICITANTES,'')
END
