USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_TA_ConsultarAsignador'
)
    DROP PROCEDURE SP_TA_ConsultarAsignador;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel Cruz
-- Create date: 22-05-17
-- Description:	Regresa la información del asignador de una tarea				
-- =============================================
-- =============================================
-- Author:		Pedro acuña
-- Create date: 30-07-18
-- Description:	en caso de que se haya dado de baja el usuario que creo la aprobacion entonces se le envia al administrador		
-- =============================================
-- =============================================
-- Author:		Abel Rivera
-- Create date: 19-12-19
-- Description:	Se modifico el select ya que la consulta era incorrecta y mostraba usuarios de diferentes proveedores	
-- =============================================
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 27-09-23
-- Description:	se agrega el usuario adinco para envio de notificaciones en adinco app
-- =============================================

CREATE PROCEDURE [dbo].[SP_TA_ConsultarAsignador]
	-- Add the parameters for the stored procedure here
	@IdOperacion INT
AS
	BEGIN
		SET NOCOUNT ON

		DECLARE @IdUsuario INT, @Nombre NVARCHAR(MAX), @Correo NVARCHAR(MAX), @IdUsuarioAdinco NVARCHAR(MAX)

		SELECT		@IdUsuario = s.IdUsuario, @Nombre = s.Nombre, @Correo = s.Correo, @IdUsuarioAdinco = ISNULL(S.IdUsuarioADINCO,0)
		FROM		TA_Operacion AS O (NOLOCK)
		INNER JOIN	S_Usuario AS S
			ON O.IdAsignador = S.IdUsuario
		WHERE
					IdOperacion = @IdOperacion
					AND S.Activo = 1

		IF ( @IdUsuario IS NULL ) -- si no esta el usuario activo tomo al primer administrador para notificarle
			BEGIN
				SELECT TOP 1
				S.IdUsuario, S.Nombre, S.Correo,ISNULL(S.IdUsuarioADINCO,0) AS IdUsuarioAdinco
				FROM dbo.TA_Operacion O (NOLOCK)
				INNER JOIN dbo.S_UsuarioProveedor UP (NOLOCK)
					ON O.IdProveedor = UP.IdProveedor
				INNER JOIN dbo.S_Usuario S (NOLOCK)
					ON UP.IdUsuario = S.IdUsuario
				WHERE 
						O.IdOperacion = @IdOperacion
						AND ( S.Activo = 1 OR S.IdTipoUsuario = 3 )

			END

		SELECT @IdUsuario  AS IdUsuario, @Nombre AS Nombre, @Correo AS Correo, @IdUsuarioAdinco AS IdUsuarioAdinco

	END
