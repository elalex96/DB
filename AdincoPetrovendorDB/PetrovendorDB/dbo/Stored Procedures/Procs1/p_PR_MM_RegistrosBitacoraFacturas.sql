CREATE PROCEDURE p_PR_MM_RegistrosBitacoraFacturas
	@IdProveedor int,
	@Estatus int ,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
as
begin
	SET NOCOUNT ON;

	DECLARE @IDCONTRATO2 INT = (SELECT TOP 1
								C.IdContrato
								FROM Adinco.dbo.CO_Contrato AS C
								LEFT JOIN Adinco.dbo.CO_Contratista AS CON ON CON.IdContratista  = C.IdContratista
								LEFT JOIN dbo.S_Proveedor AS PR ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = CON.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
								WHERE PR.IdProveedor = @IdProveedor);

	DECLARE @PLANT NVARCHAR(10) = (SELECT TOP 1
										P.Planta
										FROM Adinco.dbo.CO_Contrato AS C
										LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS P ON P.IdContratista = C.IdContratista
										WHERE C.IdContrato = @IDCONTRATO2)

	--IF(ISNULL(@IdContrato,0) = 0)
	--BEGIN
	--	SET @IdContrato = 10039;
	--END

	DECLARE @PROVEDORRFC NVARCHAR(20) = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);

	DECLARE @IDCONTRATISTA NVARCHAR(50) = (SELECT IdContratista FROM Adinco.dbo.CO_Contratista WHERE RFC = @PROVEDORRFC);
	DECLARE @FlujoSerial TABLE
    (
        IdOperacion INT,
        NoSecuencia INT
    );
    DECLARE @OperacionNoAprobadas TABLE (IdOperacion INT);

    INSERT INTO @FlujoSerial
    (
        IdOperacion,
        NoSecuencia
    )
    SELECT O.IdOperacion,
           t.NoSecuencia
    FROM dbo.TA_Operacion O
		INNER JOIN dbo.MM_AceptacionFactura af ON af.IdAceptacionFactura = o.IdDocumento
		INNER JOIN MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN MM_Pedido AS PE ON PE.IdPedido = AP.IdPedido 
        INNER JOIN dbo.TA_Tarea t
            ON t.IdOperacion = O.IdOperacion
    WHERE O.IdTipoOperacion = 10
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1
          AND t.IdAprobador = @IdUsuario
          AND t.NoSecuencia > 1
		  AND PE.IdProveedorCompras = @IdProveedor

    INSERT INTO @OperacionNoAprobadas
    (
        IdOperacion
    )
    SELECT O.IdOperacion
    FROM dbo.TA_Operacion O
        INNER JOIN @FlujoSerial f
            ON f.IdOperacion = O.IdOperacion
        INNER JOIN dbo.TA_Tarea T
            ON T.IdOperacion = O.IdOperacion
               AND T.NoSecuencia = (f.NoSecuencia - 1)
    WHERE O.IdTipoOperacion = 10
          AND T.IdEstatus <> 2;

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
	span NVARCHAR(100) NULL
	);
	
	

	 IF @Estatus=0  --TODAS
	 BEGIN
	
		INSERT INTO #AceptacionesPedido
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
		END
		FROM MPY_MM_AceptacionFactura AS AF
		inner join MPY_MM_AceptacionFactura_Bitacora afb on afb.IdAceptacionFactura = af.IdAceptacionFactura
				LEFT JOIN TA_Estatus AS E ON E.IdEstatus = AFB.IdEstatus
				LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APCN ON APCN.IdAceptacionPedido = AP.IdAceptacionPedido AND APCN.IdEstatus = 2
				LEFT JOIN S_Proveedor AS PR ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
				LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN Adinco.dbo.CO_SAPSES AS SES ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
				LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN dbo.FI_Factura AS F ON F.IdFactura = AF.IdFactura
		WHERE 
		pO.Plant = @PLANT
		
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
			F.FechaTimbrado
		ORDER BY AF.IdAceptacionPedido DESC
     END 

	 IF exists (SELECT 1 FROM #AceptacionesPedido)
	 begin
		SELECT 1 AS 'RESULT'
	 end
	 ELSE
	 BEGIN
		SELECT 0 AS 'RESULT'
	 END
end
