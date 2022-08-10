-- =============================================
-- Author:		Manuel Cruz
-- Create date: 2018-12-12
-- Description:	
-- =============================================
-- Modificado Por:			Neri del Angel
-- Fecha de Modificación:	09 de Agosto del 2022
-- Descripción:				Se agregan NOLOCK y la llamada de columnas con nombre especifico de la tabla durante su llamado.
-- =============================================
CREATE PROCEDURE [dbo].[SP_AWS_ReemplazarCCN]
    -- SP_AWS_ReemplazarCCN 3,1,61498,0
    -- Add the parameters for the stored procedure here
    @IdContrato INT,
    @IdUsuario INT,
    @IdDoc INT,
    @IdEliminar INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
    -- Insert statements for procedure here
    DECLARE @Count INT;
    --
    SELECT @Count = COUNT(dbo.AWS_DocAwsDocAdinco.IdDocAdinco)
    FROM dbo.AWS_DocAwsDocAdinco (NOLOCK)
    WHERE dbo.AWS_DocAwsDocAdinco.IdDocAdinco = @IdDoc;
    --
    IF (@Count > 0 AND @IdEliminar = 0)
    BEGIN
        SELECT 'true' AS Existe,
               dbo.AWS_Documentos.UUIDAmazon AS UUID,
               dbo.AWS_Documentos.AWSDocumentoId AS AWSDocumentoId,
               dbo.AWS_Documentos.Folder AS Folder
        FROM dbo.AWS_DocAwsDocAdinco (NOLOCK)
            JOIN dbo.AWS_Documentos (NOLOCK)
                ON dbo.AWS_DocAwsDocAdinco.AWSDocumentoId = dbo.AWS_Documentos.AWSDocumentoId
        WHERE dbo.AWS_DocAwsDocAdinco.IdDocAdinco = @IdDoc;
    END;
    --
    IF (@Count = 0 AND @IdEliminar = 0)
    BEGIN
        SELECT 'false' AS Existe,
               '' AS UUID,
               0 AS AWSDocumentoId,
               '' AS Folder;
    END;
    --
    IF (@Count > 0 AND @IdEliminar <> 0)
    BEGIN
        /*Eliminación en Ambas Tablas*/
        DELETE dbo.AWS_DocAwsDocAdinco
        WHERE dbo.AWS_DocAwsDocAdinco.IdDocAdinco = @IdDoc;
        DELETE dbo.AWS_Documentos
        WHERE dbo.AWS_Documentos.AWSDocumentoId = @IdEliminar;
        /*Resultado*/
        SELECT 'delete' AS Existe,
               '' AS UUID,
               0 AS AWSDocumentoId,
               '' AS Folder;
    END;
END;