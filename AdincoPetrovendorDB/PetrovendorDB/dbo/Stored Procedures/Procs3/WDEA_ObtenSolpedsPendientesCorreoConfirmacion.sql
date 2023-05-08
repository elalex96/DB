CREATE PROC WDEA_ObtenSolpedsPendientesCorreoConfirmacion
@Purchasing varchar(100),
@IdPedidoActual int
AS
BEGIN

INSERT INTO WDEA_Bitacora_AdincoSAP
			(
				Fecha,
				Mensaje,
				NoConsecutivoProcesamiento,
				IdBitacoraLectura
			)
			VALUES
			(
				GETDATE(),
				CONCAT('Se envía el correo a los proveedores correspondientes del Pedido No.',@IdPedidoActual, ' Purchasing Document: ',@Purchasing),
				NULL,
				NULL
			);
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
			ON SPPC.IdSolicitudPedido = P.IdSolicitudPedido
		INNER JOIN	S_Proveedor AS PR (NOLOCK)
			ON P.IdSubcontratista = PR.IdProveedor
		INNER JOIN	S_UsuarioProveedor AS UP (NOLOCK)
			ON PR.IdProveedor = UP.IdProveedor
		INNER JOIN	S_Usuario AS U (NOLOCK)
			ON UP.IdUsuario = U.IdUsuario
		INNER JOIN	MM_HorasVigenciaPedido AS H
			ON P.IdPedido = H.IdPedido
		INNER JOIN	MM_Pedidos AS PG (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador
			   AND	P.IdProveedorCompras = PG.IdProveedorCliente
		LEFT JOIN dbo.S_Proveedor AS PC (NOLOCK)
			ON P.IdProveedorCompras = PC.IdProveedor
		LEFT JOIN dbo.MM_SolicitudPedido AS SP
			ON P.IdSolicitudPedido = SP.IdSolicitudPedido
		LEFT JOIN Adinco.dbo.CO_Contrato AS CCO (NOLOCK)
			ON P.IdContrato = CCO.IdContrato
		LEFT JOIN adinco.dbo.CO_AreaContractual AS CAC (NOLOCK)
			ON CCO.IdAreaContractual = CAC.IdAreaContractual
		WHERE
		P.Version = 1
		AND
			(	U.IdTipoUsuario = 4
				OR		U.IdTipoUsuario = 3 )
				AND U.Activo = 1
		AND SPPC.Procesado = 0
		AND SPPC.IdPedidoActual = @IdPedidoActual
		AND SPPC.Purchasing_Document = @Purchasing
		ORDER BY	P.IdPedido


END