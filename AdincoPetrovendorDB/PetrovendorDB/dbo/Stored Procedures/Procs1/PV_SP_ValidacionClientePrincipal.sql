-- =============================================
-- Author:		<Jose Roman>
-- Create date: <18-06-2018>
-- Description:	<Consulta para validacion de RFC de cliente principal>
-- =============================================

CREATE procedure PV_SP_ValidacionClientePrincipal
	@IdProveedor INT,
	@RFC VARCHAR(50),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdClientePrincipales
	FROM dbo.PV_ClientePrincipales
	WHERE IdProveedor = @IdProveedor
		AND RFC = @RFC
		AND Activo = 1
END