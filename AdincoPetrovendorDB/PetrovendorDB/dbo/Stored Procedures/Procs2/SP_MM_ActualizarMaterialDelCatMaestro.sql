-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ActualizarMaterialDelCatMaestro]
@IdMaestro INT,
@TextoCorto NVARCHAR(MAX),
@TextoLargo NVARCHAR(MAX),
@IdTipoMaterial INT,
@IdUnidad INT,

@IdContrato INT,
@IdUsuario INT,
@FechaRegistro DATETIME 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	UPDATE dbo.MM_Maestro
	SET
	TextoCorto = @TextoCorto,
	TextoLargo = @TextoLargo,
	IdTipoMaterial = @IdTipoMaterial
	WHERE IdMaestro = @IdMaestro

	DECLARE @IdGFSUT INT = (
								SELECT GFSUT.IdGrupoFamiliaSubfamiliaUnidadTipo 
								FROM dbo.MM_Maestro M
								INNER JOIN dbo.PV_MM_GrupoFamiliaSubFamiliaUnidadTipo GFSUT
								ON GFSUT.IdSubFamilia = M.IdSubFamilia
								WHERE M.IdMaestro = @IdMaestro
							)

	UPDATE dbo.PV_MM_GrupoFamiliaSubFamiliaUnidadTipo
	SET
	IdUnidad = @IdUnidad
	WHERE IdGrupoFamiliaSubfamiliaUnidadTipo = @IdGFSUT

	SELECT 'MATERIAL ACTUALIZADO'


END
