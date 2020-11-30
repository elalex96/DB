-- =============================================
-- Author:		Miguel Gomez
-- Create date: 13-05-2020
-- Description:	Guarda Log de acceso a pantalla
-- =============================================
CREATE PROCEDURE [dbo].[sp_InsLogPantalla] 
-- Add the parameters for the stored procedure here
@NombrePantalla NVARCHAR(MAX) = '', 
@IdUsuario      INT, 
@IdContrato     INT
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;

     --    Insert statements for procedure here
        INSERT INTO [dbo].[AP_LogPantalla]
           ([NombrePantalla]
           ,[IdUsuario]
           ,[IdContrato]
           ,[Fecha]
           ,[CreadoPor]
           ,[CreadoEl]
           ,[ModificadoPor]
           ,[ModificadoEl]
           ,[Activo])
     VALUES
           (@NombrePantalla
           ,@IdUsuario
           ,@IdContrato
           ,GETDATE()
           ,@IdUsuario
           ,GETDATE()
           ,@IdUsuario
           ,GETDATE()
           ,1)
    END;
