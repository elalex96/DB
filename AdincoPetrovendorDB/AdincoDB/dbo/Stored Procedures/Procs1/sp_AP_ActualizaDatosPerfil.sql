USE [Adinco]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'sp_AP_ActualizaDatosPerfil'
)
    DROP PROCEDURE sp_AP_ActualizaDatosPerfil;
/****** Object:  StoredProcedure [dbo].[sp_AP_ActualizaDatosPerfil]    Script Date: 08/08/2023 05:27:56 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Miguel Gomez
-- Create date: 
-- Description:	
-- =============================================
-- =============================================
-- Author:	Daniel AC
-- Create date: 08/08/2023
-- Description:	Actualizar perfil del usuario
-- =============================================
CREATE PROCEDURE [dbo].[sp_AP_ActualizaDatosPerfil] 
	-- Add the parameters for the stored procedure here
@IdUsuario  INT          = 0,
@IdContrato INT          = 0,
@Nombre     VARCHAR(MAX) = '',
@Foto       IMAGE,
@NumeroCel VARCHAR(20),
@IdPais		INT   
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
			       ModificadoPor = @IdUsuario,
				   CodigoPais = CASE WHEN ISNULL(@IdPais,0) = 0 THEN NULL ELSE @IdPais END
             WHERE UsuarioID = @IdUsuario;
             
		   IF @@ERROR <> 0
                 SELECT 0 AS Resultado,
                        CAST(@@ERROR AS NVARCHAR(8)) AS MSG;
                 ELSE
             SELECT 1 AS Resultado,
                    'Tu perfil se ha guardado exitosamente' AS MSG;
         END;


		 