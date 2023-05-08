-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[SP_AgregarNuevaConfiguracionCatalogoMaestro]

@DescripcionCorta NVARCHAR(MAX) = '',
@DescripcionLarga NVARCHAR(MAX) = '',
@UMB              INT = 0,
@IdTipoMoneda     INT = 0,
@Precio           MONEY = 0,
--@ImagenMaterial   NVARCHAR(MAX) = '',
@IdSubFamilia     INT = 0,  
@IdCatalogo       INT = 0,

-----nueva configuracion------
@Grupo NVARCHAR(MAX) = '',
@CodGrupo NVARCHAR(MAX) = '',
@Familia NVARCHAR(MAX) = '',
@CodFamilia NVARCHAR(MAX) = '',
@SubFamilia NVARCHAR(MAX) = '',
@CodSubFamilia NVARCHAR(MAX) = '',
@IdProveedor   INT = 0,

@Condicion NVARCHAR(20) = ''
AS
BEGIN
DECLARE @IdGrupo      INT,
        @IdFamilia    INT,
		@IdSubFamiliaNC INT

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF (@Condicion = 'manual')
	BEGIN
	INSERT INTO PV_MM_MaterialGrupo(
	[CodGrupo],
	[Grupo],
	[IsActivo],
	[IsEliminado],
	[CreadoPor]
	)
	VALUES(
	@CodGrupo,
	@Grupo,
	1,
	0,
	@IdProveedor
	)
	SET @IdGrupo = (SELECT @@IDENTITY)

	INSERT INTO PV_MM_MaterialFamilia(
	[CodFamilia],
	[Familia],
	[IsActivo],
	[IsEliminado],
	[CreadoPor]
	)
	VALUES(
	@CodFamilia,
	@Familia,
	1,
	0,
	@IdProveedor
	)
	SET @IdFamilia = (SELECT @@IDENTITY)

    INSERT INTO PV_MM_MaterialSubFamilia(
	[CodSubFamilia],
	[SubFamilia],
	[IsActivo],
	[IsEliminado],
	[CreadoPor]
	)
	VALUES(
	@CodSubFamilia,
	@SubFamilia,
	1,
	0,
	@IdProveedor
	)

	SET @IdSubFamiliaNC = (SELECT @@IDENTITY)

	------------------------------

	INSERT INTO PV_MM_GrupoFamiliaSubFamiliaUnidadTipo(
	[IdGrupo],
	[IdFamilia],
	[IdSubFamilia],
    [IsActivo]
	)
	VALUES(
	@IdGrupo,
    @IdFamilia,
    @IdSubFamiliaNC,
	1
	)

	   UPDATE [dbo].[PV_MM_AltaCatalogoProveedorTemp] SET
       [DescripcionCorta] = @DescripcionCorta
      ,[DescripcionLarga] = @DescripcionLarga
      ,[UMB]              = @UMB
      ,[IdTipoMoneda]     = @IdTipoMoneda
      ,[Precio]           = @Precio
	  ,[IdSubFamilia]     = @IdSubFamiliaNC
	  WHERE IdAltaCatalogoProveedor = @IdCatalogo

	  SELECT 'MODIFICADO'

	END

	IF (@Condicion = 'automatico')
	BEGIN

		UPDATE [dbo].[PV_MM_AltaCatalogoProveedorTemp] SET
       [DescripcionCorta] = @DescripcionCorta
      ,[DescripcionLarga] = @DescripcionLarga
      ,[UMB]              = @UMB
      ,[IdTipoMoneda]     = @IdTipoMoneda
      ,[Precio]           = @Precio
	  ,[IdSubFamilia]     = @IdSubFamilia
	  WHERE IdAltaCatalogoProveedor = @IdCatalogo

	  SELECT 'MODIFICADO'

	END







END

