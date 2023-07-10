-- =============================================
-- Author:		Reyna Olvera
-- Create date: 
-- Description:
-- =============================================
CREATE PROCEDURE [dbo].[sp_Guarda_AP_Tableros]--3,10061
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
	@MuestraToolbar BIT
AS
BEGIN

	SET NOCOUNT ON;


	
	IF(@IdTableroContrato	=	0)
	BEGIN
		INSERT INTO EN_TableroContrato(IdContrato, Workbook,Sheet,Tabs,Site,DNS,CreadoPor,CreadoEn,Activo,HeightPX,IdRol,NombreMostrar,Parametros,UserTableau,MuestraToolbar )
		VALUES						  
		(	@idContrato,
			@Workbook,
			@Sheet,
			'no',
			@Site,
			'https://adincobi.mx/trusted/',
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
			@MuestraToolbar );

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
				MuestraToolbar	=	@MuestraToolbar
		WHERE
			IdTableroContrato	=	@IdTableroContrato
			AND	IdContrato	=	@idContrato
	
	END
END

