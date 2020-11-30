

-- =============================================
-- Author:		Daniel  AC
-- Create date: 26-12-2016
-- Description:	Consulta las facturas del contrato para anexar PDF Factura
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AgregaFacturaPDF] 
-- Add the parameters for the stored procedure here
	 
@IdFactura       INT,
@IdUsuario       INT,
@ComprobantePDF  NVARCHAR(MAX)=null,
@IdTipoDocumento INT,
@ComprobantePDFByte image = null
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         DECLARE @ID_DOCUMENTO INT= 0;
         DECLARE @NOMBRE_EXTENSION NVARCHAR(MAX);
	
         -- VALIDAR SI YA EXISTE FACTURA REEMPLAZAR SI NO AGREGAR NUEVA FACTURA 

         SET @ID_DOCUMENTO = ISNULL((SELECT isnull(MAX(IdDocumento),0)
                                     FROM FI_Documento
                                     WHERE IdFactura = @IdFactura
                                             AND IdTipoDocumento = @IdTipoDocumento
											 AND isnull(IsEliminado,0) = 0
                                   ), 0);
         SET @NOMBRE_EXTENSION = 'FI_'+CAST(@IdFactura AS NVARCHAR(200))+'.pdf';
         IF(@ID_DOCUMENTO <> 0)
             BEGIN 
                 ---Actualizar Comprobante ---

                 UPDATE FI_Documento
                   SET
                       --Documento = @ComprobantePDF,
                       FechaCarga = GETDATE(),
                       NombreExtensionArchivo = @NOMBRE_EXTENSION,
                       IdUsuario = @IdUsuario,
					   DocumentoByte = @ComprobantePDFByte
                 WHERE IdDocumento = @ID_DOCUMENTO
                       AND IdFactura = @IdFactura
                       AND IdTipoDocumento = @IdTipoDocumento;
             END;
         ELSE
             BEGIN 
                 ---Agregar nuevo comprobante ---

                 INSERT INTO FI_Documento
                 (
				  --Documento,
                  IdTipoDocumento,
                  NombreExtensionArchivo,
                  FechaCarga,
                  IdUsuario,
                  IdFactura,
				  DocumentoByte
                 )
                 VALUES
                 (
				 --@ComprobantePDF,
                  @IdTipoDocumento,
                  @NOMBRE_EXTENSION,
                  GETDATE(),
                  @IdUsuario,
                  @IdFactura,
				  @ComprobantePDFByte
                 );
             END;
         SELECT 'SUCCESS';
     END;


