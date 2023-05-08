CREATE PROCEDURE [dbo].[SP_FI_ActualizarEstatusEnviadoFactura] 
	@IdFactura INT 
AS
BEGIN
-- =============================================
-- Author:		Miguel - DANIEL MODIFICACION
-- Create date: 5-12-16 - 17/08/2017
-- Description:	Consulta una factura
-- =============================================
	SET NOCOUNT ON;
-- =============================================
 
		UPDATE FI_Factura 
		SET IdEstatusEnviado = 8,
		FechaEnvio = GETDATE()
		WHERE IdFactura = @IdFactura

		SELECT 'UPDATE ESTATUS PETROVENDOR'

END

