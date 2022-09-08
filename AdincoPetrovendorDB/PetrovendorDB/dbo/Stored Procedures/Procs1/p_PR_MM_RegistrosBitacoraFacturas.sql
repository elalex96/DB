USE [Petrovendor]
GO
/****** Object:  StoredProcedure [dbo].[p_PR_MM_RegistrosBitacoraFacturas]    Script Date: 08/09/2022 05:40:16 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
ALTER PROCEDURE [dbo].[p_PR_MM_RegistrosBitacoraFacturas]
	@IdProveedor int,
	@Estatus int ,	
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
as
begin
	SET NOCOUNT ON;

	DECLARE @IDCONTRATO2	INT,
			@PLANT			NVARCHAR(10),
			@PROVEDORRFC	NVARCHAR(20),
			@IDCONTRATISTA	NVARCHAR(50);

	create table #FlujoSerial
    (
        IdOperacion INT,
        NoSecuencia INT
    );

	CREATE TABLE #AceptacionesPedido
	(
		IdAceptacionPedido	INT				null,
		Pedido				NVARCHAR(max)	null,
		IdPedido			INT				null,
		FechaRegistro		DATETIME		null,
		Proveedor			NVARCHAR(100)	null,
		Nombre				NVARCHAR(100)	null,
		IdPedidoGeneral		INT				null,
		TipoPedido			NVARCHAR(MAX)	null,
		TotalPedido			MONEY			NULL,
		Moneda				NVARCHAR(100)	null,
		RFC					NVARCHAR(100)	null,
		IdSolicitudPedido	NVARCHAR(100)	NULL,
		span				NVARCHAR(100)	NULL
	);

	 select	@IDCONTRATO2	=	(SELECT TOP 1
								C.IdContrato
								FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)
								LEFT JOIN Adinco.dbo.CO_Contratista AS CON (NOLOCK) ON CON.IdContratista  = C.IdContratista
								LEFT JOIN dbo.S_Proveedor AS PR (NOLOCK) ON PR.RFC COLLATE SQL_Latin1_General_CP1_CI_AS = CON.RFC COLLATE SQL_Latin1_General_CP1_CI_AS
								WHERE PR.IdProveedor = @IdProveedor)

	select @PLANT			= (SELECT TOP 1
										P.Planta
										FROM Adinco.dbo.CO_Contrato AS C (NOLOCK)
										LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS P (NOLOCK) ON P.IdContratista = C.IdContratista
										WHERE C.IdContrato = @IDCONTRATO2);

	select	@PROVEDORRFC  = (SELECT RFC FROM dbo.S_Proveedor WHERE IdProveedor = @IdProveedor);

	select	@IDCONTRATISTA = (SELECT IdContratista FROM Adinco.dbo.CO_Contratista (NOLOCK) WHERE RFC = @PROVEDORRFC);

    INSERT INTO #FlujoSerial
    (
        IdOperacion,
        NoSecuencia
    )
    SELECT O.IdOperacion,
           t.NoSecuencia
    FROM dbo.TA_Operacion O (NOLOCK)
		INNER JOIN dbo.MM_AceptacionFactura af (NOLOCK) ON af.IdAceptacionFactura = o.IdDocumento
		AND O.IdTipoOperacion = 10
		AND ISNULL(O.IdEstatusEliminado, 0) <> 1
		INNER JOIN MM_AceptacionPedido AS AP (NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
		INNER JOIN MM_Pedido AS PE (NOLOCK) ON PE.IdPedido = AP.IdPedido 
        INNER JOIN dbo.TA_Tarea t (NOLOCK)
            ON t.IdOperacion = O.IdOperacion
    WHERE O.IdTipoOperacion = 10
          AND ISNULL(O.IdEstatusEliminado, 0) <> 1
          AND t.IdAprobador = @IdUsuario
          AND t.NoSecuencia > 1
		  AND PE.IdProveedorCompras = @IdProveedor
	
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
		FROM MPY_MM_AceptacionFactura AS AF (NOLOCK)
		INNER JOIN MPY_MM_AceptacionFactura_Bitacora afb (NOLOCK) on afb.IdAceptacionFactura = af.IdAceptacionFactura
				LEFT JOIN TA_Estatus AS E (NOLOCK) ON E.IdEstatus = AFB.IdEstatus
				LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP (NOLOCK) ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionPedidoDetalle AS APD (NOLOCK) ON APD.IdAceptacionPedido = AP.IdAceptacionPedido
				LEFT JOIN dbo.MPY_MM_AceptacionCartaPCN AS APCN (NOLOCK) ON APCN.IdAceptacionPedido = AP.IdAceptacionPedido AND APCN.IdEstatus = 2
				LEFT JOIN S_Proveedor AS PR (NOLOCK) ON PR.RFC = AP.IdSubContratista AND PR.Activo = 1
				LEFT JOIN Adinco.dbo.CO_SAPVendor AS SV (NOLOCK) ON SV.VendorIDSAP COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdSubContratista COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN Adinco.dbo.CO_SAPPRESES AS PSES (NOLOCK) ON PSES.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS AND PSES.SAPSESNumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.ReferenceNumber COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN Adinco.dbo.CO_SAPSES AS SES (NOLOCK) ON SES.PO_SAPNumer = PSES.SAPPONumber AND SES.SESReferenceNumber = PSES.SAPSESNumber AND SES.SESNumber = PSES.SESN
				LEFT JOIN Adinco.dbo.CO_SAPPO AS PO (NOLOCK) ON PO.SAPPONumber COLLATE SQL_Latin1_General_CP1_CI_AS = AP.IdPedido COLLATE SQL_Latin1_General_CP1_CI_AS
				LEFT JOIN dbo.FI_Factura AS F (NOLOCK) ON F.IdFactura = AF.IdFactura
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

	 IF exists (SELECT 1 FROM #AceptacionesPedido)
	 begin
		SELECT 1 AS 'RESULT'
	 end
	 ELSE
	 BEGIN
		SELECT 0 AS 'RESULT'
	 END
end
