
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Consulta para cargar combo de URLs para los modulos>
-- =============================================

CREATE procedure ME_SP_ComboModulosURL
	--@Id INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdModulo, URL_MODULO
	FROM dbo.Modulo 
	WHERE IsEliminado <> 1 OR IsEliminado IS NULL AND Aplicacion = 0
END