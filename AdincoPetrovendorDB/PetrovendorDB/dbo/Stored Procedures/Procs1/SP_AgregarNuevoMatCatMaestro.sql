-- =============================================
-- Author:		<ABEL RIVERA>
-- Create date: <02/01/18>
-- Description:	<Agrega un nuevo material al catalogo maestro>
-- =============================================
CREATE PROCEDURE SP_AgregarNuevoMatCatMaestro
@IdTipoCatalogoMaestro INT,
@IdSubFamilia          INT,
@DescripcionCorta      NVARCHAR(MAX),
@DescripcionLarga	   NVARCHAR(MAX),
@IdTipoMaterial		   INT

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	INSERT INTO dbo.MM_Maestro
	(
	    IdTipoCatalogoMaestro,
	    IdSubFamilia,
	    TextoCorto,
	    TextoLargo,
	    IdTipoMaterial,
	    IsActivo,
	    IsEliminado,
	    CreadoPor,
	    CreadoEn
	)
	VALUES
	(   
	    @IdTipoCatalogoMaestro, -- IdTipoCatalogoMaestro - int
	    @IdSubFamilia,          -- IdSubFamilia - int
	    @DescripcionCorta,      -- TextoCorto - nvarchar(max)
	    @DescripcionLarga,      -- TextoLargo - nvarchar(max)
	    @IdTipoMaterial	,       -- IdTipoMaterial - int
	    1,                      -- IsActivo - bit
	    0,                      -- IsEliminado - bit
	    0,                      -- CreadoPor - int
	    GETDATE()               -- CreadoEn - datetime
	 )

	 SELECT @@IDENTITY


END
