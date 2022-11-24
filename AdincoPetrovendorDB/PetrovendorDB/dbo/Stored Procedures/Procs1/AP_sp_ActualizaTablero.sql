CREATE PROCEDURE AP_sp_ActualizaTablero
@Id int,
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
as
begin
	UPDATE AP_Tableros
	SET Workbook = @Workbook,
	Sheet = @Sheet,
	Tabs = @Tabs,
	Site = @Site,
	DNS = @DNS,
	HeightPX = @HeightPX,
	NombreMostrar = @NombreMostrar,
	Parametros = @Parametros,
	UserTableau = ISNULL(@UserTableau,'admin'),
	MuestraToolbar = @MuestraToolbar
	WHERE Id = @Id
end