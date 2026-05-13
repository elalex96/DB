-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <12/02/2018>
-- Description:	<Elimina un material del catalogo maestro>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_EliminarMaterialCatMaestro]
@IdMaterial INT,

@IdContrato INT,
@IdUsuario INT,
@FechaRegistro DATETIME
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

		UPDATE dbo.MM_Maestro SET IsActivo = 0,IsEliminado = 1,ModificadoEn = GETDATE()
		WHERE IdMaestro = @IdMaterial
		

		SELECT 'MATERIAL_ELIMINADO'

END
