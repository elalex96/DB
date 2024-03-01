USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_PCN_AceptacionProveedorCompras_MV1_5'
)
    DROP PROCEDURE SP_PR_MM_PCN_AceptacionProveedorCompras_MV1_5; 
GO
/****** Object:  StoredProcedure [dbo].[SP_PR_MM_PCN_AceptacionProveedorCompras_MV1_5]    Script Date: 01/03/2024 04:03:48 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- =============================================
-- Author:	Daniel AC
-- Create date:29-11-2019
-- Description:	Se agrego detalle de los días de crédito y detalle de la aceptación, Add Linea presupuesto mes
-- =============================================
-- =============================================
-- Author:		DANIEL AC
-- Create date: 29/02/2023
-- Description:	Se agrega detalle de clasificación de criterios de FuncionalidadDetallePresupuestoAceptacionServicio
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
													ISNULL(' | Linea de presupuesto: '+dbo.Fn_RetornarMesProgramadoActividadConcat(lp.IdLineaPresupuestoMes),''),
													CASE WHEN ISNULL(APCP.Nombre,'')<>'' THEN ' | Cliente/Proyecto: '+ ISNULL(APCP.Nombre,'') ELSE '' END,
													CASE WHEN ISNULL(APACG.Nombre,'')<>'' THEN ' | Actividad/Clasificación/Gasto: '+ ISNULL(APACG.Nombre,'') ELSE '' END ,
													CASE WHEN ISNULL(APACG.Nombre,'')<>'' THEN ' | Actividad/Clasificación/Gasto(2): '+ ISNULL(APACG2.Nombre,'--') ELSE '' END 
													)				
	FROM		MM_AceptacionPedidoDetalle APD (NOLOCK)
	INNER JOIN	MM_AceptacionPedido	A (NOLOCK)		
		ON	APD.IdAceptacionPedido	= A.IdAceptacionPedido	
	INNER JOIN	MM_PedidoDetalle PD	 (NOLOCK)	
		ON	APD.IdPedidoDetalle  = PD.IdPedidoDetalle
	INNER JOIN	dbo.MM_PeticionOfertaDetalle POD		
	ON	PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle	
	INNER JOIN	MM_Pedido P		 (NOLOCK)
	ON	A.IdPedido = P.IdPedido		
	INNER JOIN	PV_TipoMoneda TM (NOLOCK)		
	ON	PD.IdMoneda  = TM.IdMoneda	
	LEFT JOIN	dbo.MM_CondicionPago CP	 (NOLOCK)	
	ON	PD.IdCondicionPago = CP.IdCondicionPago
	LEFT JOIN	dbo.MM_AceptacionPedidoDetalleInstalacion APDI (NOLOCK)	
	ON	A.IdAceptacionPedido = APDI.IdAceptacionPedido																
		AND APD.IdAceptacionPedidoDetalle = APDI.IdAceptacionPedidoDetalle	
	LEFT JOIN	Adinco.dbo.CO_Instalacion INS (NOLOCK)		
		ON APDI.IdInstalacion = INS.IdInstalacion
	LEFT JOIN	Adinco.dbo.CO_LineaPresupuestoMes lp  (NOLOCK)		
		ON APDI.IdLineaPresupuesto	 = lp.IdLineaPresupuestoMes
	LEFT JOIN Adinco..CO_Yacimiento	Y  (NOLOCK)      
		ON INS.IdYacimiento = Y.IdYacimiento
	LEFT JOIN MM_AceptacionPedidoDetalleCriterios APC(NOLOCK)     
		ON APD.IdAceptacionPedidoDetalle = APC.AceptacionPedidoDetalleId
	LEFT JOIN MM_ClienteProyecto APCP(NOLOCK)     
		ON APC.ClienteProyectoId = APCP.Id
	LEFT JOIN MM_ActividadClasificacionGasto APACG (NOLOCK)
		On APC.ActividadClasificacionGastoId = APACG.Id
	LEFT JOIN MM_ActividadClasificacionGasto APACG2 (NOLOCK)
		On APC.ActividadClasificacionGasto2Id = APACG2.Id
	WHERE		P.IdProveedorCompras						=		@IdProveedor  
	AND			A.IdAceptacionPedido						=		@IdAceptacionPedido
	GROUP BY 
	APD.IdAceptacionPedidoDetalle,
	PD.IdMaterialVendedor,
	POD.MaterialCotizadoTextoC,
	POD.MaterialCotizadoTextoL,
	POD.UnidadProveedor,
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
	APD.PrecioUnitario,
	APCP.Nombre,
	APACG.Nombre,
	APACG2.Nombre


END;
