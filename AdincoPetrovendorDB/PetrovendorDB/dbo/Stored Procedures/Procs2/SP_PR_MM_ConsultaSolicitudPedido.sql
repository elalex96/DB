USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_PR_MM_ConsultaSolicitudPedido'
)
    DROP PROCEDURE SP_PR_MM_ConsultaSolicitudPedido;
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Daniel AC
-- Create date: 10-07-17
-- Description:	LLenar reporte Solicitudes de Pedido 
-- =============================================
-- Author:		Jose Roman
-- Create date: 11-09-2018
-- Description:	Se agrega la fecha final si es una entrega parcial 
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 20/05/2021
-- Description:	Se agrega el campo de solicitante
-- =============================================
-- Author:		Alexander Gomez
-- Create date: 10/10/2023
-- Description:	se agregan estandares de desarrollo
-- =============================================
CREATE PROCEDURE [dbo].[SP_PR_MM_ConsultaSolicitudPedido]
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
                   FROM Adinco.dbo.CO_LineaPresupuestoMes LPM (NOLOCK)
                       LEFT OUTER JOIN MM_SolicitudPedido PSP (NOLOCK)
                           ON LPM.IdLineaPresupuestoMes = PSP.IdLineaPresupuesto
                       LEFT OUTER JOIN Adinco.dbo.CO_ActividadPetroleraCNH AP (NOLOCK)
                           ON LPM.IdActividadPetrolera = AP.IdActividadPetrolera
                       LEFT OUTER JOIN Adinco.dbo.CO_SubactividadPetrolera SP (NOLOCK)
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
           ISNULL(USO.Nombre,U.Nombre) AS Solicitante,
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
    FROM MM_SolicitudPedido AS SP (NOLOCK)
        LEFT JOIN MM_TipoSolicitudPedido AS TSP (NOLOCK)
            ON SP.IdTipoSolicitudPedido = TSP.IdTipoSolicitudPedido
        LEFT JOIN TA_Operacion AS TAO (NOLOCK)
            ON SP.IdSolicitudPedido = TAO.IdDocumento
        LEFT JOIN TA_Estatus AS TE (NOLOCK)
            ON TAO.IdEstatusOperacion = TE.IdEstatus
        LEFT JOIN MM_PrioridadSolicitudPedido AS PSP (NOLOCK)
            ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
        LEFT JOIN S_Usuario AS U (NOLOCK)
            ON TAO.IdAsignador = U.IdUsuario
        LEFT JOIN TA_TipoOperacion AS TiOp (NOLOCK)
            ON TAO.IdTipoOperacion = TiOp.IdTipoOperacion
        LEFT JOIN CC_CentroCosto AS CC (NOLOCK)
            ON SP.IdCentroCosto = CC.IdCentroCosto
        LEFT JOIN MM_TerminoComercio AS TC (NOLOCK)
            ON SP.IdTerminoInternacionales = TC.IdTerminoComercio
        LEFT JOIN MM_TipoGastos AS TG (NOLOCK)
            ON SP.IdTipoGasto = TG.IdTipoGasto
        LEFT JOIN S_Proveedor AS Pr (NOLOCK)
            ON SP.IdProveedor = Pr.IdProveedor
        LEFT JOIN DG_Domicilio AS DO (NOLOCK)
            ON SP.IdProveedor = DO.IdProveedor
               AND DO.IdTipoDomicilio = 1
               AND DO.Activo = 1
        LEFT JOIN Adinco.dbo.CO_Presupuesto AS P (NOLOCK)
            ON SP.IdPresupuesto = P.IdPresupuesto
        LEFT JOIN Adinco.dbo.CO_PeriodoContrato AS PC (NOLOCK)
            ON SP.IdPeriodo = PC.IdPeriodo
        LEFT JOIN Adinco.dbo.CO_Contrato AS CON (NOLOCK)
            ON SP.IdContrato = CON.IdContrato
        LEFT JOIN Adinco.dbo.CO_AreaContractual AS ACON (NOLOCK)
            ON CON.IdAreaContractual = ACON.IdAreaContractual
		LEFT JOIN S_Usuario AS USO (NOLOCK)
			ON SP.Solicitante = USO.IdUsuario
    WHERE TAO.IdTipoOperacion = 2
          AND SP.IdSolicitudPedido = @IdSolicitudPedido
          AND SP.IdProveedor = @IdProveedor;

END;