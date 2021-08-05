USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_MM_AgregarDocFianzaOperacion
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- Author:		<Jose Roman>
-- Update date: <05-11-2018 >
-- Description:	<Se agrega la fecha y el nombre de cuando y quien subio el documento>
-- =============================================
-- Author:		LUIS DAVID DE LA CRUZ
-- Update date: 02/08/2021
-- Description:	SE AGREGA LA COLUMNA BUCKET
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_AgregarDocFianzaOperacion]
    @IdProveedor INT,
    @NombreDoc VARCHAR(MAX),
    @Documento NVARCHAR(MAX),
    @IdOperacion INT,
	@IdUsuario INT,
    /*NUEVOS PARAMETROS*/
    @Carpeta NVARCHAR(MAX),
    @Identificador NVARCHAR(MAX),
    @Extension NVARCHAR(MAX),
    @Mime NVARCHAR(MAX),
	@Bucket VARCHAR(200) = NULL
AS
BEGIN
    INSERT INTO dbo.TA_DocFianzaOperacion
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
		CreadoEl,
		Bucket
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
		GETDATE(),
		@Bucket
    );
END;
