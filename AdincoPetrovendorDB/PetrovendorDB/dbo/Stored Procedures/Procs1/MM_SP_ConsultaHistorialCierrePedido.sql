-- =============================================
-- Author:		Luis David De La Cruz Bautista
-- Update date: 20/01/2021
-- Description:	920 optimización de la consulta por issue 920
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
	INNER JOIN dbo.MM_TipoRegistroHistorialCierrePedido tr 
	ON h.TipoRegistro = tr.IdTipoRegistroHistorialCierrePedido 
	INNER JOIN dbo.S_Usuario u 
	ON h.CambiadoPor = u.IdUsuario
	WHERE h.IdPedido = @IdPedido
		AND (h.TipoRegistro = @TipoRegistro OR @TipoRegistro = 0) 
END
