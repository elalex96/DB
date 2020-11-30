
-- =============================================
-- Author:		Daniel AC
-- Create date: 10-07-17
-- Description:	LLenar reporte Solicitudes de Pedido 
-- =============================================
-- Author:		Jose Roman
-- Create date: 11-09-2018
-- Description:	Se agrega la fecha final si es una entrega parcial 
-- =============================================
CREATE PROCEDURE SP_PR_MM_ConsultaSolicitudPedido
    -- Add the parameters for the stored procedure here

    @IdSolicitudPedido INT,
    @IdProveedor INT,
    @IdContrato INT,
    @FechaRegistro DATETIME,
    @IdUsuario INT
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    -- Insert statements for procedure here
    DECLARE @LINEAPRESUPUESTO NVARCHAR(MAX);
    SET @LINEAPRESUPUESTO =
    (
        SELECT ISNULL(
               (
                   SELECT TOP 1
                       CONCAT(
                                 RIGHT('00' + CAST(MONTH(LPM.AC_PRESUP_MES) AS VARCHAR(2)), 2),
                                 ' ',
                                 DATENAME(MONTH, LPM.AC_PRESUP_MES),
                                 ' ',
                                 YEAR(LPM.AC_PRESUP_MES),
                                 ' - ',
                                 AP.DescripcionActividadPetrolera COLLATE DATABASE_DEFAULT,
                                 '(',
                                 SP.SubactividadPetrolera COLLATE DATABASE_DEFAULT,
                                 ')'
                             ) AS Mes_Presupuestado
                   FROM Adinco.dbo.CO_LineaPresupuestoMes LPM
                       LEFT OUTER JOIN MM_SolicitudPedido PSP
                           ON PSP.IdLineaPresupuesto = LPM.IdLineaPresupuestoMes
                       LEFT OUTER JOIN Adinco.dbo.CO_ActividadPetroleraCNH AP
                           ON LPM.IdActividadPetrolera = AP.IdActividadPetrolera
                       LEFT OUTER JOIN Adinco.dbo.CO_SubactividadPetrolera SP
                           ON LPM.IdSubactividadPetrolera = SP.IdSubactividadPetrolera
                   WHERE PSP.IdSolicitudPedido = @IdSolicitudPedido
                         AND LPM.IdPresupuesto = PSP.IdPresupuesto
                         AND LPM.IdLineaPresupuestoMes = PSP.IdLineaPresupuesto
               ),
               'No Disponible'
                     ) AS LINEA_PRESUPUESTO
    );




    SELECT SP.IdSolicitudPedido,
           SP.MotivoUrgencia AS DescripcionPedido,
           TSP.TipoSolicitudPedido,
           SP.FechaAlta,
           CASE SP.AdjudicableParcialmente
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS Adjudicable,
           CASE SP.VisitaRequerida
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS VisitaRequerida,
           CASE SP.JuntaAclaracionesRequerida
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS JuntaAclaracionesRequerida,
           CASE SP.UnaSolaEntregaRequerida
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS EntregaUnica,
           CASE SP.UnaSolaEntregaRequerida
               WHEN 0 THEN
                   'SI'
               ELSE
                   'NO'
           END AS EntregaParcial,
           CASE SP.Fianza
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS Fianza,
           CASE SP.Controlados
               WHEN 1 THEN
                   'SI'
               ELSE
                   'NO'
           END AS Controlados,
           CASE
               WHEN SP.EntregasParciales = 1 THEN
                   CONCAT(
                             CONVERT(VARCHAR(50), SP.FechaEntregaRequerida, 103),
                             ' - ',
                             CONVERT(VARCHAR(50), SP.FechaEntregaFinRequerida, 103)
                         )
               ELSE
                   CONVERT(VARCHAR(50), SP.FechaEntregaRequerida, 103)
           END AS FechaEntregaRequerida,
           SP.FechaEntregaFinRequerida,
           TAO.IdEstatusOperacion,
           TE.Nombre,
           PSP.Prioridad,
           U.Nombre AS Solicitante,
           TAO.IdOperacion,
           ISNULL(SP.PeticionEnviada, 'false') AS PeticionEnviada,
           TiOp.NombreOperacion,
           CC.CentroCosto,
           ISNULL(TC.Termino, 'No aplica') AS Termino,
           CONCAT(P.Nombre COLLATE DATABASE_DEFAULT, '  [', P.IdPresupuestoCNH COLLATE DATABASE_DEFAULT, ']  ') AS Presupuesto,
           PC.NombrePeriodo AS Periodo,
           TG.TipoGasto,
           CONCAT(Pr.RazonSocial COLLATE DATABASE_DEFAULT, ' ', Pr.RegimenCapital COLLATE DATABASE_DEFAULT) AS Proveedor,
           @LINEAPRESUPUESTO AS LineaPresupuesto,
           TAO.Descripcion,
           CONCAT(
                     'Col.',
                     DO.Colonia,
                     ' Calle: ',
                     DO.Calle,
                     ' N�Ext: ',
                     DO.NoExterior,
                     ' N�Int: ',
                     DO.NoInterior,
                     ' C.P. ',
                     DO.CodigoPostal,
                     ' ',
                     DO.Municipio,
                     ' ',
                     DO.Estado,
                     ' ',
                     DO.Pais
                 ) AS DomicilioOperadora,
           U.Nombre NombreContacto,
           U.Correo AS CorreoContacto,
           U.Telefono AS TelefonoContacto,
           Pr.RFC,
           SP.IdFirma AS FirmaSolicitudPedido,
           ACON.NombreAreaContractual,
           CON.NumeroContrato
    FROM MM_SolicitudPedido AS SP
        LEFT JOIN MM_TipoSolicitudPedido AS TSP
            ON TSP.IdTipoSolicitudPedido = SP.IdTipoSolicitudPedido
        LEFT JOIN TA_Operacion AS TAO
            ON TAO.IdDocumento = SP.IdSolicitudPedido
        LEFT JOIN TA_Estatus AS TE
            ON TE.IdEstatus = TAO.IdEstatusOperacion
        LEFT JOIN MM_PrioridadSolicitudPedido AS PSP
            ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
        LEFT JOIN S_Usuario AS U
            ON U.IdUsuario = TAO.IdAsignador
        LEFT JOIN TA_TipoOperacion AS TiOp
            ON TiOp.IdTipoOperacion = TAO.IdTipoOperacion
        LEFT JOIN CC_CentroCosto AS CC
            ON CC.IdCentroCosto = SP.IdCentroCosto
        LEFT JOIN MM_TerminoComercio AS TC
            ON TC.IdTerminoComercio = SP.IdTerminoInternacionales
        LEFT JOIN MM_TipoGastos AS TG
            ON TG.IdTipoGasto = SP.IdTipoGasto
        LEFT JOIN S_Proveedor AS Pr
            ON SP.IdProveedor = Pr.IdProveedor
        LEFT JOIN DG_Domicilio AS DO
            ON DO.IdProveedor = SP.IdProveedor
               AND DO.IdTipoDomicilio = 1
               AND DO.Activo = 1
        LEFT JOIN Adinco.dbo.CO_Presupuesto AS P
            ON SP.IdPresupuesto = P.IdPresupuesto
        LEFT JOIN Adinco.dbo.CO_PeriodoContrato AS PC
            ON SP.IdPeriodo = PC.IdPeriodo
        LEFT JOIN Adinco.dbo.CO_Contrato AS CON
            ON CON.IdContrato = SP.IdContrato
        LEFT JOIN Adinco.dbo.CO_AreaContractual AS ACON
            ON ACON.IdAreaContractual = CON.IdAreaContractual
    WHERE TAO.IdTipoOperacion = 2
          AND SP.IdSolicitudPedido = @IdSolicitudPedido
          AND SP.IdProveedor = @IdProveedor;
END;







