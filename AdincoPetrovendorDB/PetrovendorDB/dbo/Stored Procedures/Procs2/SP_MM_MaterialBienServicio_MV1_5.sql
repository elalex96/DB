-- =============================================
-- Author:		Alexander Gomez
-- Create date: 04/07/2017
-- Description:	Metodo que obtiene los nombres de un grupo, familia, tipo, unidad y subfamilia de un material
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_MaterialBienServicio_MV1_5]
	-- Add the parameters for the stored procedure here
	@IdBienServicio INT,

   /*--------------------
	 parametros contrato 
   --------------------*/
	@IdContrato    INT,
	@IdUsuario     INT,
	@FechaRegistro DATETIME = NULL 
   /*--------------------
   --------------------*/
	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @TIPO NVARCHAR(20)

	CREATE TABLE #MM_MaestroTemp(IdMaestro INT , TextoCorto nvarchar(max),IdTipoCatalogoMaestro INT )

	IF (@IdBienServicio = 1)
		SET @TIPO = 'material --'
	IF (@IdBienServicio = 2)
		SET @TIPO = 'servicio --'

	INSERT INTO #MM_MaestroTemp
	(
	    IdMaestro,
	    TextoCorto,
		IdTipoCatalogoMaestro
	)
	VALUES
	(   0,  -- IdMaestro - int
	    '-- Seleccione un ' + @TIPO, -- TextoCorto - nvarchar(max)
		0
	)

	INSERT INTO #MM_MaestroTemp SELECT
	IdMaestro,TextoCorto,IdTipoCatalogoMaestro
	FROM dbo.MM_Maestro 
	WHERE
	IsActivo = 1 AND IsEliminado = 0 

	SELECT IdMaestro,TextoCorto AS TextoLargo
	FROM #MM_MaestroTemp
	WHERE IdTipoCatalogoMaestro IN (0,@IdBienServicio)
	ORDER BY  IdMaestro ASC 

END

