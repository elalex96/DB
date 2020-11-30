CREATE PROCEDURE AP_sp_AgregarTablero
@IdUsuario Int,
@IdContrato INT = NULL,
@Workbook VARCHAR(300) = NULL,
@Sheet VARCHAR(300) = NULL,
@Tabs VARCHAR(300) = NULL,
@Site VARCHAR(300) = NULL,
@DNS VARCHAR(300) = NULL,
@HeightPX INT = NULL,
@NombreMostrar VARCHAR(300) = NULL,
@Parametros VARCHAR(300) = NULL,
@UserTableau VARCHAR(300) = NULL,
@MuestraToolbar BIT = NULL
AS
BEGIN
	INSERT INTO AP_Tableros(IdContrato,	Workbook,		Sheet,			Tabs,
							Site,		DNS,			CreadoPor,
							CreadoEn,
							Activo,		HeightPX,		NombreMostrar,
							Parametros,	UserTableau,	MuestraToolbar) VALUES

							(@IdContrato,	 @Workbook,		@Sheet,			@Tabs,
							@Site,			 @DNS,			@IdUsuario, 
							GETDATE(),
							1,				 @HeightPX,		@NombreMostrar,
							@Parametros,	 'admin',	@MuestraToolbar)
END
