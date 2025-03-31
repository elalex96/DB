USE [Petrovendor]
GO
DROP PROCEDURE IF EXISTS MM_SP_ConsultaPedidoNotificacion
/****** Object:  StoredProcedure [dbo].[MM_SP_ConsultaPedidoNotificacion]    Script Date: 25/03/2025 11:28:03 a. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Marcos Garcia
-- Create date: <22-04-2019>
-- Description:	<Agregar Linea Presupuesto (Tarea y Subtarea) despues de DescripcionCorta
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: <06-07-2021>
-- Description:	Se modifico consulta para evitar html vacio
-- =============================================
-- Author:		David De La Cruz
-- Create date: <09-Sep-2024>
-- Description:	Se elimina consulta multiple de linea presupuesto
-- =============================================
-- Author:		Alexander Gomez
-- Create date: <25-Mar-2025>
-- Description:	Se reorganiza la consulta para obtener adecuadamente las partidas
-- =============================================
CREATE PROCEDURE [dbo].[MM_SP_ConsultaPedidoNotificacion]
	@IdSolicitudPedido INT,
	@Version INT,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
AS
BEGIN
	
	DECLARE @TablaRetorno TABLE
    (
        IdPedidoDetalle INT,
        DescripcionCorta NVARCHAR(MAX),
        PrecioUnitario FLOAT,
        Cantidad FLOAT,
        UnidadCotizada NVARCHAR(MAX),
        Moneda NVARCHAR(100),
        Subtotal FLOAT,
        IdPedido INT,
		IdSubcontratista INT,
		ProveedorJustificacion NVARCHAR(MAX),
		Contrato NVARCHAR(MAX),
		TipoPedido NVARCHAR(100)
    );

	/*OBTENER DETALLE DEL PEDIDO*/
    INSERT INTO @TablaRetorno
    (
        IdPedidoDetalle,
        DescripcionCorta,
        PrecioUnitario,
        Cantidad,
        UnidadCotizada,
        Moneda,
        Subtotal,
        IdPedido,
		IdSubcontratista,
		ProveedorJustificacion,
		Contrato,
		TipoPedido
    )
    SELECT PD.IdPedidoDetalle,
		   MAX('<b>' + ISNULL(POD.MaterialCotizadoTextoC, ISNULL(M.DescripcionCorta,'')) + '</b> | Línea Presupuesto - ' + ISNULL(dbo.Fn_RetornarMesProgramadoActividadConcat(SPLPM.IdLineaPresupuesto), '')),
           PD.PrecioUnitario,
           PD.Cantidad,
           POD.UnidadProveedor,
           TM.TipoMonedaCorto,
           PD.Subtotal,
           PDS.IdPedido,
		   P.IdSubcontratista,
		   MAX(PV.RazonSocial + ' ' + ISNULL(PV.RegimenCapital, '') + '.<br/> <b> Objeto del pedido(Justificación): </b>' + SOLP.MotivoUrgencia),
		   MAX(ISNULL(C.NumeroContrato,'') + ' - ' + ISNULL(AC.NombreAreaContractual,'')),
		   TP.TipoPedido
    FROM MM_Pedido AS P (NOLOCK)
        INNER JOIN MM_PedidoDetalle AS PD (NOLOCK)
            ON P.IdPedido = PD.IdPedido
			AND P.Version = @Version
        INNER JOIN MM_PeticionOferta AS PO (NOLOCK)
            ON P.IdPeticionOferta = PO.IdPeticionOferta 
        INNER JOIN MM_PeticionOfertaDetalle AS POD (NOLOCK)
            ON PD.IdPeticionOfertaDetalle = POD.IdPeticionOfertaDetalle 
        INNER JOIN MM_SolicitudPedidoDetalle AS SPD (NOLOCK)
            ON POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
			AND SPD.IdSolicitudPedido = @IdSolicitudPedido
        INNER JOIN S_Proveedor AS PV (NOLOCK)
            ON P.IdSubcontratista = PV.IdProveedor
        INNER JOIN TA_Operacion AS O (NOLOCK)
            ON P.IdSolicitudPedido = O.IdDocumento
        INNER JOIN PV_TipoMoneda AS TM (NOLOCK)
            ON PD.IdMoneda = TM.IdMoneda      
        INNER JOIN dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPLPM (NOLOCK)
            ON SPD.IdSolicitudPedidoDetalle = SPLPM.IdSolicitudPedidoDetalle 
		INNER JOIN MM_SolicitudPedido AS SOLP (NOLOCK)
            ON SPD.IdSolicitudPedido = SOLP.IdSolicitudPedido
		INNER JOIN MM_Pedidos AS PDS
			ON P.IdPedido = PDS.IdIdentificador
			AND SOLP.IdProveedor = PDS.IdProveedorCliente
		LEFT JOIN dbo.MM_Material M (NOLOCK) 
			ON PD.IdMaterial = M.IdMaterial
		LEFT JOIN Adinco.dbo.CO_Contrato AS C 
			(NOLOCK) ON P.IdContrato = C.IdContrato 
		LEFT JOIN Adinco.dbo.CO_AreaContractual AS AC (NOLOCK) 
			ON C.IdAreaContractual = AC.IdAreaContractual
		LEFT JOIN dbo.MM_TipoPedido AS TP (NOLOCK) 
			ON PDS.IdTipoPedido = TP.IdTipoPedido 
    WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
    GROUP BY PD.IdPedidoDetalle,
             PD.IdMaterialVendedor,
             POD.MaterialCotizadoTextoC,
             POD.UnidadProveedor,
             PD.PrecioUnitario,
             PD.Cantidad,
             TM.TipoMonedaCorto,
             PD.Subtotal,
             PD.RecepcionPedido,
             PD.Subtotal,
             PD.PorcentajeContenidoNacional,
             P.IdPedido,
             POD.MaterialCotizadoTextoL,
             SPD.IdMaterial,
             SPLPM.IdLineaPresupuesto,
			 P.IdSubcontratista,
			 PDS.IdPedido,
			 M.DescripcionCorta,
			 TP.TipoPedido;


		SELECT 
		   IdSubcontratista,
		   ProveedorJustificacion,
		   IdPedido,
		   DescripcionCorta,
		   PrecioUnitario,
		   Cantidad,
		   UnidadCotizada AS Unidad,
		   Subtotal,
		   Moneda AS TipoMonedaCorto,
		   Contrato,
		   TipoPedido
    FROM @TablaRetorno;

END;
