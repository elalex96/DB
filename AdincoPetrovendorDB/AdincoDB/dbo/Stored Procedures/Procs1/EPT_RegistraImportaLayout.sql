
CREATE PROCEDURE [dbo].[EPT_RegistraImportaLayout]
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
