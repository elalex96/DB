-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Validar Dominio de Corrreo
-- =============================================
CREATE PROCEDURE [dbo].[SP_FI_ValidarDominioCorreo] 
-- ============================================= 
--[SP_FI_ValidarDominioCorreo] 3,10047
-- ============================================= 
@IdContrato INT, 
@IdUsuario  INT
AS
     BEGIN
         IF EXISTS
         (
             SELECT *
             FROM dbo.AP_Usuario
             WHERE UsuarioID = @IdUsuario
                   AND Usuario LIKE '%@pemex.com%'
         )
             BEGIN
                 SELECT 'true' AS Resultado;
             END;
             ELSE
             BEGIN
                 SELECT 'false' AS Resultado;
             END;
     END;