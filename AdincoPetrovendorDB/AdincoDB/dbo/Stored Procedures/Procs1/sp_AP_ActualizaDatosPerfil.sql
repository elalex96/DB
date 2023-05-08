-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ActualizaDatosPerfil] 
	-- Add the parameters for the stored procedure here
@IdUsuario  INT          = 0,
@IdContrato INT          = 0,
@Nombre     VARCHAR(MAX) = '',
@Foto       IMAGE,
@NumeroCel VARCHAR(20)
AS
         BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
             SET NOCOUNT ON;

    -- Insert statements for procedure here
             UPDATE dbo.AP_Usuario
               SET
                   Nombre = @Nombre,
                   Foto = @Foto,
				   NumeroCelular=@NumeroCel,
			    ModificadoEl = GETDATE(),
			    ModificadoPor = @IdUsuario
             WHERE UsuarioID = @IdUsuario;
             
		   IF @@ERROR <> 0
                 SELECT 0 AS Resultado,
                        CAST(@@ERROR AS NVARCHAR(8)) AS MSG;
                 ELSE
             SELECT 1 AS Resultado,
                    'Tu perfil se ha guardado exitosamente' AS MSG;
         END;

