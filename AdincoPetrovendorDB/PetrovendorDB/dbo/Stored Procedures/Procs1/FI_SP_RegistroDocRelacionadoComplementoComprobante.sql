
-- =============================================
-- Author:		<Jose Roman>
-- Create date: <12-06-2018>
-- Description:	<Registro de un documento relacionado>
-- Create date: <03-12-2018>
-- Description:	<Se agrega el guardado de la relacion de factura y complemento de pago>
-- Create date: <07-02-2018>
-- Description:	<Se agrega el envio del comprobante a Adinco>
-- =============================================
-- =============================================
-- Author:   Daniel AC
-- Create date: 01/10/2019
-- Description:   Se removio insertado de registros de Adinco 
-- =============================================

CREATE procedure [dbo].[FI_SP_RegistroDocRelacionadoComplementoComprobante]
	@IdComplementoDePago INT,
	@IdDocumento NVARCHAR(max),
	@Serie NVARCHAR(50),
	@Folio NVARCHAR(50),
	@MetodoDePagoDR NVARCHAR(50),
	@MonedaDR NVARCHAR(50),
	@ImpSaldoAnt MONEY,
	@ImpSaldoInsoluto MONEY,
	@ImpPagado MONEY,
	@NumParcialidad INT,
	@TipoDeCambioDR FLOAT,
	@IdFacturaComplemento INT,
	@IdComplementoAdinco INT = NULL,
	/*--------------------parametros contrato  --------------------*/
    @IdContrato    INT = null,
    @IdUsuario     INT = null,
    @FechaRegistro DATETIME = null
	/*-------------------------------------------------------------*/
AS
BEGIN
	DECLARE @IdFactura INT,
		@IdDocRelacionado INT,
		@IdDocRelacionadoAdinco INT
	DECLARE @SUBCONTRATISTARFC NVARCHAR(50);
	DECLARE @IDSUBCONTRATISTAPETRO INT;

	SET @IdFactura = (SELECT TOP 1
							IdFactura 
						FROM dbo.FI_Factura 
						WHERE UUID = @IdDocumento AND Activa = 1
						AND ISNULL(IsEliminado,0) = 0
						ORDER BY IdFactura DESC);

	SET @IdContrato = (SELECT TOP 1
									SP.IdContrato
								FROM dbo.MM_AceptacionFactura AS AF
								LEFT JOIN dbo.MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
								LEFT JOIN dbo.MM_Pedido AS P ON P.IdPedido = AP.IdPedido
								LEFT JOIN dbo.MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = P.IdSolicitudPedido
								WHERE AF.IdFactura = @IdFactura);

	DECLARE @IDCONTRATOMPY INT = (SELECT TOP 1
										CO.IdContrato
									FROM dbo.MPY_MM_AceptacionFactura AS AF
									LEFT JOIN dbo.MPY_MM_AceptacionPedido AS AP ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
									LEFT JOIN Adinco.dbo.CO_SAPPO AS PO ON PO.SAPPONumber COLLATE Modern_Spanish_CI_AS = AP.IdPedido COLLATE Modern_Spanish_CI_AS
									LEFT JOIN Adinco.dbo.CO_SAPContratista_Planta AS PC ON PC.Planta = PO.Plant
									LEFT JOIN Adinco.dbo.CO_Contrato AS CO ON CO.IdContratista = PC.IdContratista
									WHERE AF.IdFactura = @IdFactura
									GROUP BY CO.IdContrato);

	SET @SUBCONTRATISTARFC = (SELECT TOP 1
									Emisor 
								FROM dbo.FI_Factura 
								WHERE UUID = @IdDocumento AND Activa = 1
								AND ISNULL(IsEliminado,0) = 0
								ORDER BY Emisor DESC);


	SET @IDSUBCONTRATISTAPETRO = (SELECT TOP 1 
										IdProveedor 
									FROM dbo.S_Proveedor 
									WHERE RFC = @SUBCONTRATISTARFC AND Activo = 1);
	
		UPDATE dbo.FI_Factura
		SET IdContrato = ISNULL(@IdContrato,@IDCONTRATOMPY),
			IdSubcontratista = @IDSUBCONTRATISTAPETRO
		WHERE IdFactura = @IdFacturaComplemento

		--UPDATE Adinco.dbo.FI_Factura
		--SET IdContrato = ISNULL(@IdContrato,@IDCONTRATOMPY),
		--	IdSubcontratista = @IDSUBCONTRATISTAADINCO
		--WHERE IdFactura = @IdFacturaAdinco


	--Registro en petrovendor
	INSERT into dbo.FI_CPDocRelacionado
	(
	    IdComplementoDePago,
	    IdDocumento,
	    Serie,
	    Folio,
	    MetodoDePagoDR,
	    MonedaDR,
	    ImpSaldoAnt,
	    ImpSaldoInsoluto,
	    ImpPagado,
	    NumParcialidad,
	    TipoDeCambioDR
	)
	VALUES
	(   @IdComplementoDePago,
		@IdDocumento,
		@Serie,
		@Folio,
		@MetodoDePagoDR,
		@MonedaDR,
		@ImpSaldoAnt,
		@ImpSaldoInsoluto,
		@ImpPagado,
		@NumParcialidad,
		@TipoDeCambioDR
	)

	SET @IdDocRelacionado = SCOPE_IDENTITY()
	

	INSERT INTO dbo.FI_FacturaComplemento
	(
	    IdComplemento,
	    IdFactura,
	    IdDocRelacionado,
	    MontoPagado
	)
	VALUES
	(   @IdFacturaComplemento,   -- IdComplemento - int
	    @IdFactura,   -- IdFactura - int
	    @IdDocRelacionado,   -- IdDocRelacionado - int
	    @ImpPagado -- MontoPagado - money
	)

	INSERT INTO dbo.FI_FacturaCompPagoRelacion
	(
	    IdFacturaCompPago,
	    IdFactura
	)
	VALUES
	(   @IdFacturaComplemento, -- IdFacturaCompPago - int
	    @IdFactura  -- IdFactura - int
	)

	SELECT @IdFactura
END


