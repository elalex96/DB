-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-10-2018>
-- Description:	<store para agregar nuevas paginas en la seguridad, titulos, subtitulos>
-- =============================================

CREATE PROCEDURE Sp_SeguridadAgregarNuevaPagina @NombreModulo NVARCHAR(150), @StringIdOcultarVentana NVARCHAR(150) ,
												@Url NVARCHAR(150), @Titulo NVARCHAR(150), @Subtitulo NVARCHAR(150) ,
												@Aplicacion INT
AS
	BEGIN
		DECLARE @IdTitulo INT, @IdModulo INT

		IF NOT EXISTS ( SELECT 1  FROM dbo .Modulo WHERE URL_MODULO LIKE @Url AND Aplicacion   = @Aplicacion )
			BEGIN
				INSERT INTO dbo.Titulos
					( NombreTitulo, NombreSubtitulo, FechaRegistro, IsActivo, ModificadoEl, IdIdioma )
				VALUES
					( @Titulo ,		-- NombreTitulo - nvarchar(max)
					  @Subtitulo ,	-- NombreSubtitulo - nvarchar(max)
					  GETDATE () ,	-- FechaRegistro - datetime
					  1 ,			-- IsActivo - bit
					  NULL ,		-- ModificadoEl - datetime
					  1				-- IdIdioma - int
					)

				SELECT @IdTitulo  = @@IDENTITY

				INSERT INTO dbo.Modulo
					( NombreModulo, StringModuloId, CreadoPor, CreadoEl, ModificadoPor, ModificadoEl, URL_MODULO ,
					  IsEliminado , Aplicacion )
				VALUES
					( @NombreModulo ,			-- NombreModulo - nvarchar(200)
					  @StringIdOcultarVentana , -- StringModuloId - nvarchar(200)
					  0 ,						-- CreadoPor - int
					  GETDATE () ,				-- CreadoEl - datetime
					  NULL ,					-- ModificadoPor - int
					  NULL ,					-- ModificadoEl - datetime
					  @Url ,					-- URL_MODULO - nvarchar(350)
					  0 ,						-- IsEliminado - bit
					  @Aplicacion				-- Aplicacion - int
					)

				SELECT @IdModulo  = @@IDENTITY

				INSERT INTO dbo.TituloModulo
					( IdTitulo, IdModulo, FechaRegistro, IsActivo )
				VALUES
					( @IdTitulo ,	-- IdTitulo - int
					  @IdModulo ,	-- IdModulo - int
					  GETDATE () ,	-- FechaRegistro - datetime
					  1				-- IsActivo - bit
					)
					
			END
		ELSE SELECT 'Ya existe esta Url, REGISTRO NO guardado'
	END