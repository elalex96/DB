--╔══════════════════════════════════════════╗
--║Uso de SP en Sistema de ADINCO            ║
--║En PETROVENDOR se encuetra llamado        ║
--║dentro del sp SP_FI_AgregaFacturaPDFAdinco║
--╚══════════════════════════════════════════╝
-- =============================================
-- Author:		Daniel  AC
-- Create date: 26-12-2016
-- Description:	Consulta las facturas del contrato para anexar PDF Factura
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK)
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AgregaFacturaPDF]
    @IdFactura INT,
    @IdUsuario INT,
	@ComprobantePDF VARCHAR(10) = NULL,
    @IdTipoDocumento INT,	
    @ComprobantePDFByte IMAGE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    /**/
    DECLARE @ID_DOCUMENTO INT = 0;
    DECLARE @NOMBRE_EXTENSION VARCHAR(250);
    /*VALIDAR SI YA EXISTE FACTURA REEMPLAZAR SI NO AGREGAR NUEVA FACTURA*/
    SET @ID_DOCUMENTO = ISNULL(
                        (
                            SELECT ISNULL(MAX(FI_Documento.IdDocumento), 0)
                            FROM FI_Documento (NOLOCK)
                            WHERE FI_Documento.IdFactura = @IdFactura
                                  AND FI_Documento.IdTipoDocumento = @IdTipoDocumento
                                  AND ISNULL(FI_Documento.IsEliminado, 0) = 0
                        ),
                        0
                              );
    /**/
    SET @NOMBRE_EXTENSION = 'FI_' + CAST(@IdFactura AS VARCHAR(200)) + '.pdf';
    /**/
    IF (@ID_DOCUMENTO <> 0)
    BEGIN
        /*Actualizar Comprobante*/
        UPDATE FI_Documento
        SET FI_Documento.FechaCarga = GETDATE(),
            NombreExtensionArchivo = @NOMBRE_EXTENSION,
            IdUsuario = @IdUsuario,
            DocumentoByte = @ComprobantePDFByte
        WHERE IdDocumento = @ID_DOCUMENTO
              AND IdFactura = @IdFactura
              AND IdTipoDocumento = @IdTipoDocumento;
    END;
	/**/
    ELSE
    BEGIN
        /*Agregar nuevo comprobante*/
        INSERT INTO FI_Documento
        (
            IdTipoDocumento,
            NombreExtensionArchivo,
            FechaCarga,
            IdUsuario,
            IdFactura,
            DocumentoByte
        )
        VALUES
        (@IdTipoDocumento, @NOMBRE_EXTENSION, GETDATE(), @IdUsuario, @IdFactura, @ComprobantePDFByte);
    END;
    SELECT 'SUCCESS';
END;