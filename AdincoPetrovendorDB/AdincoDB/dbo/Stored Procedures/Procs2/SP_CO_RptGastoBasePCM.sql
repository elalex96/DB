CREATE PROCEDURE [dbo].[SP_CO_RptGastoBasePCM]
    --[SP_CO_RptGastoBase] 3,1,3
    --[SP_CO_RptGastoBase] 3,1,10042
    --[SP_CO_RptGastoBase] 10036,1,10061
    -- Add the parameters for the stored procedure here
    @IdContrato    INT,
    @IdUsuario     INT,
    @IdPresupuesto INT
AS
     BEGIN
    -- =============================================
    -- Author:		Manuel Cruz
    -- Create date: 2018-10-24
    -- Description:	Reporte de Presupuesto
    -- =============================================

    SET NOCOUNT ON;
    --Temporal para el reporte
    CREATE TABLE #RptGastos
    (
        IdRegistro INT,
        Servicio NVARCHAR(MAX),
        InstalacionPresupuestada NVARCHAR(MAX),
        FechaInicio DATE,
        FechaFin DATE,
        TipoDocumento NVARCHAR(MAX),
        Numero NVARCHAR(MAX),
        FechaDocumento DATETIME,
        [Registrado ADINCO] FLOAT,
        [Pagado ADINCO] FLOAT,
        Subcontratista NVARCHAR(MAX),
        InstalacionRegistro NVARCHAR(MAX),
        InicioEjecucion DATE,
        FinEjecucion DATE,
        CreadoPor NVARCHAR(MAX),
        MontoRegistroOriginal FLOAT,
        Moneda NVARCHAR(MAX),
        MesPresentacion DATE,
        TipoDeServicio NVARCHAR(MAX),
        ActividadPetrolera NVARCHAR(MAX),
        SubactividadPetrolera NVARCHAR(MAX),
        TareaPetrolera NVARCHAR(MAX),
        EstadoValidacion NVARCHAR(MAX),
        Area NVARCHAR(MAX),
        Comentarios NVARCHAR(MAX),
        Anexo4 NVARCHAR(MAX),
        Identificador INT,
        LineaPresupuesto INT,
        Presupuesto NVARCHAR(MAX),
        Rubro NVARCHAR(MAX),
        PCN FLOAT,
        CAA NVARCHAR(MAX),
        Deuda FLOAT,
        OCAprobadas FLOAT
    );

    /**/

    CREATE TABLE #Pagado
    (
        ActividadPetrolera NVARCHAR(50) NULL,
        SubactividadPetrolera NVARCHAR(100) NULL,
        TareaPetrolera NVARCHAR(500) NULL,
        SubTareaPetrolera NVARCHAR(4000) NULL,
        Pagado FLOAT,
        Identificador INT,
        Contador INT
    );

    /**/

    CREATE TABLE #FACTURAS
    (
        IdFACTURA INT,
        MontoPagado FLOAT,
        Proporcion FLOAT
    );

    /**/

    CREATE TABLE #contador
    (
        Identificador INT,
        CantGastos INT
    );

    /**/

    CREATE TABLE #Registrado
    (
        Identificador INT,
        Registrado FLOAT
    );

    /**/

    CREATE TABLE #PagadoProporcional
    (
        IdRegistro INT,
        CantGastos INT,
        Proporcion FLOAT,
        MontoPropPago FLOAT
    );

    /**/

    CREATE TABLE #ProveedoresxLP
    (
        IdLineaPresupuesoMes INT,
        Proveedores VARCHAR(5000)
    );

    /**/

    CREATE TABLE #MontosDolares
    (
        id INT,
        idLineaPresupuesto INT,
        MontoEjercido DECIMAL,
        IdPedido INT,
        Proveedor NVARCHAR(1000),
        Requisicion INT,
        Requisitor VARCHAR(250)
    );

    /**/

    CREATE TABLE #MontoEjercidoPorLinea
    (
        Id INT,
        IdLineaPresupuesto INT,
        MontoEjercido DECIMAL,
        IdPedido INT,
        Proveedor NVARCHAR(1000),
        Requisicion INT,
        Requisitor VARCHAR(250)
    );

    /**/

    CREATE TABLE #Presupuestado
    (
        Clasificacion VARCHAR(6000),
        IdActividad VARCHAR(500),
        ActividadPetrolera VARCHAR(500),
        IdSubActividadPetrolera VARCHAR(500),
        SubactividadPetrolera VARCHAR(500),
        IdTareaPetrolera VARCHAR(500),
        TareaPetrolera VARCHAR(500),
        SubTareaPetrolera VARCHAR(5000),
        PresupuestoUSD MONEY,
        Cantidad INT
    );

    /**/

    CREATE TABLE #Cantidad
    (
        Clasificacion VARCHAR(6000),
        IdActividad VARCHAR(500),
        ActividadPetrolera VARCHAR(500),
        IdSubActividadPetrolera VARCHAR(500),
        SubactividadPetrolera VARCHAR(500),
        IdTareaPetrolera VARCHAR(500),
        TareaPetrolera VARCHAR(500),
        SubTareaPetrolera VARCHAR(5000),
        Cantidad INT
    );

    /**/

    CREATE TABLE #Presupuestos
    (
        IdPresupuesto INT
    );
    IF 1 =
         (
             SELECT COUNT(1)
    FROM dbo.CO_Presupuesto P
        JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
        JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
    WHERE P.idpresupuesto = @IdPresupuesto -- VALIDAR QUE ASI SE LLAME LA VARIABLE
        AND P.nombre LIKE '%provisional%'
        AND C.IdContratista IN(10005, 10006)
         )
             BEGIN
        INSERT INTO #Presupuestos
            (IdPresupuesto)
        SELECT P.IdPresupuesto
        FROM dbo.CO_Presupuesto P
            JOIN dbo.CO_AnioContractual AC ON P.IdAnioContractual = AC.IdAnioContractual
            JOIN dbo.CO_Contrato C ON AC.IdContrato = C.IdContrato
        WHERE C.IdContrato = @IdContrato -- VALIDAR QUE ASI SE LLAME LA VARIABLE
            AND P.nombre LIKE '%provisional%'
            AND C.IdContratista IN(10005, 10006);
    END;
             ELSE
             BEGIN
        INSERT INTO #Presupuestos
            (IdPresupuesto)
        SELECT @IdPresupuesto;
    END;

    /*   PRESUPUESTADO    */

    INSERT INTO #Presupuestado
        (Clasificacion,
        IdActividad,
        ActividadPetrolera,
        IdSubActividadPetrolera,
        SubactividadPetrolera,
        IdTareaPetrolera,
        TareaPetrolera,
        SubTareaPetrolera,
        PresupuestoUSD
        )
    SELECT CONCAT(dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, ' - ', dbo.CO_SubactividadPetrolera.SubactividadPetrolera, ' - ', dbo.CO_TareaPetrolera.TareaPetrolera, ' - ', dbo.CO_Servicio.NombreServicio),
        dbo.CO_ActividadPetroleraCNH.[id_Actividad] AS IdActividad,
        dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS ActividadPetrolera,
        dbo.CO_SubactividadPetrolera.[id_Sub-actividad] AS IdSubActividadPetrolera,
        dbo.CO_SubactividadPetrolera.SubactividadPetrolera AS SubactividadPetrolera,
        dbo.CO_TareaPetrolera.[id_Tarea] AS IdTareaPetrolera,
        dbo.CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera,
        dbo.CO_Servicio.NombreServicio AS SubTareaPetrolera,
        SUM(dbo.CO_LineaPresupuestoMes.Monto) AS PresupuestoUSD
    FROM #Presupuestos P
        JOIN CO_LineaPresupuestoMes ON P.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        LEFT JOIN CO_ActividadPetroleraCNH ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        LEFT JOIN CO_SubactividadPetrolera ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        LEFT JOIN CO_TareaPetrolera ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
        LEFT JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT JOIN CO_Presupuesto ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
    --WHERE(CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
    GROUP BY CONCAT(dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, ' - ', dbo.CO_SubactividadPetrolera.SubactividadPetrolera, ' - ', dbo.CO_TareaPetrolera.TareaPetrolera, ' - ', dbo.CO_Servicio.NombreServicio), 
                         dbo.CO_ActividadPetroleraCNH.[id_Actividad], 
                         dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         dbo.CO_SubactividadPetrolera.[id_Sub-actividad], 
                         dbo.CO_SubactividadPetrolera.SubactividadPetrolera, 
                         dbo.CO_TareaPetrolera.[id_Tarea], 
                         dbo.CO_TareaPetrolera.TareaPetrolera, 
                         dbo.CO_Servicio.NombreServicio;

    /**/

    INSERT INTO #RptGastos
        (IdRegistro,
        Servicio,
        InstalacionPresupuestada,
        FechaInicio,
        FechaFin,
        TipoDocumento,
        Numero,
        FechaDocumento,
        [Registrado ADINCO],
        [Pagado ADINCO],
        Subcontratista,
        InstalacionRegistro,
        InicioEjecucion,
        FinEjecucion,
        CreadoPor,
        MontoRegistroOriginal,
        Moneda,
        MesPresentacion,
        TipoDeServicio,
        ActividadPetrolera,
        SubactividadPetrolera,
        TareaPetrolera,
        EstadoValidacion,
        Area,
        Comentarios,
        Anexo4,
        Identificador,
        LineaPresupuesto,
        Presupuesto,
        Rubro,
        PCN,
        CAA,
        Deuda,
        OCAprobadas
        )
    SELECT ISNULL(R.IdRegistro, 0) AS IdRegistro,
        ISNULL(S.NombreServicio, 'NA') AS Servicio,
        ISNULL(I.NombreInstalacion, 'NA') AS InstalacionPresupuestada,
        LPM.AC_FEC_INI AS FechaInicio,
        LPM.AC_FEC_FIN AS FechaFin,
        CASE
                           WHEN R.CvTipoDocFacturacion = 1
                           THEN 'CF'
                           WHEN R.CvTipoDocFacturacion = 2
                           THEN 'PI'
                           WHEN R.CvTipoDocFacturacion = 3
                           THEN 'PE'
                           ELSE 'NA'
                       END AS TipoDocumento,
        CASE
                           WHEN R.CvTipoDocFacturacion = 1
                           THEN LTRIM(RTRIM(F.Serie+' '+F.Folio))
                           WHEN R.CvTipoDocFacturacion = 2
                           THEN PC.NumeroPedimento
                           WHEN R.CvTipoDocFacturacion = 3
                           THEN PC.FolioComprobante
                           ELSE 'NA'
                       END AS Numero,
        CASE
                           WHEN R.CvTipoDocFacturacion = 1
                           THEN F.Fecha
                           WHEN R.CvTipoDocFacturacion IN(2, 3)
                           THEN PC.FechaPago
                           ELSE CAST('1999-01-01' AS DATE)
                       END AS FechaDocumento,
        CASE
                           WHEN R.CvTipoDocFacturacion = 1
                           THEN SUM(CASE
                                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                        THEN ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio
                                        ELSE 0
                                    END)
                           WHEN R.CvTipoDocFacturacion IN(2, 3)
                           THEN SUM(CASE
                                        WHEN ISNULL(R.MontoRegistro, 0) <> 0
                                        THEN ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio
                                        ELSE 0
                                    END)
                           ELSE 0
                       END AS 'Registrado ADINCO',
        0,
        CASE
                           WHEN R.CvTipoDocFacturacion = 1
                           THEN ISNULL(SF.RazonSocial, 'NA')
                           WHEN R.CvTipoDocFacturacion IN(2, 3)
                           THEN ISNULL(SPC.RazonSocial, 'NA')
                           ELSE 'NA'
                       END AS Subcontratista,
        ISNULL(IR.NombreInstalacion, 'NA') AS InstalacionRegistro,
        R.InicioEjecucion,
        R.FinEjecucion,
        ISNULL(U.Nombre, 'NA') AS CreadoPor,
        ISNULL(R.MontoRegistro, 0) AS MontoRegistroOriginal, --SUM(R.MontoRegistro) AS MontoRegistroOriginal,
        CASE
                           WHEN R.CvTipoDocFacturacion = 1
                           THEN TMF.TipoMonedaCorto
                           WHEN R.CvTipoDocFacturacion IN(2, 3)
                           THEN TMPC.TipoMonedaCorto
                           ELSE 'NA'
                       END AS Moneda,
        R.MesPresentacion AS MesPresentacion,
        '' AS TipoDeServicio,
        ACNH.DescripcionActividadPetrolera AS ActividadPetrolera,
        SAP.SubactividadPetrolera AS SubactividadPetrolera,
        TP.TareaPetrolera AS TareaPetrolera,
        ISNULL(ER.NombreEstado, 'NA') AS EstadoValidacion,
        '' AS Area, --ISNULL(A.NombreArea, '-') AS Area, 
        ISNULL(R.Comentarios, 'NA') AS Comentarios,
        '' AS Anexo4, --ISNULL(CA.ClasificacionAnexo4, 'NA') AS Anexo4,
        CASE
                           WHEN R.CvTipoDocFacturacion = 1
                           THEN F.IdFactura
                           WHEN R.CvTipoDocFacturacion IN(2, 3)
                           THEN PC.IdPedimentoComprobante
                           ELSE 0
                       END AS Identificador,
        LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
        P.Nombre AS Presupuesto,
        ISNULL(rubro.Descripcion, 'NA') AS Rubro,
        ISNULL(R.PCN, 0) AS PCN,
        CASE
                           WHEN R.CostosAtribuiblesAdministracion = 1
                           THEN 'SI'
                           ELSE 'NO'
                       END AS CAA,
        0 AS Deuda,
        0 AS OCAprobadas
    FROM #Presupuestos PP
        JOIN dbo.CO_LineaPresupuestoMes LPM ON PP.IdPresupuesto = LPM.IdPresupuesto
        JOIN dbo.CO_ActividadPetroleraCNH ACNH ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
        JOIN dbo.CO_SubactividadPetrolera SAP ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
        JOIN dbo.CO_TareaPetrolera TP ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
        JOIN dbo.CO_Servicio S ON LPM.IdServicio = S.IdServicio
        JOIN dbo.CO_Presupuesto P ON LPM.IdPresupuesto = P.IdPresupuesto
        LEFT JOIN dbo.CO_Instalacion I ON LPM.IdInstalacion = I.IdInstalacion
        LEFT JOIN dbo.CO_Registro R ON R.IdPrograma = LPM.IdLineaPresupuestoMes --AND YEAR(MesPresentacion) = 2018
        LEFT JOIN dbo.CO_Instalacion IR ON R.IdInstalacion = IR.IdInstalacion
        LEFT JOIN dbo.CO_EstadoRegistro ER ON R.IdEstado = ER.IdEstadoRegistro
        LEFT JOIN dbo.CO_GastosRubro rubro ON rubro.IdGastoRubro = R.IdGastoRubro
        LEFT JOIN dbo.FI_Factura F ON F.IdFactura = R.IdFactura
        LEFT JOIN dbo.PV_Subcontratista SF ON F.IdSubcontratista = SF.IdSubcontratista
        LEFT JOIN dbo.PV_TipoMoneda TMF ON TMF.IdMoneda = F.IdMoneda
        LEFT JOIN dbo.CO_TipoCambioDiario TCDF ON TCDF.IdMoneda = F.IdMoneda
            AND DAY(TCDF.Fecha) = DAY(F.Fecha)
            AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
            AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
        LEFT JOIN dbo.FI_PedimentoComprobante PC ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
        LEFT JOIN dbo.PV_Subcontratista SPC ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
        LEFT JOIN dbo.PV_TipoMoneda TMPC ON TMPC.IdMoneda = PC.IdMoneda
        LEFT JOIN dbo.CO_TipoCambioDiario TCDPC ON TCDPC.IdMoneda = TMPC.IdMoneda
            AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
            AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
            AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
        LEFT JOIN dbo.AP_Usuario U ON R.IdUsuarioCreadoPor = U.UsuarioID
    --WHERE P.IdPresupuesto = @IdPresupuesto
    --WHERE YEAR(R.MesPresentacion) = 2017
    GROUP BY ISNULL(R.IdRegistro, 0), 
                         ISNULL(S.NombreServicio, 'NA'), 
                         ISNULL(I.NombreInstalacion, 'NA'), 
                         LPM.AC_FEC_INI, 
                         LPM.AC_FEC_FIN,
                         CASE
                             WHEN R.CvTipoDocFacturacion = 1
                             THEN 'CF'
                             WHEN R.CvTipoDocFacturacion = 2
                             THEN 'PI'
                             WHEN R.CvTipoDocFacturacion = 3
                             THEN 'PE'
                             ELSE 'NA'
                         END,
                         CASE
                             WHEN R.CvTipoDocFacturacion = 1
                             THEN LTRIM(RTRIM(F.Serie+' '+F.Folio))
                             WHEN R.CvTipoDocFacturacion = 2
                             THEN PC.NumeroPedimento
                             WHEN R.CvTipoDocFacturacion = 3
                             THEN PC.FolioComprobante
                             ELSE 'NA'
                         END,
                         CASE
                             WHEN R.CvTipoDocFacturacion = 1
                             THEN F.Fecha
                             WHEN R.CvTipoDocFacturacion IN(2, 3)
                             THEN PC.FechaPago
                             ELSE CAST('1999-01-01' AS DATE)
                         END,
                         CASE
                             WHEN R.CvTipoDocFacturacion = 1
                             THEN ISNULL(SF.RazonSocial, 'NA')
                             WHEN R.CvTipoDocFacturacion IN(2, 3)
                             THEN ISNULL(SPC.RazonSocial, 'NA')
                             ELSE 'NA'
                         END, 
                         ISNULL(IR.NombreInstalacion, 'NA'), 
                         R.InicioEjecucion, 
                         R.FinEjecucion, 
                         ISNULL(U.Nombre, 'NA'), 
                         R.MontoRegistro,
                         CASE
                             WHEN R.CvTipoDocFacturacion = 1
                             THEN TMF.TipoMonedaCorto
                             WHEN R.CvTipoDocFacturacion IN(2, 3)
                             THEN TMPC.TipoMonedaCorto
                             ELSE 'NA'
                         END, 
                         R.MesPresentacion, 
                         ACNH.DescripcionActividadPetrolera, 
                         SAP.SubactividadPetrolera, 
                         TP.TareaPetrolera, 
                         ISNULL(ER.NombreEstado, 'NA'), 
                         ISNULL(R.Comentarios, 'NA'),
                         CASE
                             WHEN R.CvTipoDocFacturacion = 1
                             THEN F.IdFactura
                             WHEN R.CvTipoDocFacturacion IN(2, 3)
                             THEN PC.IdPedimentoComprobante
                             ELSE 0
                         END, 
                         LPM.IdLineaPresupuestoMes, 
                         P.Nombre, 
                         ISNULL(rubro.Descripcion, 'NA'), 
                         ISNULL(R.PCN, 0),
                         CASE
                             WHEN R.CostosAtribuiblesAdministracion = 1
                             THEN 'SI'
                             ELSE 'NO'
                         END, 
                         R.CvTipoDocFacturacion;

    /**/

    INSERT INTO #contador
        (Identificador,
        CantGastos
        )
    SELECT Identificador,
        COUNT(1) AS [CantGastos]
    FROM #RptGastos
    GROUP BY Identificador;

    /**/

    INSERT INTO #FACTURAS
        (IdFACTURA,
        MontoPagado
        )
    SELECT F.IdFactura,
        SUM(ISNULL(TRF.MontoPagado, 0) / TCDF.TipoCambio)
    FROM dbo.FI_Factura F
        JOIN dbo.FI_TransferFactura TRF ON TRF.IdFactura = F.IdFactura
        JOIN dbo.FI_Transfer TF ON TRF.IdTransfer = TF.IdTransferencia
        JOIN dbo.CO_TipoCambioDiario TCDF ON TCDF.IdMoneda = TF.IdMoneda
            AND CONVERT(VARCHAR, TF.FechaPago, 112) = CONVERT(VARCHAR, TCDF.Fecha, 112)
    WHERE F.IdContrato = @IdContrato
    --AND YEAR(TF.FechaPago) = 2020
    GROUP BY F.IdFactura;

    /**/

    INSERT INTO #Registrado
        (Identificador,
        Registrado
        )
    SELECT Identificador,
        SUM([Registrado ADINCO]) AS [Registrado]
    FROM #RptGastos
    GROUP BY Identificador;

    /**/

    INSERT INTO #PagadoProporcional
        (IdRegistro,
        CantGastos,
        Proporcion,
        MontoPropPago
        )
    SELECT g.IdRegistro,
        c.CantGastos,
        g.[Registrado ADINCO] / r.[Registrado] AS [Proporcion],
        (g.[Registrado ADINCO] / r.[Registrado]) * f.MontoPagado AS [MontoPropPago]
    FROM #Registrado r
        JOIN #contador c ON r.Identificador = c.Identificador
        JOIN #FACTURAS f ON c.Identificador = f.IdFACTURA
        JOIN #RptGastos g ON r.Identificador = g.Identificador
    WHERE f.MontoPagado > 0;

    /**/

    INSERT INTO #Pagado
        (ActividadPetrolera,
        SubactividadPetrolera,
        TareaPetrolera,
        SubTareaPetrolera,
        Pagado,
        Identificador
        )
    SELECT REG.ActividadPetrolera,
        REG.SubactividadPetrolera,
        REG.TareaPetrolera,
        REG.Servicio,
        P.MontoPagado / C.CantGastos,
        REG.Identificador
    FROM #RptGastos REG
        JOIN #FACTURAS P ON REG.Identificador = P.IdFACTURA
        JOIN #contador c ON reg.Identificador = c.Identificador
    GROUP BY REG.ActividadPetrolera, 
                         REG.SubactividadPetrolera, 
                         REG.TareaPetrolera, 
                         REG.Servicio, 
                         P.MontoPagado / C.CantGastos, 
                         REG.Identificador;

    /*ACTUALIZAR MONTO PAGADO  */

    UPDATE G
           SET 
               [Pagado ADINCO] = P.MontoPropPago
         FROM #RptGastos G
        JOIN #PagadoProporcional P ON G.IdRegistro = P.IdRegistro;

    /*DATOS DE PETROVENDOR*/

    --Todos los montos registrados en pesos se pasan a dolares
    INSERT INTO #MontosDolares
        (id,
        idLineaPresupuesto,
        MontoEjercido,
        IdPedido,
        Proveedor,
        Requisicion,
        Requisitor
        )
    --Todas las ordenes de compra que no tienen una factura aprobada o rechazada
            SELECT ROW_NUMBER() OVER(ORDER BY lpm.IdLineaPresupuestoMes),
            lpm.IdLineaPresupuestoMes,
            CASE
                           WHEN pd.IdMoneda = 1
                           THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio(pd.Subtotal, CAST(p.CreadoEl AS DATE))
                           ELSE pd.Subtotal
                       END AS MontoDLS,
            PS.IdPedido,
            --CONCAT(LTRIM(RTRIM(S.RazonSocial)), ' ', LTRIM(RTRIM(RG.Regimen))) AS RazonSocial, 
            LTRIM(RTRIM(S.RazonSocial)) AS RazonSocial,
            SP.IdSolicitudPedido,
            LTRIM(RTRIM(REQ.Nombre))--, 
        --ISNULL(p.Cerrado, 0)
        FROM #Presupuestos PP
            JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm ON PP.IdPresupuesto = LPM.IdPresupuesto
            JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
            JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
            JOIN Petrovendor.dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = spd.IdSolicitudPedido
                AND ISNULL(sp.IdEstatusEliminado, 0) = 0
            JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
            JOIN Petrovendor.dbo.MM_PeticionOferta po ON po.IdPeticionOferta = pod.IdPeticionOferta
                AND ISNULL(po.IdEstatusEliminado, 0) = 0
            JOIN Petrovendor.dbo.MM_PedidoDetalle pd ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
            JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
                AND ISNULL(p.IdEstatusEliminado, 0) = 0
                AND ISNULL(p.Cerrado, 0) = 0
            INNER JOIN Petrovendor.dbo.S_Proveedor S ON P.IdSubcontratista = S.IdProveedor
            JOIN Petrovendor.dbo.RegimenCapital RG ON RG.IdRegimenCapital = S.IdRegimenCapital
            INNER JOIN Petrovendor.dbo.MM_Pedidos PS ON P.IdPedido = PS.IdIdentificador
            JOIN Petrovendor.dbo.TA_Operacion o ON o.IdDocumento = p.IdSolicitudPedido
                AND o.IdTipoOperacion = 9
                AND o.NoVersion = p.Version
                AND o.IdEstatusOperacion = 2
                AND ISNULL(o.IdEstatusEliminado, 0) = 0
            LEFT JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd ON apd.IdPedidoDetalle = pd.IdPedidoDetalle
            LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
            LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido = apd.IdAceptacionPedido
            LEFT JOIN Petrovendor.dbo.TA_Operacion op ON op.IdDocumento = af.IdAceptacionFactura
                AND op.IdTipoOperacion = 10
            LEFT JOIN Petrovendor.dbo.S_Usuario REQ ON sp.IdUsuarioSolicitante = REQ.IdUsuario
        WHERE --lpm.IdPresupuesto = @IdPresupuesto
                --AND 
                ISNULL(ap.IdEstatusEliminado, 0) = 0
            AND ISNULL(af.IdEstatusEliminado, 0) = 0
            AND ISNULL(op.IdEstatusEliminado, 0) = 0
            AND (op.IdEstatusOperacion NOT IN(2, 3, 4, 5, 6, 7, 8, 10)
            OR op.IdOperacion IS NULL)
        --Que la factura no este Aprobada, rechazada, cancelada, vencida, enviada, o cancelada, solo se toman las facturas sin aprobar o sin cargar
    UNION
        SELECT ROW_NUMBER() OVER(ORDER BY lpm.IdLineaPresupuestoMes),
            lpm.IdLineaPresupuestoMes,
            CASE
                           WHEN pd.IdMoneda = 1
                           THEN Petrovendor.dbo.FN_PesosDolaresTipoCambio((apd.Cantidad * pd.PrecioUnitario), CAST(p.CreadoEl AS DATE))
                           ELSE(apd.Cantidad * pd.PrecioUnitario)
                       END AS MontoDLS,
            PS.IdPedido,
            --CONCAT(LTRIM(RTRIM(S.RazonSocial)), ' ', LTRIM(RTRIM(RG.Regimen))) AS RazonSocial, 
            LTRIM(RTRIM(S.RazonSocial)) AS RazonSocial,
            SP.IdSolicitudPedido,
            LTRIM(RTRIM(REQ.Nombre))--, 
        --ISNULL(p.Cerrado, 0)
        FROM #Presupuestos PP
            JOIN Adinco.dbo.CO_LineaPresupuestoMes lpm ON PP.IdPresupuesto = LPM.IdPresupuesto
            JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto spdlp ON spdlp.IdLineaPresupuesto = lpm.IdLineaPresupuestoMes
            JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle spd ON spd.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
            JOIN Petrovendor.dbo.MM_SolicitudPedido sp ON sp.IdSolicitudPedido = spd.IdSolicitudPedido
                AND ISNULL(sp.IdEstatusEliminado, 0) = 0
            JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle pod ON pod.IdSolicitudPedidoDetalle = spdlp.IdSolicitudPedidoDetalle
            JOIN Petrovendor.dbo.MM_PeticionOferta po ON po.IdPeticionOferta = pod.IdPeticionOferta
                AND ISNULL(po.IdEstatusEliminado, 0) = 0
            JOIN Petrovendor.dbo.MM_PedidoDetalle pd ON pd.IdPeticionOfertaDetalle = pod.IdPeticionOfertaDetalle
            JOIN Petrovendor.dbo.MM_Pedido p ON p.IdPedido = pd.IdPedido
                AND ISNULL(p.IdEstatusEliminado, 0) = 0
            --AND ISNULL(p.Cerrado, 0) = 0
            INNER JOIN Petrovendor.dbo.S_Proveedor S ON P.IdSubcontratista = S.IdProveedor
            JOIN Petrovendor.dbo.RegimenCapital RG ON RG.IdRegimenCapital = S.IdRegimenCapital
            INNER JOIN Petrovendor.dbo.MM_Pedidos PS ON P.IdPedido = PS.IdIdentificador
            JOIN Petrovendor.dbo.TA_Operacion o ON o.IdDocumento = p.IdSolicitudPedido
                AND o.IdTipoOperacion = 9
                AND o.NoVersion = p.Version
                AND o.IdEstatusOperacion = 2
                AND ISNULL(o.IdEstatusEliminado, 0) = 0
            LEFT JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd ON apd.IdPedidoDetalle = pd.IdPedidoDetalle
            LEFT JOIN Petrovendor.dbo.MM_AceptacionPedido ap ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
            LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura af ON af.IdAceptacionPedido = apd.IdAceptacionPedido
            LEFT JOIN Petrovendor.dbo.TA_Operacion op ON op.IdDocumento = af.IdAceptacionFactura
                AND op.IdTipoOperacion = 10
            LEFT JOIN Petrovendor.dbo.S_Usuario REQ ON sp.IdUsuarioSolicitante = REQ.IdUsuario
        WHERE --lpm.IdPresupuesto = @IdPresupuesto
                --AND 
                ISNULL(p.Cerrado, 0) = 1
            AND ISNULL(ap.IdEstatusEliminado, 0) = 0
            AND ISNULL(af.IdEstatusEliminado, 0) = 0
            AND ISNULL(op.IdEstatusEliminado, 0) = 0
            AND (op.IdEstatusOperacion NOT IN(3, 4, 5, 6, 7, 8, 10)
            OR op.IdOperacion IS NULL);

    --SELECT * FROM #MontosDolares
    /**/

    INSERT INTO #MontoEjercidoPorLinea
        (Id,
        IdLineaPresupuesto,
        MontoEjercido,
        IdPedido,
        Proveedor,
        Requisicion,
        Requisitor
        )
    SELECT NULL,
        idLineaPresupuesto,
        SUM(MontoEjercido),
        IdPedido,
        Proveedor,
        Requisicion,
        Requisitor
    FROM #MontosDolares
    --WHERE IdPedido = 10311
    GROUP BY --id, 
                idLineaPresupuesto, 
                IdPedido, 
                Proveedor, 
                Requisicion, 
                Requisitor;

    /**/

    INSERT INTO #ProveedoresxLP
        (IdLineaPresupuesoMes,
        Proveedores
        )
    SELECT idLineaPresupuesto,
        STUFF(
                (
                    SELECT DISTINCT
            ', '+'OC '+LTRIM(IdPedido)+' | PROV '+LTRIM(Proveedor)+' | REQ '+LTRIM(Requisicion)+' | USR '+LTRIM(Requisitor)
        FROM #MontoEjercidoPorLinea A
        WHERE B.IdLineaPresupuesto = A.IdLineaPresupuesto
        FOR XML PATH('')
                ), 1, 1, '') M
    --AND B.Id = A.Id
    FROM #MontoEjercidoPorLinea B
    GROUP BY idLineaPresupuesto;

    /*ACTUALIZAR OC APROBADAS*/

    INSERT INTO #RptGastos
        (IdRegistro,
        Servicio,
        InstalacionPresupuestada,
        FechaInicio,
        FechaFin,
        TipoDocumento,
        Numero,
        FechaDocumento,
        [Registrado ADINCO],
        [Pagado ADINCO],
        Subcontratista,
        InstalacionRegistro,
        InicioEjecucion,
        FinEjecucion,
        CreadoPor,
        MontoRegistroOriginal,
        Moneda,
        MesPresentacion,
        TipoDeServicio,
        ActividadPetrolera,
        SubactividadPetrolera,
        TareaPetrolera,
        EstadoValidacion,
        Area,
        Comentarios,
        Anexo4,
        Identificador,
        LineaPresupuesto,
        Presupuesto,
        Rubro,
        PCN,
        CAA,
        Deuda,
        OCAprobadas
        )
    SELECT 0 AS IdRegistro,
        CO_Servicio.NombreServicio AS Servicio,
        CO_Instalacion.NombreInstalacion AS InstalacionPresupuestada,
        CO_LineaPresupuestoMes.AC_FEC_INI AS AC_FEC_INI,
        CO_LineaPresupuestoMes.AC_FEC_FIN AS AC_FEC_FIN,
        'NA' AS TipoDocumento,
        'NA' AS Numero,
        CAST('1999-01-01' AS DATE) AS FechaDocumento,
        0 AS [Registrado ADINCO],
        0 AS [Pagado ADINCO],
        me.Proveedor AS Subcontratista,
        'NA' AS InstalacionRegistro,
        NULL AS InicioEjecucion,
        NULL AS FinEjecucion,
        NULL AS CreadoPor,
        0 AS MontoRegistroOriginal,
        'NA' AS Moneda,
        NULL AS MesPresentacion,
        '' AS TipoDeServicio,
        CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS ActividadPetrolera,
        CO_SubactividadPetrolera.SubactividadPetrolera AS SubactividadPetrolera,
        CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera,
        'NA' AS EstadoValidacion,
        '' AS Area,
        me.IdPedido AS Comentarios,
        '' AS Anexo4,
        0 AS Identificador,
        CO_LineaPresupuestoMes.IdLineaPresupuestoMes AS LineaPresupuesto,
        CO_Presupuesto.Nombre AS Presupuesto,
        'NA' AS Rubro,
        0 AS PCN,
        NULL AS CAA,
        0 AS Deuda,
        SUM(ISNULL(me.MontoEjercido, 0)) AS OCAprobadas
    FROM #Presupuestos PP
        JOIN dbo.CO_LineaPresupuestoMes ON PP.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        JOIN CO_ActividadPetroleraCNH ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        JOIN CO_SubactividadPetrolera ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        JOIN CO_TareaPetrolera ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
        JOIN CO_Servicio ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        JOIN CO_Instalacion ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        JOIN CO_Presupuesto ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        LEFT JOIN #MontoEjercidoPorLinea me ON me.IdLineaPresupuesto = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
    --WHERE(CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)
    GROUP BY CO_LineaPresupuestoMes.IdLineaPresupuestoMes, 
                         CO_LineaPresupuestoMes.AC_FEC_INI, 
                         CO_LineaPresupuestoMes.AC_FEC_FIN, 
                         CO_ActividadPetroleraCNH.DescripcionActividadPetrolera, 
                         CO_SubactividadPetrolera.SubactividadPetrolera, 
                         CO_TareaPetrolera.TareaPetrolera, 
                         CO_Servicio.NombreServicio, 
                         CO_Instalacion.NombreInstalacion, 
                         CO_Presupuesto.Nombre, 
                         me.IdPedido, 
                         me.Proveedor
    HAVING SUM(ISNULL(me.MontoEjercido, 0)) <> 0;

    /**/

    INSERT INTO #Cantidad
        (Clasificacion,
        --			IdActividad,
        ActividadPetrolera,
        --          IdSubActividadPetrolera,
        SubactividadPetrolera,
        --          IdTareaPetrolera,
        TareaPetrolera,
        SubTareaPetrolera,
        Cantidad
        )
    SELECT CONCAT(ActividadPetrolera, ' - ', SubactividadPetrolera, ' - ', TareaPetrolera, ' - ', Servicio),
        ActividadPetrolera,
        SubactividadPetrolera,
        TareaPetrolera,
        Servicio,
        COUNT(1)
    FROM #RptGastos
    GROUP BY CONCAT(ActividadPetrolera, ' - ', SubactividadPetrolera, ' - ', TareaPetrolera, ' - ', Servicio), 
                         ActividadPetrolera, 
                         SubactividadPetrolera, 
                         TareaPetrolera, 
                         Servicio;
    UPDATE P
           SET 
               P.Cantidad = C.Cantidad
         FROM #Presupuestado P
        JOIN #Cantidad C ON P.ActividadPetrolera = C.ActividadPetrolera
            AND P.SubactividadPetrolera = C.SubactividadPetrolera
            AND P.TareaPetrolera = C.TareaPetrolera
            AND P.SubTareaPetrolera = C.SubTareaPetrolera;

    /*SELECT QUE LLENA REPORTE HOJA BASE*/
    /*SELECT LEN(Servicio), 
                LEN(InstalacionPresupuestada), 
                LEN(TipoDocumento), 
                LEN(Numero), 
                LEN(Subcontratista), 
                LEN(InstalacionRegistro), 
                LEN(CreadoPor), 
                LEN(Moneda), 
                LEN(TipoDeServicio), 
                LEN(ActividadPetrolera), 
                LEN(SubactividadPetrolera), 
                LEN(TareaPetrolera), 
                LEN(EstadoValidacion), 
                LEN(Area), 
                LEN(Comentarios), 
                LEN(Anexo4), 
                LEN(Presupuesto), 
                LEN(Rubro), 
                LEN(CAA)
				FROM #RptGastos;*/
    /**/

    --DELETE #RptGastos
    --WHERE YEAR(MesPresentacion) <> 2017;

    /**/

    SELECT #RptGastos.IdRegistro,
        --SUBSTRING(CONCAT(#RptGastos.ActividadPetrolera, ' - ', #RptGastos.SubactividadPetrolera, ' - ', #RptGastos.TareaPetrolera, ' - ', #RptGastos.Servicio), 1, 255) AS Servicio, 
        SUBSTRING(CONCAT(PRESUP.IdActividad, ' - ', PRESUP.IdSubActividadPetrolera, ' - ', PRESUP.IdTareaPetrolera, ' - ', #RptGastos.Servicio), 1, 255) AS Servicio,
        --#RptGastos.Servicio AS Servicio, 
        #RptGastos.InstalacionPresupuestada,
        #RptGastos.FechaInicio,
        #RptGastos.FechaFin,
        #RptGastos.TipoDocumento,
        #RptGastos.Numero,
        #RptGastos.FechaDocumento,
        #RptGastos.[Registrado ADINCO],
        #RptGastos.[Pagado ADINCO],
        #RptGastos.Subcontratista,
        #RptGastos.InstalacionRegistro,
        #RptGastos.InicioEjecucion,
        #RptGastos.FinEjecucion,
        #RptGastos.CreadoPor,
        #RptGastos.MontoRegistroOriginal,
        #RptGastos.Moneda,
        #RptGastos.MesPresentacion,
        #RptGastos.TipoDeServicio,
        CONCAT(PRESUP.IdActividad, ' - ', #RptGastos.ActividadPetrolera) AS ActividadPetrolera,
        CONCAT(PRESUP.IdSubActividadPetrolera, ' - ', #RptGastos.SubactividadPetrolera) AS SubactividadPetrolera,
        CONCAT(PRESUP.IdTareaPetrolera, ' - ', #RptGastos.TareaPetrolera) AS TareaPetrolera,
        #RptGastos.EstadoValidacion,
        #RptGastos.Area,
        SUBSTRING(#RptGastos.Comentarios, 1, 255),
        #RptGastos.Anexo4,
        #RptGastos.Identificador,
        #RptGastos.LineaPresupuesto,
        #RptGastos.Presupuesto,
        #RptGastos.Rubro,
        #RptGastos.PCN,
        #RptGastos.CAA,
        #RptGastos.[Registrado ADINCO] - #RptGastos.[Pagado ADINCO] AS Deuda,
        #RptGastos.OCAprobadas,
        SUBSTRING(ISNULL(P.Proveedores, ''), 1, 255) AS [OC-Prov],
        CASE
                    WHEN ISNULL(PRESUP.Cantidad, 0) = 0
                    THEN 0
                    ELSE ROUND(ISNULL(PRESUP.PresupuestoUSD, 0) / PRESUP.Cantidad, 4)
                END AS [Presupuestado],
        CASE
                    WHEN ISNULL(PRESUP.PresupuestoUSD, 0) = 0
                    THEN 0
                    ELSE((ISNULL(OCAprobadas, 0) + ISNULL([Registrado ADINCO], 0)) / ISNULL(PRESUP.PresupuestoUSD, 0))
                END AS [TotalEjercido],
        ISNULL(OCAprobadas, 0) + ISNULL([Registrado ADINCO], 0) AS [Ejercido],
        (CASE
                     WHEN ISNULL(PRESUP.Cantidad, 0) = 0
                     THEN 0
                     ELSE ROUND(ISNULL(PRESUP.PresupuestoUSD, 0) / PRESUP.Cantidad, 4)
                 END) - (ISNULL(OCAprobadas, 0) + ISNULL([Registrado ADINCO], 0)) AS SaldoUSD
    FROM #RptGastos
        LEFT JOIN #ProveedoresxLP P ON #RptGastos.LineaPresupuesto = P.IdLineaPresupuesoMes
        LEFT JOIN #Presupuestado PRESUP ON #RptGastos.ActividadPetrolera = PRESUP.ActividadPetrolera
            AND #RptGastos.SubactividadPetrolera = PRESUP.SubactividadPetrolera
            AND #RptGastos.TareaPetrolera = PRESUP.TareaPetrolera
            AND #RptGastos.Servicio = PRESUP.SubTareaPetrolera
    --LEFT JOIN dbo.FI_TransferFactura TF ON TF.IdFactura = #RptGastos.Identificador
    --LEFT JOIN dbo.FI_Transfer T ON T.IdTransferencia = TF.IdTransfer --AND YEAR(T.FechaPago) = 2019
    --WHERE OCAprobadas <> 0 AND Identificador IS NOT NULL AND [Registrado ADINCO]
    --WHERE YEAR(T.FechaPago) = 2019
    ORDER BY IdRegistro;
END;
