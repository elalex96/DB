
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <>
-- Description:	<>
-- =============================================

CREATE procedure ME_SP_ConsultarURLdeModulos
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT m.IdModulo, m2.URL_MODULO
	FROM dbo.ME_EG_Modulos m
	INNER JOIN dbo.Modulo m2 ON m2.IdModulo = m.IdModuloUrl
END