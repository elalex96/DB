-- =============================================
-- Author:		Daniel A Cruz
-- Create date: 04-01-17
-- Description:	 Consultar Aprobadores recibiendo el IdOperador
-- =============================================
-- =============================================
-- Author:		Pedro Acuña
-- Create date: 30-07-18
-- Description:	 que solo sean los que estan activos
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 06-02-2019
-- Description:	 Se quito el regimen de la consulta (ya no se usa y marcaba error)
-- =============================================
-- Author:		Marcos Garcia
-- Create date: 24-04-2019
-- Description:	Se concateno RazonRocial,NumeroContrato,NombreAreaContractual y MotivoUrgencia en IdPedidoGeneral
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarPedidoXVersion]
	-- Add the parameters for the stored procedure here
	@IdOperacion INT, @IdSolicitudPedido INT, @Version INT
AS
	BEGIN
		SET NOCOUNT ON

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
					AS IdPedidoGeneral 
	FROM MM_Pedido AS P
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
					P.IdSolicitudPedido = @IdSolicitudPedido
					AND P.Version = 1
					AND
						(	U.IdTipoUsuario = 4
							OR		U.IdTipoUsuario = 3 )
					AND U.Activo = 1

		ORDER BY	P.IdPedido
	END
