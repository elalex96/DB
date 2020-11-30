-- =============================================
-- Author:		DANIEL AC
-- Create date: 16/11/2017
-- Description: Detalle de términos y condiciones de compra directa 
-- =============================================
CREATE PROCEDURE [dbo].[SP_CO_ConsultarDocTerminosYCondicionesCompra] 
@IdFactura INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- O.IdTipoOperacion=14 Compra directa

	DECLARE @EXISTEN_TERMINOS INT = (SELECT COUNT(TYC.IdTerminosYCondiciones)
	 								FROM TA_TerminosCondicionesOperacion TCO
									INNER JOIN TA_Operacion O ON O.IdOperacion = TCO.IdOperacion
									INNER JOIN CO_Registro CO ON O.IdDocumento = CO.IdFactura
									INNER JOIN TC_TerminosYCondicionesDocV2 TYC ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
									WHERE O.IdDocumento = @IdFactura AND O.IdTipoOperacion=14 
									)
	IF (@EXISTEN_TERMINOS > 0)
	BEGIN
		SELECT TYC.Documento
		FROM TA_TerminosCondicionesOperacion TCO
		INNER JOIN TA_Operacion O ON O.IdOperacion = TCO.IdOperacion
		INNER JOIN CO_Registro CO ON O.IdDocumento = CO.IdFactura
		INNER JOIN TC_TerminosYCondicionesDocV2 TYC ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
		WHERE O.IdDocumento = @IdFactura AND O.IdTipoOperacion=14 
	END
	ELSE
		BEGIN
		SELECT 'NO_EXISTEN'
		END


	
END