USE [Petrovendor]
GO
IF EXISTS
(
    SELECT 1
    FROM dbo.sysobjects
    WHERE name = 'SP_MM_ConsultarPeticionOferta'
)
DROP PROCEDURE SP_MM_ConsultarPeticionOferta;
GO
/****** Object:  StoredProcedure [dbo].[SP_MM_ConsultarPeticionOferta]    Script Date: 25/08/2022 06:02:31 p. m. ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO		
--**************************************************************
-- Modified:      <Luis David>									
-- Updated date: <01/11/2021>									
-- Description: <Reacomodo de tablas para optimización>			
--**************************************************************
-- =============================================
-- Author:	Daniel AC
-- Create date: <25/08/2022>
-- Description:	Optimización de sp
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarPeticionOferta] 
@IdPeticionOferta INT, 
@IdProveedorVenta INT, 
@IdContrato       INT      = NULL, 
@IdUsuario        INT      = NULL, 
@FechaRegistro    DATETIME = NULL

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
               CONCAT(ISNULL(P.RazonSocial,'') ,ISNULL(' '+ P.RegimenCapital,'')) AS RazonSocial, 
               CONCAT(ISNULL(P.Municipio,''),ISNULL(' ' + P.Entidad,'')) AS Ubicacion, 
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
             JOIN MM_SolicitudPedido AS SP  (NOLOCK)
				ON PO.IdSolicitudPedido  = SP.IdSolicitudPedido  
				AND PO.IdPeticionOferta = @IdPeticionOferta 
				AND PO.IdSubcontratista = @IdProveedorVenta            
             JOIN TA_Operacion OPT  (NOLOCK)
				ON PO.IdSolicitudPedido = OPT.IdDocumento 
				AND OPT.IdTipoOperacion = 6 --> CTE 6 Es tipo de operación de Cotización 
             JOIN TA_Estatus AS TE (NOLOCK)
				ON OPT.IdEstatusOperacion = TE.IdEstatus
             JOIN MM_PrioridadSolicitudPedido AS PSP (NOLOCK)
				ON SP.IdPrioridadSolicitudPedido = PSP.IdPrioridadSolicitudPedido
             JOIN TA_Prioridad AS TP  (NOLOCK)
				ON OPT.IdPrioridad = TP.IdPrioridad
             JOIN TA_Vencimiento AS V  (NOLOCK)
				ON OPT.IdVigencia = V.IdVencimiento
             JOIN S_Proveedor AS P (NOLOCK)
				ON SP.IdProveedor = P.IdProveedor
             LEFT JOIN TA_TerminosCondicionesOperacion AS TYC  (NOLOCK)
				ON OPT.IdOperacion = TYC.IdOperacion
             LEFT JOIN TA_DocFianzaOperacion AS DFO  (NOLOCK)
				ON OPT.IdOperacion = DFO.IdOperacion
				AND DFO.Activo = 1
             LEFT JOIN dbo.MM_EdicionCotizacion AS EC  (NOLOCK)
				ON PO.IdPeticionOferta = EC.IdPeticionOferta
        
    END;
