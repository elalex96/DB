-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <08/10/19>
-- Description:	<Consulta el nombre del contrato de la operadora de la aceptación>
-- =============================================
CREATE PROCEDURE SP_ContratoOperadoraEnvioAprobacionFactura
@IdAceptacionPedido INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		SELECT
		C.IdContrato AS IdContratoOperadora,
		C.NumeroContrato + ' - ' + AC.NombreAreaContractual AS NombreContrato
		FROM dbo.MM_AceptacionPedido AP
		LEFT JOIN dbo.MM_Pedido P ON P.IdPedido = AP.IdPedido
		LEFT JOIN Adinco.dbo.CO_Contrato C ON C.IdContrato = P.IdContrato
		LEFT JOIN Adinco.dbo.CO_AreaContractual AC ON AC.IdAreaContractual = C.IdAreaContractual
		WHERE AP.IdAceptacionPedido = @IdAceptacionPedido

END
