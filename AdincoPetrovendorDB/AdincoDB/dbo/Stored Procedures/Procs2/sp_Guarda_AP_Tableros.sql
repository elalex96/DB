USE [Adinco]
GO
DROP PROCEDURE IF EXISTS sp_Guarda_AP_Tableros
/****** Object:  StoredProcedure [dbo].[sp_Guarda_AP_Tableros]    Script Date: 20/03/2025 02:01:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Reyna Olvera
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/03/2025
-- Description: Se agregan los campos de HeightPX y EsVersionCloud
-- =============================================
CREATE PROCEDURE [dbo].[sp_Guarda_AP_Tableros]
	@idContrato INT,
	@idUsuario INT,
	@IdTableroContrato	INT,
	@NombreMostrar	VARCHAR(500),
	@Workbook	VARCHAR(500),
	@Sheet	VARCHAR(500),
	@Site	VARCHAR(500),
	@Activo	BIT,
	@HeightPX	INT,
	@IdRol	INT,
	@Parametros	VARCHAR(500),
	@UserTableau VARCHAR(150),
	@MuestraToolbar BIT,
	@DNS VARCHAR(500),
	@Tabs VARCHAR(500),
	@EsVersionCloud BIT
AS
BEGIN

	SET NOCOUNT ON;


	
	IF(@IdTableroContrato	=	0)
	BEGIN
		INSERT INTO EN_TableroContrato(IdContrato, Workbook,Sheet,Tabs,Site,DNS,CreadoPor,CreadoEn,Activo,HeightPX,IdRol,NombreMostrar,Parametros,UserTableau,MuestraToolbar,EsVersionCloud )
		VALUES						  
		(	@idContrato,
			@Workbook,
			@Sheet,
			@Tabs,
			@Site,
			@DNS,
			@idUsuario,
			GETDATE(),
			1,
			@HeightPX,
			CASE
				@IdRol
			WHEN	0
				THEN	NULL
			ELSE
				@IdRol
			END,
			@NombreMostrar,
			@Parametros,
			@UserTableau,
			@MuestraToolbar,
			@EsVersionCloud);

	END
	ELSE
	BEGIN

		UPDATE
			EN_TableroContrato
			SET 
				Workbook	=	@Workbook,
				Sheet	=	@Sheet,
				Site	=	@Site,
				ModificadoPor	=	@idUsuario,
				ModificadoEn	=	GETDATE(),
				Activo	=	@Activo,
				HeightPX	=	@HeightPX,
				IdRol	=		CASE
									@IdRol
								WHEN	0
									THEN	NULL
								ELSE
									@IdRol
								END,
				NombreMostrar	=	@NombreMostrar,
				Parametros	=	@Parametros,
				UserTableau	=	@UserTableau,
				MuestraToolbar	=	@MuestraToolbar,
				DNS = @DNS,
				Tabs = @Tabs,
				EsVersionCloud = @EsVersionCloud
		WHERE
			IdTableroContrato	=	@IdTableroContrato
			AND	IdContrato	=	@idContrato
	
	END
END

