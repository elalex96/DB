CREATE PROCEDURE	SP_FM_Archivo
@NombreArchivo varchar(200) = '',
@Cantidad int
AS
BEGIN
	SELECT TOP 1 
	IdTipoReporte
	,NombreReporte
	FROM dbo.AA_TipoReporte 
	WHERE CountColumnas = @Cantidad
	ORDER BY IdTipoReporte DESC
END
---------------------------------------------------
/*--VIEJITO
CREATE PROCEDURE	SP_FM_Archivo
@NombreArchivo varchar(200) = '',
@Cantidad int
AS
BEGIN
	SELECT TOP 1 
	IdTipoExcelPemex
	,NombreTipo
	FROM dbo.PC_TipoExcelPemex 
	WHERE CountColumnas = @Cantidad
	ORDER BY IdTipoExcelPemex DESC
END*/


