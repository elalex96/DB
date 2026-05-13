-- =============================================
-- Author:		DANIEL
-- Create date: 08/05/2018
-- Description:ACTUALIZACIÓN DE REFERENCIAS DE S_DOCUMENTO A S_DOCUMENTO_S3
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_ConsultaDocumentosReportes] 
    -- Add the parameters for the stored procedure here
    @idProveedor INT,
    @Identificador INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    IF (@Identificador = 1)
    BEGIN
        SELECT S_TipoDocumento.NombreTipoDocumento,
               S_TipoValidacionDoc.TipoValidacion AS TipoValidacionDocumento,
               S_Documento_S3.Documento,
               S_Documento_S3.IdDocumento
        FROM dbo.S_Documento_S3
            INNER JOIN S_TipoDocumento
                ON S_Documento_S3.IdTipoDocumento = S_TipoDocumento.IdTipoDocumento
            INNER JOIN S_TipoValidacionDoc
                ON S_Documento_S3.IdTipoValidacionDocumento = S_TipoValidacionDoc.IdTipoValidacionDoc
        WHERE dbo.S_Documento_S3.IdProveedor = @idProveedor
              AND S_Documento_S3.Activo = 1
              AND S_TipoValidacionDoc.IdTipoValidacionDoc = 2;
    END;
    ELSE
    BEGIN
        DECLARE @idTipoRegimen INT;
        SET @idTipoRegimen =
        (
            SELECT IdTipoRegimen FROM S_Proveedor WHERE IdProveedor = @idProveedor
        );
        EXEC [dbo].[SP_DG_DocumentosProveedor_S3] @IdProveedor = @idProveedor,
                                               @IdTipoRegimen = @idTipoRegimen;


    END;
END;