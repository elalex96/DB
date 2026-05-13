-- =============================================
-- Author:		<Jose Roman>
-- Create date: <18-06-2018>
-- Description:	<Validacion del rfc de los socios comerciales>
-- =============================================

CREATE procedure PV_SP_ValidacionRFCSociosComerciales
	@IdProveedor INT,
	@RFC VARchar(max),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	SELECT IdSocioComercial
	FROM dbo.PV_SocioComercial
	WHERE IdProveedor = @IdProveedor
		AND RFC = @RFC
		AND Activo = 1
END