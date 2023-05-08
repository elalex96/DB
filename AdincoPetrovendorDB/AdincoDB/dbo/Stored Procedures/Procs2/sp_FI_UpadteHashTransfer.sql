CREATE PROCEDURE [dbo].[sp_FI_UpadteHashTransfer]
-- Add the parameters for the stored procedure here
@Hash256    NVARCHAR(MAX), 
@IdOper     NVARCHAR(MAX), 
@IdContrato INT, 
@IdUsuario  INT, 
@archivo    IMAGE         = NULL, 
@idtipo     INT           = 7
AS
     BEGIN
         SET NOCOUNT ON;
         IF(@idtipo = 7)
             BEGIN
                 UPDATE FI_Transfer
                   SET 
                       HashSHA256 = @Hash256, 
                       ModificadoPor = @IdUsuario, 
                       ModificadoEn = GETDATE()
                 WHERE IdTransferencia = CAST(@IdOper AS INT)
                       AND IdContrato = @IdContrato;
             END;

         /**/

         IF(@idtipo IN(4, 5)
            AND @archivo IS NOT NULL)
             BEGIN
                 DECLARE @IdPedCom INT;
                 SELECT @IdPedCom = IdPedimentoComprobante
                 FROM dbo.FI_PedimentoComprobante
                 WHERE AcuseElectronico LIKE CONCAT('%', LTRIM(RTRIM(@IdOper)), '%');
                 IF NOT EXISTS
                 (
                     SELECT *
                     FROM dbo.FI_Documento
                     WHERE IdPedimentoComprobante = @IdPedCom
                           AND IdTipoDocumento = @idtipo
                 )
                     BEGIN
                         INSERT INTO dbo.FI_Documento
                         (IdTipoDocumento, 
                          IdPedimentoComprobante, 
                          NombreExtensionArchivo, 
                          IdUsuario, 
                          FechaCarga, 
                          IsEliminado, 
                          DocumentoByte
                         )
                         VALUES
                         (@idtipo, -- IdTipoDocumento - int
                          @IdPedCom, -- IdPedimentoComprobante - int
                          'PE_'+@IdOper+'.pdf', -- NombreExtensionArchivo - nvarchar(150)
                          @IdUsuario, -- IdUsuario - int
                          GETDATE(), -- FechaCarga - datetime
                          0, -- IsEliminado - bit
                          @archivo       -- DocumentoByte - image
                         );
                     END;
                     ELSE
                     BEGIN
                         UPDATE dbo.FI_Documento
                           SET 
                               DocumentoByte = @archivo, 
                               FechaCarga = GETDATE(), 
                               IdUsuario = @IdUsuario, 
                               NombreExtensionArchivo = 'PE_'+@IdOper+'.pdf'
                         WHERE IdPedimentoComprobante = @IdPedCom;
                     END;
                 UPDATE dbo.FI_PedimentoComprobante
                   SET 
                       HashSHA256 = @Hash256
                 WHERE IdPedimentoComprobante = @IdPedCom
                       AND IdContrato = @IdContrato;
             END; 
         --Devuelve error o no
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;