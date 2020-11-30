
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <10-07-2018>
-- Description:	<Consulta del Historial de cierre de un pedido>
-- =============================================

CREATE procedure MM_SP_ConsultaHistorialCierrePedido
	@IdPedido INT,
	@TipoRegistro INT = 0,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT h.IdHistorialCierrePedido,
			tr.Nombre AS NombreRegistro,
			h.CambiadoEl,
			h.MotivoInterno,
			h.MotivoExterno,
			u.Nombre,
			h.TipoRegistro
	FROM dbo.MM_HistorialCierrePedido h
	INNER JOIN dbo.MM_TipoRegistroHistorialCierrePedido tr ON tr.IdTipoRegistroHistorialCierrePedido = h.TipoRegistro
	INNER JOIN dbo.S_Usuario u ON u.IdUsuario = h.CambiadoPor
	WHERE h.IdPedido = @IdPedido
		AND (h.TipoRegistro = @TipoRegistro OR @TipoRegistro = 0) 
END
