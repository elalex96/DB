
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <31-07-2018>
-- Description:	<Se consultan los modulos para su modificacion>
-- =============================================

CREATE PROCEDURE AD_EI_ConsultaModulos	
	/*---------------------Parametros contrato---------------------*/
	@IdContrato INT = NULL,
	@IdUsuario INT = NULL,
	@FechaRegistro DATETIME = NULL	
	/*---------------------Parametros contrato---------------------*/
AS
BEGIN
	SELECT IdModulo,
			Modulo
	FROM dbo.EI_Modulo
END