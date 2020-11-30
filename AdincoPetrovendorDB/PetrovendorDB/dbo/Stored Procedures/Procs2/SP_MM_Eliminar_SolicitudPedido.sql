-- =============================================
-- Author:	DANIEL AC
-- Create date: 29/06/2018
-- Description: ELIMINACIÓN DE SOLICITUD DE PEDIDO - MODIFICACIÓN
-- =============================================
-- Author:	DANIEL AC
-- Create date: 24-09-2018
-- Description: Correccion de eliminado
-- =============================================
-- Author:	Alexander Gomez
-- Create date: 02/01/2020
-- Description: agregado de eliminado de FI_ArchivoXML de adinco
-- =============================================

CREATE PROCEDURE [dbo].[SP_MM_Eliminar_SolicitudPedido] --14491, 420, 3, 'Comentario Interno prueba', 'Comentario externo prueba', 2205, 1
    @IDSOLICITUDPEDIDO INT,
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

        /*VALIDAR SOLICITUD DE PEDIDO ESTE ACTIVOY DISPONIBLE PARA ELIMINAR*/
        DECLARE @DISPONIBLE_ELIMINACION INT = (
                                                  SELECT COUNT(IdSolicitudPedido)
                                                  FROM dbo.MM_SolicitudPedido
                                                  WHERE IdSolicitudPedido = @IDSOLICITUDPEDIDO
                                                        AND IdProveedor = @IDPROVEEDOR
                                                        AND ISNULL(IdEstatusEliminado, 0) = 0
                                              );


        IF @DISPONIBLE_ELIMINACION > 0
        BEGIN
            /*INICIA PROCESO DE ELIMINACION DE PEDIDO*/

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

            /*CONSULTA DE SOLICITUD DE PEDIDO*/
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
                   CONCAT('Solicitud de pedido No.', IdSolicitudPedido),
                   '',
                   0,
                   'solicitudpedido',
                   IdSolicitudPedido
            FROM dbo.MM_SolicitudPedido
            WHERE IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND ISNULL(IdEstatusEliminado, 0) <> 1;

            /*CONSULTA DE APROBACIÓN  SOLICITUD DE PEDIDO*/
            INSERT INTO #PROCESO
            (
                ID_PADRE,
                PROCESO,
                ESTATUS,
                CLASS,
                CLAVE_PROCESO,
                ACCION_EJECUTAR,
                ID_PROCESO
            )
            SELECT 1,
                   CONCAT('Aprobación de solicitud de pedido No.', O.IdOperacion),
                   '',
                   '',
                   'aprobacionsp',
                   '',
                   O.IdOperacion
            FROM dbo.MM_SolicitudPedido AS SP
                INNER JOIN dbo.TA_Operacion AS O
                    ON O.IdDocumento = SP.IdSolicitudPedido
                INNER JOIN dbo.TA_Estatus AS E
                    ON E.IdEstatus = O.IdEstatusOperacion
            WHERE IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND O.IdTipoOperacion = 2 -->APROBACIÓN DE SOLICITUD DE PEDIDO
                  AND ISNULL(SP.IdEstatusEliminado, 0) <> 1;


            /*CONSULTA DE OPERACION DE COTIZACIÓN*/
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
                   CONCAT('Cotización No.', SP.IdSolicitudPedido),
                   0,
                   0,
                   'operacion_oferta',
                   O.IdOperacion
            FROM dbo.MM_SolicitudPedido SP
                INNER JOIN dbo.TA_Operacion O
                    ON O.IdDocumento = SP.IdSolicitudPedido
            WHERE SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND O.IdTipoOperacion = 6 ---> OPERACIÓN DE COTIZACIÓN ES DONDE SE TIENE LA FECHA DE FINALIZACIÓN DE LA COTIZACIÓN
                  AND ISNULL(SP.IdEstatusEliminado, 0) <> 1 --> QUE NO ESTE ELIMINADA
            GROUP BY O.IdOperacion,
                     SP.IdSolicitudPedido;


            /*CONSULTA DE COTIZACIONES A ELIMINAR*/
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
                   CONCAT('Cotización ', PO.IdPeticionOferta),
                   0,
                   0,
                   'cotizacion',
                   PO.IdPeticionOferta
            FROM dbo.MM_PeticionOferta PO
                INNER JOIN dbo.MM_SolicitudPedido SP
                    ON PO.IdSolicitudPedido = SP.IdSolicitudPedido
            WHERE PO.IdSolicitudPedido = PO.IdSolicitudPedido
                  AND SP.IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND ISNULL(PO.IdEstatusEliminado, 0) <> 1;

            /*CONSULTA APROBACIÓN DE PEDIDO*/

            INSERT INTO #PROCESO
            (
                ID_PADRE,
                PROCESO,
                ESTATUS,
                CLASS,
                CLAVE_PROCESO,
                ACCION_EJECUTAR,
                ID_PROCESO
            )
            SELECT 0,
                   CONCAT('Aprobación de pedido No.', O.IdOperacion),
                   E.Nombre,
                   '',
                   'aprobacionpedido',
                   '',
                   O.IdOperacion
            FROM dbo.MM_SolicitudPedido AS SP
                INNER JOIN dbo.TA_Operacion AS O
                    ON O.IdDocumento = SP.IdSolicitudPedido
                INNER JOIN dbo.TA_Estatus AS E
                    ON E.IdEstatus = O.IdEstatusOperacion
            WHERE IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
                  AND ISNULL(O.IdEstatusEliminado, 0) <> 1
            GROUP BY O.IdOperacion,
                     E.Nombre
            ORDER BY O.IdOperacion ASC;


            /*CONSULTA DE PEDIDO A ELIMINAR*/
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
                   CONCAT('Pedido ', PG.IdPedido),
                   (PV.RazonSocial + ' ' + ISNULL(PV.RegimenCapital, '')),
                   '',
                   'pedido',
                   P.IdPedido
            FROM TA_Operacion AS O
                INNER JOIN MM_Pedido AS P
                    ON O.IdDocumento = P.IdSolicitudPedido
                INNER JOIN S_Proveedor AS PV
                    ON PV.IdProveedor = P.IdSubcontratista
                INNER JOIN TA_Estatus AS E
                    ON E.IdEstatus = O.IdEstatusOperacion
                LEFT JOIN PV_TipoMoneda AS TM
                    ON TM.IdMoneda = P.IdMoneda
                INNER JOIN MM_Pedidos AS PG
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IDPROVEEDOR
                LEFT JOIN MM_TipoPedido AS TP
                    ON TP.IdTipoPedido = PG.IdTipoPedido
            WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO
                  AND O.IdProveedor = @IDPROVEEDOR
                  AND P.IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND O.NoVersion = P.Version
                  AND ISNULL(P.IdEstatusEliminado, 0) <> 1
            GROUP BY P.IdPedido,
                     PV.RazonSocial,
                     PV.RegimenCapital,
                     PG.IdPedido;


            /*ACEPTACIONES DE PEDIDO DISPONIBLES PARA ELIMINAR*/
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
                   CONCAT('Aceptación de servicio No.', AP.IdAceptacionPedido),
                   0,
                   1,
                   'aceptacionpedido',
                   AP.IdAceptacionPedido
            FROM TA_Operacion AS O
                INNER JOIN MM_Pedido AS P
                    ON O.IdDocumento = P.IdSolicitudPedido
                INNER JOIN MM_AceptacionPedido AS AP
                    ON P.IdPedido = AP.IdPedido
                INNER JOIN MM_HorasVigenciaPedido AS HV
                    ON P.IdPedido = HV.IdPedido
                INNER JOIN S_Proveedor AS PV
                    ON PV.IdProveedor = P.IdSubcontratista
                INNER JOIN TA_Estatus AS E
                    ON E.IdEstatus = O.IdEstatusOperacion
                INNER JOIN PV_TipoMoneda AS TM
                    ON TM.IdMoneda = P.IdMoneda
                INNER JOIN MM_Pedidos AS PG
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IDPROVEEDOR
                INNER JOIN #PROCESO AS PP
                    ON PP.ID_PROCESO = AP.IdPedido
                LEFT JOIN MM_TipoPedido AS TP
                    ON TP.IdTipoPedido = PG.IdTipoPedido
            WHERE O.IdTipoOperacion = 9 --> APROBACIÓN DE PEDIDO APROBADA
                  AND O.IdEstatusOperacion = 2 --> APROBADA
                  AND O.IdProveedor = @IDPROVEEDOR
                  AND O.NoVersion = P.Version
                  AND ISNULL(AP.IdEstatusEliminado, 0) <> 1
                  AND PP.CLAVE_PROCESO = 'pedido'
                  AND P.IdSolicitudPedido = @IDSOLICITUDPEDIDO
            GROUP BY P.IdPedido,
                     PV.RazonSocial,
                     PV.RegimenCapital,
                     PG.IdPedido,
                     P.RecepcionServicio,
                     HV.FechaVigencia,
                     O.IdEstatusOperacion,
                     AP.IdAceptacionPedido;


            /*SELECT * FROM #PROCESO*/
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
            SELECT PAP.ID,
                   CONCAT('Aceptación de Carta Contenido Nacional No.', AP.IdAceptacionPedido),
                   TD.TipoValidacion,
                   AC.IdEstatus,
                   'aceptacioncn',
                   AC.IdAceptacionCartaPCN
            FROM MM_AceptacionPedido AS AP
                INNER JOIN MM_Pedido AS P
                    ON P.IdPedido = AP.IdPedido
                INNER JOIN MM_AceptacionCartaPCN AS AC
                    ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                INNER JOIN S_Documento_S3 AS D
                    ON D.IdDocumento = AC.IdDocumento
                INNER JOIN S_TipoValidacionDoc AS TD
                    ON TD.IdTipoValidacionDoc = AC.IdEstatus
                INNER JOIN S_Proveedor AS PV
                    ON PV.IdProveedor = P.IdSubcontratista
                INNER JOIN MM_Pedidos AS PG
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IDPROVEEDOR
                INNER JOIN #PROCESO AS PP
                    ON PP.ID_PROCESO = AP.IdPedido
                INNER JOIN #PROCESO AS PAP
                    ON PAP.ID_PROCESO = AP.IdAceptacionPedido
                LEFT JOIN MM_TipoPedido AS TP
                    ON TP.IdTipoPedido = PG.IdTipoPedido
            WHERE ISNULL(AC.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
                  AND PAP.CLAVE_PROCESO = 'aceptacionpedido'
                  AND PP.CLAVE_PROCESO = 'pedido'
                  AND P.IdSolicitudPedido = @IDSOLICITUDPEDIDO
            GROUP BY AC.IdAceptacionCartaPCN,
                     TD.TipoValidacion,
                     AP.IdAceptacionPedido,
                     AC.IdEstatus,
                     PAP.ID;

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
            FROM MM_AceptacionFactura AS AF
                INNER JOIN TA_Operacion AS O
                    ON O.IdDocumento = AF.IdAceptacionFactura
                INNER JOIN TA_Estatus AS E
                    ON E.IdEstatus = O.IdEstatusOperacion
                INNER JOIN MM_AceptacionPedido AS AP
                    ON AP.IdAceptacionPedido = AF.IdAceptacionPedido
                INNER JOIN MM_Pedido AS P
                    ON P.IdPedido = AP.IdPedido
                INNER JOIN MM_AceptacionCartaPCN AS AC
                    ON AP.IdAceptacionPedido = AC.IdAceptacionPedido
                INNER JOIN S_Documento_S3 AS D
                    ON D.IdDocumento = AC.IdDocumento
                INNER JOIN S_TipoValidacionDoc AS TD
                    ON TD.IdTipoValidacionDoc = AC.IdEstatus
                INNER JOIN S_Proveedor AS PV
                    ON PV.IdProveedor = P.IdSubcontratista
                INNER JOIN MM_Pedidos AS PG
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = AP.IdProveedor
                INNER JOIN #PROCESO AS TEM_CN
                    ON TEM_CN.ID_PROCESO = AC.IdAceptacionCartaPCN
                LEFT JOIN MM_TipoPedido AS TP
                    ON TP.IdTipoPedido = PG.IdTipoPedido
            WHERE TEM_CN.CLAVE_PROCESO = 'aceptacioncn'
                  AND P.IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND TEM_CN.IDESTATUS = 2 --> CN APROBADA
                  AND ISNULL(AF.IdEstatusEliminado, 0) <> 1; --> QUE NO SE ENCUENTREN ELIMINADAS 

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
            SELECT PAP.ID,
                   CONCAT('Recepción de comprobante extranjero No.', AP.IdAceptacionPedido),
                   E.Nombre,
                   O.IdEstatusOperacion,
                   'aprobacionextranjera',
                   PC.IdPedimentoComprobante
            FROM MM_AceptacionPedido AS AP
                INNER JOIN MM_Pedido AS P
                    ON P.IdPedido = AP.IdPedido
                INNER JOIN S_Proveedor AS PV
                    ON PV.IdProveedor = P.IdSubcontratista
                INNER JOIN MM_Pedidos AS PG
                    ON P.IdPedido = PG.IdIdentificador
                       AND PG.IdProveedorCliente = @IDPROVEEDOR
                LEFT JOIN MM_TipoPedido AS TP
                    ON TP.IdTipoPedido = PG.IdTipoPedido
                INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APC
                    ON APC.IdAceptacionPedido = AP.IdAceptacionPedido
                INNER JOIN dbo.FI_PedimentoComprobante PC
                    ON PC.IdPedimentoComprobante = APC.IdPedimentoComprobante
                INNER JOIN dbo.TA_Operacion O
                    ON O.IdDocumento = PC.IdPedimentoComprobante
                       AND O.IdTipoOperacion = 16 -->APROBACIÓN DE COMPROBANTE EXTRANJERO
                LEFT JOIN dbo.TA_Estatus AS E
                    ON E.IdEstatus = O.IdEstatusOperacion
                INNER JOIN #PROCESO PAP
                    ON PAP.ID_PROCESO = AP.IdAceptacionPedido
            WHERE ISNULL(AP.IdNacionalidadProveedor, 0) = 2 --> NACIONALIDAD EXTRANJERA
                  AND P.IdSolicitudPedido = @IDSOLICITUDPEDIDO
                  AND PAP.CLAVE_PROCESO = 'aceptacionpedido'
                  AND ISNULL(PC.IdEstatusEliminado, 0) <> 1; --> QUE NO SE ENCUENTREN ELIMINADAS 

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
                INNER JOIN dbo.FI_PedimentoComprobante PP
                    ON PP.IdPedimentoComprobante = P.ID_PROCESO
                INNER JOIN dbo.FI_AceptacionPedido_PedimentoComprobante APP
                    ON APP.IdPedimentoComprobante = PP.IdPedimentoComprobante
                INNER JOIN dbo.MM_AceptacionPedido AP
                    ON AP.IdAceptacionPedido = APP.IdAceptacionPedido
                INNER JOIN Adinco.dbo.FI_PedimentoComprobante PA
                    ON PA.IdPedimentoComprobantePetrovendor = PP.IdPedimentoComprobante
            WHERE CLAVE_PROCESO = 'aprobacionextranjera'
                  AND ISNULL(PP.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
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
                INNER JOIN Adinco.dbo.CO_Registro R
                    ON VP.IdPedimentoAdinco = R.IdPedimentoComprobante
            GROUP BY VP.IdValidacion;

            UPDATE VP
            SET VP.TieneGastos = PG.Gastos
            FROM #VALIDACION_PEDIMENTO VP
                INNER JOIN #PEDIMENTO_GASTOS PG
                    ON PG.IdValidacion = VP.IdValidacion;

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
                INNER JOIN Adinco.dbo.FI_TransferFactura T
                    ON VP.IdPedimentoAdinco = T.IdPedimentoComprobante
            GROUP BY VP.IdValidacion;

            UPDATE VP
            SET VP.TieneTransferencias = PT.Tranferencias
            FROM #VALIDACION_PEDIMENTO VP
                INNER JOIN #PEDIMENTO_TRANFERENCIAS PT
                    ON PT.IdValidacion = VP.IdValidacion;


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
                INNER JOIN dbo.MM_AceptacionFactura AS AF
                    ON AF.IdAceptacionFactura = TEM.ID_PROCESO
                INNER JOIN dbo.FI_Factura AS FP
                    ON FP.IdFactura = AF.IdFactura
                LEFT JOIN Adinco.dbo.FI_Factura AS FA
                    ON FA.UUID = FP.UUID COLLATE SQL_Latin1_General_CP1_CI_AS
            WHERE CLAVE_PROCESO = 'aceptacionfactura'
                  AND ISNULL(AF.IdEstatusEliminado, 0) <> 1 --> QUE NO SE ENCUENTREN ELIMINADAS 
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
                INNER JOIN Adinco.dbo.CO_Registro R
                    ON R.IdFactura = VF.IdFacturaAdinco
            WHERE VF.IdFacturaAdinco IS NOT NULL
            GROUP BY VF.IdValidacion;

            /*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LOS GASTOS*/
            UPDATE VF
            SET VF.TieneGastos = FG.Gastos
            FROM #VALIDACION_FACTURA VF
                INNER JOIN #FACTURAS_GASTOS FG
                    ON FG.IdValidacion = VF.IdValidacion;

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
                INNER JOIN Adinco.dbo.FI_TransferFactura T
                    ON T.IdFactura = VF.IdFacturaAdinco
            WHERE VF.IdFacturaAdinco IS NOT NULL
            GROUP BY VF.IdValidacion;

            /*ACTUALIZAR GASTOS EN #VALIDACION_FACTURA CON LAS TRANSFERENCIAS*/
            UPDATE VF
            SET VF.TieneTransferencias = FT.Tranferencias
            FROM #VALIDACION_FACTURA VF
                INNER JOIN #FACTURAS_TRANFERENCIAS FT
                    ON FT.IdValidacion = VF.IdValidacion;

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

            /*VALIDAR POR 2DA VEZ QUE NO SE TENGA GASTOS O TRANFERENCIAS*/
            IF @TIENE_GASTOS = 0
               AND @TIENE_TRANSFERERENCIAS = 0
               AND @TIENE_GASTOS_PEDIMENTO = 0
               AND @TIENE_TRANSFERERENCIAS_PEDIMENTO = 0
            BEGIN
                /*ELIMINAR FACTURAS EN ADINCO */

                --SELECT * FROM #PROCESO
                --DECLARE @IDELIMINACION INT = 0

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
                    N'SP',               -- TipoEliminacion - nvarchar(100)
                    1,                   -- Activo - bit
                    @IDPROVEEDOR,        -- IdProveedor -- int
                    @IDCONTRATO,         -- IdContrato -- int 
                    @IDSOLICITUDPEDIDO,  -- IdProceso --int
                    @CONFIRMACION        --Confirmacion bit
                );

                DECLARE @IDELIMINACION INT = (
                                                 SELECT @@IDENTITY
                                             );


				DELETE Adinco.dbo.FI_CFDIConceptoImpuesto WHERE IdFacturaConcepto IN (
                                       SELECT IdFacturaConcepto FROM Adinco.dbo.FI_CFDIConcepto WHERE IdFactura IN (SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA)
                                   );

                --SELECT * FROM #VALIDACION_FACTURA 

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
                FROM Adinco.dbo.FI_CFDIConcepto
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
                FROM Adinco.dbo.FI_CFDIImpuesto
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
                FROM Adinco.dbo.FI_Documento
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
                
				DELETE Adinco.dbo.FI_CFDIRelacionados WHERE CFDIId IN (
																		SELECT IdFacturaAdinco FROM #VALIDACION_FACTURA
																	);

				DELETE Adinco.dbo.FI_ArchivoXml WHERE IdFactura IN (
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
                FROM Adinco.dbo.FI_Factura
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
                    F.EliminadoPor = @IDUSUARIO,
                    F.Activa = 0,
                    F.IdEliminado = @IDELIMINACION
                FROM dbo.FI_Factura F
                    INNER JOIN #VALIDACION_FACTURA VF
                        ON VF.IdFacturaPetronvendor = F.IdFactura;

                /*APROBACIÓN FACTURA EN PROCESO DE MM_AceptacionFactura*/
                UPDATE AF
                SET AF.IdEstatusEliminado = 1,
                    AF.IdEliminado = @IDELIMINACION
                FROM dbo.MM_AceptacionFactura AF
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = AF.IdAceptacionFactura
                           AND P.CLAVE_PROCESO = 'aceptacionfactura';

                /*APROBACIÓN CARTA CONTENIDO NACIONAL EN PROCESO DE MM_AceptacionCartaPCN*/
                UPDATE AC
                SET AC.IdEstatusEliminado = 1,
                    AC.IdEliminado = @IDELIMINACION
                FROM dbo.MM_AceptacionCartaPCN AC
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = AC.IdAceptacionCartaPCN
                           AND P.CLAVE_PROCESO = 'aceptacioncn';

                /*ACEPTACION DE PEDIDO EN PROCESO DE MM_AceptacionPedido*/
                UPDATE AP
                SET IdEstatusEliminado = 1,
                    IdEliminado = @IDELIMINACION
                FROM dbo.MM_AceptacionPedido AP
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = AP.IdAceptacionPedido
                           AND P.CLAVE_PROCESO = 'aceptacionpedido';

                /*ELIMINACIÓN DE PEDIDOS*/
                UPDATE P
                SET P.IdEstatusEliminado = 1,
                    P.IdEliminado = @IDELIMINACION
                FROM dbo.MM_Pedido P
                    INNER JOIN #PROCESO PP
                        ON P.IdPedido = PP.ID_PROCESO
                           AND PP.CLAVE_PROCESO = 'pedido';

                /*ELIMINACION DE APROBACIÓN DE PEDIDO*/
                UPDATE O
                SET O.IdEstatusEliminado = 1,
                    O.IdEliminado = @IDELIMINACION
                FROM dbo.TA_Operacion O
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = O.IdOperacion
                           AND P.CLAVE_PROCESO = 'aprobacionpedido';

                /*ELIMINACION DE APROBACIÓN DE SOLICITUD DE PEDIDO*/
                UPDATE O
                SET O.IdEstatusEliminado = 1,
                    O.IdEliminado = @IDELIMINACION
                FROM dbo.TA_Operacion O
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = O.IdOperacion
                           AND P.CLAVE_PROCESO = 'aprobacionsp';

                /*ELIMINACION DE COTIZACIONES*/
                UPDATE PO
                SET PO.IdEstatusEliminado = 1,
                    PO.IdEliminado = @IDELIMINACION
                FROM dbo.MM_PeticionOferta PO
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = PO.IdPeticionOferta
                           AND P.CLAVE_PROCESO = 'cotizacion';

                /*ELIMINACIÓN DE OPERACIÓN DE OFERTA-COTIZACIONES*/
                UPDATE O
                SET O.IdEstatusEliminado = 1,
                    O.IdEliminado = @IDELIMINACION
                FROM dbo.TA_Operacion O
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = O.IdOperacion
                WHERE O.IdTipoOperacion = 6 --> OPERACIÓN DE OFERTA - COTIZACIÓN
                      AND P.CLAVE_PROCESO = 'operacion_oferta';


                /*ELIMINACION DE SOLICITUD DE PEDIDO*/
                UPDATE SP
                SET IdEstatusEliminado = 1,
                    IdEliminado = @IDELIMINACION
                FROM dbo.MM_SolicitudPedido SP
                    INNER JOIN #PROCESO P
                        ON P.ID_PROCESO = SP.IdSolicitudPedido
                WHERE P.CLAVE_PROCESO = 'solicitudpedido';


                /*PROCESO DE ELIMINACION DE COMPROBANTES EXTRANJEROS*/
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
                FROM Adinco.dbo.FI_Documento
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
                FROM Adinco.dbo.FI_PedimentoComprobanteDetalle
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
                FROM Adinco.dbo.FI_PedimentoComprobante
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );
                DELETE dbo.FI_PedimentoComprobante
                WHERE IdPedimentoComprobante IN (
                                                    SELECT IdPedimentoAdinco FROM #VALIDACION_PEDIMENTO
                                                );

                UPDATE dbo.FI_PedimentoComprobante
                SET IdEstatusEliminado = 1,
                    IdEliminado = @IDELIMINACION
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
                   'NO SE ENCONTRO NINGUNA SOLICITUD DE PEDIDO CON LOS DATOS INGRESADOS';
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