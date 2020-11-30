-- =============================================
-- Author:		Marcos Garcia
-- Create date: 20-01-2020
-- Description:	Verifica si un Banco tiene cuenta bancaria
-- =============================================
CREATE PROCEDURE [dbo].[SP_PV_VerificarCuentaBancaria]
-- Add the parameters for the stored procedure here
@BancoId    INT, 
@IdUsuario  INT, 
@IdContrato INT
AS
     BEGIN
         SET NOCOUNT ON;
         IF EXISTS
         (
             SELECT *
             FROM dbo.PV_CuentaBancaria
             WHERE BancoID = @BancoId
         )
             SELECT 1 AS Relacion;
             ELSE
         SELECT 0 AS Relacion;
     END;