-- =============================================
-- Author:		Marcos Garcia
-- Create date: 20-01-2020
-- Description: Update PV_Banco
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_UpdateBanco] 
-- Add the parameters for the stored procedure here
@Banco       NVARCHAR(MAX), 
@Clave       VARCHAR(10), 
@RazonSocial NVARCHAR(MAX), 
@Nacional    BIT, 
@BancoId     INT, 
@IdContrato  INT, 
@IdUsuario   INT
AS
     BEGIN
         SET NOCOUNT ON;
         BEGIN
             UPDATE dbo.PV_Banco
               SET 
                   Banco = @Banco, 
                   Clave = @Clave, 
                   RazonSocial = @RazonSocial, 
                   Nacional = @Nacional,
				   ModificadoPor = @IdUsuario,
				   ModificadoEn = GETDATE()				   
             WHERE BancoID = @BancoId;
         END;
         IF @@ERROR <> 0
             SELECT 'false' AS msj;
             ELSE
         SELECT 'true' AS msj;
     END;