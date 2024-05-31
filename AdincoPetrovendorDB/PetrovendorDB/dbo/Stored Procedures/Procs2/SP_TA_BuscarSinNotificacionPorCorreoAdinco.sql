USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_BuscarSinNotificacionPorCorreoAdinco'
)
    DROP PROCEDURE SP_TA_BuscarSinNotificacionPorCorreoAdinco; 
GO
/****** Object:  StoredProcedure [dbo].[SP_TA_BuscarSinNotificacionPorCorreoAdinco]    Script Date: 29/05/2024 12:31:00 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 29/05/2024
-- Description:	Retorna un bit para saber si existe o no el usuario que no quiere ser notificado
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_BuscarSinNotificacionPorCorreoAdinco]
    @Destinatario NVARCHAR(MAX),
    @TipoCorreo INT,
    @IdContrato INT
AS
BEGIN    
   
		IF EXISTS (SELECT 1 
					FROM dbo.TA_NoNotificacion N
					JOIN S_Usuario U
					ON N.IdUsuario = U.IdUsuario
					WHERE	U.Correo = @Destinatario							
					AND N.IdCorreo = @TipoCorreo
					AND N.IsEliminado = 0)
		BEGIN
				SELECT 0
		END
		ELSE 
		BEGIN
				SELECT 1
		END

END;