
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <07-03-2018>
-- Description:	<Consulta de Rubros>
-- =============================================

CREATE procedure ME_SP_ConsultaModulos
	--@Id INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdModulo, Modulo, IdModuloUrl
	FROM dbo.ME_EG_Modulos
END