CREATE proc [dbo].[p_CO_SAP_ImportBitacora_GRD] @pIdContrato INT
as
SELECT B.Id,
       B.IdContrato,
       B.Inicio,
       B.Fin,
       B.TieneError,
       B.IdNotificacion,
       B.CreadoEl,
       B.CreadoPor,
       ISNULL(B.NotificacionEnviada, 0) NotificacionEnviada,
       BD.Id,
       BD.IdImportBitacora,
       BD.NombreArchivo,
       BD.Error,
       TieneError2 = ISNULL(BD.TieneError, 0),
       ISNULL(AplicacionEjecuto, '') AplicacionEjecuto
FROM CO_SAP_ImportBitacora B (NOLOCK)
    LEFT JOIN CO_SAP_ImportBitacora_Detalle BD (NOLOCK)
        ON BD.IdImportBitacora = B.Id
WHERE B.IdContrato = @pIdContrato
ORDER BY B.CreadoEl desc