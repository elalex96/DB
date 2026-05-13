-- =============================================
-- Author:      Marcos Garcia
-- Create date: 05-12-2019
-- Description: Inserta eh Historico de los cambios 
--				de Contrato de las Facturas 
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_MoverFacturaContrato]
-- [SP_FI_MoverFacturaContrato] 10002,3
@IdFactura       INT, 
@IdNuevoContrato INT, 
@IdContrato      INT, 
@IdUsuario       INT
AS
     BEGIN
         --=========================================
         DECLARE @ContratoAnt INT=
         (
             SELECT IdContrato
             FROM dbo.FI_Factura
             WHERE IdFactura = @IdFactura
         );
         --=========================================
         INSERT INTO dbo.FI_HistoricoFacturaContrato
         (IdFactura, 
          IdContratoAnterior, 
          IdContratoNuevo, 
          FechaModificacion, 
          ModificadoPor
         )
         VALUES
         (@IdFactura, 
          @ContratoAnt, 
          @IdNuevoContrato, 
          GETDATE(), 
          @IdUsuario
         );
         --=========================================
         UPDATE dbo.FI_Factura
           SET 
               IdContrato = @IdNuevoContrato
         WHERE IdFactura = @IdFactura;
         --=========================================
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;