-- =============================================
-- Author:		<Abel Rivera>
-- Create date: <11-02-18>
-- Description:	<Inserta las guias rapidas>
-- =============================================
CREATE PROCEDURE SP_GR_GuardarGuias
@NombreGuia NVARCHAR(300),
@Modulo NVARCHAR(MAX),
@plataforma NVARCHAR(MAX),
@Archivo IMAGE
--@table dbo.GuiasRapidas READONLY
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	--CREATE TABLE #tempGuias
	--(
	--    IdGuia INT IDENTITY(1,1),
	--	[NombreGuia] [NVARCHAR](300) NULL,
	--	[Modulo] [NVARCHAR](MAX) NULL,
	--	[Plataforma] [NVARCHAR](30) NULL,
	--	[Archivo] [NVARCHAR](MAX) NULL
	--)

	--INSERT INTO #tempGuias(NombreGuia,Modulo,Plataforma,Archivo) 
	--SELECT t.name,t.Modulo,t.Plataforma,t.[file]  FROM  @table t

	--INSERT INTO GuiasRapidas(NombreGuia,Modulo,Plataforma,Archivo,ArchivoEditable,Activo) 
	--SELECT tg.NombreGuia,tg.Mdulo,tg.Plataforma,tg.Archivo,NULL,1 FROM #tempGuias AS tg


	--SELECT COUNT(IdGuiaRapida) FROM GuiasRapidas

	INSERT INTO dbo.GuiasRapidas
	(
	    NombreGuia,
	    Modulo,
	    Plataforma,
	    Archivo,
		Activo
	)
	VALUES
	(   @NombreGuia, -- NombreGuia - nvarchar(max)
	    @Modulo, -- Modulo - nvarchar(max)
	    @plataforma, -- Plataforma - nvarchar(max)
	    @archivo,--@Archivo, -- Archivo - nvarchar(max)
		1
	)
	SELECT @@IDENTITY


END
