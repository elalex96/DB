
-- =============================================
-- Author:		Reyna Olvera
-- Create date: 20181023
-- Description:	Guarda las facturas PPD o P para realizar la busqueda de los ppd y complementos de pago para el reporte de CGI
-- =============================================
-- Author:		Manuel Cruz
-- Modificación date: 27-09-2019
-- Description:	Actualiza las transferencias relacionandola con el Complemento de Pago que se identifica al momento de la carga.
-- =============================================
-- Author:		Manuel Cruz
-- Modificación date: 23-02-2021
-- Description:	Se actualiza el mes presentación de los gastos relacionados a las facturas principales de los complementos de pago
-- una vez que se cargó y se ligó a la transferencia, tomando en cuenta el mes presentación el mes del pago indicado en el complemento.
-- =============================================
-- Modificado Por:	Neri Garcia
-- Fecha:			17 de Agosto del 2022
-- Descripción:		Eliminación de código comentado, agregado de (NOLOCK), ajustado de orden en los join, 
--					renombrado de las tablas, eñiminación desub querys consultas ajustadas   
--					ajustes de max varchar, ajustes de nvarchar a varchar, se mueven create table al inicio del sp
-- =============================================
-- Modificado Por:	Reyna Olvera
-- Fecha:			15 de Noviembre del 2022
-- Descripción:		Se agrega join a la tabla de transferencias, ya que se encontraron transferencias no existentes en la tabla: FI_TransferFacturaPPD
-- =============================================

CREATE PROCEDURE [dbo].[sp_FI_GuardaFacturaPPDP]
    @idContrato INT,
    @idUsuario INT,
    @idFactura INT
