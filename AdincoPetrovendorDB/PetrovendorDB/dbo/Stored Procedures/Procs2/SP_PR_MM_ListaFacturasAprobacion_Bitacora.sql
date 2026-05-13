use Petrovendor
go
drop procedure if exists SP_PR_MM_ListaFacturasAprobacion_Bitacora
go
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-02-2023
-- Description:	Se muestra UUID Y FOLIO FACTURA CONSULTAS MURPHY
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 26-06-2023
-- Description:	Se agrega columnas uuid, folio factura y fecha de timbrado
-- =============================================
-- =============================================
-- Author:		Luis David
-- Create date: 04-08-2023
-- Description:	Se agrega filtros de fecha general para evitar timeout por exceso de datos
-- =============================================
CREATE   PROCEDURE [dbo].[SP_PR_MM_ListaFacturasAprobacion_Bitacora]
	@IdProveedor int,
	@Estatus int ,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null,
	@FechaInicio datetime,
	@FechaFin datetime 
AS
BEGIN
	 
	SET NOCOUNT ON;

	CREATE TABLE #AceptacionesPedido(
	IdAceptacionPedido INT null,
	Pedido NVARCHAR(max) null,
	IdPedido INT null,
	FechaRegistro DATETIME null,
	Proveedor NVARCHAR(100) null,
	Nombre NVARCHAR(100) null,
	IdPedidoGeneral INT null,
	TipoPedido NVARCHAR(MAX) null,
	TotalPedido MONEY NULL,
	Moneda NVARCHAR(100) null,
	RFC NVARCHAR(100) null,
	IdSolicitudPedido NVARCHAR(100) NULL,
	span NVARCHAR(100) NULL,
	Contrato varchar(50),
	FolioFactura		nvarchar(200)	NULL,
	UUID				nvarchar(100)	NULL,
	FechaTimbrado		datetime		NULL
	);

	DECLARE @FlujoSerial TABLE
    (
        IdOperacion INT,
        NoSecuencia INT
    );
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);

	DECLARE @IDCONTRATO2 INT = (SELECT TOP 1
								C.IdContrato
								FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)
								LEFT JOIN Adinco.dbo.CO_Contratista AS CON  (NOLOCK)
									ON C.IdContratista = CON.IdContratista   
								LEFT JOIN dbo.S_Proveedor AS PR  (NOLOCK)
									ON CON.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS 
								WHERE PR.IdProveedor = @IdProveedor);

	DECLARE @PLANT NVARCHAR(10) = (SELECT TOP 1
										P.Planta
										FROM Adinco.dbo.CO_Contrato AS C  (NOLOCK)
										LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS P  (NOLOCK)
											ON C.IdContratista = P.IdContratista
										WHERE C.IdContrato = @IDCONTRATO2)


	DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor  (NOLOCK) WHERE IdProveedor = @IdProveedor);

	DECLARE @IDCONTRATISTA NVARCHAR(50) = (SELECT IdContratista FROM Adinco.dbo.CO_Contratista  (NOLOCK) WHERE RFC = @PROVEDORRFC);


    INSERT INTO @FlujoSerial
    (
        IdOperacion,
        NoSecuencia
    )
    SELECT O.IdOperacion,
           t.NoSecuencia
    FROM dbo.TA_Operacion O  (NOLOCK)
		JOIN dbo.MM_AceptacionFactura af  (NOLOCK)
			ON o.IdDocumento = af.IdAceptacionFactura 
		JOIN MM_AceptacionPedido AS AP  (NOLOCK)
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
		JOIN MM_Pedido AS PE  (NOLOCK)
			ON AP.IdPedido  = PE.IdPedido
        JOIN dbo.TA_Tarea t  (NOLOCK)
            ON  O.IdOperacion = t.IdOperacion
    WHERE O.IdTipoOperacion = 10 -->cte 
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1 -->cte 
          AND t.IdAprobador = @IdUsuario 
          AND t.NoSecuencia > 1 -->cte 
		  AND PE.IdProveedorCompras = @IdProveedor

    INSERT INTO @OperacionNoAprobadas
    (
        IdOperacion
    )
    SELECT O.IdOperacion
    FROM dbo.TA_Operacion O  (NOLOCK)
        INNER JOIN @FlujoSerial f
            ON O.IdOperacion =f.IdOperacion 
        INNER JOIN dbo.TA_Tarea T  (NOLOCK)
            ON  O.IdOperacion = T.IdOperacion
               AND T.NoSecuencia = (f.NoSecuencia - 1)
    WHERE O.IdTipoOperacion = 10 -->cte 
          AND T.IdEstatus <> 2; -->cte

	 IF @Estatus=0  --TODAS
	 BEGIN
	
		INSERT INTO #AceptacionesPedido(
		IdAceptacionPedido,
		Pedido,
		IdPedido,
		FechaRegistro,
		Proveedor,
		Nombre,
		IdPedidoGeneral,
		TipoPedido,
		TotalPedido,
		Moneda,
		RFC,
		IdSolicitudPedido,
		span,
		Contrato,
		UUID,
		FolioFactura,
		FechaTimbrado)
		SELECT 
		AF.IdAceptacionPedido,
		CONCAT('PO Number:', AP.IdPedido COLLATE Modern_Spanish_CI_AS,' ','- SES Number: ', SES.SESNumber COLLATE Modern_Spanish_CI_AS ,' - Proforma Number:', CAST(PSES.IdPRESES AS NVARCHAR(100)) COLLATE Modern_Spanish_CI_AS),
		00,
		AFB.CreadoEl, 
		ISNULL(SV.VendorName,PR.RazonSocial) As Proveedor, 		
		E.Nombre,
		00,
		00,
		CASE
			WHEN F.IdMoneda = 1 THEN dbo.FN_PesosDolaresTipoCambio(F.SubTotal,F.FechaTimbrado)
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
		Contrato = c.NumeroContrato,
		F.UUID,
		CONCAT(ISNULL(F.Serie,''),(CASE WHEN LEN(RTRIM(LTRIM(ISNULL(F.Serie,''))))>0 AND LEN(RTRIM(LTRIM(ISNULL(F.Folio,'')))) >0 THEN '-' END), ISNULL(F.Folio,'')) AS FolioFactura,
		F.FechaTimbrado
		FROM MPY_MM_AceptacionFactura AS AF  (NOLOCK)
		JOIN MPY_MM_AceptacionFactura_Bitacora afb   (NOLOCK)
			on af.IdAceptacionFactura = afb.IdAceptacionFactura 
		LEFT JOIN TA_Estatus AS E  (NOLOCK)
			ON AFB.IdEstatus = E.IdEstatus 
		LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP  (NOLOCK)
			ON AF.IdAceptacionPedido = AP.IdAceptacionPedido 
		LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD  (NOLOCK)
			ON AP.IdAceptacionPedido = APD.IdAceptacionPedido 
		LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APCN  (NOLOCK)
			ON AP.IdAceptacionPedido = APCN.IdAceptacionPedido 
			AND APCN.IdEstatus = 2 -->CTE
		LEFT JOIN S_Proveedor AS PR  (NOLOCK)
			ON AP.IdSubContratista  = PR.RFC  
			AND PR.Activo = 1-->CTE
		LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV  (NOLOCK)
			ON AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS = SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS 
		LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES  (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
			AND AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS = PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS 
		LEFT JOIN Adinco.dbo.CO_SAPSES AS SES  (NOLOCK)
			ON PSES.SAPPONumber  = SES.PO_SAPNumer 
			AND PSES.SAPSESNumber  = SES.SESReferenceNumber 
			AND PSES.SESN = SES.SESNumber 
		LEFT JOIN Adinco.dbo.CO_SAPPO AS PO  (NOLOCK)
			ON AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS = PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS 
		LEFT JOIN dbo.FI_Factura AS F  (NOLOCK)
			ON AF.IdFactura = F.IdFactura 
		JOIN	Adinco.dbo.CO_Contrato	AS	C 	 (NOLOCK)
			ON	SV.IdContrato = C.IdContrato
		WHERE 
		pO.Plant = @PLANT	
		and afb.CreadoEl BETWEEN @FechaInicio AND @FechaFin
	    GROUP BY AF.IdAceptacionPedido,
			AP.IdPedido,
			PR.RazonSocial,
			Pr.RegimenCapital, 
			E.Nombre,
			PR.RFC,
			AP.IdSubContratista,
			AF.IdEstatusEliminado,
			AFB.CreadoEl,
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
			F.Folio,
			F.Serie,
			F.UUID,
			c.NumeroContrato,
			c.IdContrato
		ORDER BY AF.IdAceptacionPedido DESC
     END 

	 SELECT
		ROW_NUMBER() OVER(ORDER BY FechaRegistro DESC) AS IdRow,
		IdAceptacionPedido,
		Pedido,
		IdPedido,
		FechaRegistro,
		Proveedor,
		Nombre,
		IdPedidoGeneral,
		TipoPedido,
		TotalPedido,
		Moneda,
		RFC,
		IdSolicitudPedido,
		span,
		Contrato,
		UUID,
		FolioFactura,
		FechaTimbrado
	 FROM #AceptacionesPedido 
	 ORDER BY FechaRegistro DESC;
END
