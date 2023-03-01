USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_Eliminar_AceptacionPedido'
)
    DROP PROCEDURE SP_MM_Eliminar_AceptacionPedido;
GO
-- =============================================
-- Author:	DANIEL AC
-- Create date: 08/03/2018
-- Description: CONSULTAR PROCESO DE PROCURA PARA POSIBLE ELIMINACIÓN -MODIFICACIÓN
-- =============================================
-- Update Author:	Alexander Gomez
-- Create date: 01/02/2019
-- Description: Se agrego la tabla de FI_CFDIConceptoImpuesto, PR_FI_ArchivoXml para la eliminacion de la factura
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 27/02/2023
-- Description: se agrega el bit 0 en activo al eliminar el proceso
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_Eliminar_AceptacionPedido]
    @IDACEPTACIONPEDIDO INT,
    @IDPROVEEDOR INT,
    @IDCONTRATO INT,
    @COMENTARIO_INTERNO NVARCHAR(MAX),
    @COMENTARIO_EXTERNO NVARCHAR(MAX),
    @IDUSUARIO INT,
    @CONFIRMACION BIT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    BEGIN TRAN tran1;
    BEGIN TRY


        --DECLARE @IDACEPTACIONPEDIDO INT =256
        --   DECLARE @IDPROVEEDOR INT=420
        /*CREACIÓN DE TABLA QUE LLEVARA LA JERARQUIA DE LOS PROCESOS DE PROCURA*/
        /* 
	DROP TABLE #PROCESO 
	DROP TABLE #VALIDACION_FACTURA
	DROP TABLE #VALIDACION_PEDIMENTO
	DROP TABLE #FACTURAS_GASTOS
	DROP TABLE #FACTURAS_TRANFERENCIAS
	*/

        DECLARE @DISPONIBLE_ELIMINACION INT = (
                                                  SELECT COUNT(IdAceptacionPedido)
                                                  FROM dbo.MM_AceptacionPedido (NOLOCK)
                                                  WHERE IdAceptacionPedido = @IDACEPTACIONPEDIDO
                                                        AND IdProveedor = @IDPROVEEDOR
                                                        AND ISNULL(IdEstatusEliminado, 0) = 0
                                              );

        IF @DISPONIBLE_ELIMINACION > 0
        BEGIN
            /*INICIA PROCESO DE ELIMINACION DE ACEPTACIÓN DE PEDIDO*/

            CREATE TABLE #PROCESO
            (
                ID INT IDENTITY(1, 1),
                ID_PADRE INT,
                PROCESO NVARCHAR(500),
                ESTATUS NVARCHAR(500),
                IDESTATUS INT,
                CLASS NVARCHAR(300),
                CLAVE_PROCESO NVARCHAR(200),
                ACCION_EJECUTAR NVARCHAR(300),
                ID_PROCESO INT
            );

            /*ACEPTACIONES DE CARTA CONTENIDO NACIONAL*/
            /*CONSULTA DE ACEPTACIONES DE PEDIDO DE LAS CONFIRMACIONES DE PEDIDO ACEPTADAS Y CARTA DE CONTENIDO NACIONAL SI EL PROVEEDOR ES NACIONAL*/
            INSERT INTO #PROCESO
            (
                ID_PADRE,
                PROCESO,
                ESTATUS,
                IDESTATUS,
                CLAVE_PROCESO,
                ID_PROCESO
            )
            SELECT 0,
                   CONCAT('Aceptación de Carta Contenido Nacional No.', AP.IdAceptacionPedido),
                   TD.TipoValidacion,
                   AC.IdEstatus,
                   'aceptacioncn',
                   AC.IdAceptacionCartaPCN
            FROM MM_AceptacionPedido AS AP (NOLOCK)
                INNER JOIN MM_Pedido AS P (NOLOCK)
                    ON AP.IdPedido = P.IdPedido
					AND AP.IdAceptacionPedido = @IDACEPTACIONPEDIDO
                INNER JOIN MM_AceptacionCartaPCN AS AC (NOLOCK)
                    ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
					AND ISNULL(AC.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
                INNER JOIN S_Documento_S3 AS D (NOLOCK)
                    ON AC.IdDocumento = D.IdDocumento
                INNER JOIN S_TipoValidacionDoc AS TD (NOLOCK)
                    ON AC.IdEstatus = TD.IdTipoValidacionDoc
                INNER JOIN S_Proveedor AS PV (NOLOCK)
                    ON P.IdSubcontratista = PV.IdProveedor
                INNER JOIN MM_Pedidos AS PG (NOLOCK)
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IDPROVEEDOR
                LEFT JOIN MM_TipoPedido AS TP (NOLOCK)
                    ON PG.IdTipoPedido = TP.IdTipoPedido    
            GROUP BY AC.IdAceptacionCartaPCN,
                     TD.TipoValidacion,
                     AP.IdAceptacionPedido,
                     AC.IdEstatus;

            /*RECEPCIÓN DE FACTURA DE PETROVENDOR*/
            INSERT INTO #PROCESO
            (
                ID_PADRE,
                PROCESO,
                ESTATUS,
                IDESTATUS,
                CLAVE_PROCESO,
                ID_PROCESO
            )
            SELECT TEM_CN.ID,
                   CONCAT('Recepción de factura No.', AP.IdAceptacionPedido),
                   E.Nombre,
                   O.IdEstatusOperacion,
                   'aceptacionfactura',
                   AF.IdAceptacionFactura
            FROM MM_AceptacionFactura AS AF (NOLOCK)
                INNER JOIN TA_Operacion AS O (NOLOCK)
                    ON AF.IdAceptacionFactura = O.IdDocumento 
					AND O.IdTipoOperacion = 10
					AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
                INNER JOIN TA_Estatus AS E (NOLOCK)
                    ON O.IdEstatusOperacion = E.IdEstatus
                INNER JOIN MM_AceptacionPedido AS AP (NOLOCK)
                    ON AF.IdAceptacionPedido = AP.IdAceptacionPedido
					AND AP.IdAceptacionPedido = @IDACEPTACIONPEDIDO
                INNER JOIN MM_Pedido AS P (NOLOCK)
                    ON AP.IdPedido = P.IdPedido
                LEFT JOIN MM_AceptacionCartaPCN AS AC (NOLOCK)
                    ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                LEFT JOIN S_Documento_S3 AS D (NOLOCK)
                    ON AC.IdDocumento = D.IdDocumento
                LEFT JOIN S_TipoValidacionDoc AS TD (NOLOCK)
                    ON AC.IdEstatus = TD.IdTipoValidacionDoc
                INNER JOIN S_Proveedor AS PV (NOLOCK)
                    ON P.IdSubcontratista = PV.IdProveedor
                INNER JOIN MM_Pedidos AS PG (NOLOCK)
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IDPROVEEDOR
                LEFT JOIN #PROCESO AS TEM_CN
                    ON AC.IdAceptacionCartaPCN = TEM_CN.ID_PROCESO
                LEFT JOIN MM_TipoPedido AS TP (NOLOCK)
                    ON PG.IdTipoPedido = TP.IdTipoPedido;
                  

            /*COMPROBANTE EXTRANJERO*/
            INSERT INTO #PROCESO
            (
                ID_PADRE,
                PROCESO,
                ESTATUS,
                IDESTATUS,
                CLAVE_PROCESO,
                ID_PROCESO
            )
            SELECT 0,
                   CONCAT('Recepción de comprobante extranjero No.', AP.IdAceptacionPedido),
                   E.Nombre,
                   O.IdEstatusOperacion,
                   'aprobacionextranjera',
                   PC.IdPedimentoComprobante
            FROM MM_AceptacionPedido AS AP (NOLOCK)
                INNER JOIN MM_Pedido AS P (NOLOCK)
                    ON AP.IdPedido = P.IdPedido
					AND AP.IdAceptacionPedido = @IDACEPTACIONPEDIDO
					AND ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
                INNER JOIN S_Proveedor AS PV (NOLOCK)
                    ON P.IdSubcontratista = PV.IdProveedor
                INNER JOIN MM_Pedidos AS PG (NOLOCK)
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IDPROVEEDOR
                LEFT JOIN MM_TipoPedido AS TP (NOLOCK)
                    ON PG.IdTipoPedido = TP.IdTipoPedido
                INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC (NOLOCK)
                    ON AP.IdAceptacionPedido = APC.IdAceptacionPedido
                INNER JOIN dbo.FI_PedimentoComprobante PC (NOLOCK)
                    ON APC.IdPedimentoComprobante = PC.IdPedimentoComprobante
					AND ISNULL(PC.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
                INNER JOIN dbo.TA_Operacion O (NOLOCK)
                    ON PC.IdPedimentoComprobante = O.IdDocumento
                       AND O.IdTipoOperacion = 16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
                LEFT JOIN dbo.TA_Estatus AS E (NOLOCK)
                    ON O.IdEstatusOperacion = E.IdEstatus;
                  
                  

            /*VALIDACION DE COMPROBANTES EXTRANJERO DE ADINCO*/
            CREATE TABLE #VALIDACION_PEDIMENTO
            (
                IdValidacion INT IDENTITY(1, 1),
                IdAceptacionPedido INT,
                IdPedimentoPetrovendor INT,
                IdPedimentoAdinco INT,
                TieneGastos INT,
                TieneTransferencias INT
            );

            INSERT INTO #VALIDACION_PEDIMENTO
            (
                IdAceptacionPedido,
                IdPedimentoPetrovendor,
                IdPedimentoAdinco,
                TieneGastos,
                TieneTransferencias
            )
            SELECT AP.IdAceptacionPedido,
                   PP.IdPedimentoComprobante,
                   PA.IdPedimentoComprobante,
                   0,
                   0
            FROM #PROCESO P
                INNER JOIN dbo.FI_PedimentoComprobante PP (NOLOCK)
                    ON P.ID_PROCESO = PP.IdPedimentoComprobante
					AND P.CLAVE_PROCESO = 'aprobacionextranjera'
					AND ISNULL(PP.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
                INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APP (NOLOCK)
                    ON PP.IdPedimentoComprobante = APP.IdPedimentoComprobante
                INNER JOIN dbo.MM_AceptacionPedido AP (NOLOCK)
                    ON APP.IdAceptacionPedido = AP.IdAceptacionPedido
                INNER JOIN Adinco.dbo.FI_PedimentoComprobante PA (NOLOCK)
                    ON PP.IdPedimentoComprobante = PA.IdPedimentoComprobantePetrovendor
            GROUP BY AP.IdAceptacionPedido,
                     PP.IdPedimentoComprobante,
                     PA.IdPedimentoComprobante;

            /*VALIDACIÓN DE CANTIDAD DE GASTOS DE UN PEDIMENTO*/
            CREATE TABLE #PEDIMENTO_GASTOS
            (
                IdValidacion INT,
                Gastos INT
            );
            INSERT INTO #PEDIMENTO_GASTOS
            (
                IdValidacion,
                Gastos
            )
            SELECT VP.IdValidacion,
                   COUNT(R.IdPedimentoComprobante)
            FROM #VALIDACION_PEDIMENTO VP
                INNER JOIN Adinco.dbo.CO_Registro R (NOLOCK)
                    ON VP.IdPedimentoAdinco = R.IdPedimentoComprobante
            GROUP BY VP.IdValidacion;

            UPDATE VP
            SET VP.TieneGastos = PG.Gastos
            FROM #VALIDACION_PEDIMENTO VP (NOLOCK)
                INNER JOIN #PEDIMENTO_GASTOS PG
                    ON VP.IdValidacion = PG.IdValidacion;

            /*VALIDACIÓN DE CANTIDAD DE TRANFERENCIAS DE UN PEDIMENTO*/
            CREATE TABLE #PEDIMENTO_TRANFERENCIAS
            (
                IdValidacion INT,
                Tranferencias INT
            );
            INSERT INTO #PEDIMENTO_TRANFERENCIAS
            (
                IdValidacion,
                Tranferencias
            )
            SELECT VP.IdValidacion,
                   COUNT(T.IdTransferFactura)
            FROM #VALIDACION_PEDIMENTO VP
                INNER JOIN Adinco.dbo.FI_TransferFactura T (NOLOCK)
                    ON VP.IdPedimentoAdinco = T.IdPedimentoComprobante
            GROUP BY VP.IdValidacion;

            UPDATE VP
            SET VP.TieneTransferencias = PT.Tranferencias
            FROM #VALIDACION_PEDIMENTO VP
                INNER JOIN #PEDIMENTO_TRANFERENCIAS PT
                    ON VP.IdValidacion = PT.IdValidacion;


            /*VALIDACIÓN DE FACTURAS CON FACTURAS DE ADINCO*/
            CREATE TABLE #VALIDACION_FACTURA
            (
                IdValidacion INT IDENTITY(1, 1),
                IdAceptacionPedido INT,
                IdAceptacionFactura INT,
                IdFacturaPetronvendor INT,
                IdFacturaAdinco INT,
                TieneGastos INT,
                TieneTransferencias INT
            );

            INSERT INTO #VALIDACION_FACTURA
            (
                IdAceptacionPedido,
                IdAceptacionFactura,
                IdFacturaPetronvendor,
                IdFacturaAdinco,
                TieneGastos,
                TieneTransferencias
            )
            SELECT AF.IdAceptacionPedido,
                   AF.IdAceptacionFactura,
                   AF.IdFactura,
                   FA.IdFactura,
                   0,
                   0
            FROM #PROCESO AS TEM
                INNER JOIN dbo.MM_AceptacionFactura AS AF (NOLOCK)
                    ON TEM.ID_PROCESO = AF.IdAceptacionFactura
					AND TEM.CLAVE_PROCESO = 'aceptacionfactura'
					AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
                INNER JOIN dbo.FI_Factura AS FP (NOLOCK)
                    ON AF.IdFactura = FP.IdFactura
                LEFT JOIN Adinco.dbo.FI_Factura AS FA (NOLOCK)
                    ON FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS = FA.UUID
            GROUP BY AF.IdAceptacionPedido,
                     AF.IdAceptacionFactura,
                     AF.IdFactura,
                     FA.IdFactura;

            /*VALIDACION DE GASTOS CONTRA FACTURAS DE ADINCO*/
            CREATE TABLE #FACTURAS_GASTOS
            (
                IdValidacion INT,
                Gastos INT
            );
            INSERT INTO #FACTURAS_GASTOS
            (
                IdValidacion,
                Gastos
            )
            SELECT VF.IdValidacion,
                   COUNT(R.IdRegistro)
            FROM #VALIDACION_FACTURA AS VF
                INNER JOIN Adinco.dbo.CO_Registro R (NOLOCK)
                    ON VF.IdFacturaAdinco = R.IdFactura
					AND VF.IdFacturaAdinco IS NOT NULL
            GROUP BY VF.IdValidacion;

            /*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LOS GASTOS*/
            UPDATE VF
            SET VF.TieneGastos = FG.Gastos
            FROM #VALIDACION_FACTURA VF
                INNER JOIN #FACTURAS_GASTOS FG
                    ON VF.IdValidacion = FG.IdValidacion;

            /*VALIDACION DE TRANFERENCIAS CONTRA FACTURAS DE ADINCO*/
            CREATE TABLE #FACTURAS_TRANFERENCIAS
            (
                IdValidacion INT,
                Tranferencias INT
            );
            INSERT INTO #FACTURAS_TRANFERENCIAS
            (
                IdValidacion,
                Tranferencias
            )
            SELECT VF.IdValidacion,
                   COUNT(T.IdTransferFactura)
            FROM #VALIDACION_FACTURA AS VF
                INNER JOIN Adinco.dbo.FI_TransferFactura T (NOLOCK)
                    ON VF.IdFacturaAdinco = T.IdFactura
					AND VF.IdFacturaAdinco IS NOT NULL
            GROUP BY VF.IdValidacion;

            /*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LAS TRANSFERENCIAS*/
            UPDATE VF
            SET VF.TieneTransferencias = FT.Tranferencias
            FROM #VALIDACION_FACTURA VF
                INNER JOIN #FACTURAS_TRANFERENCIAS FT
                    ON VF.IdValidacion = FT.IdValidacion;

            ----SELECT * FROM #PROCESO
            --SELECT * FROM #VALIDACION_FACTURA 


            /*VALIDACIÓN DE GASTOS Y TRANFERENCIAS*/
            DECLARE @TIENE_GASTOS INT = (
                                            SELECT COUNT(IdValidacion)
                                            FROM #VALIDACION_FACTURA
                                            WHERE TieneGastos <> 0
                                        );
            DECLARE @TIENE_TRANSFERERENCIAS INT = (
                                                      SELECT COUNT(IdValidacion)
                                                      FROM #VALIDACION_FACTURA
                                                      WHERE TieneTransferencias <> 0
                                                  );

            DECLARE @TIENE_GASTOS_PEDIMENTO INT = (
                                                      SELECT COUNT(IdValidacion)
                                                      FROM #VALIDACION_PEDIMENTO
                                                      WHERE TieneGastos <> 0
                                                  );
            DECLARE @TIENE_TRANSFERERENCIAS_PEDIMENTO INT = (
                                                                SELECT COUNT(IdValidacion)
                                                                FROM #VALIDACION_PEDIMENTO
                                                                WHERE TieneTransferencias <> 0
                                                            );

            IF @TIENE_GASTOS = 0
               AND @TIENE_TRANSFERERENCIAS = 0
               AND @TIENE_GASTOS_PEDIMENTO = 0
               AND @TIENE_TRANSFERERENCIAS_PEDIMENTO = 0
            BEGIN
                /*ELIMINAR FACTURAS EN ADINCO */

                INSERT INTO dbo.AD_RegistroEliminacion
                (
                    IdUsuario,
                    FechaRegistro,
                    ComentarioExterno,
                    ComentarioInterno,
                    TipoEliminacion,
                    Activo,
                    IdProveedor,
                    IdContrato,
                    IdProceso,
                    Confirmacion
                )
                VALUES
                (   @IDUSUARIO,          -- IdUsuario - int
                    GETDATE(),           -- FechaRegistro - dateti
                    @COMENTARIO_EXTERNO, -- ComentarioExterno - nvarchar(max)
                    @COMENTARIO_INTERNO, -- ComentarioInterno - nvarchar(max)
                    N'AP',               -- TipoEliminacion - nvarchar(100)
                    1,                   -- Activo - bit
                    @IDPROVEEDOR,        -- IdProveedor -- int
                    @IDCONTRATO,         -- IdContrato -- int 
                    @IDACEPTACIONPEDIDO, -- IdProceso --int
                    @CONFIRMACION        --Confirmacion bit
                );

                DECLARE @IDELIMINACION INT = (
                                                 SELECT @@IDENTITY
                                             );

                --SELECT * FROM #VALIDACION_FACTURA 
				INSERT INTO dbo.PR_FI_CFDIConceptoImpuesto
				(
				    IdFacturaConcepto,
				    IdTipoImpuesto,
				    NombreImpuesto,
				    Base,
				    Impuesto,
				    TipoFactor,
				    Tasa,
				    Importe,
					IdEliminacion
				)
				SELECT IdFacturaConcepto,
                       IdTipoImpuesto,
                       NombreImpuesto,
                       Base,
                       Impuesto,
                       TipoFactor,
                       Tasa,
                       Importe,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_CFDIConceptoImpuesto (NOLOCK)
                WHERE IdFacturaConcepto IN (
                                       SELECT FC.IdFacturaConcepto FROM #VALIDACION_FACTURA AS FF
									   INNER JOIN Adinco.dbo.FI_CFDIConcepto AS FC (NOLOCK) ON FF.IdFacturaAdinco = FC.IdFactura
                                   );
                DELETE Adinco.dbo.FI_CFDIConceptoImpuesto
                WHERE IdFacturaConcepto IN (
                                       SELECT FC.IdFacturaConcepto FROM #VALIDACION_FACTURA AS FF
									   INNER JOIN Adinco.dbo.FI_CFDIConcepto AS FC (NOLOCK) ON FF.IdFacturaAdinco = FC.IdFactura
                                   );

                INSERT INTO dbo.PR_FI_CFDIConcepto
                (
                    IdFacturaConcepto,
                    IdFactura,
                    ClaveProdServ,
                    Cantidad,
                    ClaveUnidad,
                    Unidad,
                    Descripcion,
                    ValorUnitario,
                    Importe,
                    NoIdentificacion,
                    IdEliminacion
                )
                SELECT IdFacturaConcepto,
                       IdFactura,
                       ClaveProdServ,
                       Cantidad,
                       ClaveUnidad,
                       Unidad,
                       Descripcion,
                       ValorUnitario,
                       Importe,
                       NoIdentificacion,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_CFDIConcepto (NOLOCK) 
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );
                DELETE Adinco.dbo.FI_CFDIConcepto
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );

                INSERT INTO dbo.PR_FI_CFDIImpuesto
                (
                    IdCFDIImpuesto,
                    IdFactura,
                    IdTipoImpuesto,
                    Impuesto,
                    TipoFactor,
                    Tasa,
                    Importe,
                    IdEliminacion
                )
                SELECT IdCFDIImpuesto,
                       IdFactura,
                       IdTipoImpuesto,
                       Impuesto,
                       TipoFactor,
                       Tasa,
                       Importe,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_CFDIImpuesto (NOLOCK) 
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );
                DELETE Adinco.dbo.FI_CFDIImpuesto
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );

                INSERT INTO dbo.PR_FI_Documento
                (
                    IdDocumento,
                    Documento,
                    IdTipoDocumento,
                    IdFactura,
                    IdPedimentoComprobante,
                    IdDocFacturacionSIPAC,
                    NombreExtensionArchivo,
                    IdUsuario,
                    FechaCarga,
                    IsEliminado,
                    DocumentoByte,
                    IdEliminacion
                )
                SELECT IdDocumento,
                       Documento,
                       IdTipoDocumento,
                       IdFactura,
                       IdPedimentoComprobante,
                       IdDocFacturacionSIPAC,
                       NombreExtensionArchivo,
                       IdUsuario,
                       FechaCarga,
                       IsEliminado,
                       DocumentoByte,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_Documento (NOLOCK) 
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   )
                      AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento 
                DELETE Adinco.dbo.FI_Documento
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   )
                      AND IdTipoDocumento = 1; --> ES TIPO FACTURA --> FI_TipoDocumento

                /*PROCESO DE ELIMINACIÓN EN ADINCO RESPALDO DE LOS ELIMINADO EN TABLAS PR(PAPELERA RECICLAJE) DE PETROVENDOR Y LUEGO ELIMINACION FISICA*/
				INSERT INTO dbo.PR_FI_ArchivoXml
				(
				    ArchivoXml,
				    HashSHA256,
				    IdFactura,
				    IdContrato,
				    CreadoPor,
				    CreadoEl,
				    ModificadoPor,
				    ModificadoEl,
				    Activo,
				    IdEliminacion
				)
				SELECT
					ArchivoXml,
					HashSHA256,
					IdFactura,
					IdContrato,
					CreadoPor,
					CreadoEl,
					ModificadoPor,
					ModificadoEl,
					Activo,
					@IDELIMINACION
				FROM Adinco.dbo.FI_ArchivoXml (NOLOCK) 
				WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );
                DELETE Adinco.dbo.FI_ArchivoXml
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );

                INSERT INTO dbo.PR_FI_Factura
                (
                    IdFactura,
                    Serie,
                    Folio,
                    Fecha,
                    Sello,
                    FormaPago,
                    NoCertificado,
                    Certificado,
                    CondicionesDePago,
                    SubTotal,
                    Descuento,
                    TipoCambio,
                    Moneda,
                    MontoConIva,
                    TipoComprobante,
                    MetodoPago,
                    LugarExpedicion,
                    NumCtaPago,
                    Emisor,
                    Receptor,
                    UUID,
                    FechaTimbrado,
                    SelloCFD,
                    NoCertificadoSAT,
                    SelloSAT,
                    Tipo,
                    FechaRecepcion,
                    IdSubcontratista,
                    IdMoneda,
                    IdContrato,
                    XML,
                    Activa,
                    ArchivoPDF,
                    ArchivoXML,
                    CreadoPor,
                    CreadoEn,
                    ModificadoPor,
                    ModificadoEn,
                    --PDF,
                    --IdReceptor,
                    --IdentificadorSIPAC,
                    NombreXML,
                    IdEstudioPrecioTransfer,
                    IdDocFacturacionSIPAC,
                    ProcesadoSIPAC,
                    --ClaveFormaPago,
                    RegimenFiscal,
                    UsoCFDI,
                    VersionCFDI,
                    --HashSHA256,
                    --UUIDRelacionado,
                    --TipoRelacion,
                    --NoParcialidad,
                    IdEliminacion
                )
                SELECT IdFactura,
                       Serie,
                       Folio,
                       Fecha,
                       Sello,
                       FormaPago,
                       NoCertificado,
                       Certificado,
                       CondicionesDePago,
                       SubTotal,
                       Descuento,
                       TipoCambio,
                       Moneda,
                       MontoConIva,
                       TipoComprobante,
                       MetodoPago,
                       LugarExpedicion,
                       NumCtaPago,
                       Emisor,
                       Receptor,
                       UUID,
                       FechaTimbrado,
                       SelloCFD,
                       NoCertificadoSAT,
                       SelloSAT,
                       Tipo,
                       FechaRecepcion,
                       IdSubcontratista,
                       IdMoneda,
                       IdContrato,
                       XML,
                       Activa,
                       ArchivoPDF,
                       ArchivoXML,
                       CreadoPor,
                       CreadoEn,
                       ModificadoPor,
                       ModificadoEn,
                       --PDF,
                       --IdReceptor,
                       --IdentificadorSIPAC,
                       NombreXML,
                       IdEstudioPrecioTransfer,
                       IdDocFacturacionSIPAC,
                       ProcesadoSIPAC,
                       --ClaveFormaPago,
                       RegimenFiscal,
                       UsoCFDI,
                       VersionCFDI,
                       --HashSHA256,
                       --UUIDRelacionado,
                       --TipoRelacion,
                       --NoParcialidad,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_Factura (NOLOCK) 
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );
                DELETE Adinco.dbo.FI_Factura
                WHERE IdFactura IN (
                                       SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
                                   );

                /*ACTUALIZAR ESTATUS DE ELIMINACIÓN DE PROCURA*/
                /*FACTURA EN FI_FACTURA*/
                UPDATE F
                SET F.IsEliminado = 1,
                    F.EliminadoEL = GETDATE(),
                    F.ComentarioEliminado = '',
                    F.EliminadoPor = 0,
                    F.Activa = 0,
                    F.IdEliminado = @IDELIMINACION
                FROM dbo.FI_Factura F  (NOLOCK)
                    INNER JOIN #VALIDACION_FACTURA VF
                        ON F.IdFactura = VF.IdFacturaPetronvendor;

                /*APROBACIÓN FACTURA EN PROCESO DE MM_AceptacionFactura*/
                UPDATE AF
                SET AF.IdEstatusEliminado = 1,
                    AF.IdEliminado = @IDELIMINACION
                FROM dbo.MM_AceptacionFactura AF  (NOLOCK)
                    INNER JOIN #PROCESO P
                        ON AF.IdAceptacionFactura = P.ID_PROCESO
                           AND P.CLAVE_PROCESO = 'aceptacionfactura';

                /*APROBACIÓN CARTA CONTENIDO NACIONAL EN PROCESO DE MM_AceptacionCartaPCN*/
                UPDATE AC
                SET AC.IdEstatusEliminado = 1,
                    AC.IdEliminado = @IDELIMINACION
                FROM dbo.MM_AceptacionCartaPCN AC (NOLOCK)
                    INNER JOIN #PROCESO P
                        ON AC.IdAceptacionCartaPCN = P.ID_PROCESO
                           AND P.CLAVE_PROCESO = 'aceptacioncn';

                /*ACEPTACION DE PEDIDO EN PROCESO DE MM_AceptacionPedido*/
                UPDATE dbo.MM_AceptacionPedido
                SET IdEstatusEliminado = 1,
                    IdEliminado = @IDELIMINACION,
					Activo = 0
                WHERE IdAceptacionPedido = @IDACEPTACIONPEDIDO;

                /*PROCESO DE ELIMINACION DE COMPROBANTES EXTRANTEJEROS*/
                INSERT INTO dbo.PR_FI_Documento
                (
                    IdDocumento,
                    Documento,
                    IdTipoDocumento,
                    IdFactura,
                    IdPedimentoComprobante,
                    IdDocFacturacionSIPAC,
                    NombreExtensionArchivo,
                    IdUsuario,
                    FechaCarga,
                    IsEliminado,
                    DocumentoByte,
                    IdEliminacion
                )
                SELECT IdDocumento,
                       Documento,
                       IdTipoDocumento,
                       IdFactura,
                       IdPedimentoComprobante,
                       IdDocFacturacionSIPAC,
                       NombreExtensionArchivo,
                       IdUsuario,
                       FechaCarga,
                       IsEliminado,
                       DocumentoByte,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_Documento (NOLOCK) 
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );
                DELETE FROM Adinco.dbo.FI_Documento
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );

                INSERT INTO dbo.PR_FI_PedimentoComprobanteDetalle
                (
                    IdPedimentoComprobanteDetalle,
                    IdPedimentoComprobante,
                    IdUnidadMedida,
                    NumeroSerieMercancia,
                    DescripcionMercancia,
                    ClaseBienServicio,
                    PrecioUnitario,
                    Cantidad,
                    ImporteTotal,
                    CreadoPor,
                    CreadoEn,
                    ModificadoPor,
                    ModificadoEn,
                    IdEliminacion
                )
                SELECT IdPedimentoComprobanteDetalle,
                       IdPedimentoComprobante,
                       IdUnidadMedida,
                       NumeroSerieMercancia,
                       DescripcionMercancia,
                       ClaseBienServicio,
                       PrecioUnitario,
                       Cantidad,
                       ImporteTotal,
                       CreadoPor,
                       CreadoEn,
                       ModificadoPor,
                       ModificadoEn,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_PedimentoComprobanteDetalle (NOLOCK) 
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );
                DELETE Adinco.dbo.FI_PedimentoComprobanteDetalle
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );

                INSERT INTO dbo.PR_FI_PedimentoComprobante
                (
                    IdPedimentoComprobante,
                    IdContrato,
                    NumeroPedimento,
                    ClavePedimento,
                    FolioComprobante,
                    FechaPago,
                    Regimen,
                    IdSubcontratistaImportador,
                    AduanaES,
                    IdSubcontratistaExportador,
                    IdFormaPago,
                    IdMoneda,
                    AcuseElectronico,
                    IdEstudioPrecioTransfer,
                    IdDocFacturacionSIPAC,
                    CvTipoDocFacturacion,
                    ProcesadoSIPAC,
                    CreadoPor,
                    CreadoEn,
                    ModificadoPor,
                    ModificadoEn,
                    HashSHA256,
                    Activo,
                    IdOrigen,
                    IdPedimentoComprobantePetrovendor,
                    FechaIntercambio,
                    FechaModificacionIntercambio,
                    IdEliminacion
                )
                SELECT IdPedimentoComprobante,
                       IdContrato,
                       NumeroPedimento,
                       ClavePedimento,
                       FolioComprobante,
                       FechaPago,
                       Regimen,
                       IdSubcontratistaImportador,
                       AduanaES,
                       IdSubcontratistaExportador,
                       IdFormaPago,
                       IdMoneda,
                       AcuseElectronico,
                       IdEstudioPrecioTransfer,
                       IdDocFacturacionSIPAC,
                       CvTipoDocFacturacion,
                       ProcesadoSIPAC,
                       CreadoPor,
                       CreadoEn,
                       ModificadoPor,
                       ModificadoEn,
                       HashSHA256,
                       Activo,
                       IdOrigen,
                       IdPedimentoComprobantePetrovendor,
                       FechaIntercambio,
                       FechaModificacionIntercambio,
                       @IDELIMINACION
                FROM Adinco.dbo.FI_PedimentoComprobante (NOLOCK) 
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );
                DELETE dbo.FI_PedimentoComprobante
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );


                UPDATE dbo.FI_PedimentoComprobante
                SET IdEstatusEliminado = 1,
                    IdEliminado = @IDELIMINACION,
					IsActivo = 0
                WHERE IdPedimentoComprobante IN (
                                                    SELECT ID_PROCESO
                                                    FROM #PROCESO
                                                    WHERE CLAVE_PROCESO = 'aprobacionextranjera'
                                                );

                COMMIT TRAN tran1;
                SELECT 'SUCCESS',
                       ISNULL(@IDELIMINACION, 0),
                       'ELIMINACION FINALIZADA CORRECTAMENTE';
            END;
            ELSE
            BEGIN
                ROLLBACK TRAN tran1;
                SELECT 'ELIMINACION_CANCELADA',
                       'SE ENCONTRARON PROCESOS EN ADINCO';
            END;
        END;
        ELSE
        BEGIN
            ROLLBACK TRAN tran1;
            SELECT 'ELIMINACION_NO_DISPONIBLE',
                   'NO SE ENCONTRO NINGUNA ACEPTACIÓN DE PEDIDO CON LOS DATOS INGRESADOS';
        END;

    END TRY
    BEGIN CATCH
        ROLLBACK TRAN tran1;
        SELECT 'ERROR_PROCESO',
               ERROR_NUMBER() AS ErrorNumber,
               ERROR_SEVERITY() AS ErrorSeverity,
               ERROR_STATE() AS ErrorState,
               ERROR_PROCEDURE() AS ErrorProcedure,
               ERROR_LINE() AS ErrorLine,
               ERROR_MESSAGE() AS ErrorMessage;
    END CATCH;


END;


