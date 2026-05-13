
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <22-03-2018>
-- Description:	<Consulta para validar si el RFC existe>
-- =============================================

CREATE procedure S_SP_ValidarRFC
	@RFC varchar(50),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT COUNT(RFC) FROM dbo.S_Proveedor WHERE RFC = @RFC
END