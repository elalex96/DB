

CREATE PROCEDURE [dbo].[SP_CO_RptGastoBase]
--[SP_CO_RptGastoBase] 3,1,3  
--[SP_CO_RptGastoBase] 3,1,10042  
--[SP_CO_RptGastoBase] 10036,1,10061  
-- Add the parameters for the stored procedure here  
@IdContrato INT,
@IdUsuario INT,
@IdPresupuesto INT
AS
BEGIN
    -- =============================================  
    -- Author:  Manuel Cruz  
    -- Create date: 2018-10-24  
    -- Description:   
    -- =============================================  
    SET NOCOUNT ON;
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
        MontoTotalPedido FLOAT,
        MontoAceptado FLOAT,
        MontoPendiente FLOAT
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

    CREATE TABLE #FACTURAS (IdFACTURA INT, MontoPagado FLOAT, Proporcion FLOAT);

    /**/

    CREATE TABLE #contador (Identificador INT, CantGastos INT);

    /**/

    CREATE TABLE #Registrado (Identificador INT, Registrado FLOAT);

    /**/

    CREATE TABLE #PagadoProporcional (IdRegistro INT, CantGastos INT, Proporcion FLOAT, MontoPropPago FLOAT);

    /**/

    CREATE TABLE #ProveedoresxLP (IdLineaPresupuesoMes INT, Proveedores VARCHAR(5000));

    /**/

    CREATE TABLE #MontosDolares
    (
        id INT,
        idLineaPresupuesto INT,
        MontoTotalPedido DECIMAL,
        MontoAceptado DECIMAL,
        MontoPendiente DECIMAL,
        IdPedido INT,
        Proveedor NVARCHAR(1000),
        Requisicion INT,
        Requisitor VARCHAR(250),
        MontoCerrado FLOAT
    );

    /**/

    CREATE TABLE #MontoEjercidoPorLinea
    (
        Id INT,
        IdLineaPresupuesto INT,
        MontoTotalPedido DECIMAL,
        MontoAceptado DECIMAL,
        MontoPendiente DECIMAL,
        IdPedido INT,
        Proveedor NVARCHAR(1000),
        Requisicion INT,
        Requisitor VARCHAR(250),
        MontoCerrado FLOAT
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

    CREATE TABLE #Presupuestos (IdPresupuesto INT);

    CREATE TABLE #PedidoDetalleConAceptacion
    (
        IdPedidoDetalle INT,
        IdLineaPresupuestoMes INT,
        IdSolicitudPedido INT,
        IdSubcontratista INT,
        IdAceptacionPedido INT,
        Cantidad FLOAT
    )

    IF 1 =
    (   SELECT COUNT(1)
        FROM dbo.CO_Presupuesto P
            JOIN dbo.CO_AnioContractual AC
                ON P.IdAnioContractual = AC.IdAnioContractual
            JOIN dbo.CO_Contrato C
                ON AC.IdContrato = C.IdContrato
        WHERE P.IdPresupuesto = @IdPresupuesto -- VALIDAR QUE ASI SE LLAME LA VARIABLE  
              AND P.Nombre LIKE '%provisional%'
              AND C.IdContratista IN ( 10005, 10006 ))
    BEGIN
        INSERT INTO #Presupuestos (IdPresupuesto)
        SELECT P.IdPresupuesto
        FROM dbo.CO_Presupuesto P
            JOIN dbo.CO_AnioContractual AC
                ON P.IdAnioContractual = AC.IdAnioContractual
            JOIN dbo.CO_Contrato C
                ON AC.IdContrato = C.IdContrato
        WHERE C.IdContrato = @IdContrato -- VALIDAR QUE ASI SE LLAME LA VARIABLE  
              AND P.Nombre LIKE '%provisional%'
              AND C.IdContratista IN ( 10005, 10006 );
    END;
    ELSE
    BEGIN
        INSERT INTO #Presupuestos (IdPresupuesto)
        SELECT @IdPresupuesto;
    END;

    /*   PRESUPUESTADO    */

    INSERT INTO #Presupuestado
    (
        Clasificacion,
        IdActividad,
        ActividadPetrolera,
        IdSubActividadPetrolera,
        SubactividadPetrolera,
        IdTareaPetrolera,
        TareaPetrolera,
        SubTareaPetrolera,
        PresupuestoUSD
    )
    SELECT CONCAT(
           dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
           ' - ',
           dbo.CO_SubactividadPetrolera.SubactividadPetrolera,
           ' - ',
           dbo.CO_TareaPetrolera.TareaPetrolera,
           ' - ',
           dbo.CO_Servicio.NombreServicio),
           dbo.CO_ActividadPetroleraCNH.[id_Actividad] AS IdActividad,
           dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera AS ActividadPetrolera,
           dbo.CO_SubactividadPetrolera.[id_Sub-actividad] AS IdSubActividadPetrolera,
           dbo.CO_SubactividadPetrolera.SubactividadPetrolera AS SubactividadPetrolera,
           dbo.CO_TareaPetrolera.[id_Tarea] AS IdTareaPetrolera,
           dbo.CO_TareaPetrolera.TareaPetrolera AS TareaPetrolera,
           dbo.CO_Servicio.NombreServicio AS SubTareaPetrolera,
           SUM(dbo.CO_LineaPresupuestoMes.Monto) AS PresupuestoUSD
    FROM #Presupuestos P
        JOIN CO_LineaPresupuestoMes
            ON P.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        LEFT JOIN CO_ActividadPetroleraCNH
            ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        LEFT JOIN CO_SubactividadPetrolera
            ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        LEFT JOIN CO_TareaPetrolera
            ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
        LEFT JOIN CO_Servicio
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        LEFT JOIN CO_Presupuesto
            ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
    --WHERE(CO_LineaPresupuestoMes.IdPresupuesto = @IdPresupuesto)  
    GROUP BY CONCAT(
             dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
             ' - ',
             dbo.CO_SubactividadPetrolera.SubactividadPetrolera,
             ' - ',
             dbo.CO_TareaPetrolera.TareaPetrolera,
             ' - ',
             dbo.CO_Servicio.NombreServicio),
             dbo.CO_ActividadPetroleraCNH.[id_Actividad],
             dbo.CO_ActividadPetroleraCNH.DescripcionActividadPetrolera,
             dbo.CO_SubactividadPetrolera.[id_Sub-actividad],
             dbo.CO_SubactividadPetrolera.SubactividadPetrolera,
             dbo.CO_TareaPetrolera.[id_Tarea],
             dbo.CO_TareaPetrolera.TareaPetrolera,
             dbo.CO_Servicio.NombreServicio;

    /**/

    INSERT INTO #RptGastos
    (
        IdRegistro,
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
        MontoTotalPedido,
        MontoAceptado,
        MontoPendiente
    )
    SELECT ISNULL(R.IdRegistro, 0) AS IdRegistro,
           ISNULL(S.NombreServicio, 'NA') AS Servicio,
           ISNULL(I.NombreInstalacion, 'NA') AS InstalacionPresupuestada,
           LPM.AC_FEC_INI AS FechaInicio,
           LPM.AC_FEC_FIN AS FechaFin,
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   'CF'
               WHEN R.CvTipoDocFacturacion = 2 THEN
                   'PI'
               WHEN R.CvTipoDocFacturacion = 3 THEN
                   'PE'
               ELSE
                   'NA'
           END AS TipoDocumento,
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   LTRIM(RTRIM(F.Serie + ' ' + F.Folio))
               WHEN R.CvTipoDocFacturacion = 2 THEN
                   PC.NumeroPedimento
               WHEN R.CvTipoDocFacturacion = 3 THEN
                   PC.FolioComprobante
               ELSE
                   'NA'
           END AS Numero,
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   F.Fecha
               WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                   PC.FechaPago
               ELSE
                   CAST('1999-01-01' AS DATE)
           END AS FechaDocumento,
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   SUM(CASE
                           WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                               ISNULL(R.MontoRegistro, 0) / TCDF.TipoCambio
                           ELSE
                               0
                       END)
               WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                   SUM(CASE
                           WHEN ISNULL(R.MontoRegistro, 0) <> 0 THEN
                               ISNULL(R.MontoRegistro, 0) / TCDPC.TipoCambio
                           ELSE
                               0
                       END)
               ELSE
                   0
           END AS 'Registrado ADINCO',
           0 AS PagadoADINCO,
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   ISNULL(SF.RazonSocial, 'NA')
               WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                   ISNULL(SPC.RazonSocial, 'NA')
               ELSE
                   'NA'
           END AS Subcontratista,
           ISNULL(IR.NombreInstalacion, 'NA') AS InstalacionRegistro,
           R.InicioEjecucion,
           R.FinEjecucion,
           ISNULL(U.Nombre, 'NA') AS CreadoPor,
           ISNULL(R.MontoRegistro, 0) AS MontoRegistroOriginal, --SUM(R.MontoRegistro) AS MontoRegistroOriginal,  
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   TMF.TipoMonedaCorto
               WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                   TMPC.TipoMonedaCorto
               ELSE
                   'NA'
           END AS Moneda,
           R.MesPresentacion AS MesPresentacion,
           '' AS TipoDeServicio,
           ACNH.DescripcionActividadPetrolera AS ActividadPetrolera,
           SAP.SubactividadPetrolera AS SubactividadPetrolera,
           TP.TareaPetrolera AS TareaPetrolera,
           ISNULL(ER.NombreEstado, 'NA') AS EstadoValidacion,
           '' AS Area,                                          --ISNULL(A.NombreArea, '-') AS Area,   
           ISNULL(R.Comentarios, 'NA') AS Comentarios,
           '' AS Anexo4,                                        --ISNULL(CA.ClasificacionAnexo4, 'NA') AS Anexo4,  
           CASE
               WHEN R.CvTipoDocFacturacion = 1 THEN
                   F.IdFactura
               WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                   PC.IdPedimentoComprobante
               ELSE
                   0
           END AS Identificador,
           LPM.IdLineaPresupuestoMes AS LineaPresupuesto,
           P.Nombre AS Presupuesto,
           ISNULL(rubro.Descripcion, 'NA') AS Rubro,
           ISNULL(R.PCN, 0) AS PCN,
           CASE
               WHEN R.CostosAtribuiblesAdministracion = 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS CAA,
           0 AS Deuda,
           0 AS MontoTotalPedido,
           0 AS MontoAceptado,
           0 AS MontoPendiente
    FROM #Presupuestos PP
        JOIN dbo.CO_LineaPresupuestoMes LPM
            ON PP.IdPresupuesto = LPM.IdPresupuesto
        JOIN dbo.CO_ActividadPetroleraCNH ACNH
            ON LPM.IdActividadPetrolera = ACNH.IdActividadPetrolera
        JOIN dbo.CO_SubactividadPetrolera SAP
            ON LPM.IdSubactividadPetrolera = SAP.IdSubactividadPetrolera
        JOIN dbo.CO_TareaPetrolera TP
            ON LPM.IdTareaPetrolera = TP.IdTareaPetrolera
        JOIN dbo.CO_Servicio S
            ON LPM.IdServicio = S.IdServicio
        JOIN dbo.CO_Presupuesto P
            ON LPM.IdPresupuesto = P.IdPresupuesto
        LEFT JOIN dbo.CO_Instalacion I
            ON LPM.IdInstalacion = I.IdInstalacion
        LEFT JOIN dbo.CO_Registro R
            ON R.IdPrograma = LPM.IdLineaPresupuestoMes
        LEFT JOIN dbo.CO_Instalacion IR
            ON R.IdInstalacion = IR.IdInstalacion
        LEFT JOIN dbo.CO_EstadoRegistro ER
            ON R.IdEstado = ER.IdEstadoRegistro
        LEFT JOIN dbo.CO_GastosRubro rubro
            ON rubro.IdGastoRubro = R.IdGastoRubro
        LEFT JOIN dbo.FI_Factura F
            ON F.IdFactura = R.IdFactura
        LEFT JOIN dbo.PV_Subcontratista SF
            ON F.IdSubcontratista = SF.IdSubcontratista
        LEFT JOIN dbo.PV_TipoMoneda TMF
            ON TMF.IdMoneda = F.IdMoneda
        LEFT JOIN dbo.CO_TipoCambioDiario TCDF
            ON TCDF.IdMoneda = F.IdMoneda
               AND DAY(TCDF.Fecha) = DAY(F.Fecha)
               AND MONTH(TCDF.Fecha) = MONTH(F.Fecha)
               AND YEAR(TCDF.Fecha) = YEAR(F.Fecha)
        LEFT JOIN dbo.FI_PedimentoComprobante PC
            ON PC.IdPedimentoComprobante = R.IdPedimentoComprobante
        LEFT JOIN dbo.PV_Subcontratista SPC
            ON SPC.IdSubcontratista = PC.IdSubcontratistaExportador
        LEFT JOIN dbo.PV_TipoMoneda TMPC
            ON TMPC.IdMoneda = PC.IdMoneda
        LEFT JOIN dbo.CO_TipoCambioDiario TCDPC
            ON TCDPC.IdMoneda = TMPC.IdMoneda
               AND DAY(TCDPC.Fecha) = DAY(PC.FechaPago)
               AND MONTH(TCDPC.Fecha) = MONTH(PC.FechaPago)
               AND YEAR(TCDPC.Fecha) = YEAR(PC.FechaPago)
        LEFT JOIN dbo.AP_Usuario U
            ON R.IdUsuarioCreadoPor = U.UsuarioID
    --WHERE P.IdPresupuesto = @IdPresupuesto  
    GROUP BY ISNULL(R.IdRegistro, 0),
             ISNULL(S.NombreServicio, 'NA'),
             ISNULL(I.NombreInstalacion, 'NA'),
             LPM.AC_FEC_INI,
             LPM.AC_FEC_FIN,
             CASE
                 WHEN R.CvTipoDocFacturacion = 1 THEN
                     'CF'
                 WHEN R.CvTipoDocFacturacion = 2 THEN
                     'PI'
                 WHEN R.CvTipoDocFacturacion = 3 THEN
                     'PE'
                 ELSE
                     'NA'
             END,
             CASE
                 WHEN R.CvTipoDocFacturacion = 1 THEN
                     LTRIM(RTRIM(F.Serie + ' ' + F.Folio))
                 WHEN R.CvTipoDocFacturacion = 2 THEN
                     PC.NumeroPedimento
                 WHEN R.CvTipoDocFacturacion = 3 THEN
                     PC.FolioComprobante
                 ELSE
                     'NA'
             END,
             CASE
                 WHEN R.CvTipoDocFacturacion = 1 THEN
                     F.Fecha
                 WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                     PC.FechaPago
                 ELSE
                     CAST('1999-01-01' AS DATE)
             END,
             CASE
                 WHEN R.CvTipoDocFacturacion = 1 THEN
                     ISNULL(SF.RazonSocial, 'NA')
                 WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                     ISNULL(SPC.RazonSocial, 'NA')
                 ELSE
                     'NA'
             END,
             ISNULL(IR.NombreInstalacion, 'NA'),
             R.InicioEjecucion,
             R.FinEjecucion,
             ISNULL(U.Nombre, 'NA'),
             R.MontoRegistro,
             CASE
                 WHEN R.CvTipoDocFacturacion = 1 THEN
                     TMF.TipoMonedaCorto
                 WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                     TMPC.TipoMonedaCorto
                 ELSE
                     'NA'
             END,
             R.MesPresentacion,
             ACNH.DescripcionActividadPetrolera,
             SAP.SubactividadPetrolera,
             TP.TareaPetrolera,
             ISNULL(ER.NombreEstado, 'NA'),
             ISNULL(R.Comentarios, 'NA'),
             CASE
                 WHEN R.CvTipoDocFacturacion = 1 THEN
                     F.IdFactura
                 WHEN R.CvTipoDocFacturacion IN ( 2, 3 ) THEN
                     PC.IdPedimentoComprobante
                 ELSE
                     0
             END,
             LPM.IdLineaPresupuestoMes,
             P.Nombre,
             ISNULL(rubro.Descripcion, 'NA'),
             ISNULL(R.PCN, 0),
             CASE
                 WHEN R.CostosAtribuiblesAdministracion = 1 THEN
                     'SI'
                 ELSE
                     'NO'
             END,
             R.CvTipoDocFacturacion;

    /**/

    INSERT INTO #contador (Identificador, CantGastos)
    SELECT Identificador,
           COUNT(1) AS [CantGastos]
    FROM #RptGastos
    GROUP BY Identificador;

    /**/

    INSERT INTO #FACTURAS (IdFACTURA, MontoPagado)
    SELECT F.IdFactura,
           SUM(ISNULL(TRF.MontoPagado, 0) / TCDF.TipoCambio)
    FROM dbo.FI_Factura F
        JOIN dbo.FI_TransferFactura TRF
            ON TRF.IdFactura = F.IdFactura
        JOIN dbo.FI_Transfer TF
            ON TRF.IdTransfer = TF.IdTransferencia
        JOIN dbo.CO_TipoCambioDiario TCDF
            ON TCDF.IdMoneda = TF.IdMoneda
               AND CONVERT(VARCHAR, TF.FechaPago, 112) = CONVERT(VARCHAR, TCDF.Fecha, 112)
    WHERE F.IdContrato = @IdContrato
    GROUP BY F.IdFactura;

    /**/

    INSERT INTO #Registrado (Identificador, Registrado)
    SELECT Identificador,
           SUM([Registrado ADINCO]) AS [Registrado]
    FROM #RptGastos
    GROUP BY Identificador;

    /**/

    INSERT INTO #PagadoProporcional (IdRegistro, CantGastos, Proporcion, MontoPropPago)
    SELECT g.IdRegistro,
           c.CantGastos,
           g.[Registrado ADINCO] / r.[Registrado] AS [Proporcion],
           (g.[Registrado ADINCO] / r.[Registrado]) * f.MontoPagado AS [MontoPropPago]
    FROM #Registrado r
        JOIN #contador c
            ON r.Identificador = c.Identificador
        JOIN #FACTURAS f
            ON c.Identificador = f.IdFACTURA
        JOIN #RptGastos g
            ON r.Identificador = g.Identificador
    WHERE f.MontoPagado > 0;

    /**/
    INSERT INTO #Pagado
    (
        ActividadPetrolera,
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
           P.MontoPagado / c.CantGastos,
           REG.Identificador
    FROM #RptGastos REG
        JOIN #FACTURAS P
            ON REG.Identificador = P.IdFACTURA
        JOIN #contador c
            ON REG.Identificador = c.Identificador
    GROUP BY REG.ActividadPetrolera,
             REG.SubactividadPetrolera,
             REG.TareaPetrolera,
             REG.Servicio,
             P.MontoPagado / c.CantGastos,
             REG.Identificador;

    /*ACTUALIZAR MONTO PAGADO  */

    UPDATE G
    SET [Pagado ADINCO] = P.MontoPropPago
    FROM #RptGastos G
        JOIN #PagadoProporcional P
            ON G.IdRegistro = P.IdRegistro;

    /*DATOS DE PETROVENDOR*/

    --Calcular proveedor operadora  
    DECLARE @IdProveedor INT;
    SET @IdProveedor =
    (   SELECT TOP 1 P.IdProveedor
        FROM Adinco.dbo.CO_Contrato C
            JOIN Adinco.dbo.CO_Contratista CC
                ON CC.IdContratista = C.IdContratista
            JOIN Petrovendor.dbo.S_Proveedor P
                ON CC.RFC = P.RFC COLLATE DATABASE_DEFAULT
        WHERE C.IdContrato = @IdContrato);

    --Todos los montos en pesos se pasan a dolares  
    SELECT LPM.IdLineaPresupuestoMes,
           PD.Subtotal / TCDF.TipoCambio AS MontoDLS,
           P.IdPedido,
           PD.IdPedidoDetalle,
           LTRIM(RTRIM(S.RazonSocial)) AS RazonSocial,
           SP.IdSolicitudPedido,
           LTRIM(RTRIM(REQ.Nombre)) AS Requisitor,
           P.IdSubcontratista
    INTO #PedidoDetalle
    FROM Petrovendor.dbo.MM_Pedido P
        JOIN Petrovendor.dbo.TA_Operacion AS O
            ON O.IdDocumento = P.IdSolicitudPedido
        JOIN Petrovendor.dbo.MM_PedidoDetalle PD
            ON PD.IdPedido = P.IdPedido --AND ISNULL(P.Activo,0) = 0  
        JOIN Petrovendor.dbo.MM_PeticionOfertaDetalle POD
            ON POD.IdPeticionOfertaDetalle = PD.IdPeticionOfertaDetalle
        JOIN Petrovendor.dbo.MM_PeticionOferta PO
            ON PO.IdPeticionOferta = POD.IdPeticionOferta
               AND PO.IdPeticionOferta = P.IdPeticionOferta
        JOIN Petrovendor.dbo.MM_SolicitudPedido SP
            ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
               AND SP.IdSolicitudPedido = P.IdSolicitudPedido
        JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalle SPD
            ON SPD.IdSolicitudPedido = SP.IdSolicitudPedido
               AND POD.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        JOIN Petrovendor.dbo.MM_SolicitudPedidoDetalleLineaPresupuesto SPDLP
            ON SPDLP.IdSolicitudPedidoDetalle = SPD.IdSolicitudPedidoDetalle
        JOIN Adinco.dbo.CO_LineaPresupuestoMes LPM
            ON SPDLP.IdLineaPresupuesto = LPM.IdLineaPresupuestoMes
        JOIN Petrovendor.dbo.S_Proveedor S
            ON P.IdSubcontratista = S.IdProveedor
               AND P.IdSubcontratista IS NOT NULL
        JOIN Petrovendor.dbo.S_Usuario REQ
            ON SP.IdUsuarioSolicitante = REQ.IdUsuario
        JOIN #Presupuestos
            ON #Presupuestos.IdPresupuesto = LPM.IdPresupuesto
        LEFT JOIN dbo.CO_TipoCambioDiario TCDF
            ON TCDF.IdMoneda = PD.IdMoneda
               AND CONVERT(VARCHAR, TCDF.Fecha, 112) = CONVERT(VARCHAR, PD.CreadoEl, 112)
    WHERE O.IdTipoOperacion = 9 --> DE TIPO DE APROBACION DE PEDIDO  
          AND P.Version = O.NoVersion --> MISMA VERSION  
          AND O.IdEstatusOperacion = 2 --> PEDIDO APROBADO  
          AND P.RecepcionServicio = 1 --> CONFIRMACION  ACEPTADA  
          AND P.IdProveedorCompras = @IdProveedor ---> NUMERO DE PROVEEDOR DE LA OPERADORA ACTUAL  
          AND ISNULL(P.IdEstatusEliminado, 0) = 0
          AND ISNULL(PO.IdEstatusEliminado, 0) = 0
          AND ISNULL(SP.IdEstatusEliminado, 0) = 0
    GROUP BY LTRIM(RTRIM(S.RazonSocial)),
             LPM.IdLineaPresupuestoMes,
             P.IdPedido,
             SP.IdSolicitudPedido,
             LTRIM(RTRIM(REQ.Nombre)),
             PD.IdPedidoDetalle,
             P.IdSubcontratista,
			 PD.Subtotal,
			 TCDF.TipoCambio
    ORDER BY P.IdPedido;

    --  

    --se obtiene cuales pedidos tienen aceptacion de pedido  
    --esto para obtener sus lineas de presupuesto ya que estas se pueden dispersar   
    -- ya que no se ocuparian las de la solicitud de pedido  
    INSERT INTO #PedidoDetalleConAceptacion
    (
        IdPedidoDetalle,
        IdLineaPresupuestoMes,
        IdSolicitudPedido,
        IdSubcontratista,
        IdAceptacionPedido,
        Cantidad
    )
    SELECT pdt.IdPedidoDetalle,
           apdi.IdLineaPresupuesto,
           pdt.IdSolicitudPedido,
           pdt.IdSubcontratista,
           ap.IdAceptacionPedido,
           apd.Cantidad
    FROM #PedidoDetalle pdt
        JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalle apd
            ON apd.IdPedidoDetalle = pdt.IdPedidoDetalle
        JOIN Petrovendor.dbo.MM_AceptacionPedidoDetalleInstalacion apdi
            ON apdi.IdAceptacionPedidoDetalle = apd.IdAceptacionPedidoDetalle
        JOIN Petrovendor.dbo.MM_AceptacionPedido ap
            ON ap.IdAceptacionPedido = apd.IdAceptacionPedido
    WHERE ISNULL(ap.IdEstatusEliminado, 0) = 0
    GROUP BY pdt.IdPedidoDetalle,
             apdi.IdLineaPresupuesto,
             pdt.IdSolicitudPedido,
             pdt.IdSubcontratista,
             ap.IdAceptacionPedido,
             apd.Cantidad


    -- se eliminan los detalles del pedido que ya tienen aceptacion de pedido  
    -- esto por que la linea de presupuesto se selecciona en la aceptacion de pedido ya no es el de la solped  
    DELETE #PedidoDetalle
    WHERE IdPedidoDetalle IN ( SELECT pdca.IdPedidoDetalle FROM #PedidoDetalleConAceptacion pdca )

    -- se agregan los pedido detalle que se eliminaron con las lineas que se seleccionaron la aceptacion de pedido  
    INSERT INTO #PedidoDetalle
    SELECT pdca.IdLineaPresupuestoMes,
           pd.Subtotal /TCDF.TipoCambio AS MontoDLS,
           PD.IdPedido,
           PD.IdPedidoDetalle,
           LTRIM(RTRIM(S.RazonSocial)) AS RazonSocial,
           pdca.IdSolicitudPedido,
           LTRIM(RTRIM(REQ.Nombre)) AS Requisitor,
           pdca.IdSubcontratista
    FROM #PedidoDetalleConAceptacion pdca
        JOIN Petrovendor.dbo.MM_PedidoDetalle PD
            ON pdca.IdPedidoDetalle = PD.IdPedidoDetalle
        JOIN Adinco.dbo.CO_LineaPresupuestoMes LPM
            ON pdca.IdLineaPresupuestoMes = LPM.IdLineaPresupuestoMes
        JOIN Petrovendor.dbo.S_Proveedor S
            ON pdca.IdSubcontratista = S.IdProveedor
        JOIN Petrovendor.dbo.MM_SolicitudPedido sp
            ON sp.IdSolicitudPedido = pdca.IdSolicitudPedido
        JOIN Petrovendor.dbo.S_Usuario REQ
            ON sp.IdUsuarioSolicitante = REQ.IdUsuario
        JOIN #Presupuestos
            ON #Presupuestos.IdPresupuesto = LPM.IdPresupuesto
		LEFT JOIN dbo.CO_TipoCambioDiario TCDF
            ON TCDF.IdMoneda = PD.IdMoneda
               AND CONVERT(VARCHAR, TCDF.Fecha, 112) = CONVERT(VARCHAR, pd.CreadoEl, 112)
    GROUP BY LTRIM(RTRIM(S.RazonSocial)),
             LTRIM(RTRIM(REQ.Nombre)),
             pdca.IdLineaPresupuestoMes,
             PD.IdPedido,
             PD.IdPedidoDetalle,
             pdca.IdSolicitudPedido,
             pdca.IdSubcontratista,
			 pd.Subtotal,
			 TCDF.TipoCambio
    ORDER BY PD.IdPedido;



    SELECT PD.IdPedido,
           pdca.IdPedidoDetalle,
           (ISNULL(PD.PrecioUnitario * pdca.Cantidad, 0) / TCDF.TipoCambio) AS MontoDLS,
           pdca.IdAceptacionPedido
    INTO #PedidosDetalleAceptacionT
    FROM #PedidoDetalleConAceptacion pdca
        INNER JOIN Petrovendor.dbo.MM_PedidoDetalle PD
            ON PD.IdPedidoDetalle = pdca.IdPedidoDetalle
		LEFT JOIN dbo.CO_TipoCambioDiario TCDF
            ON TCDF.IdMoneda = PD.IdMoneda
               AND CONVERT(VARCHAR, TCDF.Fecha, 112) = CONVERT(VARCHAR, pd.CreadoEl, 112)
    GROUP BY PD.IdPedido,
             pdca.IdPedidoDetalle,
             pdca.IdAceptacionPedido,
             PD.PrecioUnitario,
             pdca.Cantidad,
             TCDF.TipoCambio

    --  

    SELECT P.IdLineaPresupuestoMes,
           ISNULL(P.MontoDLS, 0) AS MontoPedidoDetalleDLS,
           P.IdPedido,
           PS.IdPedido AS NoPedido,
           P.RazonSocial,
           P.IdSolicitudPedido,
           P.Requisitor,
           SUM(ISNULL(PDA.MontoDLS, 0)) AS MontoAceptadoDLS,
           CASE
                   WHEN ISNULL(PO.Cerrado, 0) = 1 THEN
                       0
                   ELSE
                       ISNULL(P.MontoDLS, 0) - ISNULL(SUM(PDA.MontoDLS),0)
           END AS FaltantePorAceptar,
           AF.IdAceptacionFactura,
           CASE
                   WHEN ISNULL(PO.Cerrado, 0) = 1 THEN
                       ISNULL(P.MontoDLS, 0) - ISNULL(SUM(PDA.MontoDLS),0)
                   ELSE
                       0
               END AS MontoCerrado
    INTO #DatosPetrovendor
    FROM #PedidoDetalle P
        LEFT JOIN #PedidosDetalleAceptacionT PDA
            ON PDA.IdPedidoDetalle = P.IdPedidoDetalle
        LEFT JOIN Petrovendor.dbo.MM_Pedido PO
            ON PO.IdPedido = P.IdPedido
        LEFT JOIN Petrovendor.dbo.MM_Pedidos PS
            ON PS.IdIdentificador = PO.IdPedido
               AND PS.IdProveedorCliente = PO.IdProveedorCompras
        LEFT JOIN Petrovendor.dbo.MM_AceptacionFactura AF
            ON AF.IdAceptacionPedido = PDA.IdAceptacionPedido
        LEFT JOIN Petrovendor.dbo.TA_Operacion O
            ON O.IdDocumento = AF.IdAceptacionFactura
               AND PO.IdSubcontratista = O.IdProveedor
        LEFT JOIN Petrovendor.dbo.TA_Estatus T
            ON T.IdEstatus = O.IdEstatusOperacion
               AND O.IdTipoOperacion = 10
               AND O.IdEstatusOperacion IN ( 1 )
               AND ISNULL(AF.IdEstatusEliminado, 0) <> 1
    WHERE AF.IdAceptacionFactura IS NULL
    GROUP BY P.IdLineaPresupuestoMes,
             P.IdPedido,
             P.RazonSocial,
             P.IdSolicitudPedido,
             P.Requisitor,
             PS.IdPedido,
             AF.IdAceptacionFactura,
			 P.MontoDLS,
			 PO.Cerrado
    ORDER BY P.IdPedido DESC;

    /**/

    INSERT INTO #MontosDolares
    (
        id,
        idLineaPresupuesto,
        MontoTotalPedido,
        MontoAceptado,
        MontoPendiente,
        IdPedido,
        Proveedor,
        Requisicion,
        Requisitor,
        MontoCerrado
    )
    SELECT ROW_NUMBER() OVER (ORDER BY IdLineaPresupuestoMes),
           IdLineaPresupuestoMes,
           MontoPedidoDetalleDLS,
           MontoAceptadoDLS,
           FaltantePorAceptar,
           NoPedido,
           RazonSocial,
           IdSolicitudPedido,
           Requisitor,
           MontoCerrado
    FROM #DatosPetrovendor;

    --SELECT * FROM #MontosDolares  

    /**/

    INSERT INTO #MontoEjercidoPorLinea
    (
        Id,
        IdLineaPresupuesto,
        MontoTotalPedido,
        MontoAceptado,
        MontoPendiente,
        IdPedido,
        Proveedor,
        Requisicion,
        Requisitor,
        MontoCerrado
    )
    SELECT NULL,
           idLineaPresupuesto,
           SUM(MontoTotalPedido),
           SUM(MontoAceptado),
           SUM(MontoPendiente),
           IdPedido,
           Proveedor,
           Requisicion,
           Requisitor,
           MontoCerrado
    FROM #MontosDolares
    --WHERE IdPedido = 10311  
    GROUP BY
    --id,   
    idLineaPresupuesto,
    IdPedido,
    Proveedor,
    Requisicion,
    Requisitor,
    MontoCerrado

    /**/

    INSERT INTO #ProveedoresxLP (IdLineaPresupuesoMes, Proveedores)
    SELECT IdLineaPresupuesto,
           STUFF(
           (   SELECT DISTINCT
                      ', ' + 'OC ' + LTRIM(IdPedido) + ' | PROV ' + LTRIM(Proveedor) + ' | REQ '
                      + LTRIM(Requisicion) + ' | USR ' + LTRIM(Requisitor)
               FROM #MontoEjercidoPorLinea A
               WHERE B.IdLineaPresupuesto = A.IdLineaPresupuesto
               FOR XML PATH('')),
           1,
           1,
           '') M --AND B.Id = A.Id  
    FROM #MontoEjercidoPorLinea B
    GROUP BY IdLineaPresupuesto;

    /*ACTUALIZAR OC APROBADAS*/

    INSERT INTO #RptGastos
    (
        IdRegistro,
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
        MontoTotalPedido,
        MontoAceptado,
        MontoPendiente
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
           SUM(ISNULL(me.MontoCerrado, 0)) AS Anexo4,
           0 AS Identificador,
           CO_LineaPresupuestoMes.IdLineaPresupuestoMes AS LineaPresupuesto,
           CO_Presupuesto.Nombre AS Presupuesto,
           'NA' AS Rubro,
           0 AS PCN,
           NULL AS CAA,
           0 AS Deuda,
           SUM(ISNULL(me.MontoTotalPedido, 0)) AS MontoTotalPedido,
           SUM(ISNULL(me.MontoAceptado, 0)) AS MontoAceptado,
           SUM(ISNULL(me.MontoPendiente, 0)) AS MontoPendiente
    FROM #Presupuestos PP
        JOIN dbo.CO_LineaPresupuestoMes
            ON PP.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        JOIN CO_ActividadPetroleraCNH
            ON CO_LineaPresupuestoMes.IdActividadPetrolera = CO_ActividadPetroleraCNH.IdActividadPetrolera
        JOIN CO_SubactividadPetrolera
            ON CO_LineaPresupuestoMes.IdSubactividadPetrolera = CO_SubactividadPetrolera.IdSubactividadPetrolera
        JOIN CO_TareaPetrolera
            ON CO_LineaPresupuestoMes.IdTareaPetrolera = CO_TareaPetrolera.IdTareaPetrolera
        JOIN CO_Servicio
            ON CO_LineaPresupuestoMes.IdServicio = CO_Servicio.IdServicio
        JOIN CO_Instalacion
            ON CO_LineaPresupuestoMes.IdInstalacion = CO_Instalacion.IdInstalacion
        JOIN CO_Presupuesto
            ON CO_Presupuesto.IdPresupuesto = CO_LineaPresupuestoMes.IdPresupuesto
        LEFT JOIN #MontoEjercidoPorLinea me
            ON me.IdLineaPresupuesto = CO_LineaPresupuestoMes.IdLineaPresupuestoMes
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
    HAVING SUM(ISNULL(me.MontoTotalPedido, 0)) <> 0;

    /**/

    INSERT INTO #Cantidad
    (
        Clasificacion,
        --   IdActividad,  
        ActividadPetrolera,
        --          IdSubActividadPetrolera,  
        SubactividadPetrolera,
        --          IdTareaPetrolera,  
        TareaPetrolera,
        SubTareaPetrolera,
        Cantidad
    )
    SELECT CONCAT(
           ActividadPetrolera, ' - ', SubactividadPetrolera, ' - ', TareaPetrolera, ' - ', Servicio),
           ActividadPetrolera,
           SubactividadPetrolera,
           TareaPetrolera,
           Servicio,
           COUNT(1)
    FROM #RptGastos
    GROUP BY CONCAT(
             ActividadPetrolera,
             ' - ',
             SubactividadPetrolera,
             ' - ',
             TareaPetrolera,
             ' - ',
             Servicio),
             ActividadPetrolera,
             SubactividadPetrolera,
             TareaPetrolera,
             Servicio;
    UPDATE P
    SET P.Cantidad = C.Cantidad
    FROM #Presupuestado P
        JOIN #Cantidad C
            ON P.ActividadPetrolera = C.ActividadPetrolera
               AND P.SubactividadPetrolera = C.SubactividadPetrolera
               AND P.TareaPetrolera = C.TareaPetrolera
               AND P.SubTareaPetrolera = C.SubTareaPetrolera;

    /*SELECT QUE LLENA REPORTE HOJA BASE*/

    --DELETE #RptGastos  

    /**/

    SELECT #RptGastos.IdRegistro,
           --SUBSTRING(CONCAT(#RptGastos.ActividadPetrolera, ' - ', #RptGastos.SubactividadPetrolera, ' - ', #RptGastos.TareaPetrolera, ' - ', #RptGastos.Servicio), 1, 255) AS Servicio,   
           SUBSTRING(
           CONCAT(
           PRESUP.IdActividad,
           ' - ',
           PRESUP.IdSubActividadPetrolera,
           ' - ',
           PRESUP.IdTareaPetrolera,
           ' - ',
           #RptGastos.Servicio),
           1,
           255) AS Servicio,
           --#RptGastos.Servicio AS Servicio,   
           #RptGastos.InstalacionPresupuestada,
           #RptGastos.FechaInicio,
           #RptGastos.FechaFin,
           #RptGastos.TipoDocumento,
           #RptGastos.Numero,
           #RptGastos.FechaDocumento,
           ISNULL(#RptGastos.[Registrado ADINCO], 0) AS [Registrado ADINCO],
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
           SUBSTRING(#RptGastos.Comentarios, 1, 255) AS Comentarios,
           #RptGastos.Anexo4,
           #RptGastos.Identificador,
           #RptGastos.LineaPresupuesto,
           #RptGastos.Presupuesto,
           #RptGastos.Rubro,
           #RptGastos.PCN,
           #RptGastos.CAA,
           ISNULL(#RptGastos.[Registrado ADINCO] - #RptGastos.[Pagado ADINCO], 0) AS Deuda,
           #RptGastos.MontoTotalPedido,
           SUBSTRING(ISNULL(P.Proveedores, ''), 1, 255) AS [OC-Prov],
           CASE
               WHEN ISNULL(PRESUP.Cantidad, 0) = 0 THEN
                   0
               ELSE
                   ROUND(ISNULL(PRESUP.PresupuestoUSD, 0) / PRESUP.Cantidad, 4)
           END AS [Presupuestado],
           CASE
               WHEN ISNULL(PRESUP.PresupuestoUSD, 0) = 0 THEN
                   0
               ELSE
           ((ISNULL(MontoTotalPedido, 0) + ISNULL([Registrado ADINCO], 0))
            / ISNULL(PRESUP.PresupuestoUSD, 0))
           END AS [TotalEjercido],
           ISNULL(MontoTotalPedido, 0) + ISNULL([Registrado ADINCO], 0) AS [Ejercido],
           (CASE
                WHEN ISNULL(PRESUP.Cantidad, 0) = 0 THEN
                    0
                ELSE
                    ROUND(ISNULL(PRESUP.PresupuestoUSD, 0) / PRESUP.Cantidad, 4)
            END) - (ISNULL(MontoTotalPedido, 0) + ISNULL([Registrado ADINCO], 0)) AS SaldoUSD,
           #RptGastos.MontoAceptado,
           #RptGastos.MontoPendiente
    FROM #RptGastos
        LEFT JOIN #ProveedoresxLP P
            ON #RptGastos.LineaPresupuesto = P.IdLineaPresupuesoMes
        LEFT JOIN #Presupuestado PRESUP
            ON #RptGastos.ActividadPetrolera = PRESUP.ActividadPetrolera
               AND #RptGastos.SubactividadPetrolera = PRESUP.SubactividadPetrolera
               AND #RptGastos.TareaPetrolera = PRESUP.TareaPetrolera
               AND #RptGastos.Servicio = PRESUP.SubTareaPetrolera
    ORDER BY IdRegistro;
END;


