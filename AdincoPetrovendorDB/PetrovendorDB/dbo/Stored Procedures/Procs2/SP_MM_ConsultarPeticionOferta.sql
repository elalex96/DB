DROP PROCEDURE IF EXISTS SP_MM_ConsultarPeticionOferta
GO
-- =============================================
-- Author:		<Pedro Acuña>
-- Create date: <17-09-2018>
-- Description:	<Se agrega el bit de activo>
-- =============================================
-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar detalle de la cotización del lado de procura
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Agregue left join para obtener el registro de Edición de cotización, cambie comparación de horas por minutos en validación de vencimiento de cotización
-- =============================================
--**************************************************************
-- Modified:      <Jose Roman>									
-- Updated date: <09/01/2018>									
-- Description: <Se agrega la consulta de terminos y condiciones y verificable tambien se agregan parametros de contrato>			
--**************************************************************
--**************************************************************
-- Modified:      <Pedro Acuña>									
-- Updated date: <02/07/2018>									
-- Description: <se agrega al retorno el idsolicitudpedido (num de requisicion)>			
--**************************************************************
--**************************************************************
-- Modified:      <Alexander Gomez>									
-- Updated date: <26/07/2019>									
-- Description: <se modifico el envio de terminos y condiciones>			
--**************************************************************
-- Modified:      <Luis David>									
-- Updated date: <01/11/2021>									
-- Description: <Reacomodo de tablas para optimización>			
--**************************************************************
CREATE PROCEDURE [dbo].[SP_MM_ConsultarPeticionOferta] @IdPeticionOferta INT, 
                                                      @IdProveedorVenta INT,

                                                      /*--------------------parametros contrato  --------------------*/

                                                      @IdContrato       INT      = NULL, 
                                                      @IdUsuario        INT      = NULL, 
                                                      @FechaRegistro    DATETIME = NULL

/*---------------------------------------------------------------*/

AS
    BEGIN
        -- SET NOCOUNT ON added to prevent extra result sets from
        -- interfering with SELECT statements.
        SET NOCOUNT ON;
        SELECT 1 AS Oferta, 
               ISNULL(PO.IdEstatus, 1) AS EstatusPO, 
               PO.IdPeticionOferta, 
               SP.AdjudicableParcialmente, 
               PSP.Prioridad, 
               SP.VisitaRequerida, 
               SP.JuntaAclaracionesRequerida, 
               SP.UnaSolaEntregaRequerida, 
               SP.FechaEntregaRequerida, 
               SP.FechaEntregaFinRequerida, 
               OPT.IdEstatusOperacion, 
               TE.Nombre, 
               OPT.FechaRegistro, 
               OPT.Descripcion, 
               TP.Nombre, 
               (P.RazonSocial + ' ' + P.RegimenCapital) AS RazonSocial, 
               (P.Municipio + ' ' + P.Entidad) AS Ubicacion, 
               ISNULL(OPT.FechaFinalizacion, GETDATE()) AS FechaVencimiento, 
               OPT.IdOperacion, 
               ISNULL(PO.Cotizado, 'false') AS PeticionCotizada, 
               ((CASE
                     WHEN(DATEDIFF(MINUTE, OPT.FechaFinalizacion, GETDATE())) <= 0
                     THEN 'false'
                     ELSE 'true'
                 END)) AS POD_Vencida, 
               ISNULL(PO.NoCotizar, 'false') AS NoCotizar, 
               OPT.IdOperacion, --ISNULL ( TYC.IdTerminosYCondiciones, 0 ), 
               ISNULL(DFO.IdDocFianza, 0), 
               SP.IdTipoSolicitudPedido, 
               ISNULL(EC.IdEdicionCotizacion, 0) AS IdEdicionCotizacion, 
               ISNULL(EC.IdEstatus, 0) AS IdEstatusCotizacion, 
               ISNULL(sp.EntregasParciales, 0) AS EntregasParciales, 
               ISNULL(po.AceptoTerminosCondiciones, 0), 
               ISNULL(po.Verificable, 0), 
               ISNULL(SP.IdSolicitudPedido, 0), 
               ISNULL(PO.CotizacionRestringida, 0)
        FROM MM_PeticionOferta AS PO
             INNER JOIN MM_SolicitudPedido AS SP 
			 ON SP.IdSolicitudPedido = PO.IdSolicitudPedido  
			 AND PO.IdPeticionOferta = @IdPeticionOferta 
			 AND PO.IdSubcontratista = @IdProveedorVenta
             --INNER JOIN dbo.MM_TipoSolicitudPedido AS ts ON sp.IdTipoSolicitudPedido = ts.IdTipoSolicitudPedido
             INNER JOIN TA_Operacion OPT 
			 ON PO.IdSolicitudPedido = OPT.IdDocumento 
			 AND OPT.IdTipoOperacion = 6
             INNER JOIN TA_Estatus AS TE 
			 ON OPT.IdEstatusOperacion = TE.IdEstatus
             INNER JOIN MM_PrioridadSolicitudPedido AS PSP 
			 ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
             INNER JOIN TA_Prioridad AS TP 
			 ON OPT.IdPrioridad = TP.IdPrioridad
             INNER JOIN TA_Vencimiento AS V 
			 ON OPT.IdVigencia = V.IdVencimiento
             INNER JOIN S_Proveedor AS P 
			 ON SP.IdProveedor = P.IdProveedor
             LEFT JOIN TA_TerminosCondicionesOperacion AS TYC 
			 ON OPT.IdOperacion = TYC.IdOperacion
             LEFT JOIN TA_DocFianzaOperacion AS DFO 
			 ON OPT.IdOperacion = DFO.IdOperacion
             AND DFO.Activo = 1
             LEFT JOIN dbo.MM_EdicionCotizacion AS EC 
			 ON PO.IdPeticionOferta = EC.IdPeticionOferta
        --#Donde OPT.IdTipoOperacion = 6 Es tipo de operación de Cotización 
    END;
