-- =============================================
-- Author:		Marcos Garcia
-- Create date: 30-01-2020
-- Description:	Guarda o Actualiza la configuracion del usuario del grid
-- =============================================
CREATE PROCEDURE [dbo].[SP_AP_SaveUserGridLayout]
-- Add the parameters for the stored procedure here
@IdNombreGrid  NVARCHAR(MAX), 
@Configuracion NVARCHAR(MAX), 
@IdContrato    INT, 
@IdUsuario     INT
AS
     BEGIN
         SET NOCOUNT ON;
         IF EXISTS
         (
             SELECT *
             FROM dbo.AP_ConfiguracionGrids
             WHERE IdUsuario = @IdUsuario
                   AND IdNombreGrid = @IdNombreGrid
         )
             BEGIN
                 UPDATE dbo.AP_ConfiguracionGrids
                   SET 
                       Configuracion = @Configuracion
                 WHERE IdUsuario = @IdUsuario
                       AND IdNombreGrid = @IdNombreGrid;
             END;
             ELSE
             BEGIN
                 INSERT INTO dbo.AP_ConfiguracionGrids
                 (IdUsuario, 
                  IdNombreGrid, 
                  Configuracion, 
                  CreadoEn
                 )
                 VALUES
                 (@IdUsuario, 
                  @IdNombreGrid, 
                  @Configuracion, 
                  GETDATE()
                 );
             END;
     END;