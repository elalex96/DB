CREATE PROCEDURE AP_sp_TodosLosTableros
@IdContrato INT
as
begin
	SELECT	Id,IdContrato,	Workbook,		Sheet,			Tabs,
							Site,		DNS,			CreadoPor,
							CreadoEn,
							Activo,		HeightPX,		IdRol,			NombreMostrar,
							Parametros,	UserTableau,	MuestraToolbar
	   FROM AP_Tableros
	   WHERE IdContrato = @IdContrato
end