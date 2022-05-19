
CREATE PROCEDURE [dbo].[EPT_RegistraImportaLayout]--10007,10,10000,'20220401',12.3333,0
	@IdContrato INT,
	@IdUsuario INT,
	@ArchivoImportado VARCHAR(150)
AS
BEGIN
    SET NOCOUNT ON;

	INSERT INTO	EPT_ImportacionLayout (ArchivoImportado,UsuarioId,ContratoId,CreadoEn)
								VALUES (@ArchivoImportado,@IdUsuario,@IdContrato,GETDATE());
	SELECT SCOPE_IDENTITY() AS ImportacionLayoutId
END;

go
END;