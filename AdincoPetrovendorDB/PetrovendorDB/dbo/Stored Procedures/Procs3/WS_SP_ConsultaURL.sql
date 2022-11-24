-- =============================================
-- Author:		<Jose Roman>
-- Create date: <05-06-2018>
-- Description:	<Se consulta la url del WebSerice a consumir>
-- =============================================

CREATE procedure WS_SP_ConsultaURL
	@IdURL INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT URL
	FROM dbo.WS_URLs
	WHERE IdUrl = @IdURL
END