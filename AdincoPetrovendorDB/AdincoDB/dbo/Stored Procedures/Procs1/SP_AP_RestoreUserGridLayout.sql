-- =============================================
-- Author:		Marcos Garcia
-- Create date: 30-01-2020
-- Description: Seleciona Configuracion del Grid en uso
-- =============================================
CREATE PROCEDURE [dbo].[SP_AP_RestoreUserGridLayout]
-- Add the parameters for the stored procedure here
@IdNombreGrid NVARCHAR(MAX), 
@IdContrato   INT, 
@IdUsuario    INT
AS
     BEGIN
         SET NOCOUNT ON;
         SELECT Configuracion
         FROM dbo.AP_ConfiguracionGrids
         WHERE IdUsuario = @IdUsuario
               AND IdNombreGrid = @IdNombreGrid;
     END;