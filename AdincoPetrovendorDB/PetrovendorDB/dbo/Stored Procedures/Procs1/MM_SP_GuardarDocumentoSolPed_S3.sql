-- =============================================
-- Author:		DANIEL AC
-- Create date: 07/04/2018
-- Description:	Se guarda documento para una SolPed
-- =============================================
-- Author:		<Pedro Acuña>
-- Update date: <11-09-2018>
-- Description:	<se agrega el bit de activo o inactivo>
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <05-11-2018>
-- Description:	<Se agrega el guardado del usuario que carga el documento y la fecha de carga>
-- =============================================
CREATE PROCEDURE MM_SP_GuardarDocumentoSolPed_S3
    @IdSolPed INT,
    @Documento NVARCHAR(MAX),
    @Nombre VARCHAR(100),
    @IdContrato INT = NULL,
    @IdUsuario INT = NULL,
    @FechaRegistro DATETIME = NULL,
    /*NUEVOS PARAMETROS */
    @Mime NVARCHAR(MAX),
    @Carpeta NVARCHAR(MAX),
    @Extension NVARCHAR(MAX),
    @IdentificadorS3 NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO dbo.MM_DocumentosSolPed
    (
        IdSolPed,
        Documento,
        NombreDoc,
        Mime,
        Identificador,
        Carpeta,
        Extension,
        Activo,
		CreadoPor,
		CreadoEl
    )
    VALUES
    (   @IdSolPed,        -- IdSolPed - int
        @Documento,       -- Documento - nvarchar(max)
        @Nombre,          -- NombreDoc - varchar(100)
        @Mime,            -- Mime - nvarchar(300)
        @IdentificadorS3, -- Identificador - nvarchar(300)
        @Carpeta,         -- Carpeta - nvarchar(300)
        @Extension,       -- Extension - nvarchar(300)
        1,
		@IdUsuario,
		GETDATE()
    );
END;
