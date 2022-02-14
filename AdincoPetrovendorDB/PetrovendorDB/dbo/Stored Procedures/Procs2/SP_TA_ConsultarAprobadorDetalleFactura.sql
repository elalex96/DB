USE petrovendor
GO
DROP PROCEDURE IF EXISTS SP_TA_ConsultarAprobadorDetalleFactura
GO
-- =============================================
-- Author: Daniel AC
-- Create date: 02/09/2019
-- Description:	Consultar aprobadores de factura
-- =============================================
-- Author: Luis David
-- Create date: 10/02/2022
-- Description:	Se agrega el filtro de aprobadores activos
-- =============================================
CREATE PROCEDURE [dbo].[SP_TA_ConsultarAprobadorDetalleFactura]  
@IdOperacion int,
@IdProveedor INT,
@IdUsuario INT,
@IdAceptacionPedido INT, 
@IdTarea INT,
@Mensaje NVARCHAR(MAX)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	
			SELECT 
			    U.IdUsuario,--0
				T.NoSecuencia,--1
				U.Nombre,--2
				U.Correo,--3
				T.IdEstatus,--4
				TOO.IdDocumento,--5
				TTO.NombreOperacion,--6
				AF.IdAceptacionPedido,--7
				PG.IdPedido AS PedidoGral,--8
				ISNULL(U.Telefono,'') AS Telefono,--9
				P.IdPedido,--10
				P.IdSolicitudPedido,--11
				FT.IdFlujoTarea,--12
				FT.IdTipoFlujo,--13
				TOO.IdEstatusOperacion,--14
				TAE.Nombre,--15
				TOO.IdEstadoFlujo,--16
				TOO.IdTipoOperacion,	--17							
				TOO.IdOperacion,--18
				TOO.IdAsignador,--19				
				'' AS Comentario,		--20	
				T.MensajeAsignacion --21
			FROM TA_Tarea AS T
				INNER JOIN TA_Operacion AS TOO
					ON T.IdOperacion = TOO.IdOperacion
				INNER JOIN TA_FlujoTarea AS FT
					ON TOO.IdFlujoTarea = FT.IdFlujoTarea
				INNER JOIN S_Usuario AS U
					ON T.IdAprobador = U.IdUsuario
				INNER JOIN TA_TipoOperacion AS TTO
					ON TOO.IdTipoOperacion = TTO.IdTipoOperacion
				INNER JOIN TA_Estatus AS TAE
					ON TOO.IdEstatusOperacion = TAE.IdEstatus
				LEFT JOIN dbo.MM_AceptacionFactura AF 
					ON TOO.IdDocumento = AF.IdAceptacionFactura
				LEFT JOIN dbo.MM_AceptacionPedido AP 
					ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN dbo.MM_Pedido P 
					ON AP.IdPedido = P.IdPedido
				LEFT JOIN dbo.MM_Pedidos PG 
					ON P.IdPedido = PG.IdIdentificador
					AND P.IdProveedorCompras = PG.IdProveedorCliente
			WHERE T.IdOperacion = @IdOperacion
			AND T.IdTarea=@IdTarea
				  AND T.Activo = 1
				  AND ISNULL(U.Activo,0) = 1
			GROUP BY
			 U.IdUsuario,--0
				T.NoSecuencia,--1
				U.Nombre,--2
				U.Correo,--3
				T.IdEstatus,--4
				TOO.IdDocumento,--5
				TTO.NombreOperacion,--6
				AF.IdAceptacionPedido,--7
				PG.IdPedido,--8
				U.Telefono,
				P.IdPedido,
				FT.IdFlujoTarea,
				FT.IdTipoFlujo,
				TOO.IdEstatusOperacion,
				TAE.Nombre,
				TOO.IdEstadoFlujo,
				TOO.IdTipoOperacion,							
				TOO.IdOperacion,
				TOO.IdAsignador,								
				T.MensajeAsignacion,
				P.IdSolicitudPedido
			
	

END
