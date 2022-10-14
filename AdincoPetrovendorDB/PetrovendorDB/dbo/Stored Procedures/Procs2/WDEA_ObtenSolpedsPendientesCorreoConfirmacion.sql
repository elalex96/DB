USE PETROVENDOR
GO
DROP PROC IF EXISTS WDEA_ObtenSolpedsPendientesCorreoConfirmacion
GO
CREATE PROC WDEA_ObtenSolpedsPendientesCorreoConfirmacion
AS
BEGIN
		SELECT		
					P.IdPedido, 
					U.Nombre, 
					U.Correo, 
					PR.IdProveedor, 
					H.HorasVigencia,
					PC.RazonSocial AS Cliente, 
					U.IdUsuario,
					REPLACE(CONCAT(CAST(PG.IdPedido AS NVARCHAR) ,
						', perteneciente a ',
						REPLACE(REPLACE(REPLACE(PC.RazonSocial,CHAR(10),''),CHAR(13),''),CHAR(9),''),
						', del Contrato ',
						REPLACE(REPLACE(REPLACE(CCO.NumeroContrato,CHAR(10),''),CHAR(13),''),CHAR(9),'') COLLATE Modern_Spanish_CI_AS,
						', Bloque ',
						CAC.NombreAreaContractual COLLATE Modern_Spanish_CI_AS,
						', con Justificación ',
						REPLACE(REPLACE(REPLACE(SP.MotivoUrgencia,CHAR(10),''),CHAR(13),''),CHAR(9),''),'.'),'
						','')
					AS IdPedidoGeneral,
					SPPC.Id,
					SPPC.IdOperacion,
					SPPC.IdAprobador
	FROM WDEA_PedidosPendientesCorreosConfirmacion AS SPPC
		INNER JOIN MM_Pedido  AS P
			ON P.IdSolicitudPedido = SPPC.IdSolicitudPedido
		INNER JOIN	S_Proveedor AS PR
			ON PR.IdProveedor = P.IdSubcontratista
		INNER JOIN	S_UsuarioProveedor AS UP
			ON UP.IdProveedor = PR.IdProveedor
		INNER JOIN	S_Usuario AS U
			ON U.IdUsuario = UP.IdUsuario
		INNER JOIN	MM_HorasVigenciaPedido AS H
			ON H.IdPedido = P.IdPedido
		INNER JOIN	MM_Pedidos AS PG
			ON P.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = P.IdProveedorCompras
		LEFT JOIN dbo.S_Proveedor AS PC 
			ON PC.IdProveedor = P.IdProveedorCompras
		LEFT JOIN dbo.MM_SolicitudPedido AS SP
			ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		LEFT JOIN Adinco.dbo.CO_Contrato AS CCO
			ON CCO.IdContrato = P.IdContrato
		LEFT JOIN adinco.dbo.CO_AreaContractual AS CAC
			ON CAC.IdAreaContractual = CCO.IdAreaContractual
		WHERE
		P.Version = 1
		AND
			(	U.IdTipoUsuario = 4
				OR		U.IdTipoUsuario = 3 )
				AND U.Activo = 1
		AND SPPC.Procesado = 0
		ORDER BY	P.IdPedido
END
