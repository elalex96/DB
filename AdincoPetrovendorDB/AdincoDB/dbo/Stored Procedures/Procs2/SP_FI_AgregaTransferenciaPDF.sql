-- =============================================
-- Author:		JG
-- Create date: 26-12-2016
-- Description:	Agrega comprobante de transferencia
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_AgregaTransferenciaPDF] 
-- Add the parameters for the stored procedure here

@IdTransferencia INT,
--@IdUsuario       INT,
@ComprobantePDF  NVARCHAR(MAX)
--@IdTipoDocumento INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         -- DECLARE @PDF INT= 0;
         --DECLARE @NOMBRE_EXTENSION NVARCHAR(MAX);
         -- VALIDAR SI YA EXISTE FACTURA REEMPLAZAR SI NO AGREGAR NUEVA FACTURA 
         -- SET @PDF = ISNULL((SELECT PDF
         --                             FROM FI_Transfer
         --                             WHERE IdTransferencia = @IdTransferencia
         --                           ), 0);
         --SET @NOMBRE_EXTENSION = 'Transferencia_'+CAST(@IdFactura AS NVARCHAR(200))+'.pdf';
         -- IF(@PDF <> 0)
         BEGIN 
             ---Actualizar Comprobante ---

             UPDATE FI_Transfer
               SET 
                   PDF = @ComprobantePDF
             -- FechaCarga = GETDATE(),
             --NombreExtensionArchivo = @NOMBRE_EXTENSION,
             --IdUsuario = @IdUsuario
             WHERE IdTransferencia = @IdTransferencia;
             --AND IdFactura = @IdFactura
             --AND IdTipoDocumento = @IdTipoDocumento;
         END;
         -- ELSE
         --    BEGIN 
         ---Agregar nuevo comprobante ---
         --      INSERT INTO FI_Transfer
         --      (PDF
         --      )
         --      VALUES
         --      (@ComprobantePDF
         --      );
         --  END;
         SELECT 'SUCCESS';
     END;