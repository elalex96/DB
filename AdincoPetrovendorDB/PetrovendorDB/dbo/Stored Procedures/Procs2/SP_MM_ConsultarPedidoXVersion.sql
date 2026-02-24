USE [Petrovendor]
GO
DROP PROC IF EXISTS SP_MM_ConsultarPedidoXVersion
go
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultarPedidoXVersion]    Script Date: 23/02/2026 05:31:06 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
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
-- Author:		Alexander Gomez
-- Create date: 23-02-2026
-- Description:	 Se agrega el filtro por version de pedido
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
	FROM MM_Pedido AS P (NOLOCK)
		INNER JOIN	S_Proveedor AS PR (NOLOCK)
			ON PR.IdProveedor = P.IdSubcontratista
		INNER JOIN	S_UsuarioProveedor AS UP (NOLOCK)
			ON UP.IdProveedor = PR.IdProveedor
		INNER JOIN	S_Usuario AS U (NOLOCK)
			ON U.IdUsuario = UP.IdUsuario
		INNER JOIN	MM_HorasVigenciaPedido AS H (NOLOCK)
			ON H.IdPedido = P.IdPedido
		INNER JOIN	MM_Pedidos AS PG (NOLOCK)
			ON P.IdPedido = PG.IdIdentificador
			   AND	PG.IdProveedorCliente = P.IdProveedorCompras
		LEFT JOIN dbo.S_Proveedor AS PC (NOLOCK)
			ON PC.IdProveedor = P.IdProveedorCompras
		LEFT JOIN dbo.MM_SolicitudPedido AS SP (NOLOCK)
			ON SP.IdSolicitudPedido = P.IdSolicitudPedido
		LEFT JOIN Adinco.dbo.CO_Contrato AS CCO (NOLOCK)
			ON CCO.IdContrato = P.IdContrato
		LEFT JOIN adinco.dbo.CO_AreaContractual AS CAC (NOLOCK)
			ON CAC.IdAreaContractual = CCO.IdAreaContractual
		WHERE
			P.IdSolicitudPedido = @IdSolicitudPedido
			AND P.Version = @Version
			AND
				(	U.IdTipoUsuario = 4
				OR	U.IdTipoUsuario = 3 )
			AND U.Activo = 1
		ORDER BY	P.IdPedido

END