AS
BEGIN
    DECLARE @TipoComprobante VARCHAR(50),
            @MetodoPago VARCHAR(50),
            @MesPresentacionCGI DATE,
            @error VARCHAR(100) = '';
    /**/
    CREATE TABLE #FacturasPrincipales
    (
        IdFacturaPPD INT,
        UUID NVARCHAR(300),
        IdFacturaCP INT,
        MesDePago DATE
    );
    /**/
    CREATE TABLE #TransferenciaCP (IdTransfer INT);
    /**/
    SELECT @TipoComprobante = CASE
                                  WHEN FI_Factura.TipoComprobante LIKE '%ingreso%'
                                       OR FI_Factura.TipoComprobante LIKE 'I%' THEN
                                      'I'
                                  WHEN (FI_Factura.TipoComprobante) LIKE '%egreso%'
                                       OR FI_Factura.TipoComprobante LIKE 'E%' THEN
                                      'E'
                                  WHEN (FI_Factura.TipoComprobante) LIKE '%traslado%'
                                       OR FI_Factura.TipoComprobante LIKE 'T%' THEN
                                      'T'
                                  WHEN (FI_Factura.TipoComprobante) LIKE '%nómina%'
                                       OR FI_Factura.TipoComprobante LIKE 'N%' THEN
                                      'N'
                                  WHEN (FI_Factura.TipoComprobante) LIKE '%pago%'
                                       OR FI_Factura.TipoComprobante LIKE 'P%' THEN
                                      'P'
                                  ELSE
                                      'NA'
                              END,
           @MetodoPago = CASE
                             WHEN FI_Factura.MetodoPago LIKE '%exhibi%'
                                  OR FI_Factura.MetodoPago LIKE '%PUE%'
                                  OR FI_Factura.FormaPago LIKE '%exhibi%'
                                  OR FI_Factura.FormaPago LIKE '%PUE%' THEN
                                 'PUE'
                             WHEN FI_Factura.MetodoPago LIKE '%parcia%'
                                  OR FI_Factura.MetodoPago LIKE '%dife%'
                                  OR FI_Factura.MetodoPago LIKE '%PPD%'
                                  OR FI_Factura.FormaPago LIKE '%parcia%'
                                  OR FI_Factura.FormaPago LIKE '%dife%'
                                  OR FI_Factura.FormaPago LIKE '%PPD%' THEN
                                 'PPD'
                         END,
           @MesPresentacionCGI = CO_Contrato.MesPresentacionCGI
    FROM FI_Factura (NOLOCK)
        JOIN CO_Contrato (NOLOCK)
            ON FI_Factura.IdContrato = CO_Contrato.IdContrato
    WHERE FI_Factura.IdFactura = @idFactura
          AND FI_Factura.IdContrato = @idContrato;
    /**/
    IF (@MetodoPago = 'PPD')
    BEGIN
        INSERT INTO FI_PPD_MesPresentacion
        (
            idFactura,
            MesPresentacionFactura,
            CreadoPor,
            CreadoEn,
            ModificadoPor,
            ModificadoEn,
            Activo
        )
        VALUES
        (@idFactura, @MesPresentacionCGI, @idUsuario, GETDATE(), @idUsuario, GETDATE(), 1);
    /**/
    END;
    IF (@TipoComprobante = 'P')
    BEGIN
        /*Identificar las facturas principales PPD relacionadas a los complementos con la tabla anterior*/

        INSERT INTO #FacturasPrincipales
        (
            IdFacturaPPD,
            UUID,
            IdFacturaCP,
            MesDePago
        )
        SELECT FI_Factura.IdFactura,
               FI_Factura.UUID,
               FI_ComplementoDePago.IdFactura,
               DATEFROMPARTS(YEAR(FI_ComplementoDePago.FechaDePago), MONTH(FI_ComplementoDePago.FechaDePago), 1)
        FROM FI_ComplementoDePago (NOLOCK)
            JOIN FI_CPDocRelacionado (NOLOCK)
                ON FI_ComplementoDePago.IdComplementoDePago = FI_CPDocRelacionado.IdComplementoDePago
            JOIN FI_Factura (NOLOCK)
                ON FI_CPDocRelacionado.IdDocumento = FI_Factura.UUID
        WHERE FI_ComplementoDePago.IdFactura = @idFactura;
        /*Identificar las transferencias relacionadas directamente con las facturas PPD de la tabla anterior, 
		para posteriormente eliminarla, se creo una tabla para guardar respaldo de las relaciones*/
        INSERT INTO FI_TransferFacturaPPD
        (
            IdTransfer,
            IdFactura,
            MontoPagado,
            CvTipoDocFacturacion,
            CreadoPor,
            CreadoEn,
            ModificadoPor,
            ModificadoEn
        )
        SELECT FI_TransferFactura.IdTransfer,
               FI_TransferFactura.IdFactura,
               FI_TransferFactura.MontoPagado,
               FI_TransferFactura.CvTipoDocFacturacion,
               FI_TransferFactura.CreadoPor,
               FI_TransferFactura.CreadoEn,
               @idUsuario,
               GETDATE()
        FROM FI_TransferFactura (NOLOCK)
            JOIN #FacturasPrincipales
                ON FI_TransferFactura.IdFactura = #FacturasPrincipales.IdFacturaPPD
			JOIN
				FI_Transfer (NOLOCK)
				ON	FI_TransferFactura.IdTransfer = FI_Transfer.IdTransferencia
			WHERE FI_TransferFactura.IdTransfer IS NOT NULL;

        /*Eliminar relacion existente entre la factura principal PPD y la transferencia*/
        INSERT INTO #TransferenciaCP
        (
            IdTransfer
        )
        SELECT DISTINCT
            FI_TransferFacturaPPD.IdTransfer
        FROM FI_TransferFacturaPPD (NOLOCK)
            JOIN #FacturasPrincipales 
                ON FI_TransferFacturaPPD.IdFactura = #FacturasPrincipales.IdFacturaPPD
        WHERE #FacturasPrincipales.IdFacturaCP = @idFactura;

        /*Eliminar*/
        DELETE FI_TransferFactura
        FROM FI_TransferFactura (NOLOCK)
            JOIN #TransferenciaCP 
                ON FI_TransferFactura.IdTransfer = #TransferenciaCP.IdTransfer

        /*Actualizar en FI_Transfer IdFormaPago = 2 ya que indica que el metodo de pago es PPD*/
        UPDATE FI_Transfer
        SET FI_Transfer.IdFormaPago = 2
        FROM FI_Transfer (NOLOCK)
            JOIN #TransferenciaCP
                ON FI_Transfer.IdTransferencia = #TransferenciaCP.IdTransfer

        /*Insertar la nueva relacion del complemento de pago con la transferencia.*/
        INSERT INTO FI_TransferFactura
        (
            IdTransfer,
            IdFactura,
            MontoPagado,
            CvTipoDocFacturacion,
            CreadoPor,
            CreadoEn
        )
        SELECT DISTINCT
            FI_TransferFacturaPPD.IdTransfer,
            #FacturasPrincipales.IdFacturaCP,
 0,
            6,
            @idUsuario,
            GETDATE()
        FROM #FacturasPrincipales
            JOIN FI_TransferFacturaPPD (NOLOCK)
                ON #FacturasPrincipales.IdFacturaPPD = FI_TransferFacturaPPD.IdFactura
			JOIN
				FI_Transfer (NOLOCK)
				ON	FI_TransferFacturaPPD.IdTransfer = FI_Transfer.IdTransferencia
        WHERE #FacturasPrincipales.IdFacturaCP = @idFactura AND FI_Transfer.IdTransferencia IS NOT NULL;

        /*Actualizar mes presentación de los gastos asociados a las facturas principales del complemento*/
        UPDATE CO_Registro
        SET CO_Registro.MesPresentacion = #FacturasPrincipales.MesDePago
        FROM CO_Registro (NOLOCK)
            JOIN #FacturasPrincipales
                ON CO_Registro.IdFactura = #FacturasPrincipales.IdFacturaPPD
        WHERE CO_Registro.IdFactura = #FacturasPrincipales.IdFacturaPPD
    END;
    IF @@ERROR <> 0
    BEGIN
        SET @error
            = CAST('Inconveniente encontrado en el sp: sp_FI_GuardaFacturaPPDP, CodigoError: ' + CAST(@@ERROR AS VARCHAR(8)) AS VARCHAR(100));
    END;
    SELECT @error AS error;
END;