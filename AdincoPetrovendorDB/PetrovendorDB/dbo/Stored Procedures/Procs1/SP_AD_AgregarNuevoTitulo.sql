-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
create PROCEDURE [dbo].[SP_AD_AgregarNuevoTitulo]
@NombreTitulo NVARCHAR(max),
@NombreSubTitulo NVARCHAR(max),
@IdModulo INT,
@IdIdioma INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @IdTitulo INT 

	INSERT INTO dbo.Titulos
	(
	    NombreTitulo,
	    NombreSubtitulo,
	    FechaRegistro,
	    IsActivo,
	    ModificadoEl,
		IdIdioma
	)
	VALUES
	(   
		@NombreTitulo,     -- NombreTitulo - nvarchar(max)
	    @NombreSubTitulo,  -- NombreSubtitulo - nvarchar(max)
	    GETDATE(),         -- FechaRegistro - datetime
	    1,                 -- IsActivo - bit
	    GETDATE(),          -- ModificadoEl - datetime
		@IdIdioma
	)

	SET @IdTitulo = (@@IDENTITY) 

	INSERT INTO TituloModulo
	(
		IdTitulo,
		IdModulo,
		FechaRegistro,
		IsActivo
	)
	VALUES
	(
		@IdTitulo,
		@IdModulo,
		GETDATE(),
		1
	)

	SELECT 'SUCCESS'

END
