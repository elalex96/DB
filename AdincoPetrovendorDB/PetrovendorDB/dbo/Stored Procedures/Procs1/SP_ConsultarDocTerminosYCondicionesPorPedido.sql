-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarDocTerminosYCondicionesPorPedido]
@IdPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EXISTEN_TERMINOS INT = (SELECT COUNT(TYC.IdTerminosYCondiciones)
	 								FROM TA_TerminosCondicionesOperacion TCO
									INNER JOIN TA_Operacion O ON O.IdOperacion = TCO.IdOperacion
									INNER JOIN MM_Pedido P ON O.IdDocumento = P.IdSolicitudPedido
									INNER JOIN TC_TerminosYCondicionesDocV2 TYC ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
									WHERE P.IdPedido = @IdPedido 
									)
	IF (@EXISTEN_TERMINOS > 0)
	BEGIN
	SELECT TYC.Documento
	FROM TA_TerminosCondicionesOperacion TCO
	INNER JOIN TA_Operacion O ON O.IdOperacion = TCO.IdOperacion
	INNER JOIN MM_Pedido P ON O.IdDocumento = P.IdSolicitudPedido
	INNER JOIN TC_TerminosYCondicionesDocV2 TYC ON TCO.IdTerminosYCondiciones = TYC.IdTerminosYCondiciones
	WHERE P.IdPedido = @IdPedido 
	END
	ELSE
	BEGIN
	SELECT 'NO_EXISTEN'
	END


	
END

