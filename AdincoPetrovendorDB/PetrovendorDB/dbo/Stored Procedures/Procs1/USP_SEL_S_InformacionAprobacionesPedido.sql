USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'USP_SEL_S_InformacionAprobacionesPedido'
)
 DROP PROCEDURE USP_SEL_S_InformacionAprobacionesPedido;
GO
SET ANSI_NULLS ON
GO
-- =============================================  
-- Author: Daniel AC  
-- Create date: 07-05-2025  
-- Description: Consultar información de empresa/aprobadores de pedido
-- =============================================  
CREATE PROCEDURE [dbo].[USP_SEL_S_InformacionAprobacionesPedido] 
	@ProveedorId INT,
	@TipoConsulta NVARCHAR(MAX)
AS
BEGIN
		
		IF @TipoConsulta='PROVEEDORES_CON_PEDIDO'
		BEGIN
			SELECT 
			P.IdProveedor,
			P.RazonSocial AS Proveedor 			
			FROM TA_Operacion AS O  (NOLOCK)
			JOIN S_Proveedor AS P  (NOLOCK)
				ON O.IdProveedor = P.IdProveedor  
			WHERE O.IdTipoOperacion = 9  --> CTE APROBACIONES DE PEDIDO
			GROUP BY 
			P.RazonSocial,  
			P.IdProveedor
			ORDER BY P.RazonSocial ASC  
		END 

		IF @TipoConsulta='USUARIOS_CON_APROBACIONES_PEDIDO'
		BEGIN
			SELECT  
			U.IdUsuario,
			U.Nombre +'/'+ISNULL(TU.NombreTipoUsuario,'-') AS Nombre
			FROM TA_Operacion O	 (NOLOCK)
			JOIN TA_Tarea T (NOLOCK)
				ON O.IdOperacion = T.IdOperacion
				AND O.IdTipoOperacion = 9 --> CTE APROBACIÓN DE PEDIDO
			JOIN S_Usuario U (NOLOCK)
				ON T.IdAprobador = U.IdUsuario
			LEFT JOIN S_TipoUsuario AS TU  (NOLOCK)
				ON U.IdTipoUsuario = TU.IdTipoUsuario
			WHERE 
				O.IdProveedor = @ProveedorId 
			GROUP BY U.Nombre,
			TU.NombreTipoUsuario,
		    U.IdUsuario 
			ORDER BY U.Nombre ASC
		END 

		IF @TipoConsulta='USUARIO_APROBADORES_PEDIDO'
		BEGIN

			SELECT  
			U.IdUsuario,
			U.Nombre +'/'+TU.NombreTipoUsuario AS Nombre
			FROM dbo.S_Usuario U  (NOLOCK)
			JOIN S_TipoUsuario AS TU  (NOLOCK)
				ON U.IdTipoUsuario = TU.IdTipoUsuario
			JOIN dbo.S_UsuarioRol UR  (NOLOCK)
				ON U.IdUsuario = UR.IdUsuario
			JOIN dbo.S_Rol R  (NOLOCK)
				ON UR.IdRol = R.IdRol
			JOIN dbo.S_UsuarioProveedor UP (NOLOCK)
				ON U.IdUsuario = UP.IdUsuario 
			JOIN dbo.S_Proveedor P  (NOLOCK)
				ON UP.IdProveedor = P.IdProveedor 
			JOIN dbo.TA_TipoOperacion TIOP  (NOLOCK)
				ON  R.IdRol = TIOP.IdRol
			WHERE 
				U.Activo=1 
				AND P.IdProveedor = @ProveedorId 
				AND UR.Activo= 1 
				AND UPPER(R.Rol) = UPPER('Aprobador Pedido') 
			GROUP BY U.Nombre,
			TU.NombreTipoUsuario,
					 U.IdUsuario
			ORDER BY U.Nombre ASC

		END 
END

  