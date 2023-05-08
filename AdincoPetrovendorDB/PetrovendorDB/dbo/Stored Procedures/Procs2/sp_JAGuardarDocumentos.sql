CREATE PROCEDURE [dbo].[sp_JAGuardarDocumentos]
(
    @Documento NVARCHAR(MAX),
    @NombreArchivo NVARCHAR(MAX),
    @Extension NVARCHAR(150),
    @IdTopic INT,
	@IdUsuarioCreador INT
)
AS
BEGIN
    INSERT INTO dbo.JA_Documento
    (
        Documento,
        NombreArchivo,
        Extension,
        IdTopic,
		CreadoPor,
		FechaCreado
    )
    VALUES
    (   @Documento,     -- Documento - nvarchar(max)
        @NombreArchivo, -- NombreArchivo - nvarchar(max)
        @Extension,     -- Extension - nvarchar(max)
        @IdTopic,        -- IdTopic - int
		@IdUsuarioCreador,
		GETDATE()
    )
END

