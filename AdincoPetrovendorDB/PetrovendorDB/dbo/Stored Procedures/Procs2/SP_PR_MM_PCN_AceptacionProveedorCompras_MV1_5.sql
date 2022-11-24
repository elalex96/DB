
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	Daniel AC
-- Create date:29-11-2019
-- Description:	Se agrego detalle de los días de crédito y detalle de la aceptación, Add Linea presupuesto mes
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_AceptacionProveedorCompras_MV1_5] 
	-- Add the parameters for the stored procedure here
@IdProveedor        INT,
@IdAceptacionPedido INT,
    @IdContrato    INT,
    @IdUsuario     INT,
    @FechaRegistro DATETIME 

AS
BEGIN
-- SET NOCOUNT ON added to prevent extra result sets from
-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Insert statements for procedure here
          
	SELECT 
				IdAceptacionPedidoDetalle	=		APD.IdAceptacionPedidoDetalle,
				IdMaterial					=		PD.IdMaterialVendedor,
				DescripcionCorta			=		POD.MaterialCotizadoTextoC,
				DescripcionLarga			=		POD.MaterialCotizadoTextoL,
				Unidad						=		POD.UnidadProveedor,
				Cantidad					=		APD.Cantidad,
				Excedente					=		APD.Excedente, 
				PrecioUnitario				=		ISNULL(APD.PrecioUnitario,PD.PrecioUnitario),
				PCN							=		APD.PCN,
				Moneda						=		TM.TipoMonedaCorto,
				CantidadSolicitada			=		pd.Cantidad,
				CondicionPago				=		CASE	WHEN PD.IdCondicionPago		= 1 
															THEN	---> CREDITO
																	CONCAT(PD.DiasCredito, ' ',
																	CASE	WHEN PD.DiasCredito			= 1 
																	THEN	'día' 
																	ELSE	'días'
																	END,	
																	' de ', 
																	CP.CondicionPago )
															ELSE 	cp.CondicionPago
															END,
				DetalleAPD					=		CONCAT((CASE WHEN LEN(APD.Detalle)>0 THEN CONCAT(APD.Detalle,'| ') ELSE '' END)
													,ISNULL('Instalación: ' + INS.NombreInstalacion  COLLATE Modern_Spanish_CI_AS,''),
													ISNULL(' | Yacimiento: ' + Y.NombreYacimiento  COLLATE Modern_Spanish_CI_AS,''),
													ISNULL(' | Linea de presupuesto: '+dbo.Fn_RetornarMesProgramadoActividadConcat(lp.IdLineaPresupuestoMes),''))
	FROM		MM_AceptacionPedidoDetalle					APD
	INNER JOIN	MM_AceptacionPedido							A		ON	A.IdAceptacionPedido			=	APD.IdAceptacionPedido
	INNER JOIN	MM_PedidoDetalle							PD		ON	PD.IdPedidoDetalle				=	APD.IdPedidoDetalle
	INNER JOIN	dbo.MM_PeticionOfertaDetalle				POD		ON	POD.IdPeticionOfertaDetalle		=	PD.IdPeticionOfertaDetalle
	--left join	PV_MM_MaterialUnidad						mu		on	pod.IdUnidad				=		mu.IdUnidad
	INNER JOIN	MM_Pedido									P		ON	P.IdPedido						=	A.IdPedido	
	INNER JOIN	PV_TipoMoneda								TM		ON	TM.IdMoneda						=	PD.IdMoneda 
	LEFT JOIN	dbo.MM_CondicionPago						CP		ON	PD.IdCondicionPago				=	CP.IdCondicionPago
	LEFT JOIN	dbo.MM_AceptacionPedidoDetalleInstalacion	APDI	ON	APDI.IdAceptacionPedido			=	A.IdAceptacionPedido
																	AND APDI.IdAceptacionPedidoDetalle	=	APD.IdAceptacionPedidoDetalle
	LEFT JOIN	Adinco.dbo.CO_Instalacion					INS		ON INS.IdInstalacion				=	APDI.IdInstalacion	
	LEFT JOIN	Adinco.dbo.CO_LineaPresupuestoMes			lp 		ON lp.IdLineaPresupuestoMes			=	APDI.IdLineaPresupuesto	
	LEFT JOIN Adinco..CO_Yacimiento							Y       ON INS.IdYacimiento=Y.IdYacimiento
	--LEFT JOIN MM_SolicitudAceptacionPedidoDetalle AS S
	WHERE		P.IdProveedorCompras						=		@IdProveedor  
	AND			A.IdAceptacionPedido						=		@IdAceptacionPedido
	GROUP BY 
	APD.IdAceptacionPedidoDetalle,
	PD.IdMaterialVendedor,
	POD.MaterialCotizadoTextoC,
	POD.MaterialCotizadoTextoL,
	POD.UnidadProveedor,
	--mu.Unidad,
	APD.Cantidad,
	APD.Excedente, 
	PD.PrecioUnitario,
	APD.PCN,
	TM.TipoMonedaCorto,
	pd.Cantidad,
	cp.CondicionPago,
	PD.DiasCredito,
	PD.IdCondicionPago,
	APD.Detalle,
	INS.NombreInstalacion,
	lp.IdLineaPresupuestoMes,
	Y.NombreYacimiento,
	APD.PrecioUnitario
	--order by POD.UnidadProveedor

END;

