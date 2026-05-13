-- =============================================
-- Author:		<Jose Roman>
-- Create date: <18-06-2018>
-- Description:	<Se valida que la marca registrada no se repita>
-- =============================================

CREATE procedure PV_SP_ValidacionMarcaRegistrada
	@IdProveedor INT,
	@Marca NVARCHAR(350),
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	select IdMarca
	from dbo.PV_ProveedorRepresentaMarca
	WHERE IdProveedor = @IdProveedor
		AND NombreMarca = @Marca
		AND Activo = 1
END