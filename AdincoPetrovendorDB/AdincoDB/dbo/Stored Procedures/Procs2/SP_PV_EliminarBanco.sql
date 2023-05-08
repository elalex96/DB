-- =============================================
-- Author:		Marcos Garcia
-- Create date: 20-01-2020
-- Description:	Elimina dato de PV_Banco
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_EliminarBanco] 
-- Add the parameters for the stored procedure here
@BancoId    INT, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         SET NOCOUNT ON;
         BEGIN
             DELETE dbo.PV_Banco
             WHERE BancoID = @BancoId;
         END;
         IF @@ERROR <> 0
             SELECT 1 AS msj;
             ELSE
         SELECT 0 AS msj;
     END;