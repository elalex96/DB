-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10/01/20148>
-- Description:	<Consulta de matriz y porcentajes por solicitud de pedido>
-- =============================================

CREATE procedure [dbo].[ME_SP_ConsultaMatrizXidPedido]
	@IdSolicitudPedido INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT m.IdDocMatriz, 
			m.NombreDoc,
			m.PorcentajeET, 
			m.PorcentajeEC
		FROM dbo.TA_DocMatrizOperacion m
		WHERE m.IdOperacion = @IdSolicitudPedido
END
