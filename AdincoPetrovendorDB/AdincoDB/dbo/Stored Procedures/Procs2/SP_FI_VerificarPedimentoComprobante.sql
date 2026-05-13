-- =============================================
-- Author:		Marcos Garcia
-- Create date: 15-01-2020
-- Description:	Verifica si un Pedimento O Comprobante esta ligado a un Gasto
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_VerificarPedimentoComprobante] 
-- [SP_FI_VerificarPedimentoComprobante] 1165,10113,3
-- Add the parameters for the stored procedure here
@IdPedimentoComprobante INT, 
@IdUsuario              INT, 
@IdContrato             INT
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;
         IF EXISTS
         (
             SELECT *
             FROM dbo.FI_TransferFactura
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante
         )
            OR EXISTS
         (
             SELECT *
             FROM dbo.CO_Registro
             WHERE IdPedimentoComprobante = @IdPedimentoComprobante
         )
             SELECT 1 AS Relacion;
             ELSE
         SELECT 0 AS Relacion;
     END;