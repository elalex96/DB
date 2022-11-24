-- p_OT_MaterialesProgramaSinAsignar 4
CREATE PROC [dbo].[p_OT_MaterialesProgramaSinAsignar] @pIdOTSolicitud INT
AS
SELECT OT_SolicitudMaterial.IdOTSolicitudMaterial,
       SC_Materiales.IdSCMaterial,
       MM_Maestro.IdMaestro,
       SC_Materiales.Descripcion,
       SC_Materiales.DescripcionCorta
FROM OT_Solicitud (NOLOCK)
    INNER JOIN dbo.SC_SubContrato (NOLOCK)
        ON SC_SubContrato.IdSubContrato = OT_Solicitud.IdSubContrato
    INNER JOIN dbo.SC_Materiales (NOLOCK)
        ON SC_Materiales.IdSubContrato = SC_SubContrato.IdSubContrato
    INNER JOIN Petrovendor.dbo.MM_Maestro (NOLOCK)
        ON MM_Maestro.IdMaestro = SC_Materiales.IdMaestro
    INNER JOIN dbo.OT_SolicitudMaterial (NOLOCK)
        ON OT_SolicitudMaterial.IdOTSolicitud = OT_Solicitud.IdOTSolicitud
           AND OT_SolicitudMaterial.IdSCMaterial = SC_Materiales.IdSCMaterial
WHERE OT_Solicitud.IdOTSolicitud = @pIdOTSolicitud
      AND NOT EXISTS
(
    SELECT 1
    FROM dbo.OT_SolicitudPrograma sp
    WHERE sp.IdOTSolicitudMaterial = OT_SolicitudMaterial.IdOTSolicitudMaterial
)
GROUP BY OT_Solicitud.IdOTSolicitud,
         SC_Materiales.IdSCMaterial,
         SC_Materiales.Descripcion,
         SC_Materiales.DescripcionCorta,
         OT_SolicitudMaterial.IdOTSolicitudMaterial,
         MM_Maestro.IdMaestro
