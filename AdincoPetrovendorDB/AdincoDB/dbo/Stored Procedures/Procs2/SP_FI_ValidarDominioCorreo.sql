-- =============================================
-- Author:		Marcos Garcia
-- Create date: 26-05-2020
-- Description:	Validar Dominio de Corrreo
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Agregado de (NOLOCK)
-- ============================================= 
--[SP_FI_ValidarDominioCorreo] 3,10047
-- ============================================= 
CREATE PROCEDURE [dbo].[SP_FI_ValidarDominioCorreo]
    @IdContrato INT,
    @IdUsuario INT
AS
BEGIN
    IF EXISTS
    (
        SELECT AP_Usuario.UsuarioID
        FROM AP_Usuario (NOLOCK)
        WHERE AP_Usuario.UsuarioID = @IdUsuario
              AND AP_Usuario.Usuario LIKE '%@pemex.com%'
    )
    BEGIN
        SELECT 'true' AS Resultado;
    END;
    /**/
    ELSE
    BEGIN
        SELECT 'false' AS Resultado;
    END;
END;