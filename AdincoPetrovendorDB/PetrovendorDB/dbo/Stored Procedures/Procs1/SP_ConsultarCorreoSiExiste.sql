USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_ConsultarCorreoSiExiste'
)
    DROP PROCEDURE SP_ConsultarCorreoSiExiste; 
GO
/****** Object:  StoredProcedure [dbo].[SP_ConsultarCorreoSiExiste]    Script Date: 25/07/2023 04:13:51 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:	Daniel AC
-- Create date: 25/07/2023
-- Description:	Obtener correo contacto del proveedor x
-- =============================================
CREATE PROCEDURE [dbo].[SP_ConsultarCorreoSiExiste]
@IdProveedor INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @EXISTE INT = (SELECT COUNT(CorreoProveedor) FROM  S_Proveedor (NOLOCK) WHERE IdProveedor = @IdProveedor)

	IF (@EXISTE > 0)
	BEGIN
	SELECT CorreoProveedor FROM  S_Proveedor  (NOLOCK) WHERE IdProveedor = @IdProveedor
	END
	ELSE
	BEGIN
	DECLARE @EXISTE_EN_USUARIOS INT = (
	                                   SELECT COUNT(U.Correo) 
									   FROM dbo.S_Proveedor P  (NOLOCK)			
									   INNER JOIN dbo.S_UsuarioProveedor UP  (NOLOCK)
									   ON P.IdProveedor = UP.IdProveedor 									   
									   INNER JOIN dbo.S_Usuario U (NOLOCK)
									   ON U.IdUsuario = UP.IdUsuario 
									   AND U.Activo = 1 --> CTE debe estar activo	
									   AND ISNULL(U.IsEliminado,0)  = 0 
									   WHERE P.IdProveedor = @IdProveedor
									   AND U.Correo NOT LIKE '%adinco.mx%') -->CTE PARA EVITAR QUE MUESTRE CORREOS DE SOPORTE ADINCO EN OPERADORAS)

    IF (@EXISTE_EN_USUARIOS > 0)
	BEGIN

		SELECT U.Correo
		FROM dbo.S_Proveedor P  (NOLOCK)
		JOIN dbo.S_UsuarioProveedor UP  (NOLOCK)
		ON P.IdProveedor = UP.IdProveedor 
		JOIN dbo.S_Usuario U  (NOLOCK)
		ON UP.IdUsuario =  U.IdUsuario 
		AND U.Activo = 1 --> CTE debe estar activo	
		AND ISNULL(U.IsEliminado,0)  = 0 
		WHERE P.IdProveedor = @IdProveedor		
		AND U.Correo NOT LIKE '%adinco.mx%' -->CTE PARA EVITAR QUE MUESTRE CORREOS DE SOPORTE ADINCO EN OPERADORAS
		GROUP BY U.Correo
		
	END
	ELSE
	BEGIN
	SELECT 'SIN_CORREO'
	END
	END
	

END

