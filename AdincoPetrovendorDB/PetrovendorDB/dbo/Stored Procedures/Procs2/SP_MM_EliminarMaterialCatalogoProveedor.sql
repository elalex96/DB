-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11/01/2018>
-- Description:	<Elimina el material seleccionado por el usuario>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 12/01/2018 9:42 am
-- Description:	Agregue parametros de contrato y modificadoPor
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_EliminarMaterialCatalogoProveedor]
@IdMaterial INT,
@IdProveedor INT,
@IdContrato INT,
@IdUsuario INT,
@FechaRegistro DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.MM_Material 
	SET Activo = 0,
	IsEliminado = 1,
	ModificadoPor=@IdUsuario
	WHERE IdMaterial = @IdMaterial AND IdProveedor=@IdProveedor

	SELECT 'Material Eliminado' AS Respose

END
