CREATE VIEW dbo.ConsultaFacturasJEYP
AS
	SELECT
		F.IdFactura, S.RazonSocial, S.RFC, F.Serie, F.Folio, F.SubTotal, F.Moneda, F.MontoConIva, F.UUID, C.NumeroContrato, 
		F.FechaTimbrado, ISNULL(GR.Descripcion,'') AS Rubro, ISNULL(CCSH.Descripcion,'') AS [Catalogo Bienes/Servicios Sector Hidrocarburos],
		CONVERT(DATE,T.FechaPago) AS [Fecha Transferencia],
		CONVERT(DATE,F.Fecha) AS [Fecha para Reporte],
		CASE WHEN FP.IdFactura IS NOT NULL AND ACP.IdEstatus = 2
                    AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
            THEN 'Si tiene carta'
            WHEN DADA.IdDocAdinco IS NOT NULL
            THEN 'Si tiene carta'
            ELSE 'NO TIENE CARTA'
        END AS CartaContenidoNacional,
		R.PCN AS [PCN],
		PG.IdPedido	AS [Pedido],
		ISNULL(SOLPED.MotivoUrgencia,'')	AS [Motivo]
	FROM
		FI_Factura	F	(NOLOCK)
	JOIN
		PV_Subcontratista	S (NOLOCK)
		ON	F.Emisor	=	S.RFC
	JOIN
		CO_Contrato	C	(NOLOCK)
		ON F.IdContrato = C.IdContrato
	LEFT JOIN
		CO_Registro	R	(NOLOCK)
		ON	F.IdFactura = R.IdFactura
	LEFT JOIN
		CO_GastosRubro	GR	(NOLOCK)
		ON	R.IdGastoRubro	=	GR.IdGastoRubro
	LEFT JOIN
		CO_CatalogoCuentaSH	CCSH	(NOLOCK)
		ON	R.IdCatalogoCuentasSH	=	CCSH.IdCatalogoCuentasSH
	LEFT JOIN
		FI_TransferFactura	TF	(NOLOCK)
		ON	F.IdFactura	=	TF.IdFactura
	LEFT JOIN
		FI_Transfer		T	(NOLOCK)
		ON	TF.IdTransfer	=	T.IdTransferencia
	LEFT JOIN 
		dbo.AWS_DocAwsDocAdinco		DADA (NOLOCK) 
		ON F.IdFactura = DADA.IdDocAdinco
	LEFT JOIN 
		Petrovendor.dbo.FI_Factura FP	(NOLOCK)
		ON F.UUID = FP.UUID COLLATE DATABASE_DEFAULT
        AND FP.UUID IS NOT NULL
        AND FP.Activa = 1
        AND ISNULL(FP.IsEliminado, 0) <> 1
	LEFT JOIN
		Petrovendor.dbo.MM_AceptacionFactura	AF	(NOLOCK)
		ON FP.IdFactura	=	AF.IdFactura
	LEFT JOIN
		Petrovendor.dbo.MM_AceptacionPedido	AP	(NOLOCK)
		ON	AF.IdAceptacionPedido	=	AP.IdAceptacionPedido
	LEFT JOIN
		Petrovendor.dbo.MM_AceptacionCartaPCN	ACP	(NOLOCK)
		ON	AP.IdAceptacionPedido	=	ACP.IdAceptacionPedido
        AND ACP.IdEstatus = 2
        AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
	LEFT JOIN
		Petrovendor.dbo.MM_Pedidos AS PG (NOLOCK)
		ON AP.IdPedido = PG.IdIdentificador
		AND PG.IdProveedorCliente IN (606, 690, 1835)
	LEFT JOIN
		Petrovendor.dbo.MM_Pedido AS P (NOLOCK)
		on	PG.IdIdentificador	=	P.IdPedido
	LEFT JOIN
		Petrovendor.dbo.MM_SolicitudPedido	SOLPED	(NOLOCK)
		ON	P.IdSolicitudPedido	=	SOLPED.IdSolicitudPedido
	WHERE
		F.Receptor = 'JSE1601292U8'
	GROUP BY
		F.IdFactura, S.RazonSocial, S.RFC, F.Serie, F.Folio, F.SubTotal, F.Moneda, F.MontoConIva, F.UUID, C.NumeroContrato, 
		F.FechaTimbrado, ISNULL(GR.Descripcion,''), ISNULL(CCSH.Descripcion,''),
		CONVERT(DATE,T.FechaPago),
		CONVERT(DATE,F.Fecha),
		CASE WHEN FP.IdFactura IS NOT NULL AND ACP.IdEstatus = 2
                    AND ISNULL(ACP.IdEstatusEliminado, 0) <> 1
            THEN 'Si tiene carta'
            WHEN DADA.IdDocAdinco IS NOT NULL
            THEN 'Si tiene carta'
            ELSE 'NO TIENE CARTA'
        END,
		R.PCN,
		PG.IdPedido,
		ISNULL(SOLPED.MotivoUrgencia,'')
