-- =============================================
-- Author:      <Alexander Gomez>
-- Create date: <05/08/2019>
-- Description: <Importacion de Complementos de pago de adinco a petrovendor faltantes>
-- =============================================
CREATE PROCEDURE [dbo].[SP_CP_ImportacionComplementoPagoAdincoPetrovendor]
-- Add the parameters for the stored procedure here
AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        -- Insert statements for procedure here
        SELECT ROW_NUMBER() OVER(
               ORDER BY FP.IdFactura DESC) AS IDROW, 
               FP.IdFactura AS IDFACTURAPETRO, 
               FP.UUID AS UUIDFACTURAPETRO, 
               FA.IdFactura AS IDFACTURACOMPLEMENTEADINCO, 
               FA.UUID AS UUIDFACTURACOMPLEMENTEADINCO, 
               CPA.IdComplementoDePago AS IDCOMPLEMENTOADINCO, 
               DRA.IdDocRelacionado AS IDDOCRELACIONADO, 
               FPC.IdFactura AS IDFACTURACOMPLEMENTOPETRO
        INTO #COMPLEMENTO
        FROM Petrovendor.dbo.FI_Factura AS FP
             LEFT JOIN Adinco.dbo.FI_CPDocRelacionado AS DRA ON DRA.IdDocumento COLLATE Modern_Spanish_CI_AS = FP.UUID COLLATE Modern_Spanish_CI_AS
             LEFT JOIN Adinco.dbo.FI_ComplementoDePago AS CPA ON CPA.IdComplementoDePago = DRA.IdComplementoDePago
             LEFT JOIN Adinco.dbo.FI_Factura AS FA ON FA.IdFactura = CPA.IdFactura
             LEFT JOIN Petrovendor.dbo.FI_Factura AS FPC ON FPC.UUID COLLATE Modern_Spanish_CI_AS = FA.UUID COLLATE Modern_Spanish_CI_AS
        WHERE FP.IdFactura IS NOT NULL
              AND FP.UUID IS NOT NULL
              AND FA.IdFactura IS NOT NULL
              AND FA.UUID IS NOT NULL
              AND CPA.IdComplementoDePago IS NOT NULL
              AND FPC.IdFactura IS NULL
        GROUP BY FP.IdFactura, 
                 FP.UUID, 
                 FA.IdFactura, 
                 FA.UUID, 
                 CPA.IdComplementoDePago, 
                 DRA.IdDocRelacionado, 
                 FPC.IdFactura
        ORDER BY FP.IdFactura DESC;
        DECLARE @CONTTABLE INT=
        (
            SELECT COUNT(IDROW)
            FROM #COMPLEMENTO
        );
        DECLARE @CONTINC INT= 1;
        WHILE @CONTINC <= @CONTTABLE
            BEGIN
                DECLARE @ADINCOFACTURACOMPLEMENTO INT=
                (
                    SELECT TOP 1 IdFactura
                    FROM Adinco.dbo.FI_ComplementoDePago
                    WHERE IdComplementoDePago IN
                    (
                        SELECT IDCOMPLEMENTOADINCO
                        FROM #COMPLEMENTO
                        WHERE IDROW = @CONTINC
                    )
                );
                DECLARE @RFCContratista NVARCHAR(MAX)=
                (
                    SELECT Receptor
                    FROM Adinco.dbo.FI_Factura
                    WHERE IdFactura = @ADINCOFACTURACOMPLEMENTO
                );
                DECLARE @RFCSubcontratista NVARCHAR(MAX)=
                (
                    SELECT Emisor
                    FROM Adinco.dbo.FI_Factura
                    WHERE IdFactura = @ADINCOFACTURACOMPLEMENTO
                );
                DECLARE @IdContratista INT=
                (
                    SELECT TOP 1 IdProveedor
                    FROM Petrovendor.dbo.S_Proveedor
                    WHERE RFC = @RFCContratista
                );
                DECLARE @IdSubcontratista INT=
                (
                    SELECT TOP 1 IdProveedor
                    FROM Petrovendor.dbo.S_Proveedor
                    WHERE RFC = @RFCSubcontratista
                );
                INSERT INTO Petrovendor.dbo.FI_Factura
                (Serie, 
                 Folio, 
                 Fecha, 
                 FormaPago, 
                 NoCertificado, 
                 CondicionesDePago, 
                 SubTotal, 
                 Descuento, 
                 TipoCambio, 
                 Moneda, 
                 TipoComprobante, 
                 MetodoPago, 
                 LugarExpedicion, 
                 NumCtaPago, 
                 Emisor, 
                 Receptor, 
                 UUID, 
                 FechaRecepcion, 
                 IdSubcontratista, 
                 IdContrato, 
                 XML, 
                 Activa, 
                 CreadoPor, 
                 CreadoEn, 
                 IdReceptor, 
                 NombreXML, 
                 FechaTimbrado
                )
                       SELECT Serie, 
                              Folio, 
                              Fecha, 
                              FormaPago, 
                              NoCertificado, 
                              CondicionesDePago, 
                              SubTotal, 
                              Descuento, 
                              TipoCambio, 
                              Moneda, 
                              TipoComprobante, 
                              MetodoPago, 
                              LugarExpedicion, 
                              NumCtaPago, 
                              Emisor, 
                              Receptor, 
                              UUID, 
                              FechaRecepcion, 
                              @IdSubcontratista, 
                              IdContrato, 
                              XML, 
                              Activa, 
                              CreadoPor, 
                              CreadoEn, 
                              @IdContratista, 
                              NombreXML, 
                              FechaTimbrado
                       FROM Adinco.dbo.FI_Factura
                       WHERE IdFactura = @ADINCOFACTURACOMPLEMENTO;
                DECLARE @PETROFACTURACOMPLEMENTO INT= (SCOPE_IDENTITY());
                INSERT INTO Petrovendor.dbo.FI_ComplementoDePago
                (IdFactura, 
                 Version, 
                 FechaDePago, 
                 MonedaP, 
                 FormaDePagoP, 
                 Monto, 
                 NumOperacion, 
                 NomBancoOrdExt, 
                 CtaOrdenante, 
                 RfcEmisorCtaBen, 
                 CtaBeneficiario
                )
                       SELECT @PETROFACTURACOMPLEMENTO, 
                              Version, 
                              FechaDePago, 
                              MonedaP, 
                              FormaDePagoP, 
                              Monto, 
                              NumOperacion, 
                              NomBancoOrdExt, 
                              CtaOrdenante, 
                              RfcEmisorCtaBen, 
                              CtaBeneficiario
                       FROM Adinco.dbo.FI_ComplementoDePago
                       WHERE IdComplementoDePago IN
                       (
                           SELECT IDCOMPLEMENTOADINCO
                           FROM #COMPLEMENTO
                           WHERE IDROW = @CONTINC
                       );
                DECLARE @COMPLEMENTO INT=
                (
                    SELECT IdComplementoDePago
                    FROM Petrovendor.dbo.FI_ComplementoDePago
                    WHERE IdFactura = @PETROFACTURACOMPLEMENTO
                );
                INSERT INTO Petrovendor.dbo.FI_CPDocRelacionado
                (IdComplementoDePago, 
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
                       SELECT @COMPLEMENTO, 
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
                       FROM Adinco.dbo.FI_CPDocRelacionado
                       WHERE IdDocRelacionado IN
                       (
                           SELECT IDDOCRELACIONADO
                           FROM #COMPLEMENTO
                           WHERE IDROW = @CONTINC
                       );
                INSERT INTO Petrovendor.dbo.FI_FacturaComplemento
                (IdComplemento, 
                 IdFactura, 
                 IdDocRelacionado, 
                 MontoPagado
                )
                       SELECT @PETROFACTURACOMPLEMENTO, 
                              F.IdFactura, 
                              CPR.IdDocRelacionado, 
                              CPR.ImpPagado
                       FROM Petrovendor.dbo.FI_CPDocRelacionado AS CPR
                            LEFT JOIN Petrovendor.dbo.FI_Factura AS F ON F.UUID = CPR.IdDocumento
                       WHERE IdComplementoDePago = @COMPLEMENTO;
                INSERT INTO Petrovendor.dbo.FI_FacturaCompPagoRelacion
                       SELECT @PETROFACTURACOMPLEMENTO, 
                              F.IdFactura
                       FROM Petrovendor.dbo.FI_CPDocRelacionado AS CPR
                            LEFT JOIN Petrovendor.dbo.FI_Factura AS F ON F.UUID = CPR.IdDocumento
                       WHERE IdComplementoDePago = @COMPLEMENTO;
                SET @CONTINC = @CONTINC + 1;
            END;
    END;