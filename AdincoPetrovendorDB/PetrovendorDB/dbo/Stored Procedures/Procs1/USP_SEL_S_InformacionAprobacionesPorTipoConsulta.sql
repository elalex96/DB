USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_S_InformacionAprobacionesPorTipoConsulta'
)
 DROP PROCEDURE USP_SEL_S_InformacionAprobacionesPorTipoConsulta;
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 07-05-2025  
-- Description: Consultar información de empresa/aprobadores que tiene el tipo de consulta 
-- =============================================  
CREATE PROCEDURE [dbo].[USP_SEL_S_InformacionAprobacionesPorTipoConsulta] 
	@ProveedorId INT,
	@TipoConsulta NVARCHAR(MAX),
	@Rol NVARCHAR(MAX)  = ''
AS
BEGIN
		
		IF @TipoConsulta='PROVEEDORES_CON_SOLICITUD_PEDIDO'
		BEGIN
			SELECT 
			P.IdProveedor,
			P.RazonSocial AS Proveedor 			
			FROM TA_Operacion AS O  (NOLOCK)
			JOIN S_Proveedor AS P  (NOLOCK)
				ON O.IdProveedor = P.IdProveedor  
			WHERE O.IdTipoOperacion = 2  --> CTE SOLICITUDES DE PEDIDO
			GROUP BY P.RazonSocial,  
			P.IdProveedor
			ORDER BY P.RazonSocial ASC  
		END 

		IF @TipoConsulta='USUARIOS_CON_APROBACIONES_SOLICITUD_PEDIDO'
		BEGIN
			SELECT  
			U.IdUsuario,
			U.Nombre +'/'+ISNULL(TU.NombreTipoUsuario,'-') AS Nombre
			FROM TA_Operacion O	 (NOLOCK)
			JOIN TA_Tarea T (NOLOCK)
				ON O.IdOperacion = T.IdOperacion
				AND O.IdTipoOperacion = 2 --> CTE APROBACIÓN DE SOLPED
			JOIN S_Usuario U (NOLOCK)
				ON T.IdAprobador = U.IdUsuario
			LEFT JOIN S_TipoUsuario AS TU  (NOLOCK)
				ON TU.IdTipoUsuario=U.IdTipoUsuario
			WHERE 
				O.IdProveedor = @ProveedorId 
			GROUP BY U.Nombre,
			TU.NombreTipoUsuario,
		    U.IdUsuario 
			ORDER BY U.Nombre ASC
		END 

		IF @TipoConsulta='USUARIO_POR_ROL_APROBADOR'
		BEGIN
			SELECT  
			U.IdUsuario,
			U.Nombre +'/'+TU.NombreTipoUsuario AS Nombre
			FROM dbo.S_Usuario U  (NOLOCK)
			INNER JOIN S_TipoUsuario AS TU  (NOLOCK)
				ON TU.IdTipoUsuario=U.IdTipoUsuario
			INNER JOIN dbo.S_UsuarioRol UR  (NOLOCK)
				ON UR.IdUsuario = U.IdUsuario
			INNER JOIN dbo.S_Rol R  (NOLOCK)
				ON R.IdRol = UR.IdRol
			INNER JOIN dbo.S_UsuarioProveedor UP (NOLOCK)
				ON UP.IdUsuario = U.IdUsuario
			INNER JOIN dbo.S_Proveedor P  (NOLOCK)
				ON P.IdProveedor = UP.IdProveedor
			INNER JOIN dbo.TA_TipoOperacion TIOP  (NOLOCK)
				ON TIOP.IdRol = R.IdRol
			WHERE 
				U.Activo=1 
				AND P.IdProveedor = @ProveedorId 
				AND UR.Activo= 1 
				AND UPPER(R.Rol) = UPPER(@Rol) 
			GROUP BY U.Nombre,
			TU.NombreTipoUsuario,
					 U.IdUsuario
			ORDER BY U.Nombre ASC

		END 
END

  