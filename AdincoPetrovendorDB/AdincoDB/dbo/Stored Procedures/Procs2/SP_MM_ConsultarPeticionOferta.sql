-- =============================================
-- Author:		Daniel AC
-- Create date: 14-04-17
-- Description:	Consultar Materiales que se quieren agregar al pedido de manera Temp 
-- =============================================
CREATE PROCEDURE [dbo].[SP_MM_ConsultarPeticionOferta]
	-- Add the parameters for the stored procedure here

@IdPeticionOferta INT,
@IdProveedorVenta INT
AS
     BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.

         SET NOCOUNT ON;
	
	--SELECT O.IdOferta, O.IdEstatus, PO.IdPeticionOferta, SP.AdjudicableParcialmente, PSP.Prioridad, SP.VisitaRequerida, SP.JuntaAclaracionesRequerida,
	--SP.UnaSolaEntregaRequerida,SP.FechaEntregaRequerida, SP.FechaEntregaFinRequerida, OPT.IdEstatusOperacion, TE.Nombre, OPT.FechaRegistro,
	--OPT.Descripcion, TP.Nombre,(P.RazonSocial +' ' + P.RegimenCapital) AS RazonSocial, (P.Municipio+' '+P.Entidad) AS Ubicacion, (DATEADD (day, V.DiaVencimiento,OPT.FechaRegistro)) AS FechaVencimiento, OPT.IdOperacion
	--FROM MM_PeticionOferta  AS PO
	--INNER JOIN MM_OFERTA AS O ON PO.IdPeticionOferta = O.IdPeticionOferta
	--INNER JOIN TA_Operacion OPT ON OPT.IdDocumento = O.IdPeticionOferta
	--INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
	--INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = OPT.IdEstatusOperacion
	--INNER JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
	--INNER JOIN TA_Prioridad AS TP ON TP.IdPrioridad = OPT.IdPrioridad
	--INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = OPT.IdVigencia 
	--INNER JOIN S_Proveedor  AS P ON P.IdProveedor = PO.IdSubcontratista
	--WHERE O.IdOferta = @IdOferta AND O.IdSubcontratista =@IdProveedorVenta  AND OPT.IdTipoOperacion = 6

         SELECT 1 AS Oferta,
                isNULL(PO.IdEstatus, 1) AS EstatusPO,
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
                (S.RazonSocial+' '+S.RegimenCapital) AS RazonSocial,
                (S.Municipio+' '+S.Entidad) AS Ubicacion,
                (DATEADD(day, V.DiaVencimiento, OPT.FechaRegistro)) AS FechaVencimiento,
                OPT.IdOperacion,
                ISNULL(PO.Cotizado, 'false') AS PeticionCotizada
         FROM MM_PeticionOferta AS PO
              INNER JOIN MM_SolicitudPedido AS SP ON SP.IdSolicitudPedido = PO.IdSolicitudPedido
              INNER JOIN TA_Operacion OPT ON OPT.IdDocumento = PO.IdSolicitudPedido
              INNER JOIN TA_Estatus AS TE ON TE.IdEstatus = OPT.IdEstatusOperacion
              INNER JOIN MM_PrioridadSolicitudPedido AS PSP ON PSP.IdPrioridadSolicitudPedido = SP.IdPrioridadSolicitudPedido
              INNER JOIN TA_Prioridad AS TP ON TP.IdPrioridad = OPT.IdPrioridad
              INNER JOIN TA_Vencimiento AS V ON V.IdVencimiento = OPT.IdVigencia
              INNER JOIN PV_Subcontratista AS S ON S.IdSubcontratista = SP.IdProveedor
         WHERE PO.IdPeticionOferta = @IdPeticionOferta
               AND PO.IdSubcontratista = @IdProveedorVenta
               AND OPT.IdTipoOperacion = 6;
     END;
