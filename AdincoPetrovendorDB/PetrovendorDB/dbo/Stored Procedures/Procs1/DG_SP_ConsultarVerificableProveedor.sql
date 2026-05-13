--**************************************************************--
-- Creado por:      <Jose Roman>									--
-- Updated date: <07/01/2018>									--
-- Description: <Se reduce la consulta para agilisarla>			--
--**************************************************************--

CREATE procedure DG_SP_ConsultarVerificableProveedor
	@IdProveedor INT,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/

AS
BEGIN
	SELECT ISNULL(Verificable, 0) FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor
END
