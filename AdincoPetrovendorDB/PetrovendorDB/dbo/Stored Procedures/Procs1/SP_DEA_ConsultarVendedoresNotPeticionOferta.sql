--**************************************************************  
-- Modified:    Daniel AC     
-- Updated date: 21/11/2019       
-- Description: Se agrego validación para agregar asignación de compradores en la requisición por centro de costo --actualización de compradores 
--************************************************************** 
-- =============================================
CREATE PROCEDURE SP_DEA_ConsultarVendedoresNotPeticionOferta
	-- Add the parameters for the stored procedure here
	@IdProveedor int, 
	@IdUsuario INT,
	@IdOperacion INT,
	@IdRequisicionPR INT,
	@IdSolicitudPedido INT 
AS
BEGIN
	

		---OBTENER LOS USUARIOS RELACIONADOS A LOS CENTROS DE COSTO DE LA REQUISICIÓN ACTUAL
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
		WHERE SPD.IdSolicitudPedido=@IdSolicitudPedido
		AND U.Activo=1  --CTE USUARIO ACTIVO
		AND CCG.Activo=1 --> CTE RELACIÓN ACTIVA
		GROUP BY SPLP.IdCentroCosto, CC.CentroCosto,U.IdUsuario, U.Nombre, U.Correo


		DECLARE @COUNTCC INT 
		SELECT @COUNTCC = COUNT(1) FROM #CentroCosto
		
		IF @COUNTCC > 0 
		BEGIN 
			--SI HAY USUARIOS RELACIONADOS A LOS CENTROS DE COSTOS RETORNAR ESTA LISTA 					

			--RETORNAR LOS COMPRADORES RELACIONADOS A LOS CENTROS DE COSTO CON RELACIÓN A LA REQUISICIÓN
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
			GROUP BY CC.IdUsuario,Nombre,Correo	
			
			
		END 
		ELSE 
		BEGIN
			-- NO HAY NINGUN COMPRADOR EL LOS CENTROS DE COSTOS RELACIONADOS A LA REQUISCION
			-- ENTONCES ENVIAR A LOS ADMINISTRADORES DE COMPRAS EL CORREO
			INSERT INTO #CentroCosto
			(IdCentroCosto,CentroCosto,IdUsuario,Nombre,Correo)
			SELECT SPLP.IdCentroCosto, CC.CentroCosto,U.IdUsuario, U.Nombre, U.Correo
			FROM dbo.MM_SolicitudPedidoDetalle SPD
			INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLP 
				ON SPLP.IdSolicitudPedidoDetalle=SPD.IdSolicitudPedidoDetalle
			INNER JOIN dbo.CC_CentroCosto CC ON CC.IdCentroCosto=SPLP.IdCentroCosto
			INNER JOIN dbo.CC_AdministradorCompras CCA ON CCA.IdProveedor=CCA.IdProveedor
			INNER JOIN dbo.S_Usuario U ON U.IdUsuario=CCA.IdUsuario
			WHERE SPD.IdSolicitudPedido=@IdSolicitudPedido
			AND U.Activo=1 --> QUE EL USUARIO ESTE ACTIVO 
			AND CCA.Activo=1 -->QUE EL ADMINISTRADOR ESTE ACTIVO
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
	

	SELECT U.IdUsuario, U.Nombre
	FROM  
	dbo.DEA_AdjuntoPR PR
	INNER JOIN dbo.S_Usuario U ON U.IdUsuario=PR.CreadoPor
	WHERE PR.IdAjuntoPr=@IdRequisicionPR

	 
	  
END


