-- =============================================
-- Author:		<Jose Roman>
-- Create date: <18-06-2018>
-- Description:	<Validacion del rfc al realizar un nuevo registros>
-- =============================================

CREATE PROCEDURE PV_SP_ValidarRFCDistribuidorAutorizado
	@IdProveedor INT,
	@RFC NVARCHAR(50),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdDistribuidorAutorizado
	FROM dbo.PV_DistribuidorAutorizado
	WHERE IdProveedor = @IdProveedor
		AND RFC = @RFC
		AND Activo = 1
END