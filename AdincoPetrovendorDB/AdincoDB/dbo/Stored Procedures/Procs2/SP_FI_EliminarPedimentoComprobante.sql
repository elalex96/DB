-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-01-2020
-- Description:	Eliminar Pedimento o Comprobante
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_EliminarPedimentoComprobante] 
--[dbo].[SP_FI_EliminarPedimentoComprobante] 1185,10113,3
-- Add the parameters for the stored procedure here
@IdPedimentoCombrobante INT, 
@IdUsuario              INT, 
@IdContrato             INT
AS
     BEGIN
         SET NOCOUNT ON;
         --Eliminación en FI_PedimentoComprobanteDetalle
         DELETE dbo.FI_PedimentoComprobanteDetalle
         WHERE IdPedimentoComprobante = @IdPedimentoCombrobante;
         --Eliminación del FI_Documento
         DELETE dbo.FI_Documento
         WHERE IdPedimentoComprobante = @IdPedimentoCombrobante;
         --Eliminación en FI_PedimentoComprobante
         DELETE dbo.FI_PedimentoComprobante
         WHERE IdPedimentoComprobante = @IdPedimentoCombrobante;  
         --Verificación de error 
         IF @@ERROR <> 0
             SELECT 1 AS eliminado;
             ELSE
         SELECT 0 AS eliminado;
     END;