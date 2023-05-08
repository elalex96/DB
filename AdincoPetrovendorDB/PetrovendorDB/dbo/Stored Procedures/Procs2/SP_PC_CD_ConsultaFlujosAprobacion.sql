CREATE PROCEDURE [dbo].[SP_PC_CD_ConsultaFlujosAprobacion] (@idProveedor INT)
AS
BEGIN
    SELECT IdFlujoTarea,
           Nombre,
		   Descripcion
    FROM dbo.TA_FlujoTarea
    WHERE IdTipoOperacion = 16
          AND IdProveedor = @idProveedor
	AND Activo=1    
END

