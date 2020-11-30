-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <05-11-2018 >
-- Description:	<Se agrega la fecha y el nombre de cuando y quien subio el documento>
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_AgregarDocBasesOperacion]
    @IdProveedor INT,
    @NombreDoc VARCHAR(MAX),
    @Documento NVARCHAR(MAX),
    @IdOperacion INT,
	@IdUsuario INT,
    /*NUEVOS PARAMETROS*/
    @Carpeta NVARCHAR(MAX),
    @Identificador NVARCHAR(MAX),
    @Extension NVARCHAR(MAX),
    @Mime NVARCHAR(MAX)
AS
BEGIN
    INSERT INTO dbo.TA_DocBasesOperacion
    (
        IdProveedor,
        NombreDoc,
        Documento,
        IdOperacion,
        Carpeta,
        Identificador,
        Extension,
        Mime,
        Activo,
		CreadoPor,
		CreadoEl
    )
    VALUES
    (   @IdProveedor, -- IdProveedor - int
        @NombreDoc,   -- NombreDoc - varchar(max)
        @Documento,   -- Documento - nvarchar(max)
        @IdOperacion, -- IdOperacion - int
        @Carpeta,
        @Identificador,
        @Extension,
        @Mime,
        1,
		@IdUsuario,
		GETDATE()
    );
END;
