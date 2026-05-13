USE [Petrovendor]
GO
IF EXISTS
(
	SELECT 1
	FROM dbo.sysobjects
	WHERE name = 'SP_AD_AgregarNuevoTitulo'
)
	DROP PROCEDURE SP_AD_AgregarNuevoTitulo;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Modified date: 05/05/2026
-- Description:	Inserta un nuevo titulo y registra auditoria de creacion en la entidad Titulos.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AD_AgregarNuevoTitulo]
@NombreTitulo NVARCHAR(max),
@NombreSubTitulo NVARCHAR(max),
@IdModulo INT,
@IdIdioma INT,
@IdUsuario INT
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
	    CreadoPor,
	    IsActivo,
		IdIdioma
	)
	VALUES
	(   
		@NombreTitulo,     -- NombreTitulo - nvarchar(max)
	    @NombreSubTitulo,  -- NombreSubtitulo - nvarchar(max)
	    GETDATE(),         -- FechaRegistro - datetime
		@IdUsuario,
	    1,                 -- IsActivo - bit
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
