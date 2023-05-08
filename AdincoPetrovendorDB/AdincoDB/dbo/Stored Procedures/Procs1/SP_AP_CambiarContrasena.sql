-- =============================================
-- Author:		Manuel Cruz
-- Create date: 23-11-2018
-- Description:	
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 18-02-2020
-- Description: Agregar pass y salt en el update
-- =============================================
CREATE PROCEDURE [dbo].[SP_AP_CambiarContrasena] 
-- Add the parameters for the stored procedure here
@IdContrato  INT, 
@IdUsuario   INT, 
@Pass        VARBINARY(MAX), 
@Salt        VARBINARY(MAX), 
@PassEncript NVARCHAR(100)
AS
     BEGIN
         -- SET NOCOUNT ON added to prevent extra result sets from
         -- interfering with SELECT statements.
         SET NOCOUNT ON;

         -- Insert statements for procedure here
         --Adinco
         UPDATE Adinco.dbo.AP_Usuario
           SET 
               Pass = @Pass, 
			   Salt = @Salt,
               ModificadoPor = @IdUsuario, 
               ModificadoEl = GETDATE()
         WHERE UsuarioID = @IdUsuario;

         --Petrovendor
         UPDATE Petrovendor.dbo.S_Usuario
           SET 
               Contrasena = @PassEncript
         WHERE IdUsuarioADINCO = @IdUsuario;
     END;