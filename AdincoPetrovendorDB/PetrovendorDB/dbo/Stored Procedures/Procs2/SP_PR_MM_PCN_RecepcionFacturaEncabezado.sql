-- =============================================
-- Author:		Daniel Cruz
-- Create date: 14-10-2019
-- Description:	Agregue Columna ErrorSAT y IdTipoLectorXML y 
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
                dbo.MM_AceptacionPedido                       ap
            INNER JOIN
                dbo.MM_Pedido                                 p
                    ON p.IdPedido = ap.IdPedido
            INNER JOIN
                dbo.MM_PedidoDetalle                          pd
                    ON pd.IdPedido = p.IdPedido
            LEFT JOIN
                dbo.MM_PeticionOfertaDetalle                  pod
                    ON pod.IdPeticionOfertaDetalle = pd.IdPeticionOfertaDetalle
            LEFT JOIN
                dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdl
                    ON spdl.IdSolicitudPedidoDetalle = pod.IdSolicitudPedidoDetalle
            LEFT JOIN
                Adinco.dbo.CO_Instalacion                     i
                    ON i.IdInstalacion = spdl.IdInstalacion
            LEFT JOIN
                Adinco.dbo.CO_Yacimiento                      y
                    ON y.IdYacimiento = i.IdYacimiento
        WHERE
                ap.IdAceptacionPedido = @IdAceptacionPedido
        GROUP BY
                y.NombreYacimiento
        FOR XML PATH('')), 1, 1, '')

    SELECT ISNULL(F.ArchivoPDF, ''),
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
           (
               SELECT ComprobantePDFByte
               FROM dbo.FI_Factura
               WHERE IdFactura = F.IdFactura
           ) AS ComprobantePDFByte,
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
        INNER JOIN FI_Factura AS F
            ON F.IdFactura = AF.IdFactura
        INNER JOIN TA_Operacion AS O
            ON O.IdDocumento = AF.IdAceptacionFactura
        INNER JOIN TA_Tarea AS T
            ON T.IdOperacion = O.IdOperacion
        INNER JOIN TA_Estatus AS E
            ON E.IdEstatus = O.IdEstatusOperacion
        INNER JOIN MM_AceptacionPedido AS AP
            ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
        INNER JOIN MM_Pedido AS PE
            ON PE.IdPedido = AP.IdPedido
        INNER JOIN MM_Pedidos AS PG
            ON PE.IdPedido = PG.IdIdentificador
               AND PG.IdProveedorCliente = @IdProveedor
        INNER JOIN S_Proveedor AS PR
            ON PR.IdProveedor = PE.IdSubcontratista
        LEFT JOIN dbo.MM_TipoPedido AS TP
            ON TP.IdTipoPedido = PG.IdTipoPedido
		LEFT JOIN dbo.TA_FlujoTarea FT ON FT.IdFlujoTarea = O.IdFlujoTarea
		LEFT JOIN dbo.TA_TipoFlujoTarea TF ON TF.IdTipoFlujoTarea=FT.IdTipoFlujo
		LEFT JOIN dbo.InfoSAT ISAT ON ISAT.Id = 1
		LEFT JOIN dbo.RelacionCartaCNPedido RCN ON RCN.IdAceptacionPedido = AP.IdAceptacionPedido
    WHERE O.IdTipoOperacion = 10  --> APROBACIÓN DE TIPO FACTURA 
          AND PE.IdProveedorCompras = @IdProveedor
          AND AF.IdAceptacionPedido =@IdAceptacionPedido ---> 441
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






