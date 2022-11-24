CREATE PROC EN_sp_GuardaBitacoraReporteSASISOPA
@IdUsuario int,
@IdContrato int,
@FechaInicial datetime,
@FechaFinal datetime,
@Server varchar(300)
AS
BEGIN 
	INSERT INTO EN_Documentos_BitacoraReporteSASISOPA(
	IdUsuario,		IdContrato,		FechaInicial,
	FechaFinal,		FechaCreacion,	Procesado,
	Server) VALUES
	(@IdUsuario,	@IdContrato,	@FechaInicial,
	@FechaFinal,	GETDATE(),		0,
	@Server
	)
END