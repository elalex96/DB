
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10-12-2018>
-- Description:	<Se consulta del documento PDF de pago de una factura>
-- =============================================

CREATE PROCEDURE FI_SP_DescargaPDFPago	
	@IdTransfer INT,
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN

	SELECT IdTransferencia,
		NombreExtencionArchivo,
		PDF
	FROM Adinco.dbo.FI_Transfer
	WHERE IdTransferencia = @IdTransfer

END
