-- =============================================
-- Author:		Daniel Cruz
-- Create date: 14-10-2019
-- Description:	Agregue Columna ErrorSAT y IdTipoLectorXML y 
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 27-04-2022
-- Description:	Issue #1739  Optimizacion pantallas se ordena y revisa joins, 
-- SE DEVUELVE NULL EN EL RETORNO DE COLUMNA ComprobantePDFByte DEL PDF PARA CONSUMIRLO DESDE OTRO SP Y EN LA PANTALLA POR AJAX
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_PCN_RecepcionFacturaEncabezado]
    -- Add the parameters for the stored procedure here
    @IdProveedor INT,
    @IdUsuario INT,
    @IdAceptacionPedido INT
AS
BEGIN

    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;
	DECLARE @Yacimientos NVARCHAR(MAX)

	SELECT @Yacimientos =
    STUFF(
    (   SELECT
                CAST(', ' AS VARCHAR (MAX))
                + CONVERT(NVARCHAR (MAX), ISNULL(y.NombreYacimiento, ''))
        FROM
                dbo.MM_AceptacionPedido                       ap (NOLOCK)
            JOIN
                dbo.MM_Pedido                                 p (NOLOCK)
                    ON ap.IdPedido = p.IdPedido  
            JOIN
                dbo.MM_PedidoDetalle                          pd (NOLOCK)
                    ON  p.IdPedido = pd.IdPedido 
            LEFT JOIN
                dbo.MM_PeticionOfertaDetalle                  pod (NOLOCK)
                    ON  pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle 
            LEFT JOIN
                dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl (NOLOCK)
                    ON pod.IdSolicitudPedidoDetalle = spdl.IdSolicitudPedidoDetalle 
            LEFT JOIN
                Adinco.dbo.CO_Instalacion                     i (NOLOCK)
                    ON  spdl.IdInstalacion = i.IdInstalacion
            LEFT JOIN
                Adinco.dbo.CO_Yacimiento                      y (NOLOCK)
                    ON  i.IdYacimiento = y.IdYacimiento
        WHERE
                ap.IdAceptacionPedido = @IdAceptacionPedido
        GROUP BY
                y.NombreYacimiento
        FOR XML PATH('')), 1, 1, '')



    SELECT 
		   '' AS ArchivoPDF,		  
           F.XML,
           AF.IdAceptacionPedido,
           PE.IdPedido,
           O.FechaRegistro,
           CONCAT(PR.RazonSocial, ' ', PR.RegimenCapital, CASE WHEN @Yacimientos = '' THEN '' ELSE '- - - Yacimiento(s): ' + @Yacimientos END)  AS Proveedor,
           E.Nombre,
           E.IdEstatus,
           O.IdOperacion,
           PR.IdProveedor,
           PG.IdPedido AS IdPedidoGeneral,
           F.IdFactura,
           NULL AS ComprobantePDFByte,		   
		   TP.TipoPedido,
		   TP.IdTipoPedido,
		   FT.Nombre,
		   TF.Nombre,
		   ISNULL(F.IdLectorXMLSAT,1) AS IdLectorXMLSAT,
		   REPLACE(ISNULL(F.ErroSAT,''),'Error SAT:','') AS ErrorSAT,
		   ISNULL(ISAT.DireccionWeb,'') AS DireccionWeb,
		   ISNULL(F.UUID,'') AS UUID,
		   ISNULL(F.Emisor,'') AS RFC_Emisor,
		   ISNULL(F.Receptor,'') AS RFC_Receptor,
		   RCN.PedirCarta
    FROM MM_AceptacionFactura AS AF
         JOIN FI_Factura AS F
            ON AF.IdFactura = F.IdFactura 
         JOIN TA_Operacion AS O 
            ON AF.IdAceptacionFactura = O.IdDocumento 
			AND O.IdTipoOperacion = 10 -->CTE Aprobación Factura           
         JOIN TA_Estatus AS E (NOLOCK)
            ON O.IdEstatusOperacion = E.IdEstatus 
         JOIN MM_AceptacionPedido AS AP 
            ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
			AND AP.IdEliminado IS NULL  
         JOIN MM_Pedido AS PE
            ON  AP.IdPedido = PE.IdPedido 
         JOIN MM_Pedidos AS PG
            ON PE.IdPedido = PG.IdIdentificador
			AND PE.IdProveedorCompras	=	PG.IdProveedorCliente
            AND PG.IdProveedorCliente = @IdProveedor
			 AND PG.IdTipoPedido in (2,4,6) --> CTES 
         JOIN S_Proveedor AS PR (NOLOCK)
            ON PE.IdSubcontratista = PR.IdProveedor 
         JOIN dbo.MM_TipoPedido AS TP (NOLOCK)
            ON  PG.IdTipoPedido = TP.IdTipoPedido 
		LEFT JOIN dbo.TA_FlujoTarea FT (NOLOCK)
			ON O.IdFlujoTarea = FT.IdFlujoTarea 
		LEFT JOIN dbo.TA_TipoFlujoTarea TF  (NOLOCK)
			ON FT.IdTipoFlujo = TF.IdTipoFlujoTarea
		LEFT JOIN dbo.InfoSAT ISAT (NOLOCK)
			ON ISAT.Id = 1
		LEFT JOIN dbo.RelacionCartaCNPedido RCN 
			ON AP.IdAceptacionPedido = RCN.IdAceptacionPedido 
    WHERE PE.IdProveedorCompras = @IdProveedor
          AND AF.IdAceptacionPedido =@IdAceptacionPedido 
    GROUP BY F.ArchivoPDF,
             F.XML,
             AF.IdAceptacionPedido,
             PE.IdPedido,
             O.FechaRegistro,
             PR.RazonSocial,
             PR.RegimenCapital,
             E.Nombre,
             E.IdEstatus,
             O.IdOperacion,
             PR.IdProveedor,
             PG.IdPedido,
             F.IdFactura,
			 TP.TipoPedido,
			 TP.IdTipoPedido,
			 FT.Nombre,
		     TF.Nombre,
			 F.IdLectorXMLSAT,
			 F.ErroSAT,
			 ISAT.DireccionWeb,
			 F.UUID,
		     F.Emisor,
		     F.Receptor,
			 RCN.PedirCarta


END;
