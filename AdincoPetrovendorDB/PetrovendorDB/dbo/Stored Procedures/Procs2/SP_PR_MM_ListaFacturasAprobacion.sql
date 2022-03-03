USE Petrovendor
GO
DROP PROCEDURE IF EXISTS SP_PR_MM_ListaFacturasAprobacion
GO
-- =============================================  
-- Author:  <Daniel AC>  
-- Create date: <18/11/2020>  
-- Description: <Se revisa sp relacioando al issue #835 montos duplicados >  
-- =============================================  
-- Author:		LUIS DAVID
-- Create date: 02/03/2022
-- Description:	SE AGREGA EL PO PARA DEA ISSUE#1651
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ListaFacturasAprobacion] --420,1
@IdProveedor int,
@Estatus int,
@IdContrato int = NULL,
@IdUsuario int = NULL,
@FechaRegistro datetime = NULL
AS
BEGIN
  SET NOCOUNT ON;
	DECLARE @PLANT			nvarchar(10),
			@PROVEDORRFC	nvarchar(20),
			@IDCONTRATISTA	nvarchar(50)

	create table #FlujoSerial 
	(
		IdOperacion int,
		NoSecuencia int
	)

	create table #OperacionNoAprobadas 
	(
		IdOperacion int
	)

	CREATE TABLE #AceptacionesPedido 
	(
		IdAceptacionPedido	int				NULL,
		Pedido				nvarchar(max)	NULL,
		IdPedido			int				NULL,
		FechaRegistro		datetime		NULL,
		Proveedor			nvarchar(350)	NULL,
		Nombre				nvarchar(100)	NULL,
		TotalPedido			money			NULL,
		Moneda				nvarchar(100)	NULL,
		RFC					nvarchar(100)	NULL,
		IdSolicitudPedido	nvarchar(100)	NULL,
		span				nvarchar(100)	NULL,
		PedirCarta			bit,
		IdOperacion			int,
		Contrato			varchar(50),
		PO					varchar(300)
	)



	select	@PLANT	=	(	SELECT		TOP 1
										P.Planta
							FROM		Adinco.dbo.CO_Contrato				AS C
							LEFT JOIN	Adinco.dbo.CO_SAPContratista_Planta AS P
							ON			C.IdContratista=P.IdContratista 
							WHERE		C.IdContrato = @IdContrato)--@IDCONTRATO2);

	select	@PROVEDORRFC = (	SELECT	RFC
								FROM	dbo.S_Proveedor
								WHERE	IdProveedor = @IdProveedor);

	select	@IDCONTRATISTA	= (	SELECT	IdContratista
								FROM	Adinco.dbo.CO_Contratista
								WHERE	RFC = @PROVEDORRFC);


	
  INSERT INTO #FlujoSerial 
  (IdOperacion,
  NoSecuencia)
    SELECT
      O.IdOperacion,
      t.NoSecuencia
    FROM dbo.TA_Operacion O
    JOIN dbo.MM_AceptacionFactura af
      ON o.IdDocumento=af.IdAceptacionFactura 
    JOIN MM_AceptacionPedido AS AP
      ON AF.IdAceptacionPedido=AP.IdAceptacionPedido
    JOIN MM_Pedido AS PE
      ON AP.IdPedido=PE.IdPedido 
    JOIN dbo.TA_Tarea t
      ON O.IdOperacion=t.IdOperacion 
    JOIN dbo.TA_FlujoTarea FT
      ON O.IdFlujoTarea=FT.IdFlujoTarea 
    WHERE O.IdTipoOperacion = 10
    AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->QUE NO ESTE ELIMINADO
    AND t.IdAprobador = @IdUsuario
    AND t.NoSecuencia > 1--> SEA UN NÚMERO DE SECUENCIA MAYOR A 1
    AND t.Activo = 1
    AND FT.IdTipoFlujo = 1 ---> SOLO DEBE APLICAR PARA LAS APROBACIONES SERIALES      
    AND PE.IdProveedorCompras = @IdProveedor;

  INSERT INTO #OperacionNoAprobadas (IdOperacion)
    SELECT
      O.IdOperacion
    FROM dbo.TA_Operacion O
    JOIN #FlujoSerial f
      ON O.IdOperacion=f.IdOperacion 
    JOIN dbo.TA_Tarea T
      ON O.IdOperacion=T.IdOperacion 
      AND (f.NoSecuencia - 1) = T.NoSecuencia
    WHERE O.IdTipoOperacion = 10
    AND T.Activo = 1
    AND T.IdEstatus <> 2;

  
  IF @Estatus
    IN (1, 2, 3) --> EN APROBACIÓN, APROBADO, RECHAZADOS
  BEGIN
    INSERT INTO #AceptacionesPedido
      SELECT
        AF.IdAceptacionPedido,
        PG.IdPedido,
        Pe.IdPedido,
        O.FechaRegistro,
        PR.RazonSocial + ' ' + ISNULL(Pr.RegimenCapital, '') AS Proveedor,
        E.Nombre,
        SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido,
        TM.TipoMonedaCorto AS Moneda,
        'RFC: ' + ISNULL(PR.RFC, 'SIN DATOS') + ' - UUID:' + ISNULL(fi.UUID, 'SIN DATOS'),
        PE.IdSolicitudPedido,
        '',
        RC.PedirCarta,
        NULL,
        Contrato = c.NumeroContrato,
		ISNULL(RPO.PO,'Sin PO relacionada') AS PO
      FROM MM_AceptacionFactura AS AF
      JOIN TA_Operacion AS O
        ON AF.IdAceptacionFactura =O.IdDocumento  --AND O.IdProveedor = @IdProveedor  
        AND O.IdTipoOperacion = 10
        AND O.IdEstatusOperacion = @Estatus
        AND O.IdOperacion NOT IN (SELECT
								  IdOperacion
								  FROM #OperacionNoAprobadas)
      JOIN TA_Estatus AS E
        ON O.IdEstatusOperacion=E.IdEstatus 
      JOIN MM_AceptacionPedido AS AP
        ON AF.IdAceptacionPedido=AP.IdAceptacionPedido 
      JOIN MM_Pedido AS PE
        ON  AP.IdPedido=PE.IdPedido
        AND O.IdProveedor=PE.IdSubcontratista 
        AND @IdProveedor = PE.IdProveedorCompras
      JOIN MM_PedidoDetalle AS PED
        ON PE.IdPedido=PED.IdPedido
      JOIN dbo.MM_AceptacionPedidoDetalle AS APD
        ON AP.IdAceptacionPedido=APD.IdAceptacionPedido 
        AND PED.IdPedidoDetalle=APD.IdPedidoDetalle
      JOIN MM_Pedidos AS PG
        ON PE.IdPedido = PG.IdIdentificador
        AND PG.IdProveedorCliente = @IdProveedor
        AND PG.IdTipoPedido IN (2, 4, 6) -->	MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA
      JOIN S_Proveedor AS PR
        ON PE.IdSubcontratista=PR.IdProveedor 
      JOIN dbo.PV_TipoMoneda AS TM
        ON PE.IdMoneda=TM.IdMoneda 
      JOIN dbo.FI_Factura AS fi
        ON AF.IdFactura= fi.IdFactura
      JOIN dbo.RelacionCartaCNPedido RC
        ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 
      JOIN Adinco.dbo.CO_Contrato AS C
        ON PE.IdContrato=C.IdContrato 
	  LEFT JOIN DEA_Relacion_PR_PO AS RPO	
		ON PE.IdPedido = RPO.IdPedido
      WHERE ISNULL(AF.IdEstatusEliminado, 0) <> 1
      GROUP BY AF.IdAceptacionPedido,
               Pe.IdPedido,
               O.FechaRegistro,
               PR.RazonSocial,
               Pr.RegimenCapital,
               E.Nombre,
               PG.IdPedido,
               TM.TipoMonedaCorto,
               PR.RFC,
               PE.IdSolicitudPedido,
               E.IdEstatus,
               fi.UUID,
               RC.PedirCarta,
               c.IdContrato,
               c.NumeroContrato,
			   RPO.PO
      ORDER BY AF.IdAceptacionPedido DESC;

    IF ISNULL(@PLANT, '') <> ''
    BEGIN
      INSERT INTO #AceptacionesPedido
        SELECT
          AF.IdAceptacionPedido,
          CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS nvarchar(100)) COLLATE Modern_Spanish_CI_AS),
          00,
          AF.CreadoEl,
          ISNULL(SV.VendorName, AP.IdSubContratista) AS Proveedor,
          E.Nombre,
          CASE
            WHEN F.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
            ELSE F.SubTotal
          END AS TotalPedido,
          APD.IdMoneda,
          SV.TaxID AS RFC,
          CONCAT('Reference Num:', AP.ReferenceNumber),
          CASE
            WHEN E.IdEstatus = 2 THEN 'label label-success'
            WHEN E.IdEstatus = 1 THEN 'label label-primary'
            WHEN E.IdEstatus = 3 THEN 'label label-danger'
            WHEN E.IdEstatus IS NULL THEN 'label label-default'
          END,
          RC.PedirCarta,
          NULL,
          Contrato = c.NumeroContrato,
		  PO.SAPPONumber AS PO
        FROM MPY_MM_AceptacionFactura AS AF
        LEFT JOIN TA_Estatus AS E
          ON AF.IdEstatus=E.IdEstatus 
        LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP
          ON AF.IdAceptacionPedido=AP.IdAceptacionPedido
        LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD
          ON AP.IdAceptacionPedido=APD.IdAceptacionPedido 
        LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV
          ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS=SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
        LEFT JOIN S_Proveedor AS PR
          ON AP.IdSubContratista=PR.RFC  
          AND PR.Activo = 1
        LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES
          ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS=PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
          AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS=PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS 
        LEFT JOIN Adinco.dbo.CO_SAPSES AS SES
          ON PSES.SAPPONumber=SES.PO_SAPNumer 
          AND PSES.SAPSESNumber=SES.SESReferenceNumber
          AND PSES.SESN=SES.SESNumber 
        LEFT JOIN Adinco.dbo.CO_SAPPO AS PO
          ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS=PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
        LEFT JOIN dbo.FI_Factura AS F
          ON AF.IdFactura=F.IdFactura
        LEFT JOIN dbo.RelacionCartaCNPedido AS RC
          ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 
        INNER JOIN Adinco.dbo.CO_Contrato AS C
          ON SV.IdContrato=C.IdContrato 
        WHERE AF.IdEstatus = @Estatus
        AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
        AND PO.Plant = @PLANT
        AND AF.IdEstatusXML != 4
        AND AF.IdEstatusXML != 4
        GROUP BY AF.IdAceptacionPedido,
                 AP.IdPedido,
                 AF.CreadoEl,
                 PR.RazonSocial,
                 Pr.RegimenCapital,
                 E.Nombre,
                 AP.IdSubContratista,
                 PR.RFC,
                 APD.IdMoneda,
                 SV.TaxID,
                 SV.VendorName,
                 E.IdEstatus,
                 SES.SESNumber,
                 AP.ReferenceNumber,
                 PSES.IdPRESES,
                 F.SubTotal,
                 F.IdMoneda,
                 F.FechaTimbrado,
                 RC.PedirCarta,
                 c.IdContrato,
                 c.NumeroContrato,
				 PO.SAPPONumber
        ORDER BY AF.IdAceptacionPedido DESC
    END

  END;

  IF @Estatus = 0  --TODAS  
  BEGIN
    INSERT INTO #AceptacionesPedido
      SELECT
        AF.IdAceptacionPedido,
        PG.IdPedido,
        Pe.IdPedido,
        O.FechaRegistro,
        PR.RazonSocial + ' ' + ISNULL(Pr.RegimenCapital, '') AS Proveedor,-- 
        E.Nombre,
        SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido,---
        TM.TipoMonedaCorto AS Moneda,
        'RFC: ' + ISNULL(PR.RFC, 'SIN DATOS') + ' - UUID:' + ISNULL(fi.UUID, 'SIN DATOS'), --
        PE.IdSolicitudPedido,
        CASE
          WHEN E.IdEstatus = 2 THEN 'label label-success'
          WHEN E.IdEstatus = 1 THEN 'label label-primary'
          WHEN E.IdEstatus = 3 THEN 'label label-danger'
          WHEN E.IdEstatus IS NULL THEN 'label label-default'
        END,
        RC.PedirCarta,
        NULL,
        Contrato = c.NumeroContrato,
		ISNULL(RPO.PO,'Sin PO relacionada') AS PO
      FROM MM_AceptacionFactura AS AF
      JOIN TA_Operacion AS O
        ON AF.IdAceptacionFactura=O.IdDocumento   --AND O.IdProveedor = @IdProveedor   
        AND ISNULL(O.IdFlujoTarea, 0) <> 0
        AND O.IdTipoOperacion = 10
        AND O.IdOperacion NOT IN (SELECT
								  IdOperacion
								FROM #OperacionNoAprobadas)
      JOIN TA_Estatus AS E
        ON O.IdEstatusOperacion=E.IdEstatus
      JOIN MM_AceptacionPedido AS AP
        ON AF.IdAceptacionPedido=AP.IdAceptacionPedido 
      JOIN dbo.MM_AceptacionPedidoDetalle AS APD
        ON AP.IdAceptacionPedido=APD.IdAceptacionPedido 
      JOIN MM_Pedido AS PE
        ON AP.IdPedido=PE.IdPedido 
        AND O.IdProveedor=PE.IdSubcontratista  
        AND @IdProveedor = PE.IdProveedorCompras
      JOIN MM_PedidoDetalle AS PED
        ON PE.IdPedido=PED.IdPedido 
        AND APD.IdPedidoDetalle = PED.IdPedidoDetalle
      JOIN MM_Pedidos AS PG
        ON PE.IdPedido = PG.IdIdentificador
        AND @IdProveedor = PG.IdProveedorCliente
        AND PG.IdTipoPedido IN (2, 4, 6)-->	MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA
      JOIN S_Proveedor AS PR
        ON PE.IdSubcontratista=PR.IdProveedor  
      JOIN dbo.PV_TipoMoneda AS TM
        ON PE.IdMoneda=TM.IdMoneda
      JOIN dbo.FI_Factura AS fi
        ON AF.IdFactura=fi.IdFactura
      LEFT JOIN dbo.RelacionCartaCNPedido RC
        ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 
	  INNER JOIN Adinco.dbo.CO_Contrato AS C
        ON PE.IdContrato=C.IdContrato  
	  LEFT JOIN DEA_Relacion_PR_PO AS RPO	
		ON PE.IdPedido = RPO.IdPedido
      WHERE ISNULL(AF.IdEstatusEliminado, 0) <> 1
      GROUP BY AF.IdAceptacionPedido,
               Pe.IdPedido,
               O.FechaRegistro,
               PR.RazonSocial,
               Pr.RegimenCapital,
               E.Nombre,
               PG.IdPedido,
               TM.TipoMonedaCorto,
               PR.RFC,
               AF.IdEstatusEliminado,
               PE.IdSolicitudPedido,
               E.IdEstatus,
               fi.UUID,
               RC.PedirCarta,
               c.IdContrato,
               c.NumeroContrato,
			   RPO.PO
      ORDER BY AF.IdAceptacionPedido DESC;

    IF ISNULL(@PLANT, '') <> ''
    BEGIN

      INSERT INTO #AceptacionesPedido
        SELECT
          AF.IdAceptacionPedido,
          CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS nvarchar(100)) COLLATE Modern_Spanish_CI_AS),
          00,
          AF.CreadoEl,
          ISNULL(SV.VendorName, PR.RazonSocial) AS Proveedor,
          E.Nombre,
          CASE
            WHEN F.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
            ELSE F.SubTotal
          END AS TotalPedido,
          APD.IdMoneda,
          SV.TaxID AS RFC,
          CONCAT('Reference Num:', AP.ReferenceNumber),
          CASE
            WHEN E.IdEstatus = 2 THEN 'label label-success'
            WHEN E.IdEstatus = 1 THEN 'label label-primary'
            WHEN E.IdEstatus = 3 THEN 'label label-danger'
            WHEN E.IdEstatus IS NULL THEN 'label label-default'
          END,
          RC.PedirCarta,
          NULL,
          Contrato = c.NumeroContrato,
		  PO.SAPPONumber as PO
        FROM MPY_MM_AceptacionFactura AS AF
        LEFT JOIN TA_Estatus AS E
          ON AF.IdEstatus = E.IdEstatus
        LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP
          ON AF.IdAceptacionPedido=AP.IdAceptacionPedido 
        LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD
          ON AP.IdAceptacionPedido= APD.IdAceptacionPedido
        LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APCN
          ON AP.IdAceptacionPedido=APCN.IdAceptacionPedido 
          AND APCN.IdEstatus = 2
        LEFT JOIN S_Proveedor AS PR
          ON AP.IdSubContratista=PR.RFC
          AND PR.Activo = 1
        LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV
          ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS=SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
        LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES
          ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS=PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
          AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS=PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS 
        LEFT JOIN Adinco.dbo.CO_SAPSES AS SES
          ON PSES.SAPPONumber=SES.PO_SAPNumer 
          AND  PSES.SAPSESNumber=SES.SESReferenceNumber
          AND PSES.SESN=SES.SESNumber 
        LEFT JOIN Adinco.dbo.CO_SAPPO AS PO
          ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS=PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
        LEFT JOIN dbo.FI_Factura AS F
          ON AF.IdFactura=F.IdFactura 
        LEFT JOIN dbo.RelacionCartaCNPedido AS RC
          ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 
        INNER JOIN Adinco.dbo.CO_Contrato AS C
          ON SV.IdContrato=C.IdContrato 
        WHERE ISNULL(AF.IdEstatusEliminado, 0) <> 1
        AND PO.Plant = @PLANT
        AND AF.IdEstatusXML != 4
        AND AF.IdEstatusXML != 4
        GROUP BY AF.IdAceptacionPedido,
                 AP.IdPedido,
                 PR.RazonSocial,
                 PR.RegimenCapital,
                 E.Nombre,
                 PR.RFC,
                 AP.IdSubContratista,
         AF.IdEstatusEliminado,
                 AF.CreadoEl,
         SV.VendorName,
                 APD.IdMoneda,
                 SV.TaxID,
                 E.IdEstatus,
                 SES.SESNumber,
                 AP.ReferenceNumber,
                 PSES.IdPRESES,
                 F.SubTotal,
                 F.IdMoneda,
                 F.FechaTimbrado,
                 F.FechaTimbrado,
                 RC.PedirCarta,
                 c.IdContrato,
                 c.NumeroContrato,
				 PO.SAPPONumber
        ORDER BY AF.IdAceptacionPedido DESC;
    END

  END;

  IF @Estatus = 9 -- Facturas enviadas sin flujo de aprobación  
  BEGIN
    INSERT INTO #AceptacionesPedido
      SELECT
        AF.IdAceptacionPedido,
        PG.IdPedido,
        Pe.IdPedido,
        O.FechaRegistro,
        PR.RazonSocial + ' ' + ISNULL(Pr.RegimenCapital, '') AS Proveedor,
        E.Nombre,
        SUM(APD.Cantidad * PED.PrecioUnitario) AS TotalPedido,
        TM.TipoMonedaCorto AS Moneda,
        'RFC: ' + ISNULL(PR.RFC, 'SIN DATOS') + ' - UUID:' + ISNULL(fi.UUID, 'SIN DATOS'),
        PE.IdSolicitudPedido,
        CASE
          WHEN E.IdEstatus = 2 THEN 'label label-success'
          WHEN E.IdEstatus = 1 THEN 'label label-primary'
          WHEN E.IdEstatus = 3 THEN 'label label-danger'

          WHEN E.IdEstatus IS NULL THEN 'label label-default'
        END,
        RC.PedirCarta,
        O.IdOperacion,
        Contrato = c.NumeroContrato,
		ISNULL(RPO.PO,'Sin PO relacionada') AS PO
      FROM MM_AceptacionFactura AS AF
      JOIN TA_Operacion AS O
        ON AF.IdAceptacionFactura=O.IdDocumento --AND O.IdProveedor = @IdProveedor  
        AND O.IdTipoOperacion = 10
        AND O.IdEstatusOperacion = @Estatus
        AND ISNULL(o.IdEstadoFlujo, 0) = 0
      JOIN TA_Estatus AS E
        ON O.IdEstatusOperacion= E.IdEstatus
      JOIN MM_AceptacionPedido AS AP
        ON AF.IdAceptacionPedido=AP.IdAceptacionPedido 
      JOIN MM_Pedido AS PE
        ON AP.IdPedido=PE.IdPedido 
        AND O.IdProveedor= PE.IdSubcontratista
        AND PE.IdProveedorCompras = @IdProveedor
      JOIN MM_PedidoDetalle AS PED
        ON PE.IdPedido=PED.IdPedido 
      JOIN dbo.MM_AceptacionPedidoDetalle AS APD
        ON AP.IdAceptacionPedido=APD.IdAceptacionPedido 
        AND PED.IdPedidoDetalle=APD.IdPedidoDetalle
      JOIN MM_Pedidos AS PG
        ON PE.IdPedido = PG.IdIdentificador
        AND PG.IdTipoPedido IN (2, 4, 6) --> MERCADEO, ADJUDICACIÓN DIRECTA, CONTROL DE OBRA
        AND PG.IdProveedorCliente = @IdProveedor
      JOIN S_Proveedor AS PR
        ON PE.IdSubcontratista=PR.IdProveedor  
      JOIN dbo.PV_TipoMoneda AS TM
        ON PE.IdMoneda=TM.IdMoneda
      JOIN dbo.MM_TipoPedido AS TP
        ON PG.IdTipoPedido=TP.IdTipoPedido
      JOIN dbo.FI_Factura AS fi
        ON AF.IdFactura=fi.IdFactura 
      JOIN dbo.RelacionCartaCNPedido RC
        ON AP.IdAceptacionPedido=RC.IdAceptacionPedido 
      INNER JOIN Adinco.dbo.CO_Contrato AS C
        ON PE.IdContrato=C.IdContrato 
	  LEFT JOIN DEA_Relacion_PR_PO AS RPO	
		ON PE.IdPedido = RPO.IdPedido
      WHERE ISNULL(AF.IdEstatusEliminado, 0) <> 1
      GROUP BY AF.IdAceptacionPedido,
               Pe.IdPedido,
               O.FechaRegistro,
               PR.RazonSocial,
               Pr.RegimenCapital,
               E.Nombre,
               PG.IdPedido,
               TP.TipoPedido,
               TM.TipoMonedaCorto,
               PR.RFC,
               PE.IdSolicitudPedido,
               E.IdEstatus,
               fi.UUID,
               O.IdOperacion,
               RC.PedirCarta,
               c.IdContrato,
               c.NumeroContrato,
			   RPO.PO
      ORDER BY AF.IdAceptacionPedido DESC;

    IF ISNULL(@PLANT, '') = ''
    BEGIN
      INSERT INTO #AceptacionesPedido
        SELECT
          AF.IdAceptacionPedido,
          CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS, ' ', '- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS, ' - Proforma Number:', CAST(PSES.IdPRESES AS nvarchar(100)) COLLATE Modern_Spanish_CI_AS),
          00,
          AF.CreadoEl,
   ISNULL(SV.VendorName, AP.IdSubContratista) AS Proveedor,
          E.Nombre,
          CASE
            WHEN F.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal, F.FechaTimbrado)
            ELSE F.SubTotal
          END AS TotalPedido,
          APD.IdMoneda,
          SV.TaxID AS RFC,
          CONCAT('Reference Num:', AP.ReferenceNumber),

          CASE
            WHEN E.IdEstatus = 2 THEN 'label label-success'
            WHEN E.IdEstatus = 1 THEN 'label label-primary'
            WHEN E.IdEstatus = 3 THEN 'label label-danger'

            WHEN E.IdEstatus IS NULL THEN 'label label-default'
          END,
          RC.PedirCarta,
          NULL,
          Contrato = c.NumeroContrato,
		  PO.SAPPONumber AS PO
        FROM MPY_MM_AceptacionFactura AS AF
        LEFT JOIN TA_Estatus AS E
          ON E.IdEstatus = AF.IdEstatus
        LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP
          ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
        LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD
          ON AP.IdAceptacionPedido = APD.IdAceptacionPedido
        LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV
          ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS
        LEFT JOIN S_Proveedor AS PR
          ON AP.IdSubContratista = PR.RFC
          AND PR.Activo = 1
        LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES
          ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
          AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS
        LEFT JOIN Adinco.dbo.CO_SAPSES AS SES
          ON PSES.SAPPONumber = SES.PO_SAPNumer
          AND PSES.SAPSESNumber = SES.SESReferenceNumber
          AND PSES.SESN = SES.SESNumber
        LEFT JOIN Adinco.dbo.CO_SAPPO AS PO
          ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS
        LEFT JOIN dbo.FI_Factura AS F
          ON AF.IdFactura = F.IdFactura
        LEFT JOIN dbo.RelacionCartaCNPedido AS RC
          ON AP.IdAceptacionPedido = RC.IdAceptacionPedido
        INNER JOIN Adinco.dbo.CO_Contrato AS C
          ON SV.IdContrato = c.IdContrato
        WHERE AF.IdEstatus = @Estatus
        AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
        AND PO.Plant = @PLANT
        AND AF.IdEstatusXML != 4
        AND AF.IdEstatusXML != 4
        GROUP BY AF.IdAceptacionPedido,
                 AP.IdPedido,
                 AF.CreadoEl,
                 PR.RazonSocial,
                 Pr.RegimenCapital,
                 E.Nombre,
                 AP.IdSubContratista,
                 PR.RFC,
                 APD.IdMoneda,
                 SV.TaxID,

                 SV.VendorName,
                 E.IdEstatus,
                 SES.SESNumber,
                 AP.ReferenceNumber,
                 PSES.IdPRESES,
                 F.SubTotal,
                 F.IdMoneda,
                 F.FechaTimbrado,
                 RC.PedirCarta,
                 c.IdContrato,
                 c.NumeroContrato,
				 PO.SAPPONumber
        ORDER BY AF.IdAceptacionPedido DESC
    END
  END;

  --CONSULTAR TODOS LOS RESULTADOS
  SELECT
    ROW_NUMBER() OVER (
    ORDER BY FechaRegistro DESC) AS IdRow,
    IdAceptacionPedido,
    Pedido,
    IdPedido,
    FechaRegistro,
    Proveedor,
    Nombre,
    TotalPedido,
    Moneda,
    RFC,
    IdSolicitudPedido,
    span,
    CASE
      WHEN ISNULL(PedirCarta, 0) = 1 THEN 'Si'
      ELSE 'No'
    END AS PedirCarta,
    IdOperacion,
    Contrato,
	PO
  FROM #AceptacionesPedido
  GROUP BY IdAceptacionPedido,
           Pedido,
           IdPedido,
           FechaRegistro,
           Proveedor,
           Nombre,
           TotalPedido,
           Moneda,
           RFC,
           IdSolicitudPedido,
           span,
           PedirCarta,
           IdOperacion,
           Contrato,
		   PO
  ORDER BY FechaRegistro DESC;
END;
