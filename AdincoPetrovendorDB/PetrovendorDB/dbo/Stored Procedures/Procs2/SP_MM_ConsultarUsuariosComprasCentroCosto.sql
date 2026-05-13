-- =============================================
-- Author:		Daniel AC
-- Create date: 20/11/2019
-- Description:	Consultar usuarios de compras por centro de costo
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_ConsultarUsuariosComprasCentroCosto] 

@IdUsuario INT, 
@IdProveedor INT,
@IdSolicitudPedido INT 

AS
	BEGIN

		
		CREATE TABLE #CentroCosto(IdCentroCosto INT, CentroCosto NVARCHAR(MAX), IdUsuario INT, Nombre NVARCHAR(MAX), Correo NVARCHAR(MAX))

		INSERT INTO #CentroCosto
		(IdCentroCosto,CentroCosto,IdUsuario,Nombre,Correo)
		
		SELECT SPLP.IdCentroCosto, CC.CentroCosto,U.IdUsuario, U.Nombre, U.Correo
		FROM dbo.MM_SolicitudPedidoDetalle SPD
		INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP 
			ON SPLP.IdSolicitudPedidoDetalle=SPD.IdSolicitudPedidoDetalle
		INNER JOIN dbo.CC_CentroCosto CC ON CC.IdCentroCosto=SPLP.IdCentroCosto
		INNER JOIN dbo.CC_CentroCostoGrupoCompras CCG ON CCG.IdCentroCosto=CC.IdCentroCosto
		INNER JOIN dbo.S_Usuario U ON U.IdUsuario=CCG.IdUsuario
		WHERE IdSolicitudPedido=@IdSolicitudPedido
		AND U.Activo=1
		AND CCG.Activo=1
		GROUP BY SPLP.IdCentroCosto, CC.CentroCosto,U.IdUsuario, U.Nombre, U.Correo

		DECLARE @COUNTCC INT 

		SELECT @COUNTCC = COUNT(1) FROM #CentroCosto
		
		IF @COUNTCC > 0 
		BEGIN 
			
			SELECT CC.IdUsuario,
			CC.Nombre, 
			CC.Correo, 
			((SELECT STUFF (
				(	SELECT		CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), CF.CentroCosto )
					FROM	#CentroCosto AS CF	
					WHERE CF.IdUsuario=CC.IdUsuario
					ORDER BY	CF.CentroCosto
					FOR XML PATH ( '' )), 1, 1, '' ) )
			)  AS CentrosCostos,
			'Comprador' AS Tipo
			FROM  #CentroCosto CC
			GROUP BY CC.IdUsuario,CC.Nombre,CC.Correo
			

		END 
		ELSE 

		BEGIN
			-- NO HAY NINGUN COMPRADOR EL LOS CENTROS DE COSTOS RELACIONADOS AA LA REQUISCION
			-- ENTONCES ENVIAR A TODOS LOS COMPRADORES 
			INSERT INTO #CentroCosto
			(IdCentroCosto,CentroCosto,IdUsuario,Nombre,Correo)
			SELECT SPLP.IdCentroCosto, CC.CentroCosto,U.IdUsuario, U.Nombre, U.Correo
			FROM dbo.MM_SolicitudPedidoDetalle SPD
			INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP 
				ON SPLP.IdSolicitudPedidoDetalle=SPD.IdSolicitudPedidoDetalle
			INNER JOIN dbo.CC_CentroCosto CC ON CC.IdCentroCosto=SPLP.IdCentroCosto
			INNER JOIN dbo.CC_AdministradorCompras CCA ON CCA.IdProveedor=CC.IdProveedor
			INNER JOIN dbo.S_Usuario U ON U.IdUsuario=CCA.IdUsuario
			WHERE SPD.IdSolicitudPedido= @IdSolicitudPedido --16537	
			AND U.Activo=1
			AND CCA.Activo=1
			GROUP BY SPLP.IdCentroCosto, CC.CentroCosto,U.IdUsuario, U.Nombre, U.Correo

			SELECT CC.IdUsuario,
			CC.Nombre, 
			CC.Correo, 
			((SELECT STUFF (
				(	SELECT		CAST(', ' AS VARCHAR(MAX)) + CONVERT ( NVARCHAR(MAX), CF.CentroCosto )
					FROM	#CentroCosto AS CF	
					WHERE CF.IdUsuario=CC.IdUsuario
					ORDER BY	CF.CentroCosto
					FOR XML PATH ( '' )), 1, 1, '' ) )
			)  AS CentrosCostos,
			'AdminCompras' AS Tipo
			FROM  #CentroCosto CC
			GROUP BY CC.IdUsuario,Nombre,Correo


		END 
			
	END
